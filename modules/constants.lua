_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.MENU_ID = "blt_options"
ModOptionsSearchFilter.INPUT_ID = "mod_options_search_filter"
ModOptionsSearchFilter.SEARCH_PRIORITY = 100000
ModOptionsSearchFilter.MISSING_INLINE_INPUT_TEXT = "Install InlineInput to use search."
ModOptionsSearchFilter.MISSING_INLINE_INPUT_HELP = "Mod Options Search Filter needs the InlineInput library."
ModOptionsSearchFilter.CALLBACKS = {
	open_search = "mod_options_search_open"
}

return ModOptionsSearchFilter
