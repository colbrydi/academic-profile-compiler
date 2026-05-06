-- lua/json_render_roles.lua
-- Compact CV-style renderer for roles.json

local function format_years(start_year, end_year)
  if not start_year then return nil end
  if end_year == "present" then
    return tostring(start_year) .. "\\textendash{}present"
  elseif end_year then
    return tostring(start_year) .. "\\textendash{}" .. tostring(end_year)
  else
    return tostring(start_year)
  end
end

function render_roles(jsonfile)
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

  tex.print("\\begin{itemize}")

  for _, r in ipairs(roles) do
    local years = format_years(r.start_year, r.end_year)

    local parts = {}

    -- Institution and unit
    if r.unit and r.institution then
      table.insert(parts, r.unit .. ", " .. r.institution)
    elseif r.institution then
      table.insert(parts, r.institution)
    end

    -- Years
    if years then
      table.insert(parts, years)
    end

    -- Optional notes
    if r.notes and r.notes ~= "" then
      table.insert(parts, r.notes)
    end

    tex.print(
      "\\item \\textbf{" .. r.title .. "}. " ..
      table.concat(parts, ". ") ..
      "."
    )
  end

  tex.print("\\end{itemize}")
end