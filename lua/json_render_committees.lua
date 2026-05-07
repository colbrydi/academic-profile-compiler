-- lua/json_render_committees.lua
-- Renderer for graduate thesis and dissertation committees

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

  tex.print("\\begin{itemize}")

  for _, c in ipairs(items) do
    local line = "\\textbf{" .. latex_escape(c.student) .. "}"

    if c.program and c.program ~= "" then
      line = line .. " (" .. latex_escape(c.program) .. ")"
    end

    if c.department and c.department ~= "" then
      line = line .. ", " .. latex_escape(c.department)
    end

    if c.term or c.year then
      local when = {}
      if c.term and c.term ~= "" then
        table.insert(when, latex_escape(c.term))
      end
      if c.year and c.year ~= "" then
        table.insert(when, latex_escape(c.year))
      end
      if #when > 0 then
        line = line .. " — " .. table.concat(when, " ")
      end
    end

    tex.print("\\item " .. line)

    if c.title and c.title ~= "" then
      tex.print("\\newline \\emph{" .. latex_escape(c.title) .. "}")
    end
  end

  tex.print("\\end{itemize}")
  tex.print("\\endgroup")
end
