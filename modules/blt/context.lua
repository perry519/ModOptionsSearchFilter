_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.MENU_ID = "blt_options"
ModOptionsSearchFilter.INPUT_ID = "mod_options_search_filter"
ModOptionsSearchFilter.CALLBACKS.open_search = "mod_options_search_open"

ModOptionsSearchFilter:RegisterSearchContext({
	key = "mod_options",
	menu_id = ModOptionsSearchFilter.MENU_ID,
	input_id = ModOptionsSearchFilter.INPUT_ID,
	callback_id = ModOptionsSearchFilter.CALLBACKS.open_search,
	handle_field = "SearchInput",
	text_field = "search_text",
	desc = "Filter mod options.",
	default = true,
	matches = function(owner, node_gui, node)
		return owner:GetNodeName(node_gui or node) == owner.MENU_ID
	end
})

return ModOptionsSearchFilter
