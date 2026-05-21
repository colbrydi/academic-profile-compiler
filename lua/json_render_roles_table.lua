-- lua/json_render_roles_table.lua
-- Table-based CV renderer for roles and service
-- Adds filtering support for service_scope

--------------------------------------------------
-- Escape LaTeX special characters
--------------------------------------------------

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

--------------------------------------------------
-- Convert year to sortable number
--------------------------------------------------

local function year_to_number(y)
  if y == "present" then return 9999 end
  return tonumber(y) or 0
end

--------------------------------------------------
-- Format year range (LaTeX-aware)
--------------------------------------------------

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

--------------------------------------------------
-- Load JSON
--------------------------------------------------

local function load_json(jsonfile)
  local f = io.open(jsonfile, "r")
  if not f then return nil end

  local content = f:read("*all")
  f:close()

  return utilities.json.tolua(content)
end

--------------------------------------------------
-- Core rendering logic (used by both modes)
--------------------------------------------------

local function render_roles_internal(roles)

  -- Sort newest first
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

--------------------------------------------------
-- ORIGINAL (unchanged behavior)
--------------------------------------------------

function render_roles_table(jsonfile)
  local roles = load_json(jsonfile)

  if not roles then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  render_roles_internal(roles)
end

--------------------------------------------------
-- NEW: FILTERED VERSION (for service)
--------------------------------------------------

function render_roles_table_filtered(jsonfile, scope_filter)

  local roles = load_json(jsonfile)

  if not roles then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  local filtered = {}
  local scope = string.lower(scope_filter)

  for _, r in ipairs(roles) do
    if r.service_scope then
      local s = string.lower(tostring(r.service_scope))
      if s == scope then
        table.insert(filtered, r)
      end
    end
  end

  if #filtered == 0 then
    tex.print("\\textit{No entries in this category.}")
    return
  end

  render_roles_internal(filtered)
end