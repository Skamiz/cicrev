
mafgaha.spells = {}
local spells = mafgaha.spells

--[[
mafgaha.register_spell("vera, vitae, {
	description = "Vera",
	on_cast = function(caster),
	? mana_cost = 20,
})

--]]

mafgaha.register_spell = function(sequence, def)
	if spells[sequence] then
		return false, "A spell is already registered under this sequence."
	end
	def.sequence = sequence
	def.name = def.name or "missing name"
	def.image = def.image or "mafgaha_unknown_spell.png"

	spells[sequence] = def
end

mafgaha.register_spell("vera, vitae", {
	name = "Heal",
	on_cast = function(caster)
		-- as far as I can tell, givving a reason here is completely pointless
		caster:set_hp(caster:get_hp() + 2, "heal spell")
	end,
})
mafgaha.register_spell("rhaa, vitae", {
	name = "Damage",
	on_cast = function(caster)
		caster:set_hp(caster:get_hp() - 2, "damage spell")
	end,
})
mafgaha.register_spell("rhaa, tempus", {
	name = "Slow Time",
	on_cast = function(caster)
		player_properties.add_effect(caster, {
			name = "spell",
			property = "speed",
			-- text_influence = "function (s) return s + 0.3 end",
			text_influence = "function (s) return s + 0.8 end",
			duration = 20,
			priority = 70,
			persistant = true,
		})
	end,
})
-- mafgaha.register_rune("ru", {
-- 	name = "Vitae",
-- 	image = "mafgaha_vitae.png",
-- })
-- mafgaha.register_rune("urdrur", {
-- 	name = "Tempus",
-- 	image = "mafgaha_tempus.png",
-- })


-- local function print_table(po)
-- 	for k, v in pairs(po) do
-- 		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
-- 	end
-- end
--
-- minetest.register_on_player_hpchange(function(player, hp_change, reason)
-- 	minetest.chat_send_all("HP: " .. hp_change .. ", reason: " .. reason.type)
-- 	print_table(reason)
-- end, nil)
