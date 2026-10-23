-- Internal panel (WUXGA 1920x1200): fixed 1.25 scale gives a 1536x960 logical
-- area. Both dimensions divide evenly by 1.25, so rendering stays sharp.
-- (find a monitor name/description with: hyprctl monitors)
hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = 1.25,
})

-- Generic rule for any other monitor: preferred mode, automatic placement and
-- a scale chosen by Hyprland.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
