_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter.SEARCH_PRIORITY = 100000
ModOptionsSearchFilter.MISSING_INLINE_INPUT_TEXT = "Install InlineInput to use search."
ModOptionsSearchFilter.MISSING_INLINE_INPUT_HELP = "Mod Options Search Filter needs the InlineInput library."
ModOptionsSearchFilter.CALLBACKS = ModOptionsSearchFilter.CALLBACKS or {}
ModOptionsSearchFilter.SEARCH_CONTEXTS = ModOptionsSearchFilter.SEARCH_CONTEXTS or {}
ModOptionsSearchFilter.SEARCH_CONTEXT_ORDER = ModOptionsSearchFilter.SEARCH_CONTEXT_ORDER or {}

return ModOptionsSearchFilter
