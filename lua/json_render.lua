-- lua/json_render.lua

local function has_keyword(entry, keyword)
  if not entry.keywords then
    return false
  end
  for _, k in ipairs(entry.keywords) do
    if k == keyword then
      return true
    end
  end
  return false
end

function render_json(jsonfile, keyword)
  local f = io.open(jsonfile, "r")
  if not f then
    tex.print("Could not open " .. jsonfile)
    return
  end

  local content = f:read("*all")
  f:close()

  local data = utilities.json.tolua(content)
  if not data then
    tex.print("JSON parse failed for " .. jsonfile)
    return
  end

  tex.print("\\begin{itemize}")

  for _, item in ipairs(data) do
    if not keyword or has_keyword(item, keyword) then
      tex.print("\\item \\textbf{" .. item.title .. "} (" .. item.years .. ")\\\\")
      tex.print(item.description)
    end
  end

  tex.print("\\end{itemize}")
end