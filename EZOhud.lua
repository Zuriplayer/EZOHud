EZOhud = EZOhud or {}
local EZO_HUD = EZOhud
local ADDON_NAME = "EZOhud"

local function safeChat(message)
    if LibChatMessage then
        LibChatMessage(ADDON_NAME, "EZO"):Print(tostring(message))
    else
        d(tostring(message))
    end
end

EZO_HUD.Print = safeChat

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    if EZO_HUD.Initialize == nil then
        return
    end

    EZO_HUD:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
