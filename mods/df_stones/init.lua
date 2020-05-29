local mod_name = minetest.get_current_modname()
local stones = {"Andesite", "Basalt", "Chalk", "Chert", "Claystone",
    "Conglomerate", "Dacite", "Diorite", "Dolomite", "Gabbro", "Gneiss", "Granite", "Limestone",
    "Marble", "Mudstone", "Obsidian", "Phyllite", "Quartzite", "Rhyolite",
    "Rocksalt", "Sandstone", "Schist", "Shale", "Siltstone", "Slate"}

sedimentary = {"chalk", "chert", "claystone", "conglomerate", "dolomite",
    "limestone", "mudstone", "rocksalt", "sandstone", "shale", "siltstone"}

i_extrusive = {"andesite", "basalt", "dacite", "obsidian", "rhyolite"}

metamorphic = {"gneiss", "marble", "phyllite", "quartzite", "schist", "slate"}

i_intrusive = {"diorite", "gabbro", "granite"}

for _, v in pairs(stones) do
    local lower = string.lower(v)
    minetest.register_node(mod_name .. ":" .. lower, {
        description = v,
        tiles = {mod_name .. "_" .. lower .. ".png"},
        groups = {cracky = 1},
    })
end
