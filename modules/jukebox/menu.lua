_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

local PATCHES = {
	{
		class_name = "MenuJukeboxHeistPlaylist",
		context_key = "jukebox_heist_playlist"
	},
	{
		class_name = "MenuJukeboxHeistTracks",
		context_key = "jukebox_heist_tracks"
	},
	{
		class_name = "MenuJukeboxMenuPlaylist",
		context_key = "jukebox_menu_playlist"
	}
}

local CALLBACK_PATCHES = {
	{
		callback_name = "jukebox_option_heist_playlist",
		handler_name = "JukeboxOptionHeistPlaylist"
	},
	{
		callback_name = "jukebox_option_heist_tracks",
		handler_name = "JukeboxOptionHeistTracks"
	},
	{
		callback_name = "jukebox_option_menu_playlist",
		handler_name = "JukeboxOptionMenuPlaylist"
	}
}

local CALLBACK_PATCH_VERSION = "safe_jukebox_callback_v2"

function ModOptionsSearchFilter:ActiveMenuNode()
	if not managers or not managers.menu or not managers.menu.active_menu then
		return nil
	end

	local ok, node = pcall(function()
		local active_menu = managers.menu:active_menu()
		local logic = active_menu and active_menu.logic

		return logic and logic:selected_node()
	end)

	if ok then
		return node
	end

	return nil
end

function ModOptionsSearchFilter:JukeboxItemName(item)
	if not item then
		return nil
	end

	if type(item.name) == "function" then
		local ok, name = pcall(function()
			return item:name()
		end)

		if ok then
			return name
		end
	end

	local parameters = self:JukeboxItemParameters(item)

	return parameters and parameters.name
end

function ModOptionsSearchFilter:JukeboxItemParameters(item)
	if item and type(item.parameters) == "function" then
		local ok, parameters = pcall(function()
			return item:parameters()
		end)

		if ok and type(parameters) == "table" then
			return parameters
		end
	end

	return nil
end

function ModOptionsSearchFilter:JukeboxItemValue(item)
	if item and type(item.value) == "function" then
		local ok, value = pcall(function()
			return item:value()
		end)

		if ok then
			return value
		end
	end

	local parameters = self:JukeboxItemParameters(item)

	return parameters and parameters.value
end

function ModOptionsSearchFilter:SetJukeboxItemValue(item, value)
	if item and type(item.set_value) == "function" then
		local ok = pcall(function()
			item:set_value(value)
		end)

		return ok == true
	end

	return false
end

function ModOptionsSearchFilter:JukeboxNodeItem(node, item_name)
	if not node or not item_name or type(node.item) ~= "function" then
		return nil
	end

	local ok, item = pcall(function()
		return node:item(item_name)
	end)

	if ok then
		return item
	end

	return nil
end

function ModOptionsSearchFilter:JukeboxTrackList(method_name)
	local music = managers and managers.music

	if not music or type(music[method_name]) ~= "function" then
		return {}
	end

	local ok, tracks = pcall(function()
		return music[method_name](music)
	end)

	if ok and type(tracks) == "table" then
		return tracks
	end

	return {}
end

function ModOptionsSearchFilter:IsJukeboxPlaylistEmpty(track_list)
	local node = self:ActiveMenuNode()

	for _, track_name in pairs(track_list or {}) do
		if self:JukeboxItemValue(self:JukeboxNodeItem(node, track_name)) == "on" then
			return false
		end
	end

	return true
end

function ModOptionsSearchFilter:ClearJukeboxNodeIcons()
	for _, node_item in pairs(self:GetNodeItems(self:ActiveMenuNode())) do
		self:SafeSetRenderedItemIconVisible(node_item, false)
	end
end

function ModOptionsSearchFilter:JukeboxSettingChanged()
	if managers and managers.savefile and type(managers.savefile.setting_changed) == "function" then
		managers.savefile:setting_changed()
	end
end

function ModOptionsSearchFilter:JukeboxMusicCall(method_name, ...)
	local music = managers and managers.music

	if music and type(music[method_name]) == "function" then
		return music[method_name](music, ...)
	end

	return nil
end

function ModOptionsSearchFilter:JukeboxOptionHeistTracks(item)
	local track = self:JukeboxItemValue(item)
	local parameters = self:JukeboxItemParameters(item) or {}
	local job = parameters.heist_job

	if job == "escape" then
		self:JukeboxMusicCall("track_attachment_add", job, track)
	else
		local job_tweak = tweak_data and tweak_data.narrative and tweak_data.narrative.jobs and tweak_data.narrative.jobs[job]

		if not job_tweak then
			return
		end

		local day = parameters.heist_days or ""

		self:JukeboxMusicCall("track_attachment_add", job_tweak.name_id .. day, track)
	end

	self:ClearJukeboxNodeIcons()

	if track ~= "all" and track ~= "playlist" then
		self:JukeboxMusicCall("track_listen_start", "music_heist_assault", track)
		self:SafeSetItemIconVisible(item, true)
	else
		self:JukeboxMusicCall("track_listen_stop")
	end

	self:JukeboxSettingChanged()
end

function ModOptionsSearchFilter:JukeboxOptionHeistPlaylist(item)
	local empty_list = self:IsJukeboxPlaylistEmpty(self:JukeboxTrackList("jukebox_music_tracks"))

	self:ClearJukeboxNodeIcons()

	if empty_list then
		self:SetJukeboxItemValue(item, "on")
	elseif self:JukeboxItemValue(item) == "on" then
		local name = self:JukeboxItemName(item)

		self:JukeboxMusicCall("playlist_add", name)
		self:JukeboxMusicCall("track_listen_start", "music_heist_assault", name)
		self:SafeSetItemIconVisible(item, true)
		self:JukeboxSettingChanged()
	else
		self:JukeboxMusicCall("playlist_remove", self:JukeboxItemName(item))
		self:JukeboxMusicCall("track_listen_stop")
		self:JukeboxSettingChanged()
	end
end

function ModOptionsSearchFilter:JukeboxOptionMenuPlaylist(item)
	local empty_list = self:IsJukeboxPlaylistEmpty(self:JukeboxTrackList("jukebox_menu_tracks"))

	self:ClearJukeboxNodeIcons()

	if empty_list then
		self:SetJukeboxItemValue(item, "on")
	elseif self:JukeboxItemValue(item) == "on" then
		local name = self:JukeboxItemName(item)

		self:JukeboxMusicCall("playlist_menu_add", name)
		self:JukeboxMusicCall("track_listen_start", name)
		self:SafeSetItemIconVisible(item, true)
		self:JukeboxSettingChanged()
	else
		self:JukeboxMusicCall("playlist_menu_remove", self:JukeboxItemName(item))
		self:JukeboxMusicCall("track_listen_stop")
		self:JukeboxSettingChanged()
	end
end

function ModOptionsSearchFilter:PatchJukeboxPlaylistCallback(callback_name, handler_name)
	if not MenuCallbackHandler or type(MenuCallbackHandler[callback_name]) ~= "function" then
		return false
	end

	local patch_flag = "_mod_options_search_jukebox_callback_patched_" .. callback_name

	if MenuCallbackHandler[patch_flag] == CALLBACK_PATCH_VERSION then
		return true
	end

	MenuCallbackHandler[patch_flag] = CALLBACK_PATCH_VERSION
	MenuCallbackHandler[callback_name] = function(callback_self, item, ...)
		return ModOptionsSearchFilter[handler_name](ModOptionsSearchFilter, item)
	end

	return true
end

function ModOptionsSearchFilter:PatchJukeboxPlaylistCallbacks()
	local patched = false

	for _, callback_patch in ipairs(CALLBACK_PATCHES) do
		patched = self:PatchJukeboxPlaylistCallback(callback_patch.callback_name, callback_patch.handler_name) or patched
	end

	return patched
end

function ModOptionsSearchFilter:RegisterJukeboxMenuCallbacks()
	if not MenuCallbackHandler then
		return false
	end

	MenuCallbackHandler[self.CALLBACKS.open_jukebox_heist_playlist_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "jukebox_heist_playlist")
	end

	MenuCallbackHandler[self.CALLBACKS.open_jukebox_heist_tracks_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "jukebox_heist_tracks")
	end

	MenuCallbackHandler[self.CALLBACKS.open_jukebox_menu_playlist_search] = function(_, item)
		return ModOptionsSearchFilter:OpenSearch(item, "jukebox_menu_playlist")
	end

	self:PatchJukeboxPlaylistCallbacks()

	return true
end

function ModOptionsSearchFilter:MarkJukeboxNode(node, context_key)
	if not node or not context_key then
		return false
	end

	node[self.JUKEBOX_CONTEXT_MARKER] = context_key

	local parameters = self:GetNodeParameters(node)

	if type(parameters) == "table" then
		parameters[self.JUKEBOX_CONTEXT_MARKER] = context_key
	end

	return true
end

function ModOptionsSearchFilter:PrepareJukeboxNode(node, context_key)
	local context = self:SearchContext(context_key)

	if not node or not context then
		return false
	end

	self:MarkJukeboxNode(node, context_key)

	return self:PrepareNode({
		name = context.menu_id,
		node = node
	}, node)
end

function ModOptionsSearchFilter:PatchJukeboxInitiator(class_name, context_key)
	local initiator = rawget(_G, class_name)

	if type(initiator) ~= "table" or type(initiator.modify_node) ~= "function" then
		return false
	end

	local patch_flag = "_mod_options_search_jukebox_patched_" .. context_key

	if initiator[patch_flag] then
		return true
	end

	local original_modify_node = initiator.modify_node

	initiator[patch_flag] = true
	initiator.modify_node = function(initiator_self, node, ...)
		local result = original_modify_node(initiator_self, node, ...)
		local target_node = result or node

		ModOptionsSearchFilter:PrepareJukeboxNode(target_node, context_key)

		return result
	end

	return true
end

function ModOptionsSearchFilter:RegisterJukeboxMenuHooks()
	local registered = false

	for _, patch in ipairs(PATCHES) do
		registered = self:PatchJukeboxInitiator(patch.class_name, patch.context_key) or registered
	end

	return registered
end

return ModOptionsSearchFilter
