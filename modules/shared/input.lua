_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local function search_input_config(owner, context)
	context = owner:SearchContext(context)

	return {
		id = context.input_id,
		menu_id = context.menu_id,
		desc = context.desc,
		callback_id = context.callback_id,
		priority = owner.SEARCH_PRIORITY,
		localized = false,
		placeholder = "Filter",
		clear_on_escape = false,
		allow_escape_propagation = true,
		get_value = function()
			return owner:GetSearchText(context)
		end,
		set_value = function(value)
			owner:SetSearchText(value, context)
		end,
		refresh = function(_, node_gui)
			if node_gui and node_gui.refresh_gui and node_gui.node then
				node_gui:refresh_gui(node_gui.node)
			end

			owner:SelectSearchRow(node_gui, context)
			owner:MarkSearchNavigationActive(node_gui, true, context)
		end,
		on_cancel = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false, context)
		end,
		on_submit = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false, context)
		end,
		on_disconnect = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false, context)
		end
	}
end

function ModOptionsSearchFilter:GetInlineInputLibrary()
	local library = self.InlineInputLibrary or _G.InlineInput

	if not library or not library.EnsureInput then
		local ok, loaded = pcall(dofile, (self.MOD_PATH or "") .. "../InlineInput/require.lua")

		if ok then
			library = loaded
		end
	end

	if library and library.EnsureInput then
		self.InlineInputLibrary = library
		return library
	end

	self.InlineInputLibrary = nil
	return nil
end

function ModOptionsSearchFilter:SetupInlineInput(context)
	context = self:SearchContext(context)
	local library = self:GetInlineInputLibrary()

	if not context then
		return nil
	end

	if not library or not library.EnsureInput then
		self[context.handle_field] = nil
		return nil
	end

	self[context.handle_field] = library:EnsureInput(self, context.handle_field, function(owner)
		return search_input_config(owner, context)
	end)

	return self[context.handle_field]
end

function ModOptionsSearchFilter:GetSearchInputHandle(context)
	context = self:SearchContext(context)

	if not context then
		return nil
	end

	local handle = self[context.handle_field]

	if handle and handle.available and handle:available() then
		return handle
	end

	return self:SetupInlineInput(context)
end

function ModOptionsSearchFilter:ResolveNodeGui(target)
	local library = self:GetInlineInputLibrary()
	if library and library.ResolveNodeGui then
		local ok, node_gui = pcall(function()
			return library:ResolveNodeGui(target)
		end)

		if ok and node_gui then
			return node_gui
		end
	end

	if target and target.node then
		return target
	end

	return nil
end

function ModOptionsSearchFilter:SelectSearchRow(target, context)
	context = self:SearchContext(context)
	local node_gui = self:ResolveNodeGui(target)
	if not context or not node_gui or not self:NodeMatchesContext(node_gui, node_gui.node, context) then
		return false
	end

	local node = node_gui.node
	if not node or not node.select_item then
		return false
	end

	node:select_item(context.input_id)
	return true
end

function ModOptionsSearchFilter:MarkSearchNavigationActive(target, active, context)
	context = self:SearchContext(context)
	local node_gui = self:ResolveNodeGui(target)
	if not context or not node_gui or not self:NodeMatchesContext(node_gui, node_gui.node, context) then
		return false
	end

	node_gui._mod_options_search_input_navigation_active = active == true
	return true
end

function ModOptionsSearchFilter:FocusSearch(node_gui, context)
	context = self:SearchContext(context)
	local handle = self:GetSearchInputHandle(context)

	if handle and handle.focus then
		local focused = handle:focus(node_gui)

		if focused then
			self:SelectSearchRow(node_gui, context)
			self:MarkSearchNavigationActive(node_gui, true, context)
		end

		return focused
	end

	return false
end

function ModOptionsSearchFilter:BlurSearch(node_gui, context)
	local handle = self:GetSearchInputHandle(context)

	if handle and handle.blur then
		return handle:blur(node_gui)
	end

	return false
end

function ModOptionsSearchFilter:OpenSearch(item, context)
	return self:FocusSearch(item, context)
end

return ModOptionsSearchFilter
