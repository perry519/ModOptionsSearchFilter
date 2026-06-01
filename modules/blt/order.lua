_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter
local BLT_OPTIONS_MODIFIER_CLASS = "ModOptionsSearchFilterBltOptionsInitiator"
local BLT_OPTIONS_MODIFIER_MARKER = "_mod_options_search_order_modifier_declared"

local function has_callback_name(value, callback_name)
	for name in string.gmatch(tostring(value or ""), "%S+") do
		if name == callback_name then
			return true
		end
	end

	return false
end

local function append_callback_name(node, field, callback_name)
	if type(node) ~= "table" or has_callback_name(node[field], callback_name) then
		return false
	end

	if type(node[field]) == "string" and node[field] ~= "" then
		node[field] = node[field] .. " " .. callback_name
	else
		node[field] = callback_name
	end

	return true
end

function ModOptionsSearchFilter:PlaceBltSearchItemFirst(node)
	self:SetupInlineInput("mod_options")
	self:EnsureRuntimeSearchItem(node, "mod_options")

	return node
end

function ModOptionsSearchFilter:InstallBltOptionsModifierClass()
	if _G[BLT_OPTIONS_MODIFIER_CLASS] and _G[BLT_OPTIONS_MODIFIER_CLASS].modify_node then
		return _G[BLT_OPTIONS_MODIFIER_CLASS]
	end

	if type(class) ~= "function" then
		return nil
	end

	local modifier_class = class(MenuInitiatorBase)

	function modifier_class:modify_node(node)
		return ModOptionsSearchFilter:PlaceBltSearchItemFirst(node)
	end

	function modifier_class:refresh_node(node)
		return self:modify_node(node)
	end

	_G[BLT_OPTIONS_MODIFIER_CLASS] = modifier_class

	return modifier_class
end

function ModOptionsSearchFilter:EnsureBltOptionsRawModifier(options_node)
	if type(options_node) ~= "table" or not self:InstallBltOptionsModifierClass() then
		return false
	end

	local changed = append_callback_name(options_node, "modifier", BLT_OPTIONS_MODIFIER_CLASS)
	changed = append_callback_name(options_node, "refresh", BLT_OPTIONS_MODIFIER_CLASS) or changed

	if changed or has_callback_name(options_node.modifier, BLT_OPTIONS_MODIFIER_CLASS) then
		options_node[BLT_OPTIONS_MODIFIER_MARKER] = true
	end

	return changed
end

function ModOptionsSearchFilter:EnsureBltOptionsRuntimeModifier(node)
	if not node then
		return false
	end

	local parameters = self:GetNodeParameters(node)

	if parameters[BLT_OPTIONS_MODIFIER_MARKER] then
		return false
	end

	if type(parameters.modifier) ~= "table" or parameters._mod_options_search_modifier_added then
		return false
	end

	table.insert(parameters.modifier, function(target_node)
		return ModOptionsSearchFilter:PlaceBltSearchItemFirst(target_node)
	end)

	parameters._mod_options_search_modifier_added = true

	return true
end

return ModOptionsSearchFilter
