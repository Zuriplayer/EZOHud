EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local function OnAddonLoaded(_, addonName)
    if addonName ~= EZO_HUD.ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EZO_HUD.EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    if EZO_HUD.Initialize == nil then
        return
    end

    EZO_HUD:Initialize()
end

EVENT_MANAGER:RegisterForEvent(EZOhud.EVENT_NAMESPACE or "EZOhud_Core", EVENT_ADD_ON_LOADED, OnAddonLoaded)
