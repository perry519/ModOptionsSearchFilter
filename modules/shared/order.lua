_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:ItemName(item)
	local parameters = self:ItemParameters(item)
	local name = item and item.name

	if type(name) == "string" then
		return name
	end

	return parameters.name
end

function ModOptionsSearchFilter:SetSearchItemPriority(item, priority)
	if not item then
		return false
	end

	local parameters = self:ItemParameters(item)
	priority = priority or self.SEARCH_PRIORITY

	item.priority = priority

	if item._priority ~= nil then
		item._priority = priority
	end

	if type(parameters) == "table" then
		parameters.priority = priority
	end

	return true
end

function ModOptionsSearchFilter:SetSearchDefaultItem(target, context)
	context = self:SearchContext(context)

	if type(target) ~= "table" or not context then
		return false
	end

	if not target.items then
		local changed = false

		for _, item in ipairs(target) do
			if type(item) == "table" and item._meta == "default_item" then
				item.name = context.input_id
				changed = true
			end
		end

		return changed
	end

	local node = target.node or target

	if node.set_default_item_name then
		local ok = pcall(function()
			node:set_default_item_name(context.input_id)
		end)

		if ok then
			return true
		end
	end

	node._default_item_name = context.input_id

	return true
end

function ModOptionsSearchFilter:PlaceSearchItemFirst(items, context)
	context = self:SearchContext(context)

	if type(items) ~= "table" or not context then
		return false
	end

	local search_index = nil
	local search_item = nil

	for index, item in ipairs(items) do
		if type(item) == "table" and self:ItemName(item) == context.input_id then
			search_index = index
			search_item = item
			break
		end
	end

	if not search_item then
		return false
	end

	if search_index == 1 then
		return false
	end

	table.remove(items, search_index)
	table.insert(items, 1, search_item)

	return true
end

return ModOptionsSearchFilter
