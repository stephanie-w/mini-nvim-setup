local MiniBase16 = require("mini.base16")

local palette_solarized = {
	base00 = "#002b36", -- Default Background
	base01 = "#073642", -- Lighter Background
	base02 = "#586e75", -- Selection Background
	base03 = "#657b83", -- Comments
	base04 = "#839496", -- Dark Foreground
	base05 = "#93a1a1", -- Default Foreground
	base06 = "#eee8d5", -- Light Foreground
	base07 = "#fdf6e3", -- Light Background
	base08 = "#dc322f", -- Variables/Strings
	base09 = "#cb4b16", -- Integers/Constants
	base0A = "#b58900", -- Classes/Markup
	base0B = "#859900", -- Functions/Tags
	base0C = "#2aa198", -- Support/Regex
	base0D = "#268bd2", -- Functions/Methods
	base0E = "#6c71c4", -- Keywords
	base0F = "#d33682", -- Deprecated
}

MiniBase16.setup({
	palette = palette_solarized,
})
