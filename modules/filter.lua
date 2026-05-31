_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local function item_parameters(item)
	if item and item.parameters then
		local ok, parameters = pcall(function()
			return item:parameters()
		end)

		if ok and type(parameters) == "table" then
			return parameters
		end
	end

	return item and item._parameters or {}
end

local function append_text(parts, value)
	if value ~= nil then
		table.insert(parts, tostring(value))
	end
end

function ModOptionsSearchFilter:GetNodeName(node_gui)
	local library = self:GetInlineInputLibrary()

	if library and library.GetNodeName then
		local ok, node_name = pcall(function()
			return library:GetNodeName(node_gui)
		end)

		if ok and node_name then
			return node_name
		end
	end

	local node = node_gui and node_gui.node or node_gui
	local parameters = node and node.parameters and node:parameters()

	return parameters and parameters.name or node_gui and node_gui.name
end

function ModOptionsSearchFilter:LocalizedText(value, localized)
	if value == nil then
		return nil
	end

	local text = tostring(value)

	if localized == false or localized == "false" then
		return text
	end

	if managers and managers.localization and managers.localization.text then
		local ok, localized_text = pcall(function()
			return managers.localization:text(text)
		end)

		if ok and localized_text and localized_text ~= text then
			return tostring(localized_text)
		end
	end

	return text
end

function ModOptionsSearchFilter:ItemSearchText(item)
	local parameters = item_parameters(item)
	local parts = {}

	append_text(parts, self:LocalizedText(parameters.text_id, parameters.localize))
	append_text(parts, self:LocalizedText(parameters.help_id, parameters.localize_help))

	return table.concat(parts, " ")
end

function ModOptionsSearchFilter:NormalizeSearch(value)
	return string.lower(tostring(value or ""))
end

function ModOptionsSearchFilter:IsAlwaysVisibleItem(item)
	local parameters = item_parameters(item)

	return parameters.name == self.INPUT_ID or parameters.back == true or parameters.name == "back"
end

function ModOptionsSearchFilter:BuildSearchNodeItem()
	local item = {
		_meta = "item",
		name = self.INPUT_ID,
		localize = false,
		localize_help = false,
		priority = self.SEARCH_PRIORITY
	}

	if self.SearchInput then
		item.text_id = " "
		item.help_id = "Filter mod options."
		item.callback = self.CALLBACKS.open_search
	else
		item.text_id = self.MISSING_INLINE_INPUT_TEXT
		item.help_id = self.MISSING_INLINE_INPUT_HELP
		item.no_select = true
		item.disabled = true
	end

	return item
end

function ModOptionsSearchFilter:RawNodeHasSearchItem(options_node)
	for _, item in ipairs(options_node or {}) do
		if type(item) == "table" and item.name == self.INPUT_ID then
			return true
		end
	end

	return false
end

function ModOptionsSearchFilter:AddSearchNodeItem(options_node)
	if type(options_node) ~= "table" then
		return false
	end

	if self:RawNodeHasSearchItem(options_node) then
		return false
	end

	table.insert(options_node, self:BuildSearchNodeItem())

	return true
end

function ModOptionsSearchFilter:ItemMatchesSearch(item)
	if self:IsAlwaysVisibleItem(item) then
		return true
	end

	if not self.SearchInput then
		return true
	end

	local query = self:NormalizeSearch(self:GetSearchText())

	if query == "" then
		return true
	end

	return string.find(self:NormalizeSearch(self:ItemSearchText(item)), query, 1, true) ~= nil
end

function ModOptionsSearchFilter:PatchItemFilter(item)
	if not item or item._mod_options_search_filter_patched then
		return false
	end

	item._mod_options_search_filter_patched = true
	item._visible_callback_list = item._visible_callback_list or {}

	table.insert(item._visible_callback_list, function(menu_item)
		return _G.ModOptionsSearchFilter:ItemMatchesSearch(menu_item or item)
	end)

	return true
end

function ModOptionsSearchFilter:GetNodeItems(node)
	if node and node.items then
		local ok, items = pcall(function()
			return node:items()
		end)

		if ok and type(items) == "table" then
			return items
		end
	end

	return node and node._items or {}
end

function ModOptionsSearchFilter:FindNodeItem(node, item_name)
	for _, item in pairs(self:GetNodeItems(node)) do
		local parameters = item_parameters(item)

		if parameters.name == item_name then
			return item
		end
	end

	return nil
end

function ModOptionsSearchFilter:EnsureRuntimeSearchItem(node)
	if not node or self:FindNodeItem(node, self.INPUT_ID) then
		return false
	end

	if not node.create_item or not node.insert_item then
		return false
	end

	local item = node:create_item(self:BuildSearchNodeItem())

	if not item then
		return false
	end

	node:insert_item(item, 1)

	return true
end

function ModOptionsSearchFilter:PrepareNode(node_gui, node)
	if self:GetNodeName(node_gui) ~= self.MENU_ID then
		return false
	end

	local has_search_input = self:SetupInlineInput() ~= nil
	self:EnsureRuntimeSearchItem(node or node_gui.node)

	if has_search_input then
		for _, item in pairs(self:GetNodeItems(node or node_gui.node)) do
			if not self:IsAlwaysVisibleItem(item) then
				self:PatchItemFilter(item)
			end
		end
	end

	return true
end

return ModOptionsSearchFilter
