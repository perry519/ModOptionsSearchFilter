local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local function prepare(owner, node)
	local group
	local spacer

	for _, item in ipairs(owner:GetNodeItems(node)) do
		local parameters = owner:ItemParameters(item)
		item._mod_options_search_keybind_group = nil

		if item:type() == "divider" then
			if parameters.no_text then
				spacer = item
			else
				group = {
					name = owner:LocalizedText(parameters.text_id, parameters.localize),
					items = {},
				}
				item._mod_options_search_keybind_group = group
				if spacer then
					spacer._mod_options_search_keybind_group = group
					spacer = nil
				end
			end
		elseif parameters.connection_name and group then
			item._mod_options_search_keybind_group = group
			table.insert(group.items, item)
		end
	end
end

local function item_matches(owner, item, query)
	local group = item._mod_options_search_keybind_group

	if group and item:type() == "divider" then
		for _, binding in ipairs(group.items) do
			if binding:visible() then
				return true
			end
		end
		return false
	end

	local parameters = owner:ItemParameters(item)
	local name = owner:LocalizedText(parameters.text_id, parameters.localize)
	local text = (group and group.name or "") .. " " .. (name or "")
	return string.find(owner:NormalizeSearch(text), query, 1, true) ~= nil
end

ModOptionsSearchFilter:RegisterSearchContext({
	key = "keybindings",
	menu_id = "blt_keybinds",
	input_id = "mod_keybindings_search_filter",
	callback_id = "mod_keybindings_search_open",
	handle_field = "KeybindingsSearchInput",
	text_field = "keybindings_search_text",
	desc = "Filter by mod name or keybinding name.",
	prepare = prepare,
	item_matches = item_matches,
})

function ModOptionsSearchFilter:RegisterKeybindingsMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler.mod_keybindings_search_open = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "keybindings")
	end
	return true
end

return ModOptionsSearchFilter
