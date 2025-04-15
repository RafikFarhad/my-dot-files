local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local zsh_path = "/bin/zsh"
local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Settings
config.default_prog = {zsh_path, "-l"}

config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({{
    family = "Firacode Nerd Font",
    scale = 1,
    weight = "Medium"
}, {
    family = "Menlo",
    scale = 1
}})

config.window_background_opacity = 1
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 5000

config.window_background_image = '/Users/farhad/Documents/wezterm/wezterm_2.jpg'
config.window_background_image_hsb = {
    brightness = 0.2
}

-- config.default_workspace = "main"
config.default_cursor_style = "BlinkingBar"
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = true
config.hyperlink_rules = { -- Linkify things that look like URLs
-- This is actually the default if you don't specify any hyperlink_rules
{
    regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
    format = "$0"
}, -- match the URL with a PORT
-- such 'http://localhost:3000/index.html'
{
    regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
    format = "$0"
}, -- linkify email addresses
-- {
--     regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
--     format = "mailto:$0"
-- }, -- file:// URI
{
    regex = "\\bfile://\\S*\\b",
    format = "$0"
}}

-- Dim inactive panes
config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.4
}

-- Keys
config.leader = {
    key = "`",
    timeout_milliseconds = 1000
}
config.keys = { -- Send ` when pressing ` twice
{
    key = "`",
    mods = "LEADER",
    action = act.SendKey({
        key = "`"
    })
}, {
    key = "c",
    mods = "LEADER",
    action = act.ActivateCopyMode
}, {
    key = "phys:Space",
    mods = "LEADER",
    action = act.ActivateCommandPalette
}, -- Pane keybindings
{
    key = "_",
    mods = "LEADER",
    action = act.SplitVertical {
        domain = "CurrentPaneDomain"
    }
}, {
    key = "|",
    mods = "LEADER",
    action = act.SplitHorizontal {
        domain = "CurrentPaneDomain"
    }
}, {
    key = "LeftArrow",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Left")
}, {
    key = "DownArrow",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Down")
}, {
    key = "UpArrow",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Up")
}, {
    key = "RightArrow",
    mods = "LEADER",
    action = act.ActivatePaneDirection("Right")
}, {
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane {
        confirm = true
    }
}, -- { key = "z",          mods = "LEADER",      action = act.TogglePaneZoomState },
-- { key = "o",          mods = "LEADER",      action = act.RotatePanes "Clockwise" },
-- We can make separate keybindings for resizing panes
-- But Wezterm offers custom "mode" in the name of "KeyTable"
{ key = "r",          mods = "LEADER",      action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },
-- Tab keybindings
{
    key = "t",
    mods = "LEADER",
    action = act.SpawnTab("CurrentPaneDomain")
}, {
    key = "[",
    mods = "LEADER",
    action = act.ActivateTabRelative(-1)
}, {
    key = "]",
    mods = "LEADER",
    action = act.ActivateTabRelative(1)
}, {
    key = "n",
    mods = "LEADER",
    action = act.ShowTabNavigator
}, {
    mods = "OPT",
    key = "LeftArrow",
    action = act.SendKey({
        mods = "ALT",
        key = "b"
    })
}, {
    mods = "OPT",
    key = "RightArrow",
    action = act.SendKey({
        mods = "ALT",
        key = "f"
    })
}, {
    mods = "CMD",
    key = "LeftArrow",
    action = act.SendKey({
        mods = "CTRL",
        key = "a"
    })
}, {
    mods = "CMD",
    key = "RightArrow",
    action = act.SendKey({
        mods = "CTRL",
        key = "e"
    })
}, {
    mods = "CMD",
    key = "Backspace",
    action = act.SendKey({
        mods = "CTRL",
        key = "u"
    })
}, -- Key table for moving tabs around
-- {
--     key = "m",
--     mods = "LEADER",
--     action = act.ActivateKeyTable {
--         name = "move_tab",
--         one_shot = false
--     }
-- }, -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
{
    key = "{",
    mods = "LEADER|SHIFT",
    action = act.MoveTabRelative(-1)
}, {
    key = "}",
    mods = "LEADER|SHIFT",
    action = act.MoveTabRelative(1)
}, -- Lastly, workspace
{
    key = "w",
    mods = "LEADER",
    action = act.ShowLauncherArgs {
        flags = "FUZZY|WORKSPACES|TABS"
    }
}, {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
            -- line will be `nil` if they hit escape without entering anything
            -- An empty string if they just hit enter
            -- Or the actual line of text they wrote
            if line then
                window:active_tab():set_title(line)
            end
        end)
    }
}, {
    key = 'k',
    mods = 'CMD',
    action = act.SendKey({
        mods = "CTRL",
        key = "l"
    })
}}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = act.ActivateTab(i - 1)
    })
end

config.key_tables = {
    resize_pane = {{
        key = "LeftArrow",
        action = act.AdjustPaneSize {"Left", 1}
    }, {
        key = "DownArrow",
        action = act.AdjustPaneSize {"Down", 1}
    }, {
        key = "UpArrow",
        action = act.AdjustPaneSize {"Up", 1}
    }, {
        key = "RightArrow",
        action = act.AdjustPaneSize {"Right", 1}
    }, {
        key = "Escape",
        action = "PopKeyTable"
    }, {
        key = "Enter",
        action = "PopKeyTable"
    }},
    -- move_tab = {{
    --     key = "h",
    --     action = act.MoveTabRelative(-1)
    -- }, {
    --     key = "j",
    --     action = act.MoveTabRelative(-1)
    -- }, {
    --     key = "k",
    --     action = act.MoveTabRelative(1)
    -- }, {
    --     key = "l",
    --     action = act.MoveTabRelative(1)
    -- }, {
    --     key = "Escape",
    --     action = "PopKeyTable"
    -- }, {
    --     key = "Enter",
    --     action = "PopKeyTable"
    -- }}
}

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

local emojis = {"😀", "😁", "😂", "🤣", "😃", "😄", "😅", "😆", "😉", "😊", "😋", "😎", "😍",
                "😘", "🥰", "😗", "😙", "😚", "🙂", "🤗", "🤩"}

function random_emoji()
    local emoji_count = #emojis -- Get the number of emojis in the table
    local random_index = math.random(1, emoji_count) -- Generate a random index
    return emojis[random_index]
end

local selected_emoji = random_emoji()

wezterm.on("update-status", function(window, pane)
    local stat = window:active_workspace()
    local stat_color = "#f7768e"
    -- It's a little silly to have workspace name all the time
    -- Utilize this to display LDR or current key table name
    if window:active_key_table() then
        stat = window:active_key_table()
        stat_color = "#7dcfff"
    end
    if window:leader_is_active() then
        stat = "`"
        stat_color = "#bb9af7"
    end

    local basename = function(s)
        -- Nothing a little regex can't fix
        return string.gsub(s, "(.*[/\\])(.*)", "%2")
    end

    -- Current working directory
    local cwd = pane:get_current_working_dir()
    if cwd then
        if type(cwd) == "userdata" then
            -- Wezterm introduced the URL object in 20240127-113634-bbcac864
            cwd = basename(cwd.file_path)
        else
            -- 20230712-072601-f4abf8fd or earlier version
            cwd = basename(cwd)
        end
    else
        cwd = ""
    end

    -- Current command
    local cmd = pane:get_foreground_process_name()
    -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
    cmd = cmd and basename(cmd) or ""

    -- Time
    -- local time = wezterm.strftime("%I:%M %p  %A  %B %-d ");

    -- Left status (left of the tab line)
    window:set_left_status(wezterm.format({{
        Foreground = {
            Color = stat_color
        }
    }, {
        Text = "  "
    }, {
        Text = selected_emoji
    } --   {
    --     Text = wezterm.nerdfonts.oct_table
    -- }, {
    --     Text = " " .. utf8.char(0xf09c1)
    -- }
    }))

    -- Right status
    window:set_right_status(wezterm.format({{
        Text = " | " .. wezterm.nerdfonts.oct_table .. "  "
    }, {
        Text = stat .. " | "
    }, {
        Text = wezterm.nerdfonts.md_folder .. "  " .. cwd
    }, {
        Text = " | "
    }, {
        Foreground = {
            Color = "#e0af68"
        }
    }, {
        Text = wezterm.nerdfonts.fa_code .. "  " .. cmd
    }, "ResetAttributes", {
        Text = " | "
    }, -- {
    -- Text = wezterm.nerdfonts.md_clock .. "  " .. time
    -- }, 
    {
        Text = "  "
    }}))
end)

--[[ Appearance setting for when I need to take pretty screenshots
config.enable_tab_bar = false
config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0cell',

}
--]]

wezterm.on('gui-startup', function(cmd)
    local args = {}
    if cmd then
        args = cmd.args
    end

    local main_workspace = 'rf-mbp-main'

    local tabs = {{
        title = 'leadgenie',
        cwd = '/Users/farhad/apollo/leadgenie'
    }, {
        title = 'devops',
        cwd = '/Users/farhad/apollo/devops'
    }, {
        title = 'deployments',
        cwd = '/Users/farhad/apollo/deployments'
    }, {
        title = 'scrap-book',
        cwd = '/Users/farhad/Documents/scrap-book'
    }}

    local tab, build_pane, window = mux.spawn_window {
        workspace = main_workspace,
        cwd = wezterm.home_dir
    }
    tab:set_title('home')

    for i, t in ipairs(tabs) do
        local tab, pane = window:spawn_tab{
            workspace = main_workspace,
            cwd = t.cwd
        }
        tab:set_title(t.title)
    end

    window:gui_window():maximize()
end)

return config

-- local wezterm = require 'wezterm'

-- local config = wezterm.config_builder()

-- config.color_scheme = 'AdventureTime'

-- config.keys = {
-- {
--     key = "LeftArrow",
--     mods = "OPT",
--     action = wezterm.action {
--         SendString = "\x1bb"
--     }
-- },
-- {
--     key = "RightArrow",
--     mods = "OPT",
--     action = wezterm.action {
--         SendString = "\x1bf"
--     }
-- }, {
--     key = 'LeftArrow',
--     mods = 'CMD',
--     action = wezterm.action {
--         SendString = "\x1bOH"
--     }
-- }, {
--     key = 'RightArrow',
--     mods = 'CMD',
--     action = wezterm.action {
--         SendString = "\x1bOF"
--     }
-- }, {
--   key = '|',
--   mods = 'CTRL',
--   action = wezterm.action {
--     SplitHorizontal = {
--       domain = "CurrentPaneDomain"
--     }
--   }
-- }, {
--   key = ']',
--   mods = 'CTRL',
--   action = wezterm.action {
--     SplitVertical = {
--       domain = "CurrentPaneDomain"
--     }
--   }
-- }}

-- return config
