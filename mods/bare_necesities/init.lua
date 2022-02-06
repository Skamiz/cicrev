local recipes

minetest.register_on_mods_loaded(function()

end)

local function get_form()
end


minetest.register_chatcommand("craft", {
	params = "",
	description = "Show crafting guide.",
	func = function(name, param)
		minetest.show_formspec(name, "craft:form", formspec)
	end,
})
