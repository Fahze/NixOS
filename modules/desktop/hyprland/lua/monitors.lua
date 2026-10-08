-- Generic rule: internal panel and any external monitor use their preferred
-- mode, are placed automatically, and get a scale chosen by Hyprland.
-- (find a monitor description with: hyprctl monitors)
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
