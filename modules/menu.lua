_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:RegisterMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler[self.CALLBACKS.open_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item)
	end

	return true
end

function ModOptionsSearchFilter:RegisterMenuHooks()
	if not Hooks then
		return false
	end

	if self._menu_hooked then
		return true
	end

	self._menu_hooked = true

	Hooks:Add("BLTOnBuildOptions", "ModOptionsSearchFilter_BuildOptions", function(options_node)
		ModOptionsSearchFilter:RegisterMenuCallbacks()
		ModOptionsSearchFilter:SetupInlineInput()
		ModOptionsSearchFilter:AddSearchNodeItem(options_node)
	end)

	Hooks:Add("MenuManagerSetupCustomMenus", "ModOptionsSearchFilter_SetupMenu", function()
		ModOptionsSearchFilter:SetupInlineInput()
		ModOptionsSearchFilter:RegisterMenuCallbacks()
	end)

	Hooks:Add("MenuManagerPopulateCustomMenus", "ModOptionsSearchFilter_PopulateMenu", function()
		ModOptionsSearchFilter:SetupInlineInput()
		ModOptionsSearchFilter:RegisterMenuCallbacks()
	end)

	return true
end

return ModOptionsSearchFilter
