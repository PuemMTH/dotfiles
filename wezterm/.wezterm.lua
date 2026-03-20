local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14.0

-- Color scheme (มีกว่า 700 ธีม built-in!)
config.color_scheme = 'Tokyo Night'

-- Window
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 10, right = 10,
  top = 10, bottom = 10,
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback history
config.scrollback_lines = 10000

-- Helper: resolve path (relative → absolute using pane CWD) and open
local function open_image_path(window, pane, path)
  path = path:gsub('^%s+', ''):gsub('%s+$', '')
  if not path:match('^/') then
    local cwd_obj = pane:get_current_working_dir()
    if cwd_obj then
      local cwd = type(cwd_obj) == 'string'
        and cwd_obj:gsub('^file://', '')
        or cwd_obj.file_path
      path = cwd .. '/' .. path
    end
  end
  wezterm.open_with(path)
end

-- Hyperlink rule: underline image filenames without spaces → Cmd+Click opens
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[[^\s"']+\.(?:png|jpg|jpeg|gif|bmp|webp|svg|ico|tiff?|heic|avif)]],
  format = 'file://$0',
  highlight = 0,
})

-- Handle file:// URIs (resolves relative paths via pane CWD)
wezterm.on('open-uri', function(window, pane, uri)
  if uri:match('^file://') then
    local path = uri:gsub('^file://', ''):gsub('%%20', ' ')
    open_image_path(window, pane, path)
    return false
  end
end)

-- Cmd+Click: if text is selected and looks like an image path → open it
-- (use this for filenames with spaces: select filename first, then Cmd+Click)
local image_exts = { png=1, jpg=1, jpeg=1, gif=1, bmp=1, webp=1, svg=1, ico=1, tif=1, tiff=1, heic=1, avif=1 }

local function is_image(path)
  local ext = path:match('%.(%a+)$')
  return ext and image_exts[ext:lower()] ~= nil
end

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and is_image(sel) then
        open_image_path(window, pane, sel)
      else
        window:perform_action(wezterm.action.OpenLinkAtMouseCursor, pane)
      end
    end),
  },
}

return config
