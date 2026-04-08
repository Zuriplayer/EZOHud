EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

EZO_HUD.ADDON_NAME = "EZOhud"
EZO_HUD.ADDON_VERSION = "0.1.0"
EZO_HUD.AUTHOR = "@Zuriplayer"

EZO_HUD.defaults = {
    general = {
        language = "en",
    },
    overlay = {
        enabled = true,
        hideVanillaAttributes = false,
        style = "cone",
        atlasMode = "production",
        outOfCombatAlpha = 0.85,
        locked = false,
        centerOffsetY = 280,
        healthWidth = 240,
        sideWidth = 180,
        barHeight = 18,
        sideRise = 26,
        centerGap = 96,
        x = nil,
        y = nil,
    },
}

local function ResolveLocale()
    local language = GetCVar and zo_strlower(tostring(GetCVar("Language.2") or ""))
    if language == "es" or language == "en" then
        return language
    end

    return "en"
end

function EZO_HUD:Initialize()
    self.defaultLanguage = ResolveLocale()
    self.defaults.general.language = self.defaultLanguage

    if self.InitializeSavedVariables ~= nil then
        self:InitializeSavedVariables()
    end

    if EZOHUD_Lang and EZOHUD_Lang.Apply then
        EZOHUD_Lang.Apply((self.sv and self.sv.general and self.sv.general.language) or self.defaultLanguage)
    end

    if self.InitializeUI ~= nil then
        self:InitializeUI()
    end

    if self.InitializeOverlay ~= nil then
        self:InitializeOverlay()
    end

    if self.InitializeSettings ~= nil then
        self:InitializeSettings()
    end

    if self.Print then
        self.Print(GetString(EZO_HUD_MSG_INIT))
    end
end
