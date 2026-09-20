--------------------------------------
-- @name    MangaDex
-- @url     https://mangadex.org
-- @author  kalebhenrique
-- @license MIT
--------------------------------------

----- IMPORTS -----
Http = require("http")
HttpUtil = require("http_util")
Json = require("json")
--- END IMPORTS ---

----- VARIABLES -----
Client = Http.client()
Base = "https://api.mangadex.org"
--- END VARIABLES ---

----- MAIN -----

--- Searches for manga using official MangaDex API.
-- @param query Query to search for
-- @return Table of tables with fields: name, url
function SearchManga(query)
    local url = Base .. "/manga?title=" .. HttpUtil.query_escape(query) .. "&limit=25&order[relevance]=desc"
    local req = Http.request("GET", url)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local data = Json.decode(res.body)
    if not data or not data.data then
        return {}
    end

    local mangas = {}
    for _, item in ipairs(data.data) do
        local id = item.id
        local title = ""
        if item.attributes and item.attributes.title then
            title = item.attributes.title.en or item.attributes.title["ja-ro"] or item.attributes.title["pt-br"] or ""
            if title == "" then
                for _, v in pairs(item.attributes.title) do
                    title = v
                    break
                end
            end
        end

        if id and title ~= "" then
            table.insert(mangas, {
                name = title,
                url = id
            })
        end
    end

    return mangas
end

--- Gets the list of all manga chapters.
-- @param mangaURL ID of the manga on MangaDex
-- @return Table of tables with fields: name, url
function MangaChapters(mangaURL)
    local mangaId = mangaURL:match("([0-9a-fA-F%-]+)") or mangaURL
    local url = Base .. "/manga/" .. mangaId .. "/feed?limit=250&order[chapter]=asc&translatedLanguage[]=en"
    local req = Http.request("GET", url)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local data = Json.decode(res.body)
    if not data or not data.data then
        return {}
    end

    local chapters = {}
    for _, item in ipairs(data.data) do
        local id = item.id
        local num = (item.attributes and item.attributes.chapter) or ""
        local title = (item.attributes and item.attributes.title) or ""
        
        local displayName = ""
        if num ~= "" then
            displayName = "Chapter " .. num
            if title ~= "" then
                displayName = displayName .. ": " .. title
            end
        elseif title ~= "" then
            displayName = title
        else
            displayName = "Chapter " .. id
        end

        table.insert(chapters, {
            name = displayName,
            url = id
        })
    end

    return chapters
end

--- Gets the list of all pages of a chapter using MangaDex @Home server.
-- @param chapterURL ID of the chapter on MangaDex
-- @return Table of tables with fields: url, index
function ChapterPages(chapterURL)
    local chapId = chapterURL:match("([0-9a-fA-F%-]+)") or chapterURL
    local url = Base .. "/at-home/server/" .. chapId
    local req = Http.request("GET", url)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local data = Json.decode(res.body)
    if not data or not data.chapter or not data.chapter.data then
        return {}
    end

    local baseUrl = data.baseUrl
    local hash = data.chapter.hash
    local files = data.chapter.data
    local pages = {}

    for i, file in ipairs(files) do
        local pageUrl = baseUrl .. "/data/" .. hash .. "/" .. file
        table.insert(pages, {
            index = i - 1,
            url = pageUrl
        })
    end

    return pages
end
