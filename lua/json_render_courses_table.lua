-- lua/json_render_courses_table.lua
-- Table-based CV renderer for courses.json
-- Left column: course code
-- Right column: title + details
-- Uses longtable for page breaks

-- Escape LaTeX special characters in raw user content
local function latex_escape(str)
  if not str then return "" end
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

-- Join list of terms into readable string
local function format_terms(terms)
  if not terms or #terms == 0 then return nil end
  return table.concat(terms, ", ")
end

function render_courses_table(jsonfile)
  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("Could not open " .. jsonfile)
    return
  end

  local content = f:read("*all")
  f:close()

  local courses = utilities.json.tolua(content)
  if not courses then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  -- Longtable layout:
  -- Narrow column for course code, wide column for details
  tex.print("\\begin{longtable}{@{}p{0.13\\textwidth} p{0.82\\textwidth}@{}}")

  for _, c in ipairs(courses) do
    local left = latex_escape(c.course_code)

    local details = {}

    -- Title (bold, first line)
    table.insert(details, "\\textbf{" .. latex_escape(c.title) .. "}")

    -- Institution and role
    local meta = {}
    if c.institution then table.insert(meta, latex_escape(c.institution)) end
    if c.role then table.insert(meta, "\\emph{" .. latex_escape(c.role) .. "}") end
    if #meta > 0 then
      table.insert(details, table.concat(meta, ". "))
    end

    -- Terms taught
    local terms = format_terms(c.terms)
    if terms then
      table.insert(details, "Taught: " .. latex_escape(terms))
    end

    -- Optional notes
    if c.notes and c.notes ~= "" then
      table.insert(details, latex_escape(c.notes))
    end

    tex.print(
      left .. " & " ..
      table.concat(details, "\\newline {\\footnotesize ") ..
      ( #details > 1 and string.rep("}", #details - 1) or "" ) ..
      " \\\\"
    )
  end

  tex.print("\\end{longtable}")
end