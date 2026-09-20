--------------------------------------
-- @name    WeebCentral
-- @url     https://weebcentral.com
-- @author  kalebhenrique
-- @license MIT
--------------------------------------

----- IMPORTS -----
Html = require("html")
Http = require("http")
HttpUtil = require("http_util")
Time = require("time")
--- END IMPORTS ---

----- VARIABLES -----
Client = Http.client()
Base = "https://weebcentral.com"
--- END VARIABLES ---

----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with fields: name, url
function SearchManga(query)
    local url = Base .. "/search/data?text=" .. HttpUtil.query_escape(query) .. "&sort=Best%20Match&order=Ascending&official=Any&anime=Any&adult=Any&display_mode=Full%20Display"
    local req = Http.request("GET", url)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local doc = Html.parse(res.body)
    local mangas = {}
    local seen = {}

    -- Direct manga title links on WeebCentral: <a href="/series/..." class="... link-hover ...">
    doc:find("a[href*='/series/']"):each(function (i, el)
        local href = el:attr("href")
        local class = el:attr("class")
        local title = trim(el:text())
        if href ~= "" and title ~= "" and not seen[href] then
            local isTitleLink = class:find("link%-hover") ~= nil or class:find("link") ~= nil
            local isBadge = title:lower() == "official"
            if isTitleLink and not isBadge then
                seen[href] = true
                table.insert(mangas, {
                    name = title,
                    url = href
                })
            end
        end
    end)

    -- Fallback for any layout differences
    if #mangas == 0 then
        doc:find("a[href*='/series/']"):each(function (i, el)
            local href = el:attr("href")
            local title = trim(el:text())
            if href ~= "" and title ~= "" and not seen[href] and title:lower() ~= "official" then
                seen[href] = true
                table.insert(mangas, {
                    name = title,
                    url = href
                })
            end
        end)
    end

    return mangas
end

--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with fields: name, url
function MangaChapters(mangaURL)
    local seriesId = mangaURL:match("/series/([0-9A-Za-z]+)")
    if not seriesId then
        return {}
    end

    local fullListUrl = Base .. "/series/" .. seriesId .. "/full-chapter-list"
    local req = Http.request("GET", fullListUrl)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local doc = Html.parse(res.body)
    local chapters = {}

    doc:find("a[href*='/chapters/']"):each(function (i, el)
        local href = el:attr("href")
        local nameSpan = el:find("span.grow span"):first()
        local name = trim(nameSpan:text())
        if name == "" then
            name = trim(el:text())
        end

        name = name:gsub("Last%s*Read", "")
        name = name:gsub("%d%d%d%d%-%d%d%-%d%d.-$", "")
        name = trim(name)

        if href ~= "" and name ~= "" then
            table.insert(chapters, {
                name = name,
                url = href
            })
        end
    end)

    Reverse(chapters)
    return chapters
end

--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with fields: url, index
function ChapterPages(chapterURL)
    local chapId = chapterURL:match("/chapters/([0-9A-Za-z]+)")
    if not chapId then
        return {}
    end

    local imagesUrl = Base .. "/chapters/" .. chapId .. "/images?reading_style=long_strip"
    local req = Http.request("GET", imagesUrl)
    local res = Client:do_request(req)
    if res.status ~= 200 then
        return {}
    end

    local doc = Html.parse(res.body)
    local pages = {}
    local idx = 0

    doc:find("img"):each(function (i, el)
        local src = el:attr("src")
        if src ~= "" and (src:find("http") == 1 or src:find("//") == 1) then
            table.insert(pages, {
                index = idx,
                url = src
            })
            idx = idx + 1
        end
    end)

    return pages
end
