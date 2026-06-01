_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.MOD_OVERRIDES_MENU_ID = "mods"
ModOptionsSearchFilter.MOD_OVERRIDES_INPUT_ID = "mod_overrides_search_filter"
ModOptionsSearchFilter.CALLBACKS.open_mod_overrides_search = "mod_overrides_search_open"

function ModOptionsSearchFilter:IsModOverridesNode(node_gui, node)
	local parameters = self:GetNodeParameters(node or node_gui)

	return type(parameters.mods) == "table"
		and type(parameters.modded_content) == "table"
end

ModOptionsSearchFilter:RegisterSearchContext({
	key = "mod_overrides",
	menu_id = ModOptionsSearchFilter.MOD_OVERRIDES_MENU_ID,
	input_id = ModOptionsSearchFilter.MOD_OVERRIDES_INPUT_ID,
	callback_id = ModOptionsSearchFilter.CALLBACKS.open_mod_overrides_search,
	handle_field = "ModOverridesSearchInput",
	text_field = "mod_overrides_search_text",
	accepts_search_item = true,
	matches = function(owner, node_gui, node)
		return owner:IsModOverridesNode(node_gui, node)
	end
})

return ModOptionsSearchFilter
