-- lua/json_render_grants.lua
-- Compact single-line CV-style grant renderer

local function format_money(amount)
  if not amount then return nil end
  local s = tostring(amount)
  local rev = s:reverse():gsub("(%d%d%d)", "%1,")
  return "\\$" .. rev:reverse():gsub("^,", "")
end

local function format_years(start_date, end_date)
  if not start_date or not end_date then return nil end
  return string.sub(start_date, 1, 4) .. "--" .. string.sub(end_date, 1, 4)
end

function render_grants(jsonfile)
  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("Could not open " .. jsonfile)
    return
  end

  local content = f:read("*all")
  f:close()

  local grants = utilities.json.tolua(content)
  if not grants then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  -- Maximum compactness
  tex.print("\\begin{itemize}")

  for _, g in ipairs(grants) do
    local sponsor = g.sponsors and table.concat(g.sponsors, ", ") or nil
    local years   = format_years(g.start_date, g.end_date)
    local amount  = format_money(g.amount_usd)

    local parts = {}

    if g.role then table.insert(parts, "\\emph{" .. g.role .. "}") end
    if sponsor then table.insert(parts, sponsor) end
    if g.grant_number and g.grant_number ~= "" then
      table.insert(parts, "Award \\#" .. g.grant_number)
    end
    if amount then table.insert(parts, amount) end
    if years then table.insert(parts, years) end
    -- if g.notes and g.notes ~= "" then table.insert(parts, g.notes) end

    tex.print(
      "\\item \\textbf{" .. g.title .. "}. " ..
      table.concat(parts, ", ") ..
      "."
    )
  end

  tex.print("\\end{itemize}")
end