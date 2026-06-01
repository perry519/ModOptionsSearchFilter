_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:UpdateInlineInputRenderer(renderer_self, dt)
	local library = self.InlineInputLibrary or _G.InlineInput

	if not library then
		return false
	end

	if library.MenuNodeGuiUsable and not library:MenuNodeGuiUsable(renderer_self) then
		return false
	end

	if library.SyncNode then
		library:SyncNode(renderer_self)
	end

	if library.RestorePreservedScrollIndicators then
		library:RestorePreservedScrollIndicators(renderer_self)
	end

	if library.UpdateNodeCaretBlinks then
		library:UpdateNodeCaretBlinks(renderer_self, dt)
	end

	return true
end

function ModOptionsSearchFilter:InstallMenuRendererUpdatePatch(renderer, patch_flag)
	if not renderer or renderer[patch_flag] then
		return false
	end

	renderer[patch_flag] = true

	local original_update = renderer.update

	renderer.update = function(renderer_self, t, dt, ...)
		local result = original_update and original_update(renderer_self, t, dt, ...)

		ModOptionsSearchFilter:UpdateInlineInputRenderer(renderer_self, dt)

		return result
	end

	return true
end

function ModOptionsSearchFilter:InstallMenuRendererPatch(renderer, patch_flag)
	if not renderer or renderer[patch_flag] then
		return false
	end

	renderer[patch_flag] = true

	local original_setup_item_rows = renderer._setup_item_rows

	renderer._setup_item_rows = function(renderer_self, node, ...)
		ModOptionsSearchFilter:PrepareNode(renderer_self, node)

		local result = original_setup_item_rows and original_setup_item_rows(renderer_self, node, ...)

		ModOptionsSearchFilter:AutofocusNode(renderer_self)

		return result
	end

	return true
end

return ModOptionsSearchFilter
