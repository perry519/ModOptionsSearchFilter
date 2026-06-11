_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter
local RENDERER_PATCH_VERSION = "rendered_icon_tracking_v1"

function ModOptionsSearchFilter:MarkRenderedIconItems(renderer_self)
	if not renderer_self or type(renderer_self.row_items) ~= "table" then
		return false
	end

	local token = (renderer_self._mod_options_search_render_token or 0) + 1
	renderer_self._mod_options_search_render_token = token

	for _, row_item in ipairs(renderer_self.row_items) do
		local item = row_item and row_item.item

		if item then
			item._mod_options_search_render_owner = renderer_self
			item._mod_options_search_render_token = token
		end
	end

	return true
end

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
	if not renderer or renderer[patch_flag] == RENDERER_PATCH_VERSION then
		return false
	end

	renderer[patch_flag] = RENDERER_PATCH_VERSION

	local original_setup_item_rows = renderer._setup_item_rows

	renderer._setup_item_rows = function(renderer_self, node, ...)
		ModOptionsSearchFilter:PrepareNode(renderer_self, node)

		local result = original_setup_item_rows and original_setup_item_rows(renderer_self, node, ...)

		ModOptionsSearchFilter:MarkRenderedIconItems(renderer_self)
		ModOptionsSearchFilter:AutofocusNode(renderer_self)

		return result
	end

	return true
end

return ModOptionsSearchFilter
