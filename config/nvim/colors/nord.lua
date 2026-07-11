local MiniBase16 = require("mini.base16")

local palette_nord = {
	base00 = "#2e3440", -- Polar Night (Default Background)
	base01 = "#3b4252", -- Polar Night (Lighter Background)
	base02 = "#434c5e", -- Selection Background
	base03 = "#4c566a", -- Comments
	base04 = "#d8dee9", -- Dark Foreground
	base05 = "#e5e9f0", -- Default Foreground
	base06 = "#eceff4", -- Light Foreground
	base07 = "#8fbcbb", -- Frost (Light Background)
	base08 = "#bf616a", -- Aurora Red
	base09 = "#d08770", -- Aurora Orange
	base0A = "#ebcb8b", -- Aurora Yellow
	base0B = "#a3be8c", -- Aurora Green
	base0C = "#88c0d0", -- Frost (Support/Regex)
	base0D = "#81a1c1", -- Frost (Functions/Methods)
	base0E = "#b48ead", -- Aurora Purple
	base0F = "#5e81ac", -- Frost (Deprecated)
}

MiniBase16.setup({
	palette = palette_nord,
})
