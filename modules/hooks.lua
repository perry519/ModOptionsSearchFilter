_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter
local MENU_INPUT_PATCH_VERSION = 3

local function item_name(item)
	local parameters = item and item.parameters and item:parameters() or item and item._parameters

	return parameters and parameters.name
end

local function row_name(row_item)
	return row_item and (row_item.name or item_name(row_item.item))
end

local function row_parameters(row_item)
	local item = row_item and row_item.item

	return item and item.parameters and item:parameters() or item and item._parameters or {}
end

local function is_back_row(row_item)
	local parameters = row_parameters(row_item)

	return parameters.back == true or row_name(row_item) == "back"
end

local function panel_number(panel, method)
	if panel and panel[method] then
		local ok, value = pcall(function()
			return panel[method](panel)
		end)

		if ok and type(value) == "number" then
			return value
		end
	end

	return nil
end

local function row_position(row_item, order)
	local panel = row_item and row_item.gui_panel
	local position = row_item and row_item.position
	local y = panel_number(panel, "world_y") or panel_number(panel, "y") or position and position.y or order
	local x = panel_number(panel, "world_x") or panel_number(panel, "x") or position and position.x or order

	return y, x
end

function ModOptionsSearchFilter:AutofocusNode(node_gui)
	self:InstallMenuInputPatch()

	local library = self:GetInlineInputLibrary()

	if not library or not library.GetNodeName then
		return false
	end

	if library:GetNodeName(node_gui) ~= self.MENU_ID then
		return false
	end

	if node_gui._mod_options_search_autofocused then
		return false
	end

	node_gui._mod_options_search_autofocused = true

	local focused = self:FocusSearch(node_gui)

	return focused
end

function ModOptionsSearchFilter:InstallMenuNodeGuiPatch()
	if not MenuNodeGui or MenuNodeGui._mod_options_search_setup_item_rows_patched then
		return false
	end

	MenuNodeGui._mod_options_search_setup_item_rows_patched = true

	local original_setup_item_rows = MenuNodeGui._setup_item_rows

	function MenuNodeGui:_setup_item_rows(node, ...)
		ModOptionsSearchFilter:PrepareNode(self, node)

		local result = original_setup_item_rows and original_setup_item_rows(self, node, ...)

		ModOptionsSearchFilter:AutofocusNode(self)

		return result
	end

	return true
end

function ModOptionsSearchFilter:IsSearchInputFocused(node_gui)
	local library = self:GetInlineInputLibrary()

	if library and library.FocusedInputBox then
		local ok, config = pcall(function()
			return library:FocusedInputBox(node_gui)
		end)

		if ok and config and config.id == self.INPUT_ID then
			return true
		end
	end

	local handle = self:GetSearchInputHandle()
	if handle and handle.input_focus then
		local ok, focused = pcall(function()
			return handle:input_focus(node_gui)
		end)

		return ok and focused == true
	end

	return false
end

function ModOptionsSearchFilter:NavigationRows(node_gui)
	local entries = {}
	local back_entries = {}

	for _, row_item in ipairs(node_gui and node_gui.row_items or {}) do
		local item = row_item.item

		if item and item.visible and item:visible() and not item.no_select and row_name(row_item) then
			local order = #entries + 1
			local y, x = row_position(row_item, order)

			table.insert(entries, {
				row_item = row_item,
				order = order,
				x = x,
				y = y
			})
		end
	end

	for index = #entries, 1, -1 do
		if is_back_row(entries[index].row_item) then
			table.insert(back_entries, 1, table.remove(entries, index))
		end
	end

	table.sort(entries, function(a, b)
		if a.y ~= b.y then
			return a.y < b.y
		end

		if a.x ~= b.x then
			return a.x < b.x
		end

		return a.order < b.order
	end)

	local rows = {}

	for _, entry in ipairs(entries) do
		table.insert(rows, entry.row_item)
	end

	for _, entry in ipairs(back_entries) do
		table.insert(rows, entry.row_item)
	end

	return rows
end

function ModOptionsSearchFilter:SearchRowIndex(rows)
	for index, row_item in ipairs(rows or {}) do
		if row_name(row_item) == self.INPUT_ID then
			return index
		end
	end

	return nil
end

function ModOptionsSearchFilter:HighlightedRowIndex(rows)
	for index, row_item in ipairs(rows or {}) do
		if row_item.highlighted then
			return index
		end
	end

	return nil
end

function ModOptionsSearchFilter:ItemRowIndex(rows, target_item)
	local target_name = item_name(target_item)
	if not target_name then
		return nil
	end

	for index, row_item in ipairs(rows or {}) do
		if row_name(row_item) == target_name then
			return index
		end
	end

	return nil
end

function ModOptionsSearchFilter:CurrentNavigationIndex(menu_input, node_gui, rows)
	if self:IsSearchInputFocused(node_gui) or node_gui._mod_options_search_input_navigation_active == true then
		return self:SearchRowIndex(rows)
	end

	local highlighted_index = self:HighlightedRowIndex(rows)
	if highlighted_index then
		return highlighted_index
	end

	local logic = menu_input and menu_input._logic
	local selected_item = logic and logic.selected_item and logic:selected_item()

	return self:ItemRowIndex(rows, selected_item)
end

function ModOptionsSearchFilter:FadeHighlightedRows(node_gui, target_name)
	for _, row_item in ipairs(node_gui and node_gui.row_items or {}) do
		if row_item.highlighted and row_name(row_item) ~= target_name then
			if node_gui.fade_item and row_item.item then
				node_gui:fade_item(row_item.item)
			else
				row_item.highlighted = false
			end
		end
	end
end

function ModOptionsSearchFilter:SelectNavigationItem(menu_input, node_gui, item)
	local target_name = item_name(item)
	if not target_name then
		return false
	end

	self:FadeHighlightedRows(node_gui, target_name)

	local logic = menu_input and menu_input._logic
	if logic and logic.select_item then
		logic:select_item(target_name, true)
	elseif node_gui.node and node_gui.node.select_item then
		node_gui.node:select_item(target_name)
	end

	if target_name == self.INPUT_ID then
		self:FocusSearch(node_gui)
	else
		self:BlurSearch(node_gui)
		node_gui._mod_options_search_input_navigation_active = false
	end

	return true
end

function ModOptionsSearchFilter:MoveSelection(menu_input, direction)
	local library = self:GetInlineInputLibrary()
	local node_gui = library and library.ActiveNodeGui and library:ActiveNodeGui()

	if not node_gui or self:GetNodeName(node_gui) ~= self.MENU_ID then
		return false
	end

	local rows = self:NavigationRows(node_gui)
	if #rows <= 1 then
		return false
	end

	local current_index = self:CurrentNavigationIndex(menu_input, node_gui, rows)
	if not current_index then
		return false
	end

	local target_index = ((current_index + direction - 1) % #rows) + 1

	return self:SelectNavigationItem(menu_input, node_gui, rows[target_index].item)
end

function ModOptionsSearchFilter:MoveDownFromSearch(menu_input)
	return self:MoveSelection(menu_input, 1)
end

function ModOptionsSearchFilter:MoveUpToSearch(menu_input)
	return self:MoveSelection(menu_input, -1)
end

function ModOptionsSearchFilter:InstallMenuInputPatch()
	if not MenuInput then
		return false
	end

	if MenuInput._mod_options_search_menu_input_patch_version == MENU_INPUT_PATCH_VERSION then
		return true
	end

	MenuInput._mod_options_search_menu_input_patch_version = MENU_INPUT_PATCH_VERSION
	MenuInput._mod_options_search_next_item_patched = true

	local original_next_item = MenuInput.next_item
	local original_prev_item = MenuInput.prev_item

	function MenuInput:next_item(...)
		if ModOptionsSearchFilter:MoveDownFromSearch(self) then
			return
		end

		return original_next_item and original_next_item(self, ...)
	end

	function MenuInput:prev_item(...)
		if ModOptionsSearchFilter:MoveUpToSearch(self) then
			return
		end

		return original_prev_item and original_prev_item(self, ...)
	end

	return true
end

return ModOptionsSearchFilter
