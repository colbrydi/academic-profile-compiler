-- lua/json_render_presentations.lua
-- Selected view renderer for presentations & projects

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

local function year_to_number(d)
  if not d or d == "" then return 0 end
  local y = tostring(d):match("%d%d%d%d")
  return tonumber(y) or 0
end

local function newer_first(a, b)
  return year_to_number(b.date) < year_to_number(a.date)
end

function render_selected_presentations(jsonfile)
  tex.print("\\par\\begingroup")

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

  -- filter selected
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

  table.sort(selected, newer_first)

  tex.print("\\begin{itemize}")

  for _, p in ipairs(selected) do
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

    if p.notes and p.notes ~= "" then
      tex.print("\\newline {\\footnotesize " .. latex_escape(p.notes) .. "}")
    end
  end

  tex.print("\\end{itemize}")
  tex.print("\\endgroup")
end

function render_all_presentations(jsonfile)
  tex.print("\\par\\begingroup")

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

  table.sort(items, newer_first)

  tex.print("\\begin{itemize}")

  for _, p in ipairs(items) do
    local marker = "○"
    if p.selected == true then
      marker = "\\textbf{✔}"
    end

    local line = marker .. " " .. latex_escape(p.title)

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

    local meta = {}

    if p.activity_type and p.activity_type ~= "" then
      table.insert(meta, p.activity_type)
    end

    if p.project and p.project ~= "" then
      table.insert(meta, "project: " .. p.project)
    end

    if #meta > 0 then
      tex.print("\\newline {\\footnotesize [" ..
        latex_escape(table.concat(meta, "; ")) .. "]}")
    end
  end

  tex.print("\\end{itemize}")
  tex.print("\\endgroup")
end