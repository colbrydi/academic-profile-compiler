-- lua/json_render_committees.lua
-- Compact publication-style rendering

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

local function newer_first(a, b)
  return (tonumber(b.year) or 0) < (tonumber(a.year) or 0)
end

function render_graduate_committees(jsonfile)
  tex.print("\\par\\begingroup")

  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("\\textit{Could not open graduate committees file.}")
    tex.print("\\endgroup")
    return
  end

  local content = f:read("*all")
  f:close()

  local items = utilities.json.tolua(content)
  if not items or #items == 0 then
    tex.print("\\textit{No graduate committee data found.}")
    tex.print("\\endgroup")
    return
  end

  table.sort(items, newer_first)

  tex.print("\\begin{enumerate}")

  for _, c in ipairs(items) do

    local parts = {}

    -- Student
    table.insert(parts, latex_escape(c.student))

    -- Title (publication-like)

    if c.title and c.title ~= "" then
      table.insert(parts,
        "\\textbf{\\emph{``" .. latex_escape(c.title) .. "''}}")
    end


    -- Department or institution
    if c.department and c.department ~= "" then
      table.insert(parts, latex_escape(c.department))
    end

    -- Date
    local when = {}
    if c.term and c.term ~= "" then
      table.insert(when, latex_escape(c.term))
    end
    if c.year and c.year ~= "" then
      table.insert(when, latex_escape(c.year))
    end

    if #when > 0 then
      table.insert(parts, table.concat(when, " "))
    end

    tex.print("\\item " .. table.concat(parts, ", ") .. ".")
  end

  tex.print("\\end{enumerate}")
  tex.print("\\endgroup")
end