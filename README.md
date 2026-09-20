# 🌟 neo-mangal scrapers

Official community repository of Lua manga scrapers for [neo-mangal](https://github.com/kalebhenrique/neo-mangal).

## 🚀 Installation

To automatically install or update all scrapers into `~/.config/neo-mangal/sources/`, run:

```bash
neo-mangal sources install
```

Or open `neo-mangal`—if no sources are detected on first launch, it will prompt you to install them automatically!

## 📚 Included Scrapers

- **[WeebCentral](scrapers/WeebCentral.lua)**: Fast manga streaming & official Shonen releases.
- **[MangaDex](scrapers/MangaDex.lua)**: World's largest community scanlation library via official REST API (multilingual support).

## 🛠 Creating a New Scraper

Each scraper is a simple `.lua` file implementing three core functions:

```lua
-- Searches for manga matching the query
function SearchManga(query)
    -- returns table of { name = "Title", url = "https://..." }
end

-- Lists all chapters for a manga
function MangaChapters(mangaURL)
    -- returns table of { name = "Chapter 1", url = "https://..." }
end

-- Returns image URLs for all pages in a chapter
function ChapterPages(chapterURL)
    -- returns table of { index = 0, url = "https://.../1.jpg" }
end
```

### Available Modules

- `Http` / `http`: HTTP client (`Http.client():do_request(...)`, `http.get(url)`)
- `Html` / `html`: DOM parsing & traversal (`Html.parse(body):find(".selector"):each(...)`)
- `HttpUtil` / `http_util`: URL encoding/decoding (`HttpUtil.query_escape(...)`)
- `Json` / `json`: JSON serialization (`Json.decode(str)`, `Json.encode(tbl)`)
- `Time` / `time`: Delays (`Time.sleep(1)`)
- `Strings` / `strings`: String utilities (`strings.split`, `strings.trim`)

## 📄 License

MIT License.
