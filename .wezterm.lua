-- Wezterm Configuration.
--
-- FOR WINDOWS make sure to set your WEZTERM_CONFIG_FILE environment variable to point to the WSL dotfiles instance.

-- Pull in the wezterm API
local wezterm = require("wezterm")

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "GitHub Dark"

config.keys = {
	{
		key = "v",
		mods = "SHIFT|CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

-- config.ssh_domains = {
-- 	{
-- 		name = "zenitram",
-- 		remote_address = "127.0.0.1",
-- 		username = "zenitram",
-- 		connect_automatically = false,
-- 	},
-- }
--

-- config.default_domain = "SSH:local"
--
config.default_domain = "WSL:Zenitram-Dev"

config.window_close_confirmation = "NeverPrompt"
config.enable_tab_bar = false

config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"Consolas",
})

-- and finally, return the configuration to wezterm
return config
