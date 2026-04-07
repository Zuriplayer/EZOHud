EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local OVERLAY_NAME = "EZOhudOverlay"
local POWER_TYPE_BY_NAME = {
    health = POWERTYPE_HEALTH,
    stamina = POWERTYPE_STAMINA,
    magicka = POWERTYPE_MAGICKA,
}

local RESOURCE_COLORS = {
    health = { 0.82, 0.18, 0.22, 1.0 },
    stamina = { 0.21, 0.67, 0.29, 1.0 },
    magicka = { 0.22, 0.46, 0.88, 1.0 },
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

local function CreateBackdrop(name, parent)
    local backdrop = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    backdrop:SetCenterColor(0.02, 0.02, 0.03, 0.68)
    backdrop:SetEdgeColor(0.8, 0.8, 0.85, 0.22)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)
    return backdrop
end

local function CreateLabel(name, parent)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(0.95, 0.95, 0.98, 0.92)
    return label
end

local function CreateStatusBar(name, parent, color)
    local bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)
    bar:SetMinMax(0, 1)
    bar:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    bar:SetColor(unpack(color))
    bar:SetValue(1)
    return bar
end

local function GetVanillaAlpha()
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
    if not self.overlay or not self.overlay.bars then
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
    maximum = effectiveMaximum or maximum or 0
    local ratio = 0
    if maximum > 0 then
        ratio = Clamp(current / maximum, 0, 1)
    end

    barData.bar:SetValue(ratio)
    barData.value:SetText(string.format("%d / %d", zo_floor(current or 0), zo_floor(maximum or 0)))
end

function EZO_HUD:RefreshOverlayValues()
    self:UpdateAttributeBar("health")
    self:UpdateAttributeBar("stamina")
    self:UpdateAttributeBar("magicka")
end

function EZO_HUD:ApplyOverlayLayout()
    if not self.overlay then
        return
    end

    local settings = self.sv and self.sv.overlay or self.defaults.overlay
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
    local style = settings.style or "cone"
    local sideExtra = 0
    local healthLift = 0

    if style == "arc" then
        sideExtra = 20
        healthLift = 12
    end

    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, settings.x or 0, centerOffsetY)
    root:SetAlpha(GetVanillaAlpha())

    health:SetDimensions(healthWidth, barHeight + 22)
    stamina:SetDimensions(sideWidth, barHeight + 22)
    magicka:SetDimensions(sideWidth, barHeight + 22)

    health:ClearAnchors()
    stamina:ClearAnchors()
    magicka:ClearAnchors()

    if style == "arc" then
        health:SetAnchor(BOTTOM, root, TOP, 0, -healthLift)
        stamina:SetAnchor(RIGHT, health, LEFT, -(centerGap - 10), -(sideRise + 16))
        magicka:SetAnchor(LEFT, health, RIGHT, centerGap - 10, -(sideRise + 16))
    else
        health:SetAnchor(BOTTOM, root, TOP, 0, 0)
        stamina:SetAnchor(RIGHT, health, LEFT, -(centerGap + sideExtra), -sideRise)
        magicka:SetAnchor(LEFT, health, RIGHT, centerGap + sideExtra, -sideRise)
    end

    for _, resourceName in ipairs({ "health", "stamina", "magicka" }) do
        local entry = self.overlay.bars[resourceName]
        entry.backdrop:ClearAnchors()
        entry.backdrop:SetAnchor(TOPLEFT, entry.root, TOPLEFT, 0, 0)
        entry.backdrop:SetAnchor(BOTTOMRIGHT, entry.root, BOTTOMRIGHT, 0, 0)

        entry.caption:ClearAnchors()
        entry.caption:SetAnchor(BOTTOMLEFT, entry.root, TOPLEFT, 4, -2)

        entry.value:ClearAnchors()
        entry.value:SetAnchor(BOTTOMRIGHT, entry.root, TOPRIGHT, -4, -2)

        entry.bar:ClearAnchors()
        entry.bar:SetAnchor(BOTTOMLEFT, entry.root, BOTTOMLEFT, 0, 0)
        entry.bar:SetDimensions(entry.root:GetWidth(), barHeight)
    end

    self:RefreshOverlayValues()
end

function EZO_HUD:RefreshOverlayVisibility()
    if not self.overlay then
        return
    end

    local enabled = self.sv and self.sv.overlay and self.sv.overlay.enabled
    self.overlay.root:SetHidden(not enabled)
    if enabled then
        self.overlay.root:SetAlpha(GetVanillaAlpha())
    end
    self:ApplyVanillaVisibility()
end

function EZO_HUD:OnOverlayPowerUpdate(_, unitTag, powerIndex, powerType)
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

function EZO_HUD:BuildOverlayBar(parent, resourceName)
    local root = WINDOW_MANAGER:CreateControl(OVERLAY_NAME .. "_" .. resourceName, parent, CT_CONTROL)
    local entry = {
        root = root,
        backdrop = CreateBackdrop(root:GetName() .. "_Backdrop", root),
        caption = CreateLabel(root:GetName() .. "_Caption", root),
        value = CreateLabel(root:GetName() .. "_Value", root),
        bar = CreateStatusBar(root:GetName() .. "_Bar", root, RESOURCE_COLORS[resourceName]),
    }

    entry.caption:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    entry.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    entry.bar:SetAlpha(0.95)

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
            health = self:BuildOverlayBar(root, "health"),
            stamina = self:BuildOverlayBar(root, "stamina"),
            magicka = self:BuildOverlayBar(root, "magicka"),
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
    if not (LibAddonMenu2 and LibAddonMenu2.RegisterAddonPanel) then
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

    LibAddonMenu2:RegisterAddonPanel(self.ADDON_NAME .. "_LAM", panelData)
    LibAddonMenu2:RegisterOptionControls(self.ADDON_NAME .. "_LAM", EZOhud_LAM.BuildOptions())
end
