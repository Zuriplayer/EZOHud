EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local function RegisterWithEZOBindings()
    if not (EZOBindings and type(EZOBindings.RegisterAddon) == "function") then
        return
    end

    EZOBindings:RegisterAddon(EZO_HUD.ADDON_NAME or "EZOhud", {
        version = 1,
        actions = {},
    })
end

EZO_HUD.ADDON_NAME = "EZOhud"
EZO_HUD.ADDON_VERSION = "0.1.0"
EZO_HUD.AUTHOR = "@Zuriplayer"

EZO_HUD.defaults = {
    general = {
        language = "en",
        debugEnabled = false,
        debugToChat = false,
    },
    overlay = {
        enabled = true,
        hideVanillaAttributes = false,
        movable = false,
        outOfCombatAlpha = 0.85,
        locked = false,
        centerOffsetY = 120,
        healthShape = "circular",
        staminaShape = "circular",
        magickaShape = "circular",
        healthSize = 120,
        staminaSize = 104,
        magickaSize = 104,
        healthAlertThreshold = 35,
        staminaAlertThreshold = 25,
        magickaAlertThreshold = 25,
        healthColor = { r = 0.82, g = 0.18, b = 0.22, a = 1.0 },
        staminaColor = { r = 0.21, g = 0.67, b = 0.29, a = 1.0 },
        magickaColor = { r = 0.22, g = 0.46, b = 0.88, a = 1.0 },
        staminaRadialClockwise = true,
        staminaRadialOriginAngle = -1.5708,
        healthOffsetX = 0,
        healthOffsetY = 140,
        staminaOffsetX = -150,
        staminaOffsetY = 155,
        magickaOffsetX = 150,
        magickaOffsetY = 155,
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

    if self.InitializeDebug ~= nil then
        self:InitializeDebug()
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

    RegisterWithEZOBindings()
end
