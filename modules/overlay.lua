EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local BAR_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local NORMAL_TEXT_COLOR = { 0.98, 0.98, 0.98, 0.96 }
local DOMINANCE_MIN_SCALE = 0.82
local TEXT_INSET = 12
local SIDE_GAP = 6
local ROW_GAP = 10
local LEGACY_RESOURCE_LAYER_SUFFIXES = { "_Shadow", "_Frame", "_Background", "_Alert" }

local RESOURCE_ORDER = { "health", "magicka", "stamina" }
local RESOURCE_META = {
    health = {
        powerType = POWERTYPE_HEALTH,
        labelString = "EZO_HUD_PREVIEW_HEALTH",
        sizeKey = "healthSize",
        colorKey = "healthColor",
        offsetXKey = "healthOffsetX",
        offsetYKey = "healthOffsetY",
        minimumWidth = 190,
        barHeight = 24,
    },
    stamina = {
        powerType = POWERTYPE_STAMINA,
        labelString = "EZO_HUD_PREVIEW_STAMINA",
        sizeKey = "staminaSize",
        colorKey = "staminaColor",
        offsetXKey = "staminaOffsetX",
        offsetYKey = "staminaOffsetY",
        minimumWidth = 150,
        barHeight = 24,
    },
    magicka = {
        powerType = POWERTYPE_MAGICKA,
        labelString = "EZO_HUD_PREVIEW_MAGICKA",
        sizeKey = "magickaSize",
        colorKey = "magickaColor",
        offsetXKey = "magickaOffsetX",
        offsetYKey = "magickaOffsetY",
        minimumWidth = 150,
        barHeight = 24,
    },
}

local VANILLA_CONTROL_NAMES = {
    "ZO_PlayerAttributeHealth",
    "ZO_PlayerAttributeMagicka",
    "ZO_PlayerAttributeStamina",
    "ZO_PlayerAttributeBars",
    "ZO_PlayerAttribute",
}

local function Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function CopyColor(color)
    return {
        r = color.r,
        g = color.g,
        b = color.b,
        a = color.a or 1.0,
    }
end

local function DeepCopyTable(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = DeepCopyTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function CreateLabel(name, parent, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetColor(unpack(NORMAL_TEXT_COLOR))
    label:SetMouseEnabled(false)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function GetOutOfCombatAlpha()
    if not (EZO_HUD.sv and EZO_HUD.sv.overlay) then
        return 1
    end
    if IsUnitInCombat and IsUnitInCombat("player") then
        return 1
    end
    return EZO_HUD.sv.overlay.outOfCombatAlpha or 1
end

local function SetControlHiddenByName(controlName, hidden)
    local control = _G[controlName]
    if control and control.SetHidden then
        control:SetHidden(hidden)
    end
end

local function ConstrainColor(resourceName, r, g, b, a)
    if resourceName == "health" then
        local primary = Clamp(r, 0.45, 1.0)
        return primary, Clamp(g, 0.05, primary * 0.45), Clamp(b, 0.05, primary * 0.45), a or 1.0
    elseif resourceName == "stamina" then
        local primary = Clamp(g, 0.45, 1.0)
        return Clamp(r, 0.05, primary * 0.55), primary, Clamp(b, 0.05, primary * 0.55), a or 1.0
    end

    local primary = Clamp(b, 0.45, 1.0)
    return Clamp(r, 0.05, primary * 0.55), Clamp(g, 0.05, primary * 0.75), primary, a or 1.0
end

local function GetResourceColor(settings, resourceName)
    local color = settings[RESOURCE_META[resourceName].colorKey]
    if type(color) ~= "table" then
        return 1, 1, 1, 1
    end
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function GetHudGroupCenter(settings)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local centerX = (guiWidth / 2) + (settings.hudOffsetX or settings.healthOffsetX or 0)
    local centerY = (guiHeight / 2) + (settings.hudOffsetY or settings.healthOffsetY or 170)
    return centerX, centerY
end

local function GetAnchorFromCenter(centerX, centerY, width, height)
    return zo_floor(centerX - (width / 2)), zo_floor(centerY - (height / 2))
end

local function HideLegacyResourceLayers(rootName)
    for _, suffix in ipairs(LEGACY_RESOURCE_LAYER_SUFFIXES) do
        local control = _G[rootName .. suffix]
        if control then
            control:SetHidden(true)
            if control.SetAlpha then
                control:SetAlpha(0)
            end
            if control.ClearAnchors then
                control:ClearAnchors()
            end
            if control.SetDimensions then
                control:SetDimensions(1, 1)
            end
        end
    end
end

local function CreateStatusBar(name, parent)
    local bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)
    bar:SetMouseEnabled(false)
    bar:SetTexture(BAR_TEXTURE)
    bar:SetOrientation(ORIENTATION_HORIZONTAL)
    bar:SetMinMax(0, 1)
    bar:SetValue(1)
    if type(bar.SetTextureCoords) == "function" then
        bar:SetTextureCoords(0, 1, 0, 0.53125)
    end
    if type(bar.SetBarAlignment) == "function" and BAR_ALIGNMENT_NORMAL then
        bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end
    return bar
end

local function BuildResource(parent, resourceName)
    local root = WINDOW_MANAGER:CreateControl("EZOhud_" .. resourceName .. "_Root", parent, CT_CONTROL)
    root:SetMouseEnabled(false)
    HideLegacyResourceLayers(root:GetName())

    return {
        root = root,
        fill = CreateStatusBar(root:GetName() .. "_Fill", root),
        caption = CreateLabel(root:GetName() .. "_Caption", root),
        value = CreateLabel(root:GetName() .. "_Value", root, "ZoFontGameBold"),
        percent = CreateLabel(root:GetName() .. "_Percent", root, "ZoFontGameBold"),
        meta = RESOURCE_META[resourceName],
    }
end

local function GetResourceSettings(settings, resourceName)
    local meta = RESOURCE_META[resourceName]
    return {
        size = settings[meta.sizeKey] or 180,
        offsetX = settings[meta.offsetXKey] or 0,
        offsetY = settings[meta.offsetYKey] or 0,
    }
end

local function GetResourceMaximum(resourceName)
    local meta = RESOURCE_META[resourceName]
    if not meta then
        return 0
    end

    local _, maximum, effectiveMaximum = GetUnitPower("player", meta.powerType)
    return effectiveMaximum or maximum or 0
end

local function GetDominantMaximum()
    local dominantMaximum = 0
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        dominantMaximum = math.max(dominantMaximum, GetResourceMaximum(resourceName))
    end
    return dominantMaximum
end

local function GetDominanceScaledSize(baseSize, resourceName, dominantMaximum)
    local maximum = GetResourceMaximum(resourceName)
    if maximum <= 0 or dominantMaximum <= 0 then
        return baseSize
    end

    local ratio = Clamp(maximum / dominantMaximum, 0, 1)
    local scale = DOMINANCE_MIN_SCALE + ((1 - DOMINANCE_MIN_SCALE) * ratio)
    return zo_floor(baseSize * scale)
end

local function GetCleanBarDimensions(resource, scaledSize)
    local meta = resource.meta
    local width = math.max(meta.minimumWidth, zo_floor(scaledSize))
    return width, meta.barHeight
end

local function ApplyCleanBarLayout(resource, width, height)
    resource.root:SetDimensions(width, height)

    resource.fill:ClearAnchors()
    resource.fill:SetAnchorFill(resource.root)

    resource.caption:ClearAnchors()
    resource.caption:SetAnchor(CENTER, resource.root, CENTER, 0, 0)
    resource.caption:SetHidden(true)

    resource.percent:ClearAnchors()
    resource.percent:SetAnchor(RIGHT, resource.root, RIGHT, -TEXT_INSET, 0)
    resource.percent:SetDimensions(math.max(48, zo_floor(width * 0.32)), height)
    resource.percent:SetScale(1.05)
    resource.percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    resource.percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    resource.value:ClearAnchors()
    resource.value:SetAnchor(LEFT, resource.root, LEFT, TEXT_INSET, 0)
    resource.value:SetDimensions(math.max(70, zo_floor(width * 0.52)), height)
    resource.value:SetScale(1.05)
    resource.value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    resource.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

function EZO_HUD:ApplyVanillaVisibility()
    local shouldHide = self.sv
        and self.sv.overlay
        and self.sv.overlay.hideVanillaAttributes

    for _, controlName in ipairs(VANILLA_CONTROL_NAMES) do
        SetControlHiddenByName(controlName, shouldHide == true)
    end
end

function EZO_HUD:RefreshOverlayText()
    if not self.overlay then
        return
    end

    for _, resourceName in ipairs(RESOURCE_ORDER) do
        self.overlay.resources[resourceName].caption:SetText(GetString(_G[RESOURCE_META[resourceName].labelString]))
    end
end

function EZO_HUD:RefreshMovementState()
    if not self.overlay then
        return
    end

    local movable = self:IsMoveModeEnabled("overlay")
    self.overlay.root:SetMovable(movable)
    self.overlay.root:SetMouseEnabled(movable)
end

function EZO_HUD:SaveHudPosition()
    local root = self.overlay and self.overlay.root
    local settings = self.sv and self.sv.overlay
    if not (root and settings) then
        return
    end

    local left = root:GetLeft()
    local top = root:GetTop()
    local width = root:GetWidth()
    local height = root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then
        return
    end

    settings.hudOffsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings.hudOffsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyOverlayLayout()
end

function EZO_HUD:ResetAllDefaults()
    self.sv.general = DeepCopyTable(self.defaults.general)
    self.sv.overlay = DeepCopyTable(self.defaults.overlay)
    self.sv.ultimate = DeepCopyTable(self.defaults.ultimate)
    self.sv.execute = DeepCopyTable(self.defaults.execute)
    self.sv.crux = DeepCopyTable(self.defaults.crux)
    self:InitializeRuntimeState()
    EZOHUD_Lang.Apply(self.sv.general.language or self.defaultLanguage or "en")
    self:RefreshOverlayText()
    if self.RefreshUltimateText then
        self:RefreshUltimateText()
    end
    self:ApplyOverlayLayout()
    self:RefreshOverlayVisibility()
    if self.ApplyUltimateLayout then
        self:ApplyUltimateLayout()
        self:RefreshUltimateVisibility()
        self:RefreshUltimateValues()
    end
    if self.ApplyExecuteLayout then
        self:ApplyExecuteLayout()
    end
    if self.ApplyCruxLayout then
        self:ApplyCruxLayout()
        self:ScanCruxState()
    end
end

function EZO_HUD:UpdateResourceDisplay(resourceName)
    local resource = self.overlay and self.overlay.resources and self.overlay.resources[resourceName]
    if not resource then
        return
    end

    local settings = (self.sv and self.sv.overlay) or self.defaults.overlay
    local current, maximum, effectiveMaximum = GetUnitPower("player", resource.meta.powerType)
    current = current or 0
    maximum = effectiveMaximum or maximum or 0
    if resource.lastMaximum ~= nil and resource.lastMaximum ~= maximum then
        resource.lastMaximum = maximum
        self:ApplyOverlayLayout()
        return
    end
    resource.lastMaximum = maximum

    local ratio = 0
    if maximum > 0 then
        ratio = Clamp(current / maximum, 0, 1)
    end

    local r, g, b = GetResourceColor(settings, resourceName)
    local alphaScale = GetOutOfCombatAlpha()
    local percentValue = zo_floor(ratio * 100)

    resource.fill:SetColor(r, g, b, 1)
    resource.fill:SetMinMax(0, math.max(1, maximum))
    resource.fill:SetValue(current)

    resource.value:SetText(string.format("%d / %d", zo_floor(current), zo_floor(maximum)))
    resource.percent:SetText(string.format("%d%%", percentValue))
    resource.value:SetAlpha(alphaScale)
    resource.value:SetColor(1, 1, 1, 0.92 * alphaScale)
    resource.percent:SetColor(1, 1, 1, 0.92 * alphaScale)
end

function EZO_HUD:RefreshOverlayValues()
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        self:UpdateResourceDisplay(resourceName)
    end
end

function EZO_HUD:ApplyOverlayLayout()
    if not self.overlay then
        return
    end

    local settings = (self.sv and self.sv.overlay) or self.defaults.overlay
    local dominantMaximum = GetDominantMaximum()
    local layout = {}
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        local resource = self.overlay.resources[resourceName]
        local resourceSettings = GetResourceSettings(settings, resourceName)
        local scaledSize = GetDominanceScaledSize(resourceSettings.size, resourceName, dominantMaximum)
        local width, height = GetCleanBarDimensions(resource, scaledSize)

        ApplyCleanBarLayout(resource, width, height)

        layout[resourceName] = {
            resource = resource,
            width = resource.root:GetWidth(),
            height = resource.root:GetHeight(),
        }
    end

    local bottomWidth = layout.magicka.width + SIDE_GAP + layout.stamina.width
    local bottomHeight = math.max(layout.magicka.height, layout.stamina.height)
    local groupWidth = math.max(layout.health.width, bottomWidth)
    local groupHeight = layout.health.height + ROW_GAP + bottomHeight
    local centerX, centerY = GetHudGroupCenter(settings)
    local left, top = GetAnchorFromCenter(centerX, centerY, groupWidth, groupHeight)

    self.overlay.root:SetDimensions(groupWidth, groupHeight)
    self.overlay.root:ClearAnchors()
    self.overlay.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    layout.health.resource.root:ClearAnchors()
    layout.health.resource.root:SetAnchor(TOP, self.overlay.root, TOP, 0, 0)

    local bottomLeft = zo_floor((groupWidth - bottomWidth) / 2)
    local bottomTop = layout.health.height + ROW_GAP
    layout.magicka.resource.root:ClearAnchors()
    layout.magicka.resource.root:SetAnchor(TOPLEFT, self.overlay.root, TOPLEFT, bottomLeft, bottomTop)
    layout.stamina.resource.root:ClearAnchors()
    layout.stamina.resource.root:SetAnchor(TOPLEFT, self.overlay.root, TOPLEFT, bottomLeft + layout.magicka.width + SIDE_GAP, bottomTop)

    self:RefreshMovementState()
    self:RefreshOverlayValues()
end

function EZO_HUD:RefreshOverlayVisibility()
    if not self.overlay then
        return
    end

    local enabled = self.sv and self.sv.overlay and self.sv.overlay.enabled
    local hudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    self.overlay.root:SetHidden(not enabled or not hudVisible)
    self:RefreshMovementState()
    self:ApplyVanillaVisibility()
end

function EZO_HUD:OnOverlayPowerUpdate(_, unitTag, _, powerType)
    if unitTag ~= "player" then
        return
    end
    for resourceName, meta in pairs(RESOURCE_META) do
        if powerType == meta.powerType then
            self:UpdateResourceDisplay(resourceName)
            return
        end
    end
end

function EZO_HUD:InitializeOverlay()
    local root = WINDOW_MANAGER:CreateTopLevelWindow("EZOhudOverlayRoot")
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetMouseEnabled(false)

    self.overlay = {
        root = root,
        resources = {},
    }

    root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("overlay") then
            control:StartMoving()
        end
    end)
    root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("overlay") then
            control:StopMovingOrResizing()
        end
    end)
    root:SetHandler("OnMoveStop", function()
        self:SaveHudPosition()
    end)
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(root)
    end

    for _, resourceName in ipairs(RESOURCE_ORDER) do
        local resource = BuildResource(root, resourceName)
        self.overlay.resources[resourceName] = resource
    end

    self:RefreshOverlayText()
    self:ApplyOverlayLayout()
    self:RefreshOverlayVisibility()

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_OverlayPower",
        EVENT_POWER_UPDATE,
        function(...)
            self:OnOverlayPowerUpdate(...)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_OverlayActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            self:ApplyOverlayLayout()
            self:RefreshOverlayVisibility()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_OverlayCombat",
        EVENT_PLAYER_COMBAT_STATE,
        function()
            self:RefreshOverlayVisibility()
            self:RefreshOverlayValues()
        end
    )
end

function EZO_HUD:InitializeSettings()
    local lam = nil
    if LibStub then
        local ok, resolved = pcall(LibStub, "LibAddonMenu-2.0", true)
        if ok and type(resolved) == "table" then
            lam = resolved
        elseif type(LibStub.GetLibrary) == "function" then
            lam = LibStub:GetLibrary("LibAddonMenu-2.0", true)
        end
    end
    if not lam and type(LibAddonMenu2) == "table"
        and type(LibAddonMenu2.RegisterAddonPanel) == "function"
        and type(LibAddonMenu2.RegisterOptionControls) == "function" then
        lam = LibAddonMenu2
    end

    local registerAddonPanel = lam and lam.RegisterAddonPanel or nil
    local registerOptionControls = lam and lam.RegisterOptionControls or nil
    local buildOptions = EZOhud_LAM and EZOhud_LAM.BuildOptions or nil
    if not (lam and type(registerAddonPanel) == "function" and type(registerOptionControls) == "function" and type(buildOptions) == "function") then
        if self.Print then
            self.Print(GetString(EZO_HUD_MSG_LAM_MISSING))
        end
        return
    end

    local function LanguageDefaultChoice()
        return (self.GetDefaultLanguage and self.GetDefaultLanguage()) or "auto"
    end

    local function WarnForcedLanguage()
        if self.Print then
            self.Print(GetString(EZO_HUD_MSG_LANGUAGE_FORCED_WARNING))
        end
    end

    local function BuildResourceOptions(resourceName)
        local meta = RESOURCE_META[resourceName]
        local headerId = _G["EZO_HUD_OPTION_RESOURCE_" .. string.upper(resourceName)] or _G[meta.labelString]
        local defaultColor = CopyColor(self.defaults.overlay[meta.colorKey])
        return {
            { type = "header", name = GetString(headerId) },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_SIZE),
                tooltip = GetString(EZO_HUD_OPTION_SIZE_TOOLTIP),
                min = 90,
                max = 500,
                step = 5,
                getFunc = function()
                    return self.sv.overlay[meta.sizeKey]
                end,
                setFunc = function(value)
                    self.sv.overlay[meta.sizeKey] = value
                    self:ApplyOverlayLayout()
                end,
                default = self.defaults.overlay[meta.sizeKey],
                width = "half",
            },
            {
                type = "colorpicker",
                name = GetString(EZO_HUD_OPTION_COLOR),
                tooltip = GetString(EZO_HUD_OPTION_COLOR_TOOLTIP),
                getFunc = function()
                    return GetResourceColor(self.sv.overlay, resourceName)
                end,
                setFunc = function(r, g, b, a)
                    r, g, b, a = ConstrainColor(resourceName, r, g, b, a)
                    self.sv.overlay[meta.colorKey] = { r = r, g = g, b = b, a = a }
                    self:RefreshOverlayValues()
                end,
                default = defaultColor,
                width = "half",
            },
        }
    end

    EZOhud_LAM.RegisterSection("general", 10, function()
        return {
            { type = "header", name = GetString(EZO_HUD_OPTION_GENERAL) },
            {
                type = "dropdown",
                name = GetString(EZO_HUD_OPTION_LANGUAGE),
                tooltip = GetString(EZO_HUD_OPTION_LANGUAGE_TOOLTIP),
                choices = { GetString(EZO_HUD_OPTION_LANGUAGE_AUTO), "English", "Español" },
                choicesValues = { "auto", "en", "es" },
                getFunc = function()
                    return self.sv.general.language or "auto"
                end,
                setFunc = function(value)
                    value = tostring(value or "auto")
                    self.sv.general.language = value
                    if EZOHUD_Lang and EZOHUD_Lang.Apply then
                        EZOHUD_Lang.Apply(value)
                    end
                    self:RefreshOverlayText()
                    if self.RefreshUltimateText then
                        self:RefreshUltimateText()
                    end
                    self:ApplyOverlayLayout()
                    if self.IsForcedLanguage and self.IsForcedLanguage(value) then
                        WarnForcedLanguage()
                    end
                end,
                default = LanguageDefaultChoice(),
                width = "half",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_DEBUG_ENABLE),
                tooltip = GetString(EZO_HUD_OPTION_DEBUG_ENABLE_TOOLTIP),
                getFunc = function()
                    return self.sv.general.debugEnabled
                end,
                setFunc = function(value)
                    self.sv.general.debugEnabled = value
                    if value and self.InitializeDebug then
                        self:InitializeDebug()
                    end
                end,
                default = self.defaults.general.debugEnabled,
                width = "half",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_DEBUG_CHAT),
                tooltip = GetString(EZO_HUD_OPTION_DEBUG_CHAT_TOOLTIP),
                getFunc = function()
                    return self.sv.general.debugToChat
                end,
                setFunc = function(value)
                    self.sv.general.debugToChat = value
                end,
                default = self.defaults.general.debugToChat,
                width = "half",
            },
        }
    end)

    EZOhud_LAM.RegisterSection("overlay", 20, function()
        local options = {
            { type = "header", name = GetString(EZO_HUD_OPTION_OVERLAY) },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_OVERLAY_ENABLE),
                tooltip = GetString(EZO_HUD_OPTION_OVERLAY_ENABLE_TOOLTIP),
                getFunc = function() return self.sv.overlay.enabled end,
                setFunc = function(value) self.sv.overlay.enabled = value; self:RefreshOverlayVisibility() end,
                default = self.defaults.overlay.enabled,
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_HIDE_VANILLA),
                tooltip = GetString(EZO_HUD_OPTION_HIDE_VANILLA_TOOLTIP),
                getFunc = function() return self.sv.overlay.hideVanillaAttributes end,
                setFunc = function(value) self.sv.overlay.hideVanillaAttributes = value; self:ApplyVanillaVisibility() end,
                default = self.defaults.overlay.hideVanillaAttributes,
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_MOVE_HUD),
                tooltip = GetString(EZO_HUD_OPTION_MOVE_HUD_TOOLTIP),
                getFunc = function() return self:IsMoveModeEnabled("overlay") end,
                setFunc = function(value) self:SetMoveModeEnabled("overlay", value); self:RefreshMovementState() end,
                default = self.defaults.overlay.movable,
                width = "full",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_OUT_OF_COMBAT_ALPHA),
                min = 0.2,
                max = 1.0,
                step = 0.05,
                getFunc = function() return self.sv.overlay.outOfCombatAlpha end,
                setFunc = function(value) self.sv.overlay.outOfCombatAlpha = value; self:RefreshOverlayValues() end,
                default = self.defaults.overlay.outOfCombatAlpha,
                width = "half",
            },
        }

        for _, resourceName in ipairs({ "health", "stamina", "magicka" }) do
            local resourceOptions = BuildResourceOptions(resourceName)
            for _, option in ipairs(resourceOptions) do
                options[#options + 1] = option
            end
        end
        return options
    end)

    local panelData = {
        type = "panel",
        name = GetString(EZO_HUD_PANEL_NAME),
        displayName = GetString(EZO_HUD_LABEL_NAME),
        author = GetString(EZO_HUD_PANEL_AUTHOR),
        version = self.ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            self:ResetAllDefaults()
        end,
    }

    registerAddonPanel(lam, self.ADDON_NAME .. "_LAM", panelData)
    registerOptionControls(lam, self.ADDON_NAME .. "_LAM", buildOptions())
end
