-- lua/json_render_courses.lua
-- Compact CV-style renderer for courses.json

-- Join term list into a readable string
local function format_terms(terms)
  if not terms or #terms == 0 then return nil end
  return table.concat(terms, ", ")
end

function render_courses(jsonfile)
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

  tex.print("\\begin{itemize}")

  for _, c in ipairs(courses) do
    local title = c.course_code .. " — " .. c.title
    local terms = format_terms(c.terms)

    local parts = {}

    if c.role then
      table.insert(parts, "\\emph{" .. c.role .. "}")
    end

    if c.institution then
      table.insert(parts, c.institution)
    end

    if terms then
      table.insert(parts, "Taught: " .. terms)
    end

    if c.notes and c.notes ~= "" then
      table.insert(parts, c.notes)
    end

    tex.print(
      "\\item \\textbf{" .. title .. "}. " ..
      table.concat(parts, ". ") ..
      "."
    )
  end

  tex.print("\\end{itemize}")
end