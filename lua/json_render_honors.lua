-- lua/json_render_honors.lua


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


local function year_to_number(y)
  if not y or y == "" then return 0 end
  if type(y) == "number" then return y end
  local n = tostring(y):match("%d%d%d%d")
  return tonumber(n) or 0
end

local function newer_first(a, b)
  return year_to_number(b.year) < year_to_number(a.year)
end

function render_honors(jsonfile)
  tex.print("\\par")
  tex.print("\\begingroup")

  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("\\textit{Could not open honors file.}")
    tex.print("\\endgroup")
    return
  end

  local content = f:read("*all")
  f:close()

  local items = utilities.json.tolua(content)
  if not items or #items == 0 then
    tex.print("\\textit{No honors data found.}")
    tex.print("\\endgroup")
    return
  end

  table.sort(items, newer_first)

  tex.print("\\begin{itemize}")

  for _, h in ipairs(items) do
    local line = "\\textbf{" .. latex_escape(h.title) .. "}"

    if h.organization and h.organization ~= "" then
      line = line .. ", " .. latex_escape(h.organization)
    end

    if h.year and h.year ~= "" then
      line = line .. " (" .. latex_escape(h.year) .. ")"
    end

    tex.print("\\item " .. line)

    if h.notes and h.notes ~= "" then
      tex.print("\\newline {\\footnotesize " .. latex_escape(h.notes) .. "}")
    end
  end

  tex.print("\\end{itemize}")
  tex.print("\\endgroup")
end