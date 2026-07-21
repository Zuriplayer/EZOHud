EZOhud = EZOhud or {}
local EZO_HUD = EZOhud
local LANGUAGE_INHERIT = "inherit"
local LANGUAGE_AUTO = "auto"
local MOVE_MODE_SECTIONS = { "overlay", "ultimate", "execute", "crux", "customSynergy", "customLoot" }
local languageCallbackRegistered = false
local ezocoreRegistered = false
local layoutSurfacesRegistered = false
local debugControllerRegistered = false

EZO_HUD.ADDON_NAME = "EZOhud"
EZO_HUD.ADDON_VERSION = "0.1.82"
EZO_HUD.AUTHOR = "@Zuriplayer"
EZO_HUD.LANGUAGE_INHERIT = LANGUAGE_INHERIT
EZO_HUD.LANGUAGE_AUTO = LANGUAGE_AUTO

EZO_HUD.defaults = {
    general = {
        language = LANGUAGE_AUTO,
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
    nativeQuestTracker = {
        enabled = false,
        offsetX = -40,
        offsetY = 120,
        scale = 1.0,
    },
    nativeCenterScreen = {
        enabled = false,
        offsetX = 0,
        offsetY = 150,
        scale = 1.0,
    },
    nativeLootHistoryKeyboard = {
        enabled = false,
        offsetX = 0,
        offsetY = -84,
        scale = 1.0,
    },
    nativeLootHistoryGamepad = {
        enabled = false,
        offsetX = 0,
        offsetY = -120,
        scale = 1.0,
    },
    customSynergy = {
        enabled = false,
        movable = false,
        offsetX = 0,
        offsetY = 150,
        size = 50,
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
    return LANGUAGE_AUTO
end

function EZO_HUD.GetClientLanguage()
    return GetClientLanguage()
end

function EZO_HUD.GetEffectiveLanguage(language)
    language = tostring(language or EZO_HUD.GetDefaultLanguage())
    if EZO_HUD.IsLanguageManagedByEZOCore and EZO_HUD.IsLanguageManagedByEZOCore() then
        local ok, inherited = pcall(function()
            return EZOCore:GetLanguage()
        end)
        if ok and (inherited == "es" or inherited == "en") then
            return inherited
        end
    end
    if language == LANGUAGE_INHERIT then
        language = LANGUAGE_AUTO
    end
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function EZO_HUD.IsForcedLanguage(language)
    language = tostring(language or EZO_HUD.GetDefaultLanguage())
    if EZO_HUD.IsLanguageManagedByEZOCore and EZO_HUD.IsLanguageManagedByEZOCore() then
        return false
    end
    return language == "es" or language == "en"
end

function EZO_HUD.IsLanguageManagedByEZOCore()
    if not (EZOCore and type(EZOCore.IsLanguageGloballyManaged) == "function") then
        return false
    end
    local ok, managed = pcall(function()
        return EZOCore:IsLanguageGloballyManaged()
    end)
    return ok and managed == true
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
            if self.sv and self.sv.general then
                self:ApplyLanguagePreference(self.sv.general.language or self.GetDefaultLanguage())
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

function EZO_HUD:RegisterWithEZOCore()
    if ezocoreRegistered
        or not (EZOCore and type(EZOCore.RegisterAddon) == "function") then
        return false
    end

    local ok, result = pcall(function()
        return EZOCore:RegisterAddon({
            id = "ezohud",
            name = self.ADDON_NAME or "EZOhud",
            version = self.ADDON_VERSION or "0.0.0",
            addOnVersion = 10053,
            apiVersion = 1,
            capabilities = {
                "family.language.consumer",
                "family.debug.controller",
                "family.layout.consumer",
                "family.settings.consumer",
                "hud.attributes",
                "hud.visualOverlay",
            },
        })
    end)

    ezocoreRegistered = ok and result == true
    return ezocoreRegistered
end

function EZO_HUD:RegisterDebugWithEZOCore()
    if debugControllerRegistered
        or not (EZOCore and type(EZOCore.GetService) == "function") then
        return false
    end

    local service = EZOCore:GetService("family.debug", 1)
    if not service or type(service.RegisterController) ~= "function" then
        return false
    end

    local ok, result = pcall(function()
        return service:RegisterController({
            id = "ezohud.debug",
            addonId = "ezohud",
            addonName = "EZOhud",
            name = function() return GetString(EZO_HUD_OPTION_DEBUG_ENABLE) end,
            isEnabled = function()
                return (self.IsDebugModeEnabled and self:IsDebugModeEnabled())
                    or (self.IsCruxDebugEnabled and self:IsCruxDebugEnabled())
            end,
            setEnabled = function(enabled)
                if enabled == true then
                    return false
                end
                local generalDisabled = not self.SetDebugModeEnabled or self:SetDebugModeEnabled(false)
                local cruxDisabled = not self.SetCruxDebugEnabled or self:SetCruxDebugEnabled(false, true)
                return generalDisabled and cruxDisabled
            end,
        })
    end)

    debugControllerRegistered = ok and result == true
    return debugControllerRegistered
end

function EZO_HUD:RefreshMoveModeSection(sectionName)
    if sectionName == "overlay" then
        self:RefreshMovementState()
        self:RefreshOverlayVisibility()
    elseif sectionName == "ultimate" then
        self:RefreshUltimateMovementState()
        self:RefreshUltimateVisibility()
    elseif sectionName == "execute" then
        self:RefreshExecuteMovementState()
        self:RefreshExecute()
    elseif sectionName == "crux" then
        self:RefreshCruxMovementState()
        self:RefreshCruxDisplay()
    elseif sectionName == "customSynergy" then
        self:RefreshCustomSynergyMovementState()
        self:RefreshCustomSynergy()
    elseif sectionName == "customLoot" then
        self:RefreshCustomLootMovementState()
        if self.ApplyCustomLootLayout then
            self:ApplyCustomLootLayout()
        end
    end
end

function EZO_HUD:SetLayoutEditMode(sectionName, enabled)
    self:SetMoveModeEnabled(sectionName, enabled)
    self:RefreshMoveModeSection(sectionName)
    return self:IsMoveModeEnabled(sectionName)
end

function EZO_HUD:RegisterLayoutWithEZOCore()
    if layoutSurfacesRegistered
        or not (EZOCore and type(EZOCore.GetService) == "function") then
        return false
    end

    local service = EZOCore:GetService("family.layout", 1)
    if not service or type(service.RegisterSurface) ~= "function" then
        return false
    end

    local definitions = {
        { id = "ezohud.attributes", section = "overlay", order = 10, name = EZO_HUD_OPTION_MOVE_HUD, tooltip = EZO_HUD_OPTION_MOVE_HUD_TOOLTIP },
        { id = "ezohud.ultimate", section = "ultimate", order = 20, name = EZO_HUD_OPTION_ULTIMATE_MOVE, tooltip = EZO_HUD_OPTION_ULTIMATE_MOVE_TOOLTIP },
        { id = "ezohud.execute", section = "execute", order = 30, name = EZO_HUD_OPTION_EXECUTE_MOVE, tooltip = EZO_HUD_OPTION_EXECUTE_MOVE_TOOLTIP },
        { id = "ezohud.crux", section = "crux", order = 40, name = EZO_HUD_OPTION_CRUX_MOVE, tooltip = EZO_HUD_OPTION_CRUX_MOVE_TOOLTIP },
        { id = "ezohud.customSynergy", section = "customSynergy", order = 50, name = EZO_HUD_OPTION_CUSTOM_SYNERGY_MOVE, tooltip = EZO_HUD_OPTION_CUSTOM_SYNERGY_MOVE_TOOLTIP },
        { id = "ezohud.customLoot", section = "customLoot", order = 60, name = EZO_HUD_OPTION_CUSTOM_LOOT_MOVE, tooltip = EZO_HUD_OPTION_CUSTOM_LOOT_MOVE_TOOLTIP },
    }

    for _, definition in ipairs(definitions) do
        local sectionName = definition.section
        local nameStringId = definition.name
        local tooltipStringId = definition.tooltip
        local ok, result = pcall(function()
            return service:RegisterSurface({
                id = definition.id,
                addonId = "ezohud",
                addonName = "EZOhud",
                name = function() return GetString(nameStringId) end,
                tooltip = function() return GetString(tooltipStringId) end,
                sortOrder = definition.order,
                setEditMode = function(enabled)
                    self:SetLayoutEditMode(sectionName, enabled)
                    return self:IsMoveModeEnabled(sectionName) == (enabled == true)
                end,
                isEditMode = function()
                    return self:IsMoveModeEnabled(sectionName)
                end,
            })
        end)
        if not ok or result ~= true then
            return false
        end
    end

    layoutSurfacesRegistered = true
    return true
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

function EZO_HUD:SaveMoveModeSectionPosition(sectionName)
    if sectionName == "overlay" and self.SaveHudPosition then
        self:SaveHudPosition()
    elseif sectionName == "ultimate" and self.ultimate and self.SaveUltimatePosition then
        self:SaveUltimatePosition("main")
        self:SaveUltimatePosition("backup")
    elseif sectionName == "execute" and self.SaveExecutePosition then
        self:SaveExecutePosition()
    elseif sectionName == "crux" and self.SaveCruxPosition then
        self:SaveCruxPosition()
    elseif sectionName == "customSynergy" and self.SaveCustomSynergyPosition then
        self:SaveCustomSynergyPosition()
    elseif sectionName == "customLoot" and self.SaveCustomLootPosition then
        self:SaveCustomLootPosition()
    end
end

function EZO_HUD:SetMoveModeEnabled(sectionName, enabled)
    self.runtime = self.runtime or {}
    self.runtime.moveMode = self.runtime.moveMode or {}

    if self.runtime.moveMode[sectionName] == true and enabled ~= true then
        self:SaveMoveModeSectionPosition(sectionName)
    end

    self.runtime.moveMode[sectionName] = enabled == true

    if self.sv and self.sv[sectionName] then
        self.sv[sectionName].movable = false
    end
end

function EZO_HUD:Initialize()
    self.defaultLanguage = LANGUAGE_AUTO

    if self.InitializeSavedVariables ~= nil then
        self:InitializeSavedVariables()
    end

    self:InitializeRuntimeState()

    self:ApplyLanguagePreference((self.sv and self.sv.general and self.sv.general.language) or self.defaultLanguage)
    self:RegisterEZOCoreLanguageCallback()
    self:RegisterWithEZOCore()

    if self.InitializeDebug ~= nil then
        self:InitializeDebug()
    end

    if self.InitializeCruxDebug ~= nil then
        self:InitializeCruxDebug()
    end
    self:RegisterDebugWithEZOCore()

    if self.InitializeUI ~= nil then
        self:InitializeUI()
    end

    if self.InitializeHudVisibility ~= nil then
        self:InitializeHudVisibility()
    end

    if self.InitializeNativeWidgets ~= nil then
        self:InitializeNativeWidgets()
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

    if self.InitializeCustomSynergy ~= nil then
        self:InitializeCustomSynergy()
    end

    if self.InitializeCustomLoot ~= nil then
        self:InitializeCustomLoot()
    end

    self:RegisterLayoutWithEZOCore()

    if self.InitializeSettings ~= nil then
        self:InitializeSettings()
    end

    if self.Print then
        self.Print(GetString(EZO_HUD_MSG_INIT))
    end

end
