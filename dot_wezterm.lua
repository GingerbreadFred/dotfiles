local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 14

config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

if wezterm.target_triple:find("windows") then
	config.default_prog = {
		"pwsh.exe",
		"-NoLogo",
	}
end

config.term = "xterm-256color"

config.keys = {
	{ key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

tabline.setup({
	options = {
		theme = "Tokyo Night",
	},
})

tabline.apply_to_config(config)

config.tab_bar_at_bottom = true

return config
