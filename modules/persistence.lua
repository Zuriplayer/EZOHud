EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

function EZO_HUD:InitializeSavedVariables()
    self.savedVariables = ZO_SavedVars:NewAccountWide("EZOhud_Saved", 1, nil, self.DEFAULTS)
end
