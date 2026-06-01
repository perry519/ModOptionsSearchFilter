_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local function append_text(parts, value)
	if value ~= nil then
		table.insert(parts, tostring(value))
	end
end

function ModOptionsSearchFilter:ItemParameters(item)
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
	local parameters = self:ItemParameters(item)
	local parts = {}

	append_text(parts, self:LocalizedText(parameters.text_id, parameters.localize))
	append_text(parts, self:LocalizedText(parameters.help_id, parameters.localize_help))

	return table.concat(parts, " ")
end

function ModOptionsSearchFilter:NormalizeSearch(value)
	return string.lower(tostring(value or ""))
end

function ModOptionsSearchFilter:IsAlwaysVisibleItem(item)
	local parameters = self:ItemParameters(item)

	if parameters.back == true or parameters.name == "back" then
		return true
	end

	for _, key in ipairs(self.SEARCH_CONTEXT_ORDER or {}) do
		local context = self.SEARCH_CONTEXTS and self.SEARCH_CONTEXTS[key]

		if context and parameters.name == context.input_id then
			return true
		end
	end

	return false
end

function ModOptionsSearchFilter:BuildSearchNodeItem(context)
	context = self:SearchContext(context)

	if not context then
		return nil
	end

	local item = {
		_meta = "item",
		name = context.input_id,
		localize = false,
		localize_help = false,
		priority = self.SEARCH_PRIORITY
	}

	if self[context.handle_field] then
		item.text_id = " "
		item.help_id = context.desc
		item.callback = context.callback_id
	else
		item.text_id = self.MISSING_INLINE_INPUT_TEXT
		item.help_id = self.MISSING_INLINE_INPUT_HELP
		item.no_select = true
		item.disabled = true
	end

	return item
end

function ModOptionsSearchFilter:FindRawSearchItem(options_node, context)
	context = self:SearchContext(context)

	if not context then
		return nil
	end

	for _, item in ipairs(options_node or {}) do
		if type(item) == "table" and self:ItemName(item) == context.input_id then
			return item
		end
	end

	return nil
end

function ModOptionsSearchFilter:AddSearchNodeItem(options_node, context)
	context = self:SearchContext(context)

	if type(options_node) ~= "table" or not context then
		return false
	end

	local search_item = self:FindRawSearchItem(options_node, context)

	self:SetSearchDefaultItem(options_node, context)

	if search_item then
		self:SetSearchItemPriority(search_item)
		self:PlaceSearchItemFirst(options_node, context)
		return false
	end

	table.insert(options_node, self:BuildSearchNodeItem(context))
	self:PlaceSearchItemFirst(options_node, context)

	return true
end

function ModOptionsSearchFilter:ItemMatchesSearch(item, context)
	context = self:SearchContext(context)

	if not context or self:IsAlwaysVisibleItem(item) then
		return true
	end

	if not self[context.handle_field] then
		return true
	end

	local query = self:NormalizeSearch(self:GetSearchText(context))

	if query == "" then
		return true
	end

	return string.find(self:NormalizeSearch(self:ItemSearchText(item)), query, 1, true) ~= nil
end

function ModOptionsSearchFilter:PatchItemFilter(item, context)
	context = self:SearchContext(context)

	if not context then
		return false
	end

	local patch_flag = "_mod_options_search_filter_patched_" .. context.key

	if not item or item[patch_flag] then
		return false
	end

	item[patch_flag] = true
	item._visible_callback_list = item._visible_callback_list or {}

	table.insert(item._visible_callback_list, function(menu_item)
		return _G.ModOptionsSearchFilter:ItemMatchesSearch(menu_item or item, context)
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
		local parameters = self:ItemParameters(item)

		if parameters.name == item_name then
			return item
		end
	end

	return nil
end

function ModOptionsSearchFilter:EnsureRuntimeSearchItem(node, context)
	context = self:SearchContext(context)

	if not context or not node then
		return false
	end

	local items = self:GetNodeItems(node)
	local search_item = self:FindNodeItem(node, context.input_id)

	self:SetSearchDefaultItem(node, context)

	if search_item then
		self:SetSearchItemPriority(search_item)
		return self:PlaceSearchItemFirst(items, context)
	end

	if not node.create_item or not node.insert_item then
		return false
	end

	local item = node:create_item({}, self:BuildSearchNodeItem(context))

	if not item then
		return false
	end

	node:insert_item(item, 1)
	self:PlaceSearchItemFirst(self:GetNodeItems(node), context)

	return true
end

function ModOptionsSearchFilter:PrepareNode(node_gui, node)
	local context = self:NodeSearchContext(node_gui, node)

	if not context then
		return false
	end

	local target_node = node or node_gui and node_gui.node
	local has_search_input = self:SetupInlineInput(context) ~= nil
	self:EnsureRuntimeSearchItem(target_node, context)

	if has_search_input then
		for _, item in pairs(self:GetNodeItems(target_node)) do
			if not self:IsAlwaysVisibleItem(item) then
				self:PatchItemFilter(item, context)
			end
		end
	end

	return true
end

return ModOptionsSearchFilter
