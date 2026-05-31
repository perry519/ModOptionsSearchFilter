_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local function search_input_config(owner)
	return {
		id = owner.INPUT_ID,
		menu_id = owner.MENU_ID,
		desc = "Filter mod options.",
		callback_id = owner.CALLBACKS.open_search,
		priority = owner.SEARCH_PRIORITY,
		localized = false,
		placeholder = "Filter",
		clear_on_escape = false,
		allow_escape_propagation = true,
		get_value = function()
			return _G.ModOptionsSearchFilter.search_text or ""
		end,
		set_value = function(value)
			_G.ModOptionsSearchFilter.search_text = tostring(value or "")
		end,
		refresh = function(_, node_gui)
			if node_gui and node_gui.refresh_gui and node_gui.node then
				node_gui:refresh_gui(node_gui.node)
			end

			owner:SelectSearchRow(node_gui)
			owner:MarkSearchNavigationActive(node_gui, true)
		end,
		on_cancel = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false)
		end,
		on_submit = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false)
		end,
		on_disconnect = function(_, node_gui)
			owner:MarkSearchNavigationActive(node_gui, false)
		end
	}
end

function ModOptionsSearchFilter:GetSearchText()
	return tostring(_G.ModOptionsSearchFilter.search_text or "")
end

function ModOptionsSearchFilter:SetSearchText(value)
	_G.ModOptionsSearchFilter.search_text = tostring(value or "")
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

function ModOptionsSearchFilter:SetupInlineInput()
	local library = self:GetInlineInputLibrary()

	if not library or not library.EnsureInput then
		self.SearchInput = nil
		return nil
	end

	self.SearchInput = library:EnsureInput(self, "SearchInput", search_input_config)

	return self.SearchInput
end

function ModOptionsSearchFilter:GetSearchInputHandle()
	if self.SearchInput and self.SearchInput.available and self.SearchInput:available() then
		return self.SearchInput
	end

	return self:SetupInlineInput()
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

function ModOptionsSearchFilter:SelectSearchRow(target)
	local node_gui = self:ResolveNodeGui(target)
	if not node_gui or self:GetNodeName(node_gui) ~= self.MENU_ID then
		return false
	end

	local node = node_gui.node
	if not node or not node.select_item then
		return false
	end

	node:select_item(self.INPUT_ID)
	return true
end

function ModOptionsSearchFilter:MarkSearchNavigationActive(target, active)
	local node_gui = self:ResolveNodeGui(target)
	if not node_gui or self:GetNodeName(node_gui) ~= self.MENU_ID then
		return false
	end

	node_gui._mod_options_search_input_navigation_active = active == true
	return true
end

function ModOptionsSearchFilter:FocusSearch(node_gui)
	local handle = self:GetSearchInputHandle()

	if handle and handle.focus then
		local focused = handle:focus(node_gui)

		if focused then
			self:SelectSearchRow(node_gui)
			self:MarkSearchNavigationActive(node_gui, true)
		end

		return focused
	end

	return false
end

function ModOptionsSearchFilter:BlurSearch(node_gui)
	local handle = self:GetSearchInputHandle()

	if handle and handle.blur then
		return handle:blur(node_gui)
	end

	return false
end

function ModOptionsSearchFilter:OpenSearch(item)
	return self:FocusSearch(item)
end

return ModOptionsSearchFilter
