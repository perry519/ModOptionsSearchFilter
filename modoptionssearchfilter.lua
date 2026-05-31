_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.MOD_PATH = ModOptionsSearchFilter.MOD_PATH or ModPath or "ModOptionsSearchFilter/"
ModOptionsSearchFilter.search_text = ModOptionsSearchFilter.search_text or ""

local function load_module(path)
	dofile(ModOptionsSearchFilter.MOD_PATH .. path)
end

local modules = {
	"modules/constants.lua",
	"modules/input.lua",
	"modules/filter.lua",
	"modules/menu.lua",
	"modules/hooks.lua",
	"modules/core.lua",
}

for _, module_path in ipairs(modules) do
	load_module(module_path)
end

return ModOptionsSearchFilter
