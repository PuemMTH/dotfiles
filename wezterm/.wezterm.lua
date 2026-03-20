local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14.0

-- Color scheme (มีกว่า 700 ธีม built-in!)
config.color_scheme = 'Kanagawa'

-- Tab bar + status bar colors (match Kanagawa palette)
config.colors = {
    tab_bar = {
        background = '#1f1f28',
        active_tab = {
            bg_color = '#d27e99', -- sakura pink
            fg_color = '#1f1f28',
        },
        inactive_tab = {
            bg_color = '#2a2a37',
            fg_color = '#727169',
        },
        inactive_tab_hover = {
            bg_color = '#363646',
            fg_color = '#dcd7ba',
        },
        new_tab = {
            bg_color = '#2a2a37',
            fg_color = '#e6c384', -- gold
        },
        new_tab_hover = {
            bg_color = '#d27e99', -- sakura pink on hover
            fg_color = '#1f1f28',
        },
    },
}

-- Window
config.window_background_opacity = 0.70
config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}

-- windows default

-- Tab bar
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Status bar: Host + CPU + Memory (updates every second)
--
-- ══ Remote shell integration ══════════════════════════════════════════════════
-- เพิ่มใน ~/.zshrc หรือ ~/.bashrc ของทุก remote machine:
--
-- function _wezterm_stats() {
--   local cpu mem
--   if [[ "$(uname)" == "Darwin" ]]; then
--     cpu=$(top -l 1 -n 0 -s 0 2>/dev/null | awk '/CPU usage/{gsub(/%/,"",$3);printf "%.2f%%",$3}')
--     local total=$(sysctl -n hw.memsize 2>/dev/null)
--     mem=$(vm_stat 2>/dev/null | awk \
--       '/Pages active/{a=$3}/Pages wired down/{w=$4}/Pages occupied by compressor/{c=$5}
--        END{printf "%.1fGB/'$(( ${total:-0}/1073741824 ))'GB",(a+w+c)*4096/1073741824}')
--   else
--     cpu=$(awk '/^cpu /{u=$2+$4;t=$2+$3+$4+$5;printf "%.2f%%",u/t*100;exit}' /proc/stat 2>/dev/null)
--     mem=$(awk '/^MemTotal/{t=$2}/^MemAvailable/{a=$2}END{printf "%.1fGB/%.0fGB",(t-a)/1048576,t/1048576}' /proc/meminfo 2>/dev/null)
--   fi
--   [[ -n "$cpu" ]] && printf '\033]1337;SetUserVar=stat_cpu=%s\007' "$(printf '%s' "$cpu" | base64 | tr -d '\n')"
--   [[ -n "$mem" ]] && printf '\033]1337;SetUserVar=stat_mem=%s\007' "$(printf '%s' "$mem" | base64 | tr -d '\n')"
--   # OSC 7: แจ้ง WezTerm ว่า remote CWD คืออะไร (ต้องมีเพื่อให้ CMD+Click หาไฟล์ถูก)
--   printf '\033]7;file://%s%s\007' "$(hostname)" "$PWD"
-- }
-- # zsh:  precmd_functions+=(_wezterm_stats)
-- # bash: PROMPT_COMMAND="${PROMPT_COMMAND%%;};_wezterm_stats"
--
-- ══════════════════════════════════════════════════════════════════════════════


wezterm.on('update-right-status', function(window, pane)
    -- Hostname: local machine or from pane title (remote shell sets user@hostname)
    local host = wezterm.hostname()
    local title_host = pane:get_title():match('@([%w][%w%.%-]*)')
    if title_host then host = title_host end

    -- Use stats sent by shell integration (works local + remote)
    local uv = pane:get_user_vars()
    local cpu = uv.stat_cpu
    local mem = uv.stat_mem

    -- Fallback to local commands if no shell integration data yet
    if not cpu then
        local ok, stdout = wezterm.run_child_process({
            'sh', '-c',
            "top -l 1 -n 0 -s 0 | awk '/CPU usage/ {gsub(/%/,\"\",$3); printf \"%.2f%%\",$3}'"
        })
        cpu = (ok and stdout ~= '') and stdout or 'NaN'
    end

    if not mem then
        local ok2, stdout2 = wezterm.run_child_process({
            'sh', '-c',
            "total=$(sysctl -n hw.memsize); used=$(vm_stat | awk '/Pages active/{a=$3}/Pages wired down/{w=$4}/Pages occupied by compressor/{c=$5}END{printf \"%.1f\",(a+w+c)*4096/1073741824}'); printf \"%sGB/$(( total/1073741824 ))GB\" \"$used\""
        })
        mem = (ok2 and stdout2 ~= '') and stdout2:gsub('%s+$', '') or 'NaN'
    end

    -- GPU: only available locally via ioreg (Apple Silicon)
    local gpu_part = ''
    if not uv.stat_cpu then -- only show GPU when using local stats
        local ok3, stdout3 = wezterm.run_child_process({
            'sh', '-c',
            "ioreg -r -d 2 -w 0 -c AGXAccelerator 2>/dev/null | awk '/PerformanceStatistics/{match($0,/Device Utilization %[^,}]*/,a);split(a[0],b,\"=\");gsub(/[^0-9]/,\"\",b[2]);if(b[2]!=\"\")print b[2]\"%\"}'"
        })
        local gpu = (ok3 and stdout3 ~= '') and stdout3:gsub('%s+$', '') or nil
        if gpu then gpu_part = '   GPU ' .. gpu end
    end

    window:set_right_status(wezterm.format({
        { Background = { Color = '#d27e99' } }, -- sakura pink (Kanagawa)
        { Foreground = { Color = '#ffffff' } },
        { Attribute = { Intensity = 'Bold' } },
        { Text = '  ' .. host .. '   CPU ' .. cpu .. gpu_part .. '   MEM ' .. mem .. '  ' },
    }))
end)

-- Scrollback history
config.scrollback_lines = 10000


-- Hyperlink rule: underline image & markdown filenames without spaces → CMD+Click opens
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
    regex = [[[^\s"']+\.(?:png|jpg|jpeg|gif|bmp|webp|svg|ico|tiff?|heic|avif|md)]],
    format = 'file://$0',
    highlight = 0,
})

-- Handle file:// URIs — open local files directly
wezterm.on('open-uri', function(window, pane, uri)
    if uri:match('^file://') then
        local path = uri:gsub('^file://[^/]*', ''):gsub('%%20', ' ')
        wezterm.open_with(path)
        return false
    end
end)

return config
