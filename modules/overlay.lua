EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local SEGMENT_COUNT = 48
local WHITE_TEXTURE = "EZOhud/media/radial/white.dds"
local DISC_TEXTURE = "EZOhud/media/radial/stamina_disc.dds"
local NORMAL_TEXT_COLOR = { 0.98, 0.98, 0.98, 1.0 }
local ALERT_DISC_COLOR = { 1.0, 0.28, 0.14, 0.95 }

local RESOURCE_ORDER = { "stamina", "health", "magicka" }
local RESOURCE_META = {
    health = {
        powerType = POWERTYPE_HEALTH,
        labelString = "EZO_HUD_PREVIEW_HEALTH",
        shapeKey = "healthShape",
        sizeKey = "healthSize",
        alertKey = "healthAlertThreshold",
        colorKey = "healthColor",
        offsetXKey = "healthOffsetX",
        offsetYKey = "healthOffsetY",
        reverseRect = false,
    },
    stamina = {
        powerType = POWERTYPE_STAMINA,
        labelString = "EZO_HUD_PREVIEW_STAMINA",
        shapeKey = "staminaShape",
        sizeKey = "staminaSize",
        alertKey = "staminaAlertThreshold",
        colorKey = "staminaColor",
        offsetXKey = "staminaOffsetX",
        offsetYKey = "staminaOffsetY",
        reverseRect = false,
    },
    magicka = {
        powerType = POWERTYPE_MAGICKA,
        labelString = "EZO_HUD_PREVIEW_MAGICKA",
        shapeKey = "magickaShape",
        sizeKey = "magickaSize",
        alertKey = "magickaAlertThreshold",
        colorKey = "magickaColor",
        offsetXKey = "magickaOffsetX",
        offsetYKey = "magickaOffsetY",
        reverseRect = true,
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
    label:SetColor(0.95, 0.95, 0.98, 0.92)
    label:SetMouseEnabled(false)
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

local function GetResourceAnchorPosition(settings, resourceName, width, height)
    local meta = RESOURCE_META[resourceName]
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local centerX = (guiWidth / 2) + (settings[meta.offsetXKey] or 0)
    local centerY = (guiHeight / 2) + (settings[meta.offsetYKey] or 0)
    return zo_floor(centerX - (width / 2)), zo_floor(centerY - (height / 2))
end

local function BuildSegment(parent, resourceName, index)
    local root = WINDOW_MANAGER:CreateControl(
        string.format("EZOhud_%sSegment%d", resourceName, index),
        parent,
        CT_CONTROL
    )
    local fill = WINDOW_MANAGER:CreateControl(root:GetName() .. "_Fill", root, CT_TEXTURE)
    fill:SetTexture(WHITE_TEXTURE)
    fill:SetMouseEnabled(false)
    root:SetMouseEnabled(false)
    return {
        root = root,
        fill = fill,
    }
end

local function BuildResource(resourceName)
    local root = WINDOW_MANAGER:CreateTopLevelWindow("EZOhud_" .. resourceName .. "_Root")
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetMouseEnabled(false)

    local resource = {
        root = root,
        caption = CreateLabel(root:GetName() .. "_Caption", root),
        value = CreateLabel(root:GetName() .. "_Value", root),
        percent = CreateLabel(root:GetName() .. "_Percent", root, "ZoFontGameBold"),
        centerDisc = WINDOW_MANAGER:CreateControl(root:GetName() .. "_CenterDisc", root, CT_TEXTURE),
        segments = {},
        meta = RESOURCE_META[resourceName],
    }

    resource.centerDisc:SetTexture(DISC_TEXTURE)
    resource.centerDisc:SetMouseEnabled(false)
    resource.percent:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    resource.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    resource.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    resource.percent:SetScale(0.9)

    for index = 1, SEGMENT_COUNT do
        resource.segments[index] = BuildSegment(root, resourceName, index)
    end

    return resource
end

local function GetResourceSettings(settings, resourceName)
    local meta = RESOURCE_META[resourceName]
    return {
        shape = settings[meta.shapeKey] or "circular",
        size = settings[meta.sizeKey] or 100,
        alertThreshold = settings[meta.alertKey] or 25,
        offsetX = settings[meta.offsetXKey] or 0,
        offsetY = settings[meta.offsetYKey] or 0,
    }
end

local function GetRectHeight(size)
    return math.max(16, zo_floor(size * 0.16))
end

local function ApplySegmentVisual(segment, r, g, b, alphaScale, state)
    if state == "active" then
        segment.fill:SetColor(r, g, b, 1.0 * alphaScale)
    elseif state == "partial" then
        segment.fill:SetColor(r, g, b, 0.45 * alphaScale)
    else
        segment.fill:SetColor(0.14, 0.15, 0.18, 0.42 * alphaScale)
    end
end

function EZO_HUD:ApplyVanillaVisibility()
    local shouldHide = self.sv
        and self.sv.overlay
        and self.sv.overlay.enabled
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

    local movable = self.sv and self.sv.overlay and self.sv.overlay.movable == true
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        local root = self.overlay.resources[resourceName].root
        root:SetMovable(movable)
        root:SetMouseEnabled(movable)
    end
end

function EZO_HUD:SaveResourcePosition(resourceName)
    local resource = self.overlay and self.overlay.resources and self.overlay.resources[resourceName]
    local settings = self.sv and self.sv.overlay
    if not (resource and settings) then
        return
    end

    local left = resource.root:GetLeft()
    local top = resource.root:GetTop()
    local width = resource.root:GetWidth()
    local height = resource.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then
        return
    end

    settings[resource.meta.offsetXKey] = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings[resource.meta.offsetYKey] = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyOverlayLayout()
end

function EZO_HUD:ResetAllDefaults()
    self.sv.general = DeepCopyTable(self.defaults.general)
    self.sv.overlay = DeepCopyTable(self.defaults.overlay)
    EZOHUD_Lang.Apply(self.sv.general.language or self.defaultLanguage or "en")
    self:RefreshOverlayText()
    self:ApplyOverlayLayout()
    self:RefreshOverlayVisibility()
end

function EZO_HUD:ApplyCircularLayout(resource, size)
    local ringThickness = math.max(5, zo_floor(size * 0.08))
    local segmentLength = math.max(8, zo_floor(size * 0.14))
    local radialOffset = math.max(8, zo_floor((size / 2) - (segmentLength / 2) - 6))
    local centerSize = math.max(34, zo_floor(size * 0.46))

    resource.root:SetDimensions(size, size)
    resource.centerDisc:ClearAnchors()
    resource.centerDisc:SetDimensions(centerSize, centerSize)
    resource.centerDisc:SetAnchor(CENTER, resource.root, CENTER, 0, 0)

    for _, segment in ipairs(resource.segments) do
        segment.root:ClearAnchors()
        segment.root:SetAnchor(CENTER, resource.root, CENTER, 0, 0)
        segment.root:SetDimensions(size, size)
        segment.root:SetTransformRotationZ(0)

        segment.fill:ClearAnchors()
        segment.fill:SetDimensions(ringThickness, segmentLength)
        segment.fill:SetAnchor(CENTER, segment.root, CENTER, 0, -radialOffset)
    end
end

function EZO_HUD:ApplyRectangularLayout(resource, width)
    local barHeight = GetRectHeight(width)
    local gap = 1
    local totalGap = gap * (SEGMENT_COUNT - 1)
    local segmentWidth = math.max(2, zo_floor((width - totalGap) / SEGMENT_COUNT))
    local finalWidth = (segmentWidth * SEGMENT_COUNT) + totalGap
    local centerWidth = math.max(46, zo_floor(finalWidth * 0.30))
    local centerHeight = math.max(18, zo_floor(barHeight * 1.35))

    resource.root:SetDimensions(finalWidth, math.max(barHeight, centerHeight))
    resource.centerDisc:ClearAnchors()
    resource.centerDisc:SetDimensions(centerWidth, centerHeight)
    resource.centerDisc:SetAnchor(CENTER, resource.root, CENTER, 0, 0)

    for index, segment in ipairs(resource.segments) do
        segment.root:ClearAnchors()
        segment.root:SetAnchor(LEFT, resource.root, LEFT, (index - 1) * (segmentWidth + gap), 0)
        segment.root:SetDimensions(segmentWidth, barHeight)
        segment.root:SetTransformRotationZ(0)

        segment.fill:ClearAnchors()
        segment.fill:SetAnchorFill(segment.root)
    end
end

function EZO_HUD:UpdateResourceDisplay(resourceName)
    local resource = self.overlay and self.overlay.resources and self.overlay.resources[resourceName]
    if not resource then
        return
    end

    local settings = (self.sv and self.sv.overlay) or self.defaults.overlay
    local resourceSettings = GetResourceSettings(settings, resourceName)
    local current, maximum, effectiveMaximum = GetUnitPower("player", resource.meta.powerType)
    current = current or 0
    maximum = effectiveMaximum or maximum or 0

    local ratio = 0
    if maximum > 0 then
        ratio = Clamp(current / maximum, 0, 1)
    end

    local r, g, b, _ = GetResourceColor(settings, resourceName)
    local alphaScale = GetOutOfCombatAlpha()
    local scaled = ratio * SEGMENT_COUNT
    local fullSegments = zo_floor(scaled)
    local partial = scaled - fullSegments

    if resourceSettings.shape == "circular" then
        local clockwise = settings.staminaRadialClockwise ~= false
        local originAngle = settings.staminaRadialOriginAngle or (-math.pi / 2)
        for index, segment in ipairs(resource.segments) do
            local zeroBased = index - 1
            local visualIndex = clockwise and zeroBased or ((SEGMENT_COUNT - zeroBased) % SEGMENT_COUNT)
            local angle = originAngle + ((math.pi * 2) * visualIndex / SEGMENT_COUNT)
            segment.root:SetTransformRotationZ(angle)

            local state = "inactive"
            if zeroBased < fullSegments then
                state = "active"
            elseif zeroBased == fullSegments and partial > 0 then
                state = "partial"
            end
            ApplySegmentVisual(segment, r, g, b, alphaScale, state)
        end
    else
        for index, segment in ipairs(resource.segments) do
            local zeroBased = index - 1
            local visualIndex = resource.meta.reverseRect and (SEGMENT_COUNT - index) or zeroBased
            local state = "inactive"
            if visualIndex < fullSegments then
                state = "active"
            elseif visualIndex == fullSegments and partial > 0 then
                state = "partial"
            end
            ApplySegmentVisual(segment, r, g, b, alphaScale, state)
        end
    end

    local percentValue = zo_floor(ratio * 100)
    resource.value:SetText(string.format("%d / %d", zo_floor(current), zo_floor(maximum)))
    resource.percent:SetText(string.format("%d%%", percentValue))
    resource.caption:SetAlpha(alphaScale)
    resource.value:SetAlpha(alphaScale)
    resource.percent:SetColor(r, g, b, 1.0)

    if percentValue <= resourceSettings.alertThreshold then
        resource.centerDisc:SetColor(unpack(ALERT_DISC_COLOR))
    else
        resource.centerDisc:SetColor(r, g, b, 0.22)
    end
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
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        local resource = self.overlay.resources[resourceName]
        local resourceSettings = GetResourceSettings(settings, resourceName)

        if resourceSettings.shape == "rectangular" then
            self:ApplyRectangularLayout(resource, resourceSettings.size)
        else
            self:ApplyCircularLayout(resource, resourceSettings.size)
        end

        local left, top = GetResourceAnchorPosition(settings, resourceName, resource.root:GetWidth(), resource.root:GetHeight())
        resource.root:ClearAnchors()
        resource.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

        resource.caption:ClearAnchors()
        resource.caption:SetAnchor(BOTTOM, resource.root, TOP, 0, -8)
        resource.value:ClearAnchors()
        resource.value:SetAnchor(TOP, resource.root, BOTTOM, 0, 6)
        resource.percent:ClearAnchors()
        resource.percent:SetAnchor(CENTER, resource.centerDisc, CENTER, 0, 0)
    end

    self:RefreshMovementState()
    self:RefreshOverlayValues()
end

function EZO_HUD:RefreshOverlayVisibility()
    if not self.overlay then
        return
    end

    local enabled = self.sv and self.sv.overlay and self.sv.overlay.enabled
    for _, resourceName in ipairs(RESOURCE_ORDER) do
        self.overlay.resources[resourceName].root:SetHidden(not enabled)
    end
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
    self.overlay = { resources = {} }

    for _, resourceName in ipairs(RESOURCE_ORDER) do
        local resource = BuildResource(resourceName)
        resource.root:SetHandler("OnMouseDown", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self.sv and self.sv.overlay and self.sv.overlay.movable then
                control:StartMoving()
            end
        end)
        resource.root:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self.sv and self.sv.overlay and self.sv.overlay.movable then
                control:StopMovingOrResizing()
            end
        end)
        resource.root:SetHandler("OnMoveStop", function()
            self:SaveResourcePosition(resourceName)
        end)
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

    local function ResourceShapeChoice(shape)
        if shape == "rectangular" then
            return GetString(EZO_HUD_SHAPE_RECTANGULAR)
        end
        return GetString(EZO_HUD_SHAPE_CIRCULAR)
    end

    local function LanguageDefaultChoice()
        return (self.defaultLanguage == "es") and "Español" or "English"
    end

    local function BuildResourceOptions(resourceName)
        local meta = RESOURCE_META[resourceName]
        local headerId = _G["EZO_HUD_OPTION_RESOURCE_" .. string.upper(resourceName)] or _G[meta.labelString]
        local defaultColor = CopyColor(self.defaults.overlay[meta.colorKey])
        local shapeDefault = ResourceShapeChoice(self.defaults.overlay[meta.shapeKey])
        return {
            { type = "header", name = GetString(headerId) },
            {
                type = "dropdown",
                name = GetString(EZO_HUD_OPTION_SHAPE),
                tooltip = GetString(EZO_HUD_OPTION_SHAPE_TOOLTIP),
                choices = { GetString(EZO_HUD_SHAPE_CIRCULAR), GetString(EZO_HUD_SHAPE_RECTANGULAR) },
                getFunc = function()
                    return ResourceShapeChoice(self.sv.overlay[meta.shapeKey])
                end,
                setFunc = function(value)
                    self.sv.overlay[meta.shapeKey] = (value == GetString(EZO_HUD_SHAPE_RECTANGULAR)) and "rectangular" or "circular"
                    self:ApplyOverlayLayout()
                end,
                default = shapeDefault,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_SIZE),
                tooltip = GetString(EZO_HUD_OPTION_SIZE_TOOLTIP),
                min = 60,
                max = 220,
                step = 4,
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
                type = "slider",
                name = GetString(EZO_HUD_OPTION_ALERT_THRESHOLD),
                tooltip = GetString(EZO_HUD_OPTION_ALERT_THRESHOLD_TOOLTIP),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function()
                    return self.sv.overlay[meta.alertKey]
                end,
                setFunc = function(value)
                    self.sv.overlay[meta.alertKey] = value
                    self:RefreshOverlayValues()
                end,
                default = self.defaults.overlay[meta.alertKey],
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
                choices = { "English", "Español" },
                getFunc = function()
                    return (self.sv.general.language == "es") and "Español" or "English"
                end,
                setFunc = function(value)
                    self.sv.general.language = (value == "Español") and "es" or "en"
                    EZOHUD_Lang.Apply(self.sv.general.language)
                    self:RefreshOverlayText()
                    self:ApplyOverlayLayout()
                end,
                default = LanguageDefaultChoice,
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
                getFunc = function() return self.sv.overlay.movable end,
                setFunc = function(value) self.sv.overlay.movable = value; self:RefreshMovementState() end,
                default = self.defaults.overlay.movable,
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_STAMINA_CLOCKWISE),
                tooltip = GetString(EZO_HUD_OPTION_STAMINA_CLOCKWISE_TOOLTIP),
                getFunc = function() return self.sv.overlay.staminaRadialClockwise end,
                setFunc = function(value) self.sv.overlay.staminaRadialClockwise = value; self:ApplyOverlayLayout() end,
                default = self.defaults.overlay.staminaRadialClockwise,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_STAMINA_ORIGIN),
                tooltip = GetString(EZO_HUD_OPTION_STAMINA_ORIGIN_TOOLTIP),
                min = -3.14,
                max = 3.14,
                step = 0.17,
                getFunc = function() return self.sv.overlay.staminaRadialOriginAngle end,
                setFunc = function(value) self.sv.overlay.staminaRadialOriginAngle = value; self:ApplyOverlayLayout() end,
                default = self.defaults.overlay.staminaRadialOriginAngle,
                width = "half",
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
