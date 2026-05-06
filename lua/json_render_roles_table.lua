-- lua/json_render_roles_table.lua
-- Table-based CV renderer for roles.json
-- FIXED: Do not LaTeX-escape formatted year strings

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

-- Convert year to sortable number
local function year_to_number(y)
  if y == "present" then return 9999 end
  return tonumber(y) or 0
end

-- Format year range (produces LaTeX on purpose)
local function format_years(start_year, end_year)
  if not start_year then return "" end
  if end_year == "present" then
    return tostring(start_year) .. "\\textendash{}present"
  elseif end_year then
    return tostring(start_year) .. "\\textendash{}" .. tostring(end_year)
  else
    return tostring(start_year)
  end
end

function render_roles_table(jsonfile)
  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("Could not open " .. jsonfile)
    return
  end

  local content = f:read("*all")
  f:close()

  local roles = utilities.json.tolua(content)
  if not roles then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  -- Sort most recent first
  table.sort(roles, function(a, b)
    local a_end = year_to_number(a.end_year)
    local b_end = year_to_number(b.end_year)
    if a_end ~= b_end then
      return a_end > b_end
    end
    return year_to_number(a.start_year) > year_to_number(b.start_year)
  end)

  tex.print("\\begin{longtable}{@{}p{0.13\\textwidth} p{0.80\\textwidth}@{}}")

  for _, r in ipairs(roles) do
    local years = format_years(r.start_year, r.end_year)

    local details = {}

    if r.unit and r.institution then
      table.insert(details,
        latex_escape(r.unit) .. ", " .. latex_escape(r.institution)
      )
    elseif r.institution then
      table.insert(details, latex_escape(r.institution))
    end

    if r.notes and r.notes ~= "" then
      table.insert(details, latex_escape(r.notes))
    end

    tex.print(
      years .. " & " ..
      "\\textbf{" .. latex_escape(r.title) .. "}" ..
      (#details > 0 and
        "\\newline {\\footnotesize " .. table.concat(details, ". ") .. "}" or ""
      ) ..
      " \\\\"
    )
  end

  tex.print("\\end{longtable}")
end