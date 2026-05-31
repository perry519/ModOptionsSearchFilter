_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:Install()
	self.search_text = self.search_text or ""

	self:RegisterMenuCallbacks()
	self:RegisterMenuHooks()
	self:SetupInlineInput()
	self:InstallMenuNodeGuiPatch()
	self:InstallMenuInputPatch()

	return self
end

return ModOptionsSearchFilter
