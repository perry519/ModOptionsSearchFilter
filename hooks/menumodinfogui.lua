_G.ModOptionsSearchFilter = _G.ModOptionsSearchFilter or {}

dofile((ModPath or "ModOptionsSearchFilter/") .. "modoptionssearchfilter.lua")

local ModOptionsSearchFilter = _G.ModOptionsSearchFilter

ModOptionsSearchFilter:Install()
ModOptionsSearchFilter:InstallMenuModInfoGuiPatch()
