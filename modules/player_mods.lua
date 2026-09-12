local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter:RegisterSearchContext({
	key = "player_mods",
	menu_id = "inspect_player",
	input_id = "player_mods_search_filter",
	callback_id = "player_mods_search_open",
	handle_field = "PlayerModsSearchInput",
	text_field = "player_mods_search_text",
	desc = "Filter this player's installed mods by name or folder.",
	insert_after = "peer_mods",
	matches = function(owner, node_gui, node)
		return owner:GetNodeName(node_gui or node) == "inspect_player"
			and owner:FindNodeItem(node or node_gui.node or node_gui, "peer_mods") ~= nil
	end,
	item_matches = function(owner, item, query)
		local parameters = owner:ItemParameters(item)
		if not tostring(parameters.name):match("^mod_%d+$") then
			return true
		end

		local text = owner:ItemSearchText(item) .. " " .. tostring(parameters.mod_id or "")
		return string.find(owner:NormalizeSearch(text), query, 1, true) ~= nil
	end,
})

function ModOptionsSearchFilter:RegisterPlayerModsMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler.player_mods_search_open = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "player_mods")
	end
	return true
end

return ModOptionsSearchFilter
