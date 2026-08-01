EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CUSTOM_COMPANION_NAME = "EZOhud_CustomCompanion"
local NATIVE_HIDDEN_REASON = "EZOhud_CustomCompanion"
local VISIBILITY_ALWAYS = "always"
local VISIBILITY_SOLO = "solo"
local VISIBILITY_GROUP = "group"
local HEALTH_TEXT_OFF = "off"
local HEALTH_TEXT_PERCENT = "percent"
local HEALTH_TEXT_CURRENT_MAX = "currentMax"
local HEALTH_TEXT_BOTH = "both"
local PANEL_HEIGHT = 76
local HEALTH_POWER_TYPE = COMBAT_MECHANIC_FLAGS_HEALTH or POWERTYPE_HEALTH

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

local function GetCustomCompanionSettings()
    if EZO_HUD.sv then
        EZO_HUD.sv.customCompanion = EZO_HUD.sv.customCompanion or DeepCopyTable(EZO_HUD.defaults.customCompanion)
        for key, value in pairs(EZO_HUD.defaults.customCompanion) do
            if EZO_HUD.sv.customCompanion[key] == nil then
                EZO_HUD.sv.customCompanion[key] = value
            end
        end
        return EZO_HUD.sv.customCompanion
    end

    return EZO_HUD.defaults.customCompanion
end

local function AreCustomCompanionSettingsDisabled()
    return not GetCustomCompanionSettings().enabled
end

local function IsGrouped()
    return type(IsUnitGrouped) == "function" and IsUnitGrouped("player") == true
end

local function ShouldShowInCurrentGroupState(settings)
    if settings.visibility == VISIBILITY_SOLO then
        return not IsGrouped()
    elseif settings.visibility == VISIBILITY_GROUP then
        return IsGrouped()
    end
    return true
end

local function VisibilityIncludesSolo(settings)
    return settings.visibility ~= VISIBILITY_GROUP
end

local function SetNativeCompanionHidden(hidden)
    if UNIT_FRAMES and type(UNIT_FRAMES.SetFrameHiddenForReason) == "function" then
        UNIT_FRAMES:SetFrameHiddenForReason("companion", NATIVE_HIDDEN_REASON, hidden == true)
        return
    end

    if type(ZO_UnitFrames_GetUnitFrame) == "function" then
        local unitFrame = ZO_UnitFrames_GetUnitFrame("companion")
        if unitFrame and type(unitFrame.SetHiddenForReason) == "function" then
            unitFrame:SetHiddenForReason(NATIVE_HIDDEN_REASON, hidden == true)
        end
    end
end

local function GetLocalCompanionUnitTag()
    if IsGrouped()
        and type(GetLocalPlayerGroupUnitTag) == "function"
        and type(GetCompanionUnitTagByGroupUnitTag) == "function" then
        local playerGroupTag = GetLocalPlayerGroupUnitTag()
        local companionTag = playerGroupTag and GetCompanionUnitTagByGroupUnitTag(playerGroupTag)
        if companionTag and type(DoesUnitExist) == "function" and DoesUnitExist(companionTag) then
            return companionTag
        end
    end

    if type(DoesUnitExist) == "function" and DoesUnitExist("companion") then
        return "companion"
    end

    return nil
end

local function FormatNumber(value)
    value = zo_floor(tonumber(value) or 0)
    if type(ZO_CommaDelimitNumber) == "function" then
        return ZO_CommaDelimitNumber(value)
    end
    return tostring(value)
end

local function FormatHealthText(mode, current, maximum)
    local percent = maximum > 0 and zo_floor(((current / maximum) * 100) + 0.5) or 0
    if mode == HEALTH_TEXT_OFF then
        return ""
    elseif mode == HEALTH_TEXT_PERCENT then
        return zo_strformat(GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_PERCENT), percent)
    elseif mode == HEALTH_TEXT_CURRENT_MAX then
        return zo_strformat(
            GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_CURRENT_MAX),
            FormatNumber(current),
            FormatNumber(maximum)
        )
    end
    return zo_strformat(
        GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_BOTH),
        FormatNumber(current),
        FormatNumber(maximum),
        percent
    )
end

local function GetCompanionDisplayName(unitTag)
    local name = unitTag and type(GetUnitName) == "function" and GetUnitName(unitTag) or ""
    if (not name or name == "")
        and type(GetActiveCompanionDefId) == "function"
        and type(_G.GetCompanionName) == "function" then
        local companionDefId = GetActiveCompanionDefId()
        if companionDefId and companionDefId > 0 then
            name = _G.GetCompanionName(companionDefId)
        end
    end

    if name and name ~= "" and SI_COMPANION_NAME_FORMATTER then
        return zo_strformat(SI_COMPANION_NAME_FORMATTER, name)
    end
    return GetString(EZO_HUD_CUSTOM_COMPANION_PREVIEW_NAME)
end

local function IsMatchingUnitTag(left, right)
    if not left or not right then return false end
    if left == right then return true end
    if type(AreUnitsEqual) == "function" then
        return AreUnitsEqual(left, right) == true
    end
    return false
end

local function BuildCustomCompanionPanel()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CUSTOM_COMPANION_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_CONTROLS)
    root:SetDrawTier(DT_MEDIUM)
    root:SetDrawLevel(20)
    root:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(CUSTOM_COMPANION_NAME .. "_Backdrop", root, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.015, 0.02, 0.02, 0.72)
    backdrop:SetEdgeColor(0.43, 0.40, 0.31, 0.9)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2)
    backdrop:SetInsets(6, 6, -6, -6)
    backdrop:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(CUSTOM_COMPANION_NAME .. "_Icon", root, CT_TEXTURE)
    icon:SetTexture("EsoUI/Art/MapPins/activeCompanion_pin.dds")
    icon:SetColor(0.58, 0.86, 0.79, 1)
    icon:SetMouseEnabled(false)

    local name = WINDOW_MANAGER:CreateControl(CUSTOM_COMPANION_NAME .. "_Name", root, CT_LABEL)
    name:SetFont("ZoFontGameBold")
    name:SetColor(0.94, 0.88, 0.70, 1)
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    name:SetMouseEnabled(false)
    if type(name.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    if type(name.SetMaxLineCount) == "function" then
        name:SetMaxLineCount(1)
    end

    local health = WINDOW_MANAGER:CreateControlFromVirtual(
        CUSTOM_COMPANION_NAME .. "_Health",
        root,
        "ZO_ArrowStatusBarWithBG"
    )
    health:SetColor(0.15, 0.56, 0.48, 1)
    health:SetMouseEnabled(false)

    local healthText = WINDOW_MANAGER:CreateControl(CUSTOM_COMPANION_NAME .. "_HealthText", root, CT_LABEL)
    healthText:SetFont("ZoFontGameSmall")
    healthText:SetColor(0.92, 0.92, 0.86, 1)
    healthText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    healthText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    healthText:SetMouseEnabled(false)
    if type(healthText.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        healthText:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    if type(healthText.SetMaxLineCount) == "function" then
        healthText:SetMaxLineCount(1)
    end

    root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and EZO_HUD:IsMoveModeEnabled("customCompanion") then
            EZO_HUD.customCompanionDragActive = true
            control:SetMovable(true)
            control:StartMoving()
        end
    end)

    root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and EZO_HUD:IsMoveModeEnabled("customCompanion") then
            control:StopMovingOrResizing()
            EZO_HUD.customCompanionDragActive = false
            control:SetMovable(false)
            EZO_HUD:SaveCustomCompanionPosition()
        end
    end)

    root:SetHandler("OnMoveStop", function()
        root:SetMovable(false)
        EZO_HUD.customCompanionDragActive = false
        EZO_HUD:SaveCustomCompanionPosition()
    end)

    return {
        root = root,
        backdrop = backdrop,
        icon = icon,
        name = name,
        health = health,
        healthText = healthText,
    }
end

function EZO_HUD:ApplyCustomCompanionLayout()
    if not self.customCompanion then return end

    local settings = GetCustomCompanionSettings()
    local width = zo_clamp(tonumber(settings.width) or 288, 220, 420)
    local scale = zo_clamp(tonumber(settings.scale) or 1, 0.7, 2)
    local alpha = zo_clamp(tonumber(settings.alpha) or 1, 0.3, 1)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.offsetX or -500) - (width / 2))
    local top = zo_floor((guiHeight / 2) + (settings.offsetY or -260) - (PANEL_HEIGHT / 2))
    local contentWidth = width - 58

    self.customCompanion.root:SetDimensions(width, PANEL_HEIGHT)
    self.customCompanion.root:SetScale(scale)
    self.customCompanion.root:SetAlpha(alpha)
    self.customCompanion.root:ClearAnchors()
    self.customCompanion.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.customCompanion.icon:SetDimensions(34, 34)
    self.customCompanion.icon:ClearAnchors()
    self.customCompanion.icon:SetAnchor(TOPLEFT, self.customCompanion.root, TOPLEFT, 10, 12)

    self.customCompanion.name:SetDimensions(contentWidth, 24)
    self.customCompanion.name:ClearAnchors()
    self.customCompanion.name:SetAnchor(TOPLEFT, self.customCompanion.root, TOPLEFT, 50, 7)

    self.customCompanion.health:SetDimensions(contentWidth, 10)
    self.customCompanion.health:ClearAnchors()
    self.customCompanion.health:SetAnchor(TOPLEFT, self.customCompanion.root, TOPLEFT, 50, 34)

    self.customCompanion.healthText:SetDimensions(contentWidth, 20)
    self.customCompanion.healthText:ClearAnchors()
    self.customCompanion.healthText:SetAnchor(TOPLEFT, self.customCompanion.root, TOPLEFT, 50, 47)

    self:RefreshCustomCompanionMovementState()
end

function EZO_HUD:RefreshCustomCompanionMovementState()
    if not self.customCompanion then return end

    local isMovable = self:IsMoveModeEnabled("customCompanion")
    if self.customCompanionDragActive and not isMovable then
        self.customCompanion.root:StopMovingOrResizing()
        self.customCompanionDragActive = false
    end

    self.customCompanion.root:SetMovable(false)
    self.customCompanion.root:SetMouseEnabled(isMovable)
    if isMovable then
        self.customCompanion.root:SetDrawLayer(DL_OVERLAY)
        self.customCompanion.root:SetDrawTier(DT_HIGH)
        self.customCompanion.root:SetDrawLevel(1000)
        self.customCompanion.backdrop:SetCenterColor(0.03, 0.12, 0.04, 0.82)
        self.customCompanion.backdrop:SetEdgeColor(0.20, 0.95, 0.30, 1)
    else
        self.customCompanion.root:SetDrawLayer(DL_CONTROLS)
        self.customCompanion.root:SetDrawTier(DT_MEDIUM)
        self.customCompanion.root:SetDrawLevel(20)
        self.customCompanion.backdrop:SetCenterColor(0.015, 0.02, 0.02, 0.72)
        self.customCompanion.backdrop:SetEdgeColor(0.43, 0.40, 0.31, 0.9)
    end
end

function EZO_HUD:SaveCustomCompanionPosition()
    if not self.customCompanion then return end

    local settings = GetCustomCompanionSettings()
    local left = self.customCompanion.root:GetLeft()
    local top = self.customCompanion.root:GetTop()
    local width, height = self.customCompanion.root:GetDimensions()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()

    if left and top and width and height then
        settings.offsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
        settings.offsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))
        self:ApplyCustomCompanionLayout()
    end
end

function EZO_HUD:RefreshCustomCompanion()
    if not self.customCompanion then return end

    local settings = GetCustomCompanionSettings()
    local isMovable = self:IsMoveModeEnabled("customCompanion")
    local isHudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    local shouldHideNative = settings.enabled == true
        and settings.hideNative == true
        and VisibilityIncludesSolo(settings)
    SetNativeCompanionHidden(shouldHideNative)

    if isMovable then
        self.customCompanion.name:SetText(GetString(EZO_HUD_CUSTOM_COMPANION_PREVIEW_NAME))
        self.customCompanion.health:SetMinMax(0, 32000)
        self.customCompanion.health:SetValue(27500)
        self.customCompanion.health:SetColor(0.15, 0.56, 0.48, 1)
        self.customCompanion.healthText:SetText(FormatHealthText(settings.healthTextMode, 27500, 32000))
        self.customCompanion.root:SetHidden(false)
        return
    end

    if not settings.enabled
        or not isHudVisible
        or not ShouldShowInCurrentGroupState(settings) then
        self.customCompanion.root:SetHidden(true)
        return
    end

    local unitTag = GetLocalCompanionUnitTag()
    if not unitTag then
        self.customCompanion.root:SetHidden(true)
        return
    end

    local current, maximum = GetUnitPower(unitTag, HEALTH_POWER_TYPE)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then
        self.customCompanion.root:SetHidden(true)
        return
    end

    local isDead = type(IsUnitDead) == "function" and IsUnitDead(unitTag) == true
    self.customCompanion.name:SetText(GetCompanionDisplayName(unitTag))
    self.customCompanion.health:SetMinMax(0, maximum)
    self.customCompanion.health:SetValue(zo_clamp(current, 0, maximum))
    self.customCompanion.health:SetColor(isDead and 0.39 or 0.15, isDead and 0.06 or 0.56, isDead and 0.09 or 0.48, 1)
    self.customCompanion.healthText:SetText(
        isDead and GetString(EZO_HUD_CUSTOM_COMPANION_DEAD)
        or FormatHealthText(settings.healthTextMode, current, maximum)
    )
    self.customCompanion.root:SetHidden(false)
end

function EZO_HUD:InitializeCustomCompanion()
    if self.customCompanion then return end

    GetCustomCompanionSettings()
    self.customCompanion = BuildCustomCompanionPanel()
    self:ApplyCustomCompanionLayout()
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.customCompanion.root)
    end

    local function refresh()
        self:RefreshCustomCompanion()
    end

    local function refreshDeferred()
        refresh()
        if type(zo_callLater) == "function" then
            zo_callLater(refresh, 100)
        end
    end

    local eventName = self.ADDON_NAME .. "_CustomCompanion"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, refreshDeferred)
    if EVENT_ACTIVE_COMPANION_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ACTIVE_COMPANION_STATE_CHANGED, refreshDeferred)
    end
    if EVENT_GROUP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_GROUP_UPDATE, refreshDeferred)
    end
    if EVENT_GROUP_MEMBER_JOINED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_GROUP_MEMBER_JOINED, refreshDeferred)
    end
    if EVENT_GROUP_MEMBER_LEFT then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_GROUP_MEMBER_LEFT, refreshDeferred)
    end
    if EVENT_UNIT_CREATED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_CREATED, refreshDeferred)
    end
    if EVENT_UNIT_DESTROYED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_DESTROYED, refreshDeferred)
    end
    if EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag)
            if IsMatchingUnitTag(unitTag, GetLocalCompanionUnitTag()) then
                refresh()
            end
        end)
    end
    if EVENT_POWER_UPDATE and HEALTH_POWER_TYPE then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_POWER_UPDATE, function(_, unitTag)
            if IsMatchingUnitTag(unitTag, GetLocalCompanionUnitTag()) then
                refresh()
            end
        end)
        if REGISTER_FILTER_POWER_TYPE then
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, HEALTH_POWER_TYPE)
        end
    end

    refreshDeferred()
end

EZOhud_LAM.RegisterSection("customCompanion", 69, function()
    local settings = GetCustomCompanionSettings()
    return {
        EZOhud_LAM.CreateInfoHeader(
            GetString(EZO_HUD_OPTION_CUSTOM_COMPANION),
            GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_HEADER_TOOLTIP)
        ),
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_ENABLE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_ENABLE_TOOLTIP),
            getFunc = function() return GetCustomCompanionSettings().enabled end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.enabled = value
                EZO_HUD:RefreshCustomCompanionMovementState()
                EZO_HUD:RefreshCustomCompanion()
                EZO_HUD:RequestSettingsPanelRefresh()
            end,
            default = EZO_HUD.defaults.customCompanion.enabled,
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_HIDE_NATIVE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_HIDE_NATIVE_TOOLTIP),
            getFunc = function() return GetCustomCompanionSettings().hideNative end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.hideNative = value
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = EZO_HUD.defaults.customCompanion.hideNative,
            width = "half",
        },
        {
            type = "dropdown",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_VISIBILITY),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_VISIBILITY_TOOLTIP),
            choices = {
                GetString(EZO_HUD_CUSTOM_COMPANION_VISIBILITY_ALWAYS),
                GetString(EZO_HUD_CUSTOM_COMPANION_VISIBILITY_SOLO),
                GetString(EZO_HUD_CUSTOM_COMPANION_VISIBILITY_GROUP),
            },
            choicesValues = { VISIBILITY_ALWAYS, VISIBILITY_SOLO, VISIBILITY_GROUP },
            getFunc = function() return GetCustomCompanionSettings().visibility end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.visibility = value
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = EZO_HUD.defaults.customCompanion.visibility,
            width = "half",
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_MOVE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_MOVE_TOOLTIP),
            getFunc = function() return EZO_HUD:IsMoveModeEnabled("customCompanion") end,
            setFunc = function(value)
                EZO_HUD:SetMoveModeEnabled("customCompanion", value)
                EZO_HUD:RefreshCustomCompanionMovementState()
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = false,
        },
        {
            type = "dropdown",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_HEALTH_TEXT),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_HEALTH_TEXT_TOOLTIP),
            choices = {
                GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_TEXT_OFF),
                GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_TEXT_PERCENT),
                GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_TEXT_CURRENT_MAX),
                GetString(EZO_HUD_CUSTOM_COMPANION_HEALTH_TEXT_BOTH),
            },
            choicesValues = { HEALTH_TEXT_OFF, HEALTH_TEXT_PERCENT, HEALTH_TEXT_CURRENT_MAX, HEALTH_TEXT_BOTH },
            getFunc = function() return GetCustomCompanionSettings().healthTextMode end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.healthTextMode = value
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = EZO_HUD.defaults.customCompanion.healthTextMode,
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_SCALE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_SCALE_TOOLTIP),
            min = 70,
            max = 200,
            step = 5,
            getFunc = function() return zo_floor((GetCustomCompanionSettings().scale or 1) * 100) end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.scale = value / 100
                EZO_HUD:ApplyCustomCompanionLayout()
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = zo_floor(EZO_HUD.defaults.customCompanion.scale * 100),
            width = "half",
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_WIDTH),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_WIDTH_TOOLTIP),
            min = 220,
            max = 420,
            step = 4,
            getFunc = function() return GetCustomCompanionSettings().width end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.width = value
                EZO_HUD:ApplyCustomCompanionLayout()
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = EZO_HUD.defaults.customCompanion.width,
            width = "half",
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_ALPHA),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_COMPANION_ALPHA_TOOLTIP),
            min = 30,
            max = 100,
            step = 5,
            getFunc = function() return zo_floor((GetCustomCompanionSettings().alpha or 1) * 100) end,
            setFunc = function(value)
                settings = GetCustomCompanionSettings()
                settings.alpha = value / 100
                EZO_HUD:ApplyCustomCompanionLayout()
                EZO_HUD:RefreshCustomCompanion()
            end,
            disabled = AreCustomCompanionSettingsDisabled,
            default = zo_floor(EZO_HUD.defaults.customCompanion.alpha * 100),
            width = "half",
        },
    }
end)
