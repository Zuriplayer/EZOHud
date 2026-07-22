EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CUSTOM_GROUP_SEARCH_NAME = "EZOhud_CustomGroupSearch"
local NATIVE_HIDDEN_REASON = "EZOhud_CustomGroupSearch"
local PANEL_WIDTH = 250
local PANEL_HEIGHT = 96

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

local function GetCustomGroupSearchSettings()
    if EZO_HUD.sv then
        EZO_HUD.sv.customGroupSearch = EZO_HUD.sv.customGroupSearch or DeepCopyTable(EZO_HUD.defaults.customGroupSearch)
        for key, value in pairs(EZO_HUD.defaults.customGroupSearch) do
            if EZO_HUD.sv.customGroupSearch[key] == nil then
                EZO_HUD.sv.customGroupSearch[key] = value
            end
        end
        return EZO_HUD.sv.customGroupSearch
    end

    return EZO_HUD.defaults.customGroupSearch
end

local function SafeCall(func, ...)
    if type(func) ~= "function" then
        return nil
    end

    local ok, result1, result2, result3, result4, result5, result6 = pcall(func, ...)
    if not ok then
        return nil
    end

    return result1, result2, result3, result4, result5, result6
end

local function GetLocalizedString(id, fallback)
    if id ~= nil then
        local value = GetString(id)
        if value ~= nil and value ~= "" then
            return value
        end
    end

    return fallback or ""
end

local function GetActivityStatus()
    return SafeCall(GetActivityFinderStatus)
end

local function GetTrackedActivityId()
    if SafeCall(IsCurrentlySearchingForGroup) then
        return SafeCall(GetActivityRequestIds, 1)
    end

    if SafeCall(IsInLFGGroup) then
        return SafeCall(GetCurrentLFGActivityId)
    end

    return nil
end

local function GetActivityCategoryName(activityId)
    local activityType = activityId and SafeCall(GetActivityType, activityId) or nil
    if activityType == nil then
        return GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_TITLE, "Group Search")
    end

    if activityType == LFG_ACTIVITY_DUNGEON or activityType == LFG_ACTIVITY_MASTER_DUNGEON then
        return GetLocalizedString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER, "Dungeon Finder")
    elseif activityType == LFG_ACTIVITY_BATTLE_GROUND_CHAMPION
        or activityType == LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION
        or activityType == LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL then
        return GetLocalizedString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS, "Battlegrounds")
    elseif activityType == LFG_ACTIVITY_TRIBUTE_COMPETITIVE or activityType == LFG_ACTIVITY_TRIBUTE_CASUAL then
        return GetLocalizedString(SI_ACTIVITY_FINDER_CATEGORY_TRIBUTE, "Tales of Tribute")
    end

    return GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_TITLE, "Group Search")
end

local function GetActivityDisplayName(activityId)
    if activityId == nil or activityId == 0 then
        return GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_UNKNOWN_ACTIVITY, "Selected activity")
    end

    local activityName = SafeCall(GetActivityName, activityId)
    if activityName ~= nil and activityName ~= "" then
        return zo_strformat("<<C:1>>", activityName)
    end

    activityName = SafeCall(GetActivityInfo, activityId)
    if activityName ~= nil and activityName ~= "" then
        return zo_strformat("<<C:1>>", activityName)
    end

    return GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_UNKNOWN_ACTIVITY, "Selected activity")
end

local function GetSelectedRoleAcronym()
    local role = SafeCall(GetSelectedLFGRole)
    if role == LFG_ROLE_TANK then
        return "T"
    elseif role == LFG_ROLE_HEAL then
        return "H"
    elseif role == LFG_ROLE_DPS then
        return "DD"
    end

    return "-"
end

local function FormatMilliseconds(milliseconds)
    if type(ZO_FormatTimeMilliseconds) == "function" then
        return ZO_FormatTimeMilliseconds(milliseconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    end

    local totalSeconds = zo_floor((tonumber(milliseconds) or 0) / 1000)
    local minutes = zo_floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%d:%02d", minutes, seconds)
end

local function GetSearchDurationText(status)
    if status ~= ACTIVITY_FINDER_STATUS_QUEUED then
        return "--:--"
    end

    local searchStartTimeMs = SafeCall(GetLFGSearchTimes)
    if not searchStartTimeMs or searchStartTimeMs <= 0 then
        return "--:--"
    end

    return FormatMilliseconds(zo_max(0, GetFrameTimeMilliseconds() - searchStartTimeMs))
end

local function GetDestinationText(activityId)
    return zo_strformat(
        GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_DESTINATION_FORMAT, "Destination: <<1>>"),
        GetActivityDisplayName(activityId)
    )
end

local function GetMetaText(status)
    return zo_strformat(
        GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_META_FORMAT, "Search: <<1>> - <<2>>"),
        GetSearchDurationText(status),
        GetSelectedRoleAcronym()
    )
end

local function HasTrackedActivityState()
    if SafeCall(IsCurrentlySearchingForGroup) then
        return true
    end

    if SafeCall(IsInLFGGroup) then
        return true
    end

    return GetActivityStatus() == ACTIVITY_FINDER_STATUS_READY_CHECK
end

local function SetFragmentHidden(fragment, hidden)
    if fragment and type(fragment.SetHiddenForReason) == "function" then
        fragment:SetHiddenForReason(NATIVE_HIDDEN_REASON, hidden)
    end
end

local function SetControlAlpha(control, alpha)
    if control and type(control.SetAlpha) == "function" then
        control:SetAlpha(alpha)
    end
end

local function SetNativeActivityTrackerHidden(hidden)
    SetFragmentHidden(ACTIVITY_TRACKER_FRAGMENT, hidden)
    SetFragmentHidden(READY_CHECK_TRACKER_FRAGMENT, hidden)
    SetControlAlpha(ZO_ActivityTracker, hidden and 0 or 1)
    SetControlAlpha(ZO_ReadyCheckTrackerTopLevel, hidden and 0 or 1)
end

local function BuildCustomGroupSearchPanel()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CUSTOM_GROUP_SEARCH_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(CUSTOM_GROUP_SEARCH_NAME .. "_Bg", root, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    bg:SetInsets(8, 8, -8, -8)
    bg:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl(CUSTOM_GROUP_SEARCH_NAME .. "_Title", root, CT_LABEL)
    title:SetFont("ZoFontGameShadow")
    title:SetColor(0.93, 0.86, 0.62, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetMouseEnabled(false)

    local status = WINDOW_MANAGER:CreateControl(CUSTOM_GROUP_SEARCH_NAME .. "_Status", root, CT_LABEL)
    status:SetFont("ZoFontWinH3")
    status:SetColor(1, 1, 1, 1)
    status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    status:SetMouseEnabled(false)

    local destination = WINDOW_MANAGER:CreateControl(CUSTOM_GROUP_SEARCH_NAME .. "_Destination", root, CT_LABEL)
    destination:SetFont("ZoFontGameSmall")
    destination:SetColor(0.82, 0.82, 0.74, 1)
    destination:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    destination:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    destination:SetMouseEnabled(false)
    if type(destination.SetMaxLineCount) == "function" then
        destination:SetMaxLineCount(1)
    end
    if type(destination.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        destination:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    local meta = WINDOW_MANAGER:CreateControl(CUSTOM_GROUP_SEARCH_NAME .. "_Meta", root, CT_LABEL)
    meta:SetFont("ZoFontGameSmall")
    meta:SetColor(0.82, 0.82, 0.74, 1)
    meta:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    meta:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    meta:SetMouseEnabled(false)
    if type(meta.SetMaxLineCount) == "function" then
        meta:SetMaxLineCount(1)
    end
    if type(meta.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        meta:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and EZO_HUD:IsMoveModeEnabled("customGroupSearch") then
            EZO_HUD.customGroupSearchDragActive = true
            control:SetMovable(true)
            control:StartMoving()
        end
    end)

    root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and EZO_HUD:IsMoveModeEnabled("customGroupSearch") then
            control:StopMovingOrResizing()
            EZO_HUD.customGroupSearchDragActive = false
            control:SetMovable(false)
            if EZO_HUD.SaveCustomGroupSearchPosition then
                EZO_HUD:SaveCustomGroupSearchPosition()
            end
        end
    end)

    root:SetHandler("OnMoveStop", function()
        root:SetMovable(false)
        EZO_HUD.customGroupSearchDragActive = false
        if EZO_HUD.SaveCustomGroupSearchPosition then
            EZO_HUD:SaveCustomGroupSearchPosition()
        end
    end)

    return {
        root = root,
        bg = bg,
        title = title,
        status = status,
        destination = destination,
        meta = meta,
    }
end

function EZO_HUD:ApplyCustomGroupSearchLayout()
    if not self.customGroupSearch then return end

    local settings = GetCustomGroupSearchSettings()
    local scale = settings.scale or 1.0
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.offsetX or 360) - (PANEL_WIDTH / 2))
    local top = zo_floor((guiHeight / 2) + (settings.offsetY or -120) - (PANEL_HEIGHT / 2))

    self.customGroupSearch.root:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    self.customGroupSearch.root:SetScale(scale)
    self.customGroupSearch.root:ClearAnchors()
    self.customGroupSearch.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.customGroupSearch.title:SetDimensions(PANEL_WIDTH, 24)
    self.customGroupSearch.title:ClearAnchors()
    self.customGroupSearch.title:SetAnchor(TOPLEFT, self.customGroupSearch.root, TOPLEFT, 0, 3)

    self.customGroupSearch.status:SetDimensions(PANEL_WIDTH, 30)
    self.customGroupSearch.status:ClearAnchors()
    self.customGroupSearch.status:SetAnchor(TOPLEFT, self.customGroupSearch.title, BOTTOMLEFT, 0, -2)

    self.customGroupSearch.destination:SetDimensions(PANEL_WIDTH, 18)
    self.customGroupSearch.destination:ClearAnchors()
    self.customGroupSearch.destination:SetAnchor(TOPLEFT, self.customGroupSearch.status, BOTTOMLEFT, 0, -2)

    self.customGroupSearch.meta:SetDimensions(PANEL_WIDTH, 18)
    self.customGroupSearch.meta:ClearAnchors()
    self.customGroupSearch.meta:SetAnchor(TOPLEFT, self.customGroupSearch.destination, BOTTOMLEFT, 0, -2)

    self:RefreshCustomGroupSearchMovementState()
end

function EZO_HUD:RefreshCustomGroupSearchMovementState()
    if not self.customGroupSearch then return end

    local isMovable = self:IsMoveModeEnabled("customGroupSearch")
    if self.customGroupSearchDragActive and not isMovable then
        self.customGroupSearch.root:StopMovingOrResizing()
        self.customGroupSearchDragActive = false
    end
    self.customGroupSearch.root:SetMovable(false)
    self.customGroupSearch.root:SetMouseEnabled(isMovable)

    if isMovable then
        self.customGroupSearch.bg:SetCenterColor(0.05, 0.05, 0.02, 0.74)
        self.customGroupSearch.bg:SetEdgeColor(0.82, 0.75, 0.24, 1)
    else
        self.customGroupSearch.bg:SetCenterColor(0, 0, 0, 0)
        self.customGroupSearch.bg:SetEdgeColor(0, 0, 0, 0)
    end
end

function EZO_HUD:SaveCustomGroupSearchPosition()
    if not self.customGroupSearch then return end

    local settings = GetCustomGroupSearchSettings()
    local left = self.customGroupSearch.root:GetLeft()
    local top = self.customGroupSearch.root:GetTop()
    local width, height = self.customGroupSearch.root:GetDimensions()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()

    settings.offsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings.offsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))

    self:ApplyCustomGroupSearchLayout()
end

function EZO_HUD:RefreshCustomGroupSearch()
    if not self.customGroupSearch then return end

    local settings = GetCustomGroupSearchSettings()
    local isHudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    local isMovable = self:IsMoveModeEnabled("customGroupSearch")
    SetNativeActivityTrackerHidden(settings.enabled == true)

    if (not isHudVisible and not isMovable) or (not settings.enabled and not isMovable) then
        self.customGroupSearch.root:SetHidden(true)
        return
    end

    if isMovable then
        self.customGroupSearch.title:SetText(GetLocalizedString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER, "Dungeon Finder"))
        self.customGroupSearch.status:SetText(GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_PREVIEW_STATUS, "Queued"))
        self.customGroupSearch.destination:SetText(zo_strformat(
            GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_DESTINATION_FORMAT, "Destination: <<1>>"),
            GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_UNKNOWN_ACTIVITY, "Selected activity")
        ))
        self.customGroupSearch.meta:SetText(zo_strformat(
            GetLocalizedString(EZO_HUD_CUSTOM_GROUP_SEARCH_META_FORMAT, "Search: <<1>> - <<2>>"),
            "0:00",
            "DD"
        ))
        self.customGroupSearch.root:SetHidden(false)
        return
    end

    if not HasTrackedActivityState() then
        self.customGroupSearch.root:SetHidden(true)
        return
    end

    local status = GetActivityStatus()
    local activityId = GetTrackedActivityId()
    local title = GetActivityCategoryName(activityId)
    local statusText = status and GetString("SI_ACTIVITYFINDERSTATUS", status) or ""

    self.customGroupSearch.title:SetText(title)
    self.customGroupSearch.status:SetText(statusText)
    self.customGroupSearch.destination:SetText(GetDestinationText(activityId))
    self.customGroupSearch.meta:SetText(GetMetaText(status))
    self.customGroupSearch.root:SetHidden(false)
end

function EZO_HUD:InitializeCustomGroupSearch()
    if self.customGroupSearch then return end

    GetCustomGroupSearchSettings()

    self.customGroupSearch = BuildCustomGroupSearchPanel()
    self:ApplyCustomGroupSearchLayout()
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.customGroupSearch.root)
    end

    local refresh = function()
        self:RefreshCustomGroupSearch()
    end

    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomGroupSearch", EVENT_PLAYER_ACTIVATED, refresh)
    if EVENT_ACTIVITY_FINDER_STATUS_UPDATE then
        EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomGroupSearch", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, refresh)
    end
    if EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED then
        EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomGroupSearch", EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, refresh)
    end
    if EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED then
        EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomGroupSearch", EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, refresh)
    end
    if ZO_ACTIVITY_FINDER_ROOT_MANAGER and type(ZO_ACTIVITY_FINDER_ROOT_MANAGER.RegisterCallback) == "function" then
        ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnActivityFinderStatusUpdate", refresh)
    end

    EVENT_MANAGER:RegisterForUpdate(self.ADDON_NAME .. "_CustomGroupSearchTimer", 1000, refresh)
    refresh()
end

EZOhud_LAM.RegisterSection("customGroupSearch", 68, function()
    local settings = GetCustomGroupSearchSettings()
    return {
        EZOhud_LAM.CreateInfoHeader(
            GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH),
            GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_HEADER_TOOLTIP)
        ),
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_ENABLE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_ENABLE_TOOLTIP),
            getFunc = function() return settings.enabled end,
            setFunc = function(value)
                settings.enabled = value
                EZO_HUD:RefreshCustomGroupSearchMovementState()
                EZO_HUD:RefreshCustomGroupSearch()
            end,
            default = EZO_HUD.defaults.customGroupSearch.enabled,
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_MOVE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_MOVE_TOOLTIP),
            getFunc = function() return EZO_HUD:IsMoveModeEnabled("customGroupSearch") end,
            setFunc = function(value)
                EZO_HUD:SetMoveModeEnabled("customGroupSearch", value)
                EZO_HUD:RefreshCustomGroupSearchMovementState()
                EZO_HUD:RefreshCustomGroupSearch()
            end,
            disabled = function() return not settings.enabled end,
            default = false,
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_SCALE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_GROUP_SEARCH_SCALE_TOOLTIP),
            min = 70,
            max = 200,
            step = 5,
            getFunc = function() return zo_floor((settings.scale or 1.0) * 100) end,
            setFunc = function(value)
                settings.scale = value / 100
                EZO_HUD:ApplyCustomGroupSearchLayout()
                EZO_HUD:RefreshCustomGroupSearch()
            end,
            disabled = function() return not settings.enabled end,
            default = zo_floor(EZO_HUD.defaults.customGroupSearch.scale * 100),
        },
    }
end)
