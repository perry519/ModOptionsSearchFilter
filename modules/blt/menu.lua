_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:RegisterBltMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler[self.CALLBACKS.open_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "mod_options")
	end

	return true
end

function ModOptionsSearchFilter:RegisterBltMenuHooks()
	if not Hooks then
		return false
	end

	if self._blt_menu_hooked then
		return true
	end

	self._blt_menu_hooked = true

	Hooks:Add("BLTOnBuildOptions", "ModOptionsSearchFilter_BuildOptions", function(options_node)
		ModOptionsSearchFilter:RegisterBltMenuCallbacks()
		ModOptionsSearchFilter:SetupInlineInput("mod_options")
		ModOptionsSearchFilter:EnsureBltOptionsRawModifier(options_node)
		ModOptionsSearchFilter:AddSearchNodeItem(options_node, "mod_options")
	end)

	Hooks:Add("MenuManagerSetupCustomMenus", "ModOptionsSearchFilter_SetupMenu", function()
		ModOptionsSearchFilter:SetupInlineInput("mod_options")
		ModOptionsSearchFilter:RegisterBltMenuCallbacks()
	end)

	Hooks:Add("MenuManagerPopulateCustomMenus", "ModOptionsSearchFilter_PopulateMenu", function()
		ModOptionsSearchFilter:SetupInlineInput("mod_options")
		ModOptionsSearchFilter:RegisterBltMenuCallbacks()
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "ModOptionsSearchFilter_BuildMenu", function(_, nodes)
		local node = nodes and nodes[ModOptionsSearchFilter.MENU_ID]

		ModOptionsSearchFilter:SetupInlineInput("mod_options")
		ModOptionsSearchFilter:RegisterBltMenuCallbacks()
		ModOptionsSearchFilter:EnsureBltOptionsRuntimeModifier(node)
		ModOptionsSearchFilter:PlaceBltSearchItemFirst(node)
	end)

	return true
end

function ModOptionsSearchFilter:InstallMenuNodeGuiPatch()
	return self:InstallMenuRendererPatch(MenuNodeGui, "_mod_options_search_setup_item_rows_patched")
end

return ModOptionsSearchFilter
