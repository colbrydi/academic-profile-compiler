-- lua/json_render_presentations.lua
-- Renderer for selected presentations and projects
-- Clean grouping + stable formatting

--------------------------------------------------
-- Helper: Safe LaTeX escape
--------------------------------------------------

local function latex_escape(x)
  local str = tostring(x or "")
  str = str:gsub("\\", "\\textbackslash{}")
  str = str:gsub("%%", "\\%%")
  str = str:gsub("%$", "\\$")
  str = str:gsub("&", "\\&")
  str = str:gsub("_", "\\_")
  str = str:gsub("#", "\\#")
  str = str:gsub("{", "\\{")
  str = str:gsub("}", "\\}")
  str = str:gsub("%^", "\\^{}")
  str = str:gsub("~", "\\textasciitilde{}")
  return str
end

--------------------------------------------------
-- Helper: Extract year for sorting
--------------------------------------------------

local function year_to_number(d)
  if not d or d == "" then return 0 end
  local y = tostring(d):match("%d%d%d%d")
  return tonumber(y) or 0
end

--------------------------------------------------
-- Comparator: newest first
--------------------------------------------------

local function newer_first(a, b)
  return year_to_number(b.date) < year_to_number(a.date)
end

--------------------------------------------------
-- Optional: prettier group names
--------------------------------------------------

local function format_group_name(name)
  local map = {
    ["Invited Talk"] = "Invited Talks",
    ["Workshop Facilitation"] = "Workshops and Facilitation",
    ["Hosted Event"] = "Projects and Hosted Events",
    ["Conference Presentation"] = "Conference Presentations",
    ["Poster Presentation"] = "Posters",
    ["Workshop Organization and Presentation"] = "Workshops and Facilitation"
  }

  return map[name] or name or "Other"
end

--------------------------------------------------
-- MAIN RENDER FUNCTION
--------------------------------------------------

function render_selected_presentations(jsonfile)
  tex.print("\\par\\begingroup")

  --------------------------------------------------
  -- Load JSON file
  --------------------------------------------------

  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("\\textit{Could not open presentations file.}")
    tex.print("\\endgroup")
    return
  end

  local content = f:read("*all")
  f:close()

  local items = utilities.json.tolua(content)
  if not items or #items == 0 then
    tex.print("\\textit{No presentation data found.}")
    tex.print("\\endgroup")
    return
  end

  --------------------------------------------------
  -- Filter selected items
  --------------------------------------------------

  local selected = {}
  for _, item in ipairs(items) do
    if item.selected == true then
      table.insert(selected, item)
    end
  end

  if #selected == 0 then
    tex.print("\\textit{No selected presentations.}")
    tex.print("\\endgroup")
    return
  end

  --------------------------------------------------
  -- Group by activity_type
  --------------------------------------------------

  local groups = {}

  for _, p in ipairs(selected) do
    local key = p.activity_type or "Other"

    if not groups[key] then
      groups[key] = {}
    end

    table.insert(groups[key], p)
  end

  --------------------------------------------------
  -- Sort group keys for stable output
  --------------------------------------------------

  local group_keys = {}
  for k, _ in pairs(groups) do
    table.insert(group_keys, k)
  end
  table.sort(group_keys)

  --------------------------------------------------
  -- Render groups
  --------------------------------------------------

  for _, group_name in ipairs(group_keys) do
    local entries = groups[group_name]

    table.sort(entries, newer_first)

    tex.print("\\medskip")
    tex.print("\\textbf{" .. latex_escape(format_group_name(group_name)) .. "}")

    tex.print("\\begin{itemize}")

    for _, p in ipairs(entries) do

      --------------------------------------------------
      -- Main line
      --------------------------------------------------

      local line = "\\textbf{" .. latex_escape(p.title) .. "}"

      if p.venue and p.venue ~= "" then
        line = line .. ", " .. latex_escape(p.venue)
      end

      if p.location and p.location ~= "" then
        line = line .. ", " .. latex_escape(p.location)
      end

      if p.date and p.date ~= "" then
        line = line .. " (" .. latex_escape(p.date) .. ")"
      end

      tex.print("\\item " .. line)

      --------------------------------------------------
      -- Secondary description (same bullet)
      --------------------------------------------------

      local extras = {}

      if p.project and p.project ~= "" then
        table.insert(extras, p.project)
      end

      if p.notes and p.notes ~= "" then
        table.insert(extras, p.notes)
      end

      -- if #extras > 0 then
      --   tex.print("\\\\ {\\footnotesize " ..
      --     latex_escape(table.concat(extras, ". ")) .. "}")
      -- end

    end

    tex.print("\\end{itemize}")
  end

  tex.print("\\endgroup")
end


--------------------------------------------------
-- GROUPED RENDER (one entry per talk/project)
--------------------------------------------------

function render_selected_presentations_grouped(jsonfile)

  tex.print("\\par\\begingroup")

  --------------------------------------------------
  -- Load JSON
  --------------------------------------------------

  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("\\textit{Could not open presentations file.}")
    tex.print("\\endgroup")
    return
  end

  local content = f:read("*all")
  f:close()

  local items = utilities.json.tolua(content)
  if not items or #items == 0 then
    tex.print("\\textit{No presentation data found.}")
    tex.print("\\endgroup")
    return
  end

  --------------------------------------------------
  -- Filter selected
  --------------------------------------------------

  local selected = {}
  for _, item in ipairs(items) do
    if item.selected == true then
      table.insert(selected, item)
    end
  end

  if #selected == 0 then
    tex.print("\\textit{No selected presentations.}")
    tex.print("\\endgroup")
    return
  end

  --------------------------------------------------
  -- Group by TITLE (key idea)
  --------------------------------------------------

  local grouped = {}

  for _, p in ipairs(selected) do
    local key = p.title or "Untitled"

    if not grouped[key] then
      grouped[key] = {}
    end

    table.insert(grouped[key], p)
  end

  --------------------------------------------------
  -- Build summary list (most recent per group)
  --------------------------------------------------

  local summary = {}

  local function year_to_number(d)
    if not d or d == "" then return 0 end
    local y = tostring(d):match("%d%d%d%d")
    return tonumber(y) or 0
  end

  for title, entries in pairs(grouped) do
    table.sort(entries, function(a, b)
      return year_to_number(b.date) < year_to_number(a.date)
    end)

    local most_recent = entries[1]

    table.insert(summary, {
      title = title,
      venue = most_recent.venue,
      location = most_recent.location,
      date = most_recent.date,
      count = #entries,
      project = most_recent.project
    })
  end

  --------------------------------------------------
  -- Sort summaries (newest first)
  --------------------------------------------------

  table.sort(summary, function(a, b)
    return year_to_number(b.date) < year_to_number(a.date)
  end)

  --------------------------------------------------
  -- Render simple list
  --------------------------------------------------

  tex.print("\\begin{itemize}")

  for _, s in ipairs(summary) do

    local line = "\\textbf{" .. latex_escape(s.title) .. "}"

    if s.venue and s.venue ~= "" then
      line = line .. ", " .. latex_escape(s.venue)
    end

    if s.location and s.location ~= "" then
      line = line .. ", " .. latex_escape(s.location)
    end

    if s.date and s.date ~= "" then
      line = line .. " (" .. latex_escape(s.date) .. ")"
    end

    -- OPTIONAL: show repeat count
    if s.count > 1 then
      line = line .. " {\\footnotesize (" .. s.count .. " occurrences)}"
    end

    tex.print("\\item " .. line)
  end

  tex.print("\\end{itemize}")
  tex.print("\\endgroup")
end
