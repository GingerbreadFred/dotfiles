local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 14

config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.enable_tab_bar = false

if wezterm.target_triple:find("windows") then
	config.default_prog = {
		"pwsh.exe",
		"-NoLogo",
	}
end

config.term = "xterm-256color"

return config
