_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:RegisterModOverridesMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler[self.CALLBACKS.open_mod_overrides_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "mod_overrides")
	end

	return true
end

function ModOptionsSearchFilter:InstallMenuModInfoGuiPatch()
	local setup_patched = self:InstallMenuRendererPatch(MenuModInfoGui, "_mod_options_search_setup_item_rows_patched")
	local update_patched = self:InstallMenuRendererUpdatePatch(MenuModInfoGui, "_mod_options_search_update_patched")

	return setup_patched or update_patched
end

function ModOptionsSearchFilter:InstallModMenuCreatorPatch()
	if not ModMenuCreator or ModMenuCreator._mod_options_search_create_mod_menu_patched then
		return false
	end

	ModMenuCreator._mod_options_search_create_mod_menu_patched = true

	local original_create_mod_menu = ModMenuCreator.create_mod_menu

	function ModMenuCreator:create_mod_menu(node, ...)
		local result = original_create_mod_menu and original_create_mod_menu(self, node, ...)

		ModOptionsSearchFilter:PrepareNode({ name = ModOptionsSearchFilter.MOD_OVERRIDES_MENU_ID, node = node }, node)

		return result
	end

	return true
end

return ModOptionsSearchFilter
