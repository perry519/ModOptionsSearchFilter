_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.MOD_PATH = ModOptionsSearchFilter.MOD_PATH or ModPath or "ModOptionsSearchFilter/"
ModOptionsSearchFilter.search_text = ModOptionsSearchFilter.search_text or ""

local function load_module(path)
	dofile(ModOptionsSearchFilter.MOD_PATH .. path)
end

local modules = {
	"modules/shared/constants.lua",
	"modules/shared/context.lua",
	"modules/blt/context.lua",
	"modules/mo/context.lua",
	"modules/shared/input.lua",
	"modules/shared/filter.lua",
	"modules/shared/renderer.lua",
	"modules/shared/navigation.lua",
	"modules/blt/menu.lua",
	"modules/mo/menu.lua",
	"modules/shared/core.lua",
}

for _, module_path in ipairs(modules) do
	load_module(module_path)
end

return ModOptionsSearchFilter
