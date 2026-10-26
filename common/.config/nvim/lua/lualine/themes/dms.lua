local ok, base46_lualine = pcall(require, "lualine.themes._base46")
if ok and type(base46_lualine) == "function" then
  local ok_theme, theme = pcall(base46_lualine, "dms")
  if ok_theme and theme then
    return theme
  end
end

-- Fallback to default/auto if dms theme isn't generated yet
local ok_auto, auto = pcall(require, "lualine.themes.auto")
if ok_auto and auto then
  return auto
end

return "auto"
