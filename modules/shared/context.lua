_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:RegisterSearchContext(context)
	if not context or not context.key then
		return nil
	end

	self.SEARCH_CONTEXTS = self.SEARCH_CONTEXTS or {}
	self.SEARCH_CONTEXT_ORDER = self.SEARCH_CONTEXT_ORDER or {}

	if not self.SEARCH_CONTEXTS[context.key] then
		table.insert(self.SEARCH_CONTEXT_ORDER, context.key)
	end

	self.SEARCH_CONTEXTS[context.key] = context

	if context.default or not self.DEFAULT_SEARCH_CONTEXT then
		self.DEFAULT_SEARCH_CONTEXT = context
	end

	return context
end

function ModOptionsSearchFilter:SearchContext(context)
	if type(context) == "table" and context.input_id then
		return context
	end

	for _, key in ipairs(self.SEARCH_CONTEXT_ORDER or {}) do
		local candidate = self.SEARCH_CONTEXTS and self.SEARCH_CONTEXTS[key]

		if candidate and (context == candidate.key or context == candidate.menu_id or context == candidate.input_id) then
			return candidate
		end
	end

	return self.DEFAULT_SEARCH_CONTEXT
end

function ModOptionsSearchFilter:InitializeSearchState()
	for _, key in ipairs(self.SEARCH_CONTEXT_ORDER or {}) do
		local context = self.SEARCH_CONTEXTS and self.SEARCH_CONTEXTS[key]

		if context and context.text_field then
			self[context.text_field] = self[context.text_field] or ""
		end
	end

	return true
end

function ModOptionsSearchFilter:GetSearchText(context)
	context = self:SearchContext(context)

	return tostring(context and _G.ModOptionsSearchFilter[context.text_field] or "")
end

function ModOptionsSearchFilter:SetSearchText(value, context)
	context = self:SearchContext(context)

	if not context then
		return false
	end

	_G.ModOptionsSearchFilter[context.text_field] = tostring(value or "")

	return true
end

function ModOptionsSearchFilter:GetNodeName(node_gui)
	local library = self.GetInlineInputLibrary and self:GetInlineInputLibrary()

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

function ModOptionsSearchFilter:GetNodeParameters(node)
	node = node and node.node or node

	if node and node.parameters then
		local ok, parameters = pcall(function()
			return node:parameters()
		end)

		if ok and type(parameters) == "table" then
			return parameters
		end
	end

	return node and node._parameters or {}
end

function ModOptionsSearchFilter:ContextMatchesNode(context, node_gui, node)
	context = self:SearchContext(context)

	if not context then
		return false
	end

	if context.matches then
		return context.matches(self, node_gui, node) == true
	end

	return self:GetNodeName(node_gui or node) == context.menu_id
end

function ModOptionsSearchFilter:NodeSearchContext(node_gui, node)
	for _, key in ipairs(self.SEARCH_CONTEXT_ORDER or {}) do
		local context = self.SEARCH_CONTEXTS and self.SEARCH_CONTEXTS[key]

		if context and self:ContextMatchesNode(context, node_gui, node) then
			return context
		end
	end

	return nil
end

function ModOptionsSearchFilter:NodeMatchesContext(node_gui, node, context)
	context = self:SearchContext(context)

	if not context then
		return false
	end

	if self:ContextMatchesNode(context, node_gui, node) then
		return true
	end

	if context.accepts_search_item and self.FindNodeItem then
		return self:FindNodeItem(node or node_gui and node_gui.node or node_gui, context.input_id) ~= nil
	end

	return false
end

return ModOptionsSearchFilter
