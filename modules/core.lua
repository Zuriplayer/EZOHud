EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

EZO_HUD.ADDON_NAME = "EZOhud"
EZO_HUD.EVENT_NAMESPACE = "EZOhud_Core"
EZO_HUD.DEFAULTS = {
    unlocked = true,
}

local function ResolveLocale()
    local language = GetCVar and GetCVar("Language.2")
    if language == "es" then
        return "es"
    end

    return "en"
end

function EZO_HUD:Initialize()
    self.locale = ResolveLocale()
    self.strings = (self.Strings and self.Strings[self.locale]) or (self.Strings and self.Strings.en) or {}

    if self.InitializeSavedVariables ~= nil then
        self:InitializeSavedVariables()
    end

    if self.InitializeUI ~= nil then
        self:InitializeUI()
    end
end
