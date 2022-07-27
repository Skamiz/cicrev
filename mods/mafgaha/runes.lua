
mafgaha.runes = {}
local runes = mafgaha.runes

--[[
mafgaha.register_rune("u", {
	name = "vera",
	description = "Vera",
	image = "mafgaha_vera.png",
	color = "#RRGGBB",
})

--]]

mafgaha.register_rune = function(strokes, def)
	if runes[strokes] then
		return false, "Rune already registered under the name: '" .. runes[strokes].name .. "'"
	end
	def.strokes = strokes
	def.name = def.name or "missing name"
	def.image = def.image or "mafgaha_unknown_rune.png"

	runes[strokes] = def
end

mafgaha.register_rune("u", {
	name = "vera",
	description = "Vera",
	image = "mafgaha_vera.png",
})
mafgaha.register_rune("d", {
	name = "rhaa",
	description = "Rhaa",
	image = "mafgaha_rhaa.png",
})
mafgaha.register_rune("ru", {
	name = "vitae",
	description = "Vitae",
	image = "mafgaha_vitae.png",
})
mafgaha.register_rune("urdrur", {
	name = "tempus",
	description = "Tempus",
	image = "mafgaha_tempus.png",
})
