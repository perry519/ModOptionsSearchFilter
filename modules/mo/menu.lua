_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local empty_mod_info_item = {
	parameters = function()
		return { back = true }
	end
}

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
	local info_patched = self:InstallMenuModInfoGuiSearchInfoPatch()

	return setup_patched or update_patched or info_patched
end

function ModOptionsSearchFilter:IsModOverridesSearchItem(item)
	return self:ItemParameters(item).name == self.MOD_OVERRIDES_INPUT_ID
end

function ModOptionsSearchFilter:InstallMenuModInfoGuiSearchInfoPatch()
	if not MenuModInfoGui or MenuModInfoGui._mod_options_search_set_mod_info_patched then
		return false
	end

	local original_set_mod_info = MenuModInfoGui.set_mod_info

	if type(original_set_mod_info) ~= "function" then
		return false
	end

	MenuModInfoGui._mod_options_search_set_mod_info_patched = true

	function MenuModInfoGui:set_mod_info(item, ...)
		if ModOptionsSearchFilter:IsModOverridesSearchItem(item) then
			return original_set_mod_info(self, empty_mod_info_item, ...)
		end

		return original_set_mod_info(self, item, ...)
	end

	return true
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
