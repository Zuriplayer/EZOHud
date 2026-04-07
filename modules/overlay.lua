EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local OVERLAY_NAME = "EZOhudOverlay"
local PLACEHOLDER_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericfill.dds"
local DEFAULT_COORDS = { 0, 1, 0, 1 }
local FUTURE_CONE_ATLAS = "media/curved/cone_atlas.dds"
local FUTURE_ARC_ATLAS = "media/curved/arc_atlas.dds"

local POWER_TYPE_BY_NAME = {
    health = POWERTYPE_HEALTH,
    stamina = POWERTYPE_STAMINA,
    magicka = POWERTYPE_MAGICKA,
}

local RESOURCE_COLORS = {
    health = { 0.82, 0.18, 0.22, 0.98 },
    stamina = { 0.21, 0.67, 0.29, 0.98 },
    magicka = { 0.22, 0.46, 0.88, 0.98 },
}

local VANILLA_CONTROL_NAMES = {
    "ZO_PlayerAttributeHealth",
    "ZO_PlayerAttributeMagicka",
    "ZO_PlayerAttributeStamina",
    "ZO_PlayerAttributeBars",
    "ZO_PlayerAttribute",
}

local UV = {
    healthBackground = { 0.250, 0.500, 0.000, 1.000 },
    healthTop = { 0.375, 0.500, 0.000, 0.500 },
    healthBottom = { 0.375, 0.500, 0.500, 1.000 },
    leftPrimaryBackground = { 0.000, 0.125, 0.000, 0.667 },
    leftPrimaryFill = { 0.125, 0.250, 0.000, 0.667 },
    leftSecondaryBackground = { 0.000, 0.125, 0.667, 1.000 },
    leftSecondaryFill = { 0.125, 0.250, 0.667, 1.000 },
    rightPrimaryBackground = { 0.500, 0.625, 0.000, 0.667 },
    rightPrimaryFill = { 0.625, 0.750, 0.000, 0.667 },
    rightSecondaryBackground = { 0.500, 0.625, 0.667, 1.000 },
    rightSecondaryFill = { 0.625, 0.750, 0.667, 1.000 },
}

local TEXTURE_LAYOUTS = {
    cone = {
        atlasTexture = PLACEHOLDER_TEXTURE,
        futureAtlasTexture = FUTURE_CONE_ATLAS,
        healthLift = -18,
        sideRise = 46,
        sideDistance = 58,
        health = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthBottom },
            { widthFactor = 0.92, heightFactor = 0.92, x = 0, y = -8, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthBottom },
            { widthFactor = 0.82, heightFactor = 0.84, x = 0, y = -15, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthTop },
            { widthFactor = 0.68, heightFactor = 0.74, x = 0, y = -21, fillDirection = "up", backgroundCoords = UV.healthTop, coords = UV.healthTop },
        },
        left = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.leftPrimaryBackground, coords = UV.leftPrimaryFill },
            { widthFactor = 0.92, heightFactor = 0.92, x = -10, y = -8, fillDirection = "up", backgroundCoords = UV.leftPrimaryBackground, coords = UV.leftPrimaryFill },
            { widthFactor = 0.80, heightFactor = 0.82, x = -20, y = -16, fillDirection = "up", backgroundCoords = UV.leftSecondaryBackground, coords = UV.leftSecondaryFill },
            { widthFactor = 0.66, heightFactor = 0.72, x = -30, y = -23, fillDirection = "up", backgroundCoords = UV.leftSecondaryBackground, coords = UV.leftSecondaryFill },
        },
        right = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.rightPrimaryBackground, coords = UV.rightPrimaryFill },
            { widthFactor = 0.92, heightFactor = 0.92, x = 10, y = -8, fillDirection = "up", backgroundCoords = UV.rightPrimaryBackground, coords = UV.rightPrimaryFill },
            { widthFactor = 0.80, heightFactor = 0.82, x = 20, y = -16, fillDirection = "up", backgroundCoords = UV.rightSecondaryBackground, coords = UV.rightSecondaryFill },
            { widthFactor = 0.66, heightFactor = 0.72, x = 30, y = -23, fillDirection = "up", backgroundCoords = UV.rightSecondaryBackground, coords = UV.rightSecondaryFill },
        },
    },
    arc = {
        atlasTexture = PLACEHOLDER_TEXTURE,
        futureAtlasTexture = FUTURE_ARC_ATLAS,
        healthLift = -28,
        sideRise = 62,
        sideDistance = 40,
        health = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthBottom },
            { widthFactor = 0.96, heightFactor = 0.94, x = 0, y = -7, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthBottom },
            { widthFactor = 0.88, heightFactor = 0.86, x = 0, y = -14, fillDirection = "up", backgroundCoords = UV.healthBackground, coords = UV.healthTop },
            { widthFactor = 0.76, heightFactor = 0.76, x = 0, y = -20, fillDirection = "up", backgroundCoords = UV.healthTop, coords = UV.healthTop },
            { widthFactor = 0.60, heightFactor = 0.66, x = 0, y = -25, fillDirection = "up", backgroundCoords = UV.healthTop, coords = UV.healthTop },
        },
        left = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.leftPrimaryBackground, coords = UV.leftPrimaryFill },
            { widthFactor = 0.94, heightFactor = 0.94, x = -8, y = -10, fillDirection = "up", backgroundCoords = UV.leftPrimaryBackground, coords = UV.leftPrimaryFill },
            { widthFactor = 0.84, heightFactor = 0.86, x = -18, y = -20, fillDirection = "up", backgroundCoords = UV.leftSecondaryBackground, coords = UV.leftSecondaryFill },
            { widthFactor = 0.70, heightFactor = 0.76, x = -32, y = -29, fillDirection = "up", backgroundCoords = UV.leftSecondaryBackground, coords = UV.leftSecondaryFill },
        },
        right = {
            { widthFactor = 1.00, heightFactor = 1.00, x = 0, y = 0, fillDirection = "up", backgroundCoords = UV.rightPrimaryBackground, coords = UV.rightPrimaryFill },
            { widthFactor = 0.94, heightFactor = 0.94, x = 8, y = -10, fillDirection = "up", backgroundCoords = UV.rightPrimaryBackground, coords = UV.rightPrimaryFill },
            { widthFactor = 0.84, heightFactor = 0.86, x = 18, y = -20, fillDirection = "up", backgroundCoords = UV.rightSecondaryBackground, coords = UV.rightSecondaryFill },
            { widthFactor = 0.70, heightFactor = 0.76, x = 32, y = -29, fillDirection = "up", backgroundCoords = UV.rightSecondaryBackground, coords = UV.rightSecondaryFill },
        },
    },
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

local function CreateLabel(name, parent)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(0.95, 0.95, 0.98, 0.92)
    return label
end

local function CreateTextureLayer(name, parent, texturePath, color, drawLayer)
    local texture = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    texture:SetTexture(texturePath)
    texture:SetColor(unpack(color))
    texture:SetDrawLayer(drawLayer or DL_OVERLAY)
    return texture
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

local function ApplyTextureCoords(texture, coords)
    texture:SetTextureCoords(coords[1], coords[2], coords[3], coords[4])
end

local function LayoutTextureFill(segment, pct)
    pct = Clamp(pct or 0, 0, 1)

    local fill = segment.fill
    local coords = segment.coords or DEFAULT_COORDS
    local width = segment.width or 1
    local height = segment.height or 1
    local deltaX = coords[2] - coords[1]
    local deltaY = coords[4] - coords[3]

    fill:ClearAnchors()

    if segment.fillDirection == "left" then
        fill:SetAnchor(TOPRIGHT, segment.root, TOPRIGHT, 0, 0)
        fill:SetAnchor(BOTTOMRIGHT, segment.root, BOTTOMRIGHT, 0, 0)
        fill:SetWidth(width * pct)
        fill:SetTextureCoords(coords[2] - deltaX * pct, coords[2], coords[3], coords[4])
    elseif segment.fillDirection == "right" then
        fill:SetAnchor(TOPLEFT, segment.root, TOPLEFT, 0, 0)
        fill:SetAnchor(BOTTOMLEFT, segment.root, BOTTOMLEFT, 0, 0)
        fill:SetWidth(width * pct)
        fill:SetTextureCoords(coords[1], coords[1] + deltaX * pct, coords[3], coords[4])
    else
        fill:SetAnchor(BOTTOMLEFT, segment.root, BOTTOMLEFT, 0, 0)
        fill:SetAnchor(BOTTOMRIGHT, segment.root, BOTTOMRIGHT, 0, 0)
        fill:SetHeight(height * pct)
        fill:SetTextureCoords(coords[1], coords[2], coords[4] - deltaY * pct, coords[4])
    end

    fill:SetHidden(pct <= 0.01)
end

local function BuildSegment(parent, name, texturePath, color)
    local root = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    local segment = {
        root = root,
        background = CreateTextureLayer(name .. "_Bg", root, texturePath, { 0.08, 0.09, 0.12, 0.48 }, DL_BACKGROUND),
        fill = CreateTextureLayer(name .. "_Fill", root, texturePath, color, DL_OVERLAY),
        coords = DEFAULT_COORDS,
        fillDirection = "up",
        width = 1,
        height = 1,
    }

    segment.background:SetAlpha(0.7)
    segment.fill:SetAlpha(0.96)

    return segment
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

    self.overlay.bars.health.caption:SetText(GetString(EZO_HUD_PREVIEW_HEALTH))
    self.overlay.bars.stamina.caption:SetText(GetString(EZO_HUD_PREVIEW_STAMINA))
    self.overlay.bars.magicka.caption:SetText(GetString(EZO_HUD_PREVIEW_MAGICKA))
end

function EZO_HUD:UpdateAttributeBar(resourceName)
    if not self.overlay or not self.overlay.bars then
        return
    end

    local barData = self.overlay.bars[resourceName]
    local powerType = POWER_TYPE_BY_NAME[resourceName]
    if not (barData and powerType) then
        return
    end

    local current, maximum, effectiveMaximum = GetUnitPower("player", powerType)
    current = current or 0
    maximum = effectiveMaximum or maximum or 0

    local ratio = 0
    if maximum > 0 then
        ratio = Clamp(current / maximum, 0, 1)
    end

    for _, segment in ipairs(barData.segments) do
        LayoutTextureFill(segment, ratio)
    end

    barData.value:SetText(string.format("%d / %d", zo_floor(current), zo_floor(maximum)))
end

function EZO_HUD:RefreshOverlayValues()
    self:UpdateAttributeBar("health")
    self:UpdateAttributeBar("stamina")
    self:UpdateAttributeBar("magicka")
end

function EZO_HUD:ApplyBarTextureLayout(barData, rows, width, height)
    local alphaBase = GetOutOfCombatAlpha()

    for index, row in ipairs(rows) do
        local segment = barData.segments[index]
        if segment then
            local rowWidth = zo_floor(width * row.widthFactor)
            local rowHeight = math.max(6, zo_floor(height * row.heightFactor))
            local rowAlpha = Clamp(alphaBase - ((index - 1) * 0.08), 0.35, 1)

            segment.coords = row.coords or DEFAULT_COORDS
            segment.fillDirection = row.fillDirection or "up"
            segment.width = rowWidth
            segment.height = rowHeight

            segment.root:ClearAnchors()
            segment.root:SetAnchor(CENTER, segment.root:GetParent(), CENTER, row.x or 0, row.y or 0)
            segment.root:SetDimensions(rowWidth, rowHeight)
            segment.root:SetHidden(false)
            segment.root:SetAlpha(rowAlpha)

            segment.background:ClearAnchors()
            segment.background:SetAnchor(TOPLEFT, segment.root, TOPLEFT, 0, 0)
            segment.background:SetAnchor(BOTTOMRIGHT, segment.root, BOTTOMRIGHT, 0, 0)
            ApplyTextureCoords(segment.background, row.backgroundCoords or segment.coords)

            segment.fill:SetColor(unpack(barData.color))
            ApplyTextureCoords(segment.fill, segment.coords)
        end
    end

    for index = #rows + 1, #barData.segments do
        barData.segments[index].root:SetHidden(true)
    end
end

function EZO_HUD:ApplyOverlayLayout()
    if not self.overlay then
        return
    end

    local settings = self.sv and self.sv.overlay or self.defaults.overlay
    local style = settings.style or "cone"
    local layout = TEXTURE_LAYOUTS[style] or TEXTURE_LAYOUTS.cone
    local root = self.overlay.root
    local health = self.overlay.bars.health.root
    local stamina = self.overlay.bars.stamina.root
    local magicka = self.overlay.bars.magicka.root

    local healthWidth = settings.healthWidth or 240
    local sideWidth = settings.sideWidth or 180
    local barHeight = settings.barHeight or 18
    local centerGap = settings.centerGap or 96
    local centerOffsetY = settings.centerOffsetY or 280
    local sideRise = settings.sideRise or 26
    local sideRiseOffset = sideRise - 26

    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, settings.x or 0, centerOffsetY)
    root:SetDimensions(1, 1)
    root:SetAlpha(GetOutOfCombatAlpha())

    health:SetDimensions(healthWidth + 32, barHeight + 44)
    stamina:SetDimensions(sideWidth + 50, barHeight + 48)
    magicka:SetDimensions(sideWidth + 50, barHeight + 48)

    health:ClearAnchors()
    stamina:ClearAnchors()
    magicka:ClearAnchors()

    health:SetAnchor(BOTTOM, root, TOP, 0, layout.healthLift)
    stamina:SetAnchor(RIGHT, health, LEFT, -(centerGap + layout.sideDistance), -(layout.sideRise + sideRiseOffset))
    magicka:SetAnchor(LEFT, health, RIGHT, centerGap + layout.sideDistance, -(layout.sideRise + sideRiseOffset))

    self:ApplyBarTextureLayout(self.overlay.bars.health, layout.health, healthWidth, barHeight)
    self:ApplyBarTextureLayout(self.overlay.bars.stamina, layout.left, sideWidth, barHeight)
    self:ApplyBarTextureLayout(self.overlay.bars.magicka, layout.right, sideWidth, barHeight)

    local labelY = -(barHeight + 18)
    self.overlay.bars.health.caption:ClearAnchors()
    self.overlay.bars.health.caption:SetAnchor(BOTTOMLEFT, health, TOPLEFT, 10, labelY)
    self.overlay.bars.health.value:ClearAnchors()
    self.overlay.bars.health.value:SetAnchor(BOTTOMRIGHT, health, TOPRIGHT, -10, labelY)

    self.overlay.bars.stamina.caption:ClearAnchors()
    self.overlay.bars.stamina.caption:SetAnchor(BOTTOMLEFT, stamina, TOPLEFT, 0, -10)
    self.overlay.bars.stamina.value:ClearAnchors()
    self.overlay.bars.stamina.value:SetAnchor(BOTTOMRIGHT, stamina, TOPRIGHT, 0, -10)

    self.overlay.bars.magicka.caption:ClearAnchors()
    self.overlay.bars.magicka.caption:SetAnchor(BOTTOMLEFT, magicka, TOPLEFT, 0, -10)
    self.overlay.bars.magicka.value:ClearAnchors()
    self.overlay.bars.magicka.value:SetAnchor(BOTTOMRIGHT, magicka, TOPRIGHT, 0, -10)

    self:RefreshOverlayValues()
end

function EZO_HUD:RefreshOverlayVisibility()
    if not self.overlay then
        return
    end

    local enabled = self.sv and self.sv.overlay and self.sv.overlay.enabled
    self.overlay.root:SetHidden(not enabled)
    if enabled then
        self.overlay.root:SetAlpha(GetOutOfCombatAlpha())
    end
    self:ApplyVanillaVisibility()
end

function EZO_HUD:OnOverlayPowerUpdate(_, unitTag, _, powerType)
    if unitTag ~= "player" then
        return
    end

    if powerType == POWERTYPE_HEALTH then
        self:UpdateAttributeBar("health")
    elseif powerType == POWERTYPE_STAMINA then
        self:UpdateAttributeBar("stamina")
    elseif powerType == POWERTYPE_MAGICKA then
        self:UpdateAttributeBar("magicka")
    end
end

function EZO_HUD:BuildOverlayBar(parent, resourceName, segmentCount)
    local root = WINDOW_MANAGER:CreateControl(OVERLAY_NAME .. "_" .. resourceName, parent, CT_CONTROL)
    local entry = {
        root = root,
        caption = CreateLabel(root:GetName() .. "_Caption", root),
        value = CreateLabel(root:GetName() .. "_Value", root),
        segments = {},
        color = RESOURCE_COLORS[resourceName],
    }

    entry.caption:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    entry.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    for index = 1, segmentCount do
        entry.segments[index] = BuildSegment(root, root:GetName() .. "_Segment" .. index, PLACEHOLDER_TEXTURE, entry.color)
    end

    return entry
end

function EZO_HUD:InitializeOverlay()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(OVERLAY_NAME)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDimensions(1, 1)
    root:SetHidden(false)

    self.overlay = {
        root = root,
        bars = {
            health = self:BuildOverlayBar(root, "health", 5),
            stamina = self:BuildOverlayBar(root, "stamina", 4),
            magicka = self:BuildOverlayBar(root, "magicka", 4),
        },
    }

    self:RefreshOverlayText()
    self:ApplyOverlayLayout()
    self:RefreshOverlayVisibility()

    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_OverlayPower", EVENT_POWER_UPDATE, function(...)
        self:OnOverlayPowerUpdate(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_OverlayActivated", EVENT_PLAYER_ACTIVATED, function()
        self:RefreshOverlayValues()
        self:ApplyOverlayLayout()
        self:RefreshOverlayVisibility()
    end)

    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_OverlayCombat", EVENT_PLAYER_COMBAT_STATE, function()
        self:RefreshOverlayVisibility()
    end)
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

    if not (lam and type(lam.RegisterAddonPanel) == "function" and type(lam.RegisterOptionControls) == "function") then
        if self.Print then
            self.Print(GetString(EZO_HUD_MSG_LAM_MISSING))
        end
        return
    end

    EZOhud_LAM.RegisterSection("general", 10, function()
        return {
            {
                type = "header",
                name = GetString(EZO_HUD_OPTION_GENERAL),
            },
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
                end,
                width = "half",
            },
        }
    end)

    EZOhud_LAM.RegisterSection("overlay", 20, function()
        return {
            {
                type = "header",
                name = GetString(EZO_HUD_OPTION_OVERLAY),
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_OVERLAY_ENABLE),
                tooltip = GetString(EZO_HUD_OPTION_OVERLAY_ENABLE_TOOLTIP),
                getFunc = function() return self.sv.overlay.enabled end,
                setFunc = function(value)
                    self.sv.overlay.enabled = value
                    self:RefreshOverlayVisibility()
                end,
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(EZO_HUD_OPTION_HIDE_VANILLA),
                tooltip = GetString(EZO_HUD_OPTION_HIDE_VANILLA_TOOLTIP),
                getFunc = function() return self.sv.overlay.hideVanillaAttributes end,
                setFunc = function(value)
                    self.sv.overlay.hideVanillaAttributes = value
                    self:ApplyVanillaVisibility()
                end,
                width = "full",
            },
            {
                type = "dropdown",
                name = GetString(EZO_HUD_OPTION_STYLE),
                tooltip = GetString(EZO_HUD_OPTION_STYLE_TOOLTIP),
                choices = {
                    GetString(EZO_HUD_STYLE_CONE),
                    GetString(EZO_HUD_STYLE_ARC),
                },
                getFunc = function()
                    return (self.sv.overlay.style == "arc") and GetString(EZO_HUD_STYLE_ARC) or GetString(EZO_HUD_STYLE_CONE)
                end,
                setFunc = function(value)
                    self.sv.overlay.style = (value == GetString(EZO_HUD_STYLE_ARC)) and "arc" or "cone"
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_CENTER_OFFSET),
                tooltip = GetString(EZO_HUD_OPTION_CENTER_OFFSET_TOOLTIP),
                min = 150,
                max = 420,
                step = 5,
                getFunc = function() return self.sv.overlay.centerOffsetY end,
                setFunc = function(value)
                    self.sv.overlay.centerOffsetY = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_CENTER_GAP),
                tooltip = GetString(EZO_HUD_OPTION_CENTER_GAP_TOOLTIP),
                min = 40,
                max = 180,
                step = 2,
                getFunc = function() return self.sv.overlay.centerGap end,
                setFunc = function(value)
                    self.sv.overlay.centerGap = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_HEALTH_WIDTH),
                min = 120,
                max = 360,
                step = 5,
                getFunc = function() return self.sv.overlay.healthWidth end,
                setFunc = function(value)
                    self.sv.overlay.healthWidth = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_SIDE_WIDTH),
                min = 120,
                max = 300,
                step = 5,
                getFunc = function() return self.sv.overlay.sideWidth end,
                setFunc = function(value)
                    self.sv.overlay.sideWidth = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_BAR_HEIGHT),
                min = 10,
                max = 36,
                step = 1,
                getFunc = function() return self.sv.overlay.barHeight end,
                setFunc = function(value)
                    self.sv.overlay.barHeight = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_SIDE_RISE),
                tooltip = GetString(EZO_HUD_OPTION_SIDE_RISE_TOOLTIP),
                min = 0,
                max = 120,
                step = 2,
                getFunc = function() return self.sv.overlay.sideRise end,
                setFunc = function(value)
                    self.sv.overlay.sideRise = value
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
            {
                type = "slider",
                name = GetString(EZO_HUD_OPTION_OUT_OF_COMBAT_ALPHA),
                min = 0.2,
                max = 1.0,
                step = 0.05,
                getFunc = function() return self.sv.overlay.outOfCombatAlpha end,
                setFunc = function(value)
                    self.sv.overlay.outOfCombatAlpha = value
                    self:RefreshOverlayVisibility()
                    self:ApplyOverlayLayout()
                end,
                width = "half",
            },
        }
    end)

    local panelData = {
        type = "panel",
        name = GetString(EZO_HUD_PANEL_NAME),
        displayName = GetString(EZO_HUD_LABEL_NAME),
        author = GetString(EZO_HUD_PANEL_AUTHOR),
        version = self.ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    lam:RegisterAddonPanel(self.ADDON_NAME .. "_LAM", panelData)
    lam:RegisterOptionControls(self.ADDON_NAME .. "_LAM", EZOhud_LAM.BuildOptions())
end
