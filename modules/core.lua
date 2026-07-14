EZOhud = EZOhud or {}
local EZO_HUD = EZOhud
local LANGUAGE_INHERIT = "inherit"
local LANGUAGE_AUTO = "auto"
local MOVE_MODE_SECTIONS = { "overlay", "ultimate", "execute", "crux" }
local languageCallbackRegistered = false

EZO_HUD.ADDON_NAME = "EZOhud"
EZO_HUD.ADDON_VERSION = "0.1.48"
EZO_HUD.AUTHOR = "@Zuriplayer"
EZO_HUD.LANGUAGE_INHERIT = LANGUAGE_INHERIT
EZO_HUD.LANGUAGE_AUTO = LANGUAGE_AUTO

EZO_HUD.defaults = {
    general = {
        language = LANGUAGE_INHERIT,
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
        hudOffsetX = 0,
        hudOffsetY = 170,
        healthSize = 220,
        staminaSize = 180,
        magickaSize = 180,
        healthWarningPercent = 35,
        staminaWarningPercent = 20,
        magickaWarningPercent = 20,
        healthColor = { r = 0.82, g = 0.18, b = 0.22, a = 1.0 },
        staminaColor = { r = 0.21, g = 0.67, b = 0.29, a = 1.0 },
        magickaColor = { r = 0.22, g = 0.46, b = 0.88, a = 1.0 },
        healthOffsetX = 0,
        healthOffsetY = 170,
        staminaOffsetX = 94,
        staminaOffsetY = 192,
        magickaOffsetX = -94,
        magickaOffsetY = 192,
    },
    ultimate = {
        enabled = true,
        movable = false,
        displayMode = "both",
        size = 54,
        mainOffsetX = -70,
        mainOffsetY = 265,
        backupOffsetX = 70,
        backupOffsetY = 265,
    },
    execute = {
        enabled = true,
        movable = false,
        mode = "active",
        size = 42,
        offsetX = 0,
        offsetY = 80,
    },
    crux = {
        enabled = true,
        movable = false,
        hideWhenZero = true,
        size = 58,
        barGap = 1,
        offsetX = 0,
        offsetY = 95,
    },
}

local function GetClientLanguage()
    if type(GetCVar) == "function" then
        local language = zo_strlower(tostring(GetCVar("Language.2") or ""))
        local prefix = language:sub(1, 2)
        if prefix == "es" then
            return "es"
        end
        if prefix == "en" then
            return "en"
        end
    end

    return "en"
end

function EZO_HUD.GetDefaultLanguage()
    return LANGUAGE_INHERIT
end

function EZO_HUD.GetClientLanguage()
    return GetClientLanguage()
end

function EZO_HUD.GetEffectiveLanguage(language)
    language = tostring(language or EZO_HUD.GetDefaultLanguage())
    if language == LANGUAGE_INHERIT then
        if EZOCore and type(EZOCore.GetLanguage) == "function" then
            local ok, inherited = pcall(function()
                return EZOCore:GetLanguage()
            end)
            if ok and (inherited == "es" or inherited == "en") then
                return inherited
            end
        end
        return GetClientLanguage()
    end
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function EZO_HUD.IsForcedLanguage(language)
    language = tostring(language or EZO_HUD.GetDefaultLanguage())
    return language == "es" or language == "en"
end

function EZO_HUD:ApplyLanguagePreference(language)
    local configuredLanguage = tostring(language or self.GetDefaultLanguage())
    if EZOHUD_Lang and EZOHUD_Lang.Apply then
        EZOHUD_Lang.Apply(configuredLanguage)
    end
end

function EZO_HUD:RegisterEZOCoreLanguageCallback()
    if languageCallbackRegistered
        or not (EZOCore and type(EZOCore.RegisterCallback) == "function") then
        return false
    end

    local eventName = EZOCore.EVENT_LANGUAGE_CHANGED or "EZO_CORE_LANGUAGE_CHANGED"
    local ok, result = pcall(function()
        return EZOCore:RegisterCallback(eventName, function()
            if self.sv and self.sv.general and self.sv.general.language == LANGUAGE_INHERIT then
                self:ApplyLanguagePreference(LANGUAGE_INHERIT)
                if self.RefreshOverlayText then
                    self:RefreshOverlayText()
                end
                if self.RefreshUltimateText then
                    self:RefreshUltimateText()
                end
                if self.ApplyOverlayLayout then
                    self:ApplyOverlayLayout()
                end
            end
        end)
    end)
    languageCallbackRegistered = ok and result == true
    return languageCallbackRegistered
end

function EZO_HUD:InitializeRuntimeState()
    self.runtime = self.runtime or {}
    self.runtime.moveMode = self.runtime.moveMode or {}

    for _, sectionName in ipairs(MOVE_MODE_SECTIONS) do
        self.runtime.moveMode[sectionName] = false
        if self.sv and self.sv[sectionName] then
            self.sv[sectionName].movable = false
        end
    end
end

function EZO_HUD:IsMoveModeEnabled(sectionName)
    return self.runtime
        and self.runtime.moveMode
        and self.runtime.moveMode[sectionName] == true
end

function EZO_HUD:SetMoveModeEnabled(sectionName, enabled)
    self.runtime = self.runtime or {}
    self.runtime.moveMode = self.runtime.moveMode or {}
    self.runtime.moveMode[sectionName] = enabled == true

    if self.sv and self.sv[sectionName] then
        self.sv[sectionName].movable = false
    end
end

function EZO_HUD:Initialize()
    self.defaultLanguage = LANGUAGE_INHERIT

    if self.InitializeSavedVariables ~= nil then
        self:InitializeSavedVariables()
    end

    self:InitializeRuntimeState()

    self:ApplyLanguagePreference((self.sv and self.sv.general and self.sv.general.language) or self.defaultLanguage)
    self:RegisterEZOCoreLanguageCallback()

    if self.InitializeDebug ~= nil then
        self:InitializeDebug()
    end

    if self.InitializeCruxDebug ~= nil then
        self:InitializeCruxDebug()
    end

    if self.InitializeUI ~= nil then
        self:InitializeUI()
    end

    if self.InitializeHudVisibility ~= nil then
        self:InitializeHudVisibility()
    end

    if self.InitializeOverlay ~= nil then
        self:InitializeOverlay()
    end

    if self.InitializeUltimate ~= nil then
        self:InitializeUltimate()
    end

    if self.InitializeExecute ~= nil then
        self:InitializeExecute()
    end

    if self.InitializeCrux ~= nil then
        self:InitializeCrux()
    end

    if self.InitializeSettings ~= nil then
        self:InitializeSettings()
    end

    if self.Print then
        self.Print(GetString(EZO_HUD_MSG_INIT))
    end

end
