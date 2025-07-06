local cartography = cartography

--[[
page = {
	name = "height map",
	description = "Height Map"
	get_page_fs = function(self, data_maps)
		local fs = {}
		return table.concat(fs)
	end
	depends = {"height", "normal"},
})

]]




cartography.registered_pages = {}
cartography.page_names = {}
cartography.register_page = function(name, def)
	def.name = name

	if not cartography.registered_pages[name] then
		table.insert(cartography.page_names, name)
	end

	def.tab = #cartography.page_names
	cartography.registered_pages[name] = def
end
