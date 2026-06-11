_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local MARKER = "_mod_options_search_jukebox_context"

ModOptionsSearchFilter.JUKEBOX_CONTEXT_MARKER = MARKER
ModOptionsSearchFilter.JUKEBOX_HEIST_PLAYLIST_INPUT_ID = "jukebox_heist_playlist_search_filter"
ModOptionsSearchFilter.JUKEBOX_HEIST_TRACKS_INPUT_ID = "jukebox_heist_tracks_search_filter"
ModOptionsSearchFilter.JUKEBOX_MENU_PLAYLIST_INPUT_ID = "jukebox_menu_playlist_search_filter"
ModOptionsSearchFilter.CALLBACKS.open_jukebox_heist_playlist_search = "jukebox_heist_playlist_search_open"
ModOptionsSearchFilter.CALLBACKS.open_jukebox_heist_tracks_search = "jukebox_heist_tracks_search_open"
ModOptionsSearchFilter.CALLBACKS.open_jukebox_menu_playlist_search = "jukebox_menu_playlist_search_open"

function ModOptionsSearchFilter:NodeHasJukeboxCallback(node, callback_name)
	if not node or not callback_name then
		return false
	end

	local items = self.GetNodeItems and self:GetNodeItems(node) or node._items or {}

	for _, item in pairs(items) do
		local parameters = self.ItemParameters and self:ItemParameters(item) or item and item._parameters or {}

		if parameters.callback == callback_name then
			return true
		end
	end

	return false
end

function ModOptionsSearchFilter:IsJukeboxSearchNode(node_gui, node, context_key, callback_name)
	local target_node = node or node_gui and node_gui.node or node_gui

	if not target_node then
		return false
	end

	if target_node[MARKER] == context_key then
		return true
	end

	local parameters = self:GetNodeParameters(target_node)

	if parameters and parameters[MARKER] == context_key then
		return true
	end

	return self:NodeHasJukeboxCallback(target_node, callback_name)
end

ModOptionsSearchFilter:RegisterSearchContext({
	key = "jukebox_heist_playlist",
	menu_id = "jukebox_heist_playlist",
	input_id = ModOptionsSearchFilter.JUKEBOX_HEIST_PLAYLIST_INPUT_ID,
	callback_id = ModOptionsSearchFilter.CALLBACKS.open_jukebox_heist_playlist_search,
	handle_field = "JukeboxHeistPlaylistSearchInput",
	text_field = "jukebox_heist_playlist_search_text",
	desc = "Filter custom heist playlist.",
	accepts_search_item = true,
	matches = function(owner, node_gui, node)
		return owner:IsJukeboxSearchNode(node_gui, node, "jukebox_heist_playlist", "jukebox_option_heist_playlist")
	end
})

ModOptionsSearchFilter:RegisterSearchContext({
	key = "jukebox_heist_tracks",
	menu_id = "jukebox_heist_tracks",
	input_id = ModOptionsSearchFilter.JUKEBOX_HEIST_TRACKS_INPUT_ID,
	callback_id = ModOptionsSearchFilter.CALLBACKS.open_jukebox_heist_tracks_search,
	handle_field = "JukeboxHeistTracksSearchInput",
	text_field = "jukebox_heist_tracks_search_text",
	desc = "Filter custom heist tracks.",
	accepts_search_item = true,
	matches = function(owner, node_gui, node)
		return owner:IsJukeboxSearchNode(node_gui, node, "jukebox_heist_tracks", "jukebox_option_heist_tracks")
	end
})

ModOptionsSearchFilter:RegisterSearchContext({
	key = "jukebox_menu_playlist",
	menu_id = "jukebox_menu_playlist",
	input_id = ModOptionsSearchFilter.JUKEBOX_MENU_PLAYLIST_INPUT_ID,
	callback_id = ModOptionsSearchFilter.CALLBACKS.open_jukebox_menu_playlist_search,
	handle_field = "JukeboxMenuPlaylistSearchInput",
	text_field = "jukebox_menu_playlist_search_text",
	desc = "Filter custom menu playlist.",
	accepts_search_item = true,
	matches = function(owner, node_gui, node)
		return owner:IsJukeboxSearchNode(node_gui, node, "jukebox_menu_playlist", "jukebox_option_menu_playlist")
	end
})

return ModOptionsSearchFilter
