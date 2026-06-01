_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

function ModOptionsSearchFilter:RegisterMenuCallbacks()
	local registered = false

	if self.RegisterBltMenuCallbacks then
		registered = self:RegisterBltMenuCallbacks() or registered
	end

	if self.RegisterModOverridesMenuCallbacks then
		registered = self:RegisterModOverridesMenuCallbacks() or registered
	end

	return registered
end

function ModOptionsSearchFilter:RegisterMenuHooks()
	local registered = false

	if self.RegisterBltMenuHooks then
		registered = self:RegisterBltMenuHooks() or registered
	end

	return registered
end

function ModOptionsSearchFilter:Install()
	self:InitializeSearchState()
	self:RegisterMenuCallbacks()
	self:RegisterMenuHooks()
	self:SetupInlineInput("mod_options")
	self:InstallMenuNodeGuiPatch()
	self:InstallMenuModInfoGuiPatch()
	self:InstallModMenuCreatorPatch()
	self:InstallMenuInputPatch()

	return self
end

return ModOptionsSearchFilter
