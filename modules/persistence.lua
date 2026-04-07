EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

function EZO_HUD:InitializeSavedVariables()
    local world = GetWorldName()
    self.sv = ZO_SavedVars:NewAccountWide("EZOhud_Saved", 1, world, self.defaults)
end
