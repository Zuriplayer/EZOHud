EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CUSTOM_QUEST_TRACKER_NAME = "EZOhud_CustomQuestTracker"
local NATIVE_HIDDEN_REASON = "EZOhud_CustomQuestTracker"
local PANEL_WIDTH = 360
local PANEL_HEIGHT = 140
local OBJECTIVE_LINES = 2
local HINT_LINES = 2

local function GetCustomQuestTrackerSettings()
    if EZO_HUD.sv and not EZO_HUD.sv.customQuestTracker then
        EZO_HUD.sv.customQuestTracker = {
            enabled = EZO_HUD.defaults.customQuestTracker.enabled,
            movable = EZO_HUD.defaults.customQuestTracker.movable,
            offsetX = EZO_HUD.defaults.customQuestTracker.offsetX,
            offsetY = EZO_HUD.defaults.customQuestTracker.offsetY,
            scale = EZO_HUD.defaults.customQuestTracker.scale,
            showHints = EZO_HUD.defaults.customQuestTracker.showHints,
        }
    end
    return (EZO_HUD.sv and EZO_HUD.sv.customQuestTracker) or EZO_HUD.defaults.customQuestTracker
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result1, result2, result3, result4, result5, result6, result7, result8, result9, result10 = pcall(fn, ...)
    if ok then
        return result1, result2, result3, result4, result5, result6, result7, result8, result9, result10
    end
end

local function IsStringPresent(value)
    return value ~= nil and value ~= ""
end

local function AddLine(lines, value, maxLines)
    if #lines >= maxLines or not IsStringPresent(value) then return end
    table.insert(lines, zo_strformat(value))
end

local function SetLabelMaxOneLine(label)
    if type(label.SetMaxLineCount) == "function" then
        label:SetMaxLineCount(1)
    end
    if type(label.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

local function SetLabelMaxLines(label, maxLines)
    if type(label.SetMaxLineCount) == "function" then
        label:SetMaxLineCount(maxLines)
    end
    if type(label.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

local function SetFragmentHidden(fragment, hidden)
    if fragment and type(fragment.SetHiddenForReason) == "function" then
        fragment:SetHiddenForReason(NATIVE_HIDDEN_REASON, hidden, 0, 0)
    end
end

local function SetControlAlpha(control, alpha)
    if control and type(control.SetAlpha) == "function" then
        control:SetAlpha(alpha)
    end
end

local function SetNativeQuestTrackerHidden(hidden)
    SetFragmentHidden(FOCUSED_QUEST_TRACKER_FRAGMENT, hidden)
    SetControlAlpha(ZO_FocusedQuestTrackerPanel, hidden and 0 or 1)
end

local function GetFocusedQuestIndex()
    if GetNumTracked and GetTrackedByIndex and GetTrackedIsAssisted and TRACK_TYPE_QUEST then
        local numTracked = SafeCall(GetNumTracked) or 0
        for index = 1, numTracked do
            local trackType, arg1, arg2 = SafeCall(GetTrackedByIndex, index)
            if trackType == TRACK_TYPE_QUEST and SafeCall(GetTrackedIsAssisted, trackType, arg1, arg2) then
                return arg1
            end
        end
    end

    if QUEST_JOURNAL_MANAGER and type(QUEST_JOURNAL_MANAGER.GetFocusedQuestIndex) == "function" then
        local questIndex = SafeCall(QUEST_JOURNAL_MANAGER.GetFocusedQuestIndex, QUEST_JOURNAL_MANAGER)
        if questIndex then return questIndex end
    end

    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.assistedData then
        local data = FOCUSED_QUEST_TRACKER.assistedData
        if type(data.GetJournalIndex) == "function" then
            local questIndex = SafeCall(data.GetJournalIndex, data)
            if questIndex then return questIndex end
        end
        return data.arg1
    end
end

local function GetHintHeaderText()
    if SI_QUEST_HINT_STEP_HEADER then
        return GetString(SI_QUEST_HINT_STEP_HEADER)
    end
    return GetString(EZO_HUD_CUSTOM_QUEST_TRACKER_HINTS)
end

local function FormatHintText(text)
    if SI_QUEST_HINT_STEP_FORMAT then
        return zo_strformat(SI_QUEST_HINT_STEP_FORMAT, text)
    end
    return zo_strformat("* <<1>>", text)
end

local function FormatOrText(text)
    if SI_QUEST_OR_CONDITION_FORMAT then
        return zo_strformat(SI_QUEST_OR_CONDITION_FORMAT, text)
    end
    return zo_strformat("* <<1>>", text)
end

local function CollectStepLines(questIndex, startStep, desiredVisibility, maxLines)
    local lines = {}
    local numSteps = SafeCall(GetJournalQuestNumSteps, questIndex) or 0
    for stepIndex = startStep, numSteps do
        local _, visibility, stepType, stepOverrideText, conditionCount = SafeCall(GetJournalQuestStepInfo, questIndex, stepIndex)
        if desiredVisibility == nil or visibility == desiredVisibility then
            if IsStringPresent(stepOverrideText) then
                if visibility == QUEST_STEP_VISIBILITY_HINT then
                    AddLine(lines, FormatHintText(stepOverrideText), maxLines)
                else
                    AddLine(lines, stepOverrideText, maxLines)
                end
            elseif conditionCount then
                for conditionIndex = 1, conditionCount do
                    local conditionText, _curCount, _maxCount, isFailCondition, isComplete, _isGroupCreditShared, isVisible =
                        SafeCall(GetJournalQuestConditionInfo, questIndex, stepIndex, conditionIndex)
                    if not isFailCondition and not isComplete and isVisible and IsStringPresent(conditionText) then
                        if visibility == QUEST_STEP_VISIBILITY_HINT then
                            AddLine(lines, FormatHintText(conditionText), maxLines)
                        elseif stepType == QUEST_STEP_TYPE_OR then
                            AddLine(lines, FormatOrText(conditionText), maxLines)
                        else
                            AddLine(lines, conditionText, maxLines)
                        end
                    end
                    if #lines >= maxLines then return lines end
                end
            end
        end
        if #lines >= maxLines then return lines end
    end
    return lines
end

local function GetQuestDisplayData(questIndex)
    if not questIndex or not IsValidQuestIndex or not IsValidQuestIndex(questIndex) then
        return nil
    end

    local questName, _backgroundText, _activeStepText, _stepType, stepTrackerText, isComplete =
        SafeCall(GetJournalQuestInfo, questIndex)
    if not IsStringPresent(questName) then
        return nil
    end

    local mainStepIndex = QUEST_MAIN_STEP_INDEX or 1
    local objectiveLines = {}
    AddLine(objectiveLines, stepTrackerText, OBJECTIVE_LINES)
    for _, line in ipairs(CollectStepLines(questIndex, mainStepIndex, nil, OBJECTIVE_LINES)) do
        AddLine(objectiveLines, line, OBJECTIVE_LINES)
    end
    if #objectiveLines == 0 and isComplete then
        AddLine(objectiveLines, GetString(EZO_HUD_CUSTOM_QUEST_TRACKER_COMPLETE), OBJECTIVE_LINES)
    end
    if #objectiveLines == 0 then
        AddLine(objectiveLines, questName, OBJECTIVE_LINES)
    end

    local hintStartStep = mainStepIndex + 1
    local hintLines = {}
    if QUEST_STEP_VISIBILITY_HINT then
        hintLines = CollectStepLines(questIndex, hintStartStep, QUEST_STEP_VISIBILITY_HINT, HINT_LINES)
    end

    return {
        title = questName,
        objective = table.concat(objectiveLines, "\n"),
        hints = hintLines,
    }
end

local function BuildCustomQuestTracker()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CUSTOM_QUEST_TRACKER_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_Bg", root, CT_BACKDROP)
    bg:SetAnchorFill(root)
    bg:SetCenterColor(0, 0, 0, 0.28)
    bg:SetEdgeColor(0, 1, 0, 0.85)
    bg:SetEdgeTexture("", 1, 1, 2, 0)
    bg:SetHidden(true)

    local keybind = WINDOW_MANAGER:CreateControlFromVirtual(CUSTOM_QUEST_TRACKER_NAME .. "_Keybind", root, "ZO_KeybindButton")
    keybind:SetMouseEnabled(false)
    keybind:SetKeybind("ASSIST_NEXT_TRACKED_QUEST", false)

    local title = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_Title", root, CT_LABEL)
    title:SetFont("ZoFontWinH3")
    title:SetColor(1.0, 0.86, 0.22, 1.0)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetMouseEnabled(false)
    SetLabelMaxOneLine(title)

    local objective = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_Objective", root, CT_LABEL)
    objective:SetFont("ZoFontWinH2")
    objective:SetColor(1, 1, 1, 1)
    objective:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    objective:SetVerticalAlignment(TEXT_ALIGN_TOP)
    objective:SetMouseEnabled(false)
    SetLabelMaxLines(objective, OBJECTIVE_LINES)

    local hintsHeader = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_HintsHeader", root, CT_LABEL)
    hintsHeader:SetFont("ZoFontGameBold")
    hintsHeader:SetColor(0.92, 0.86, 0.58, 0.86)
    hintsHeader:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hintsHeader:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hintsHeader:SetMouseEnabled(false)
    SetLabelMaxOneLine(hintsHeader)

    local hintOne = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_HintOne", root, CT_LABEL)
    hintOne:SetFont("ZoFontGameLarge")
    hintOne:SetColor(0.72, 0.72, 0.64, 0.92)
    hintOne:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hintOne:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hintOne:SetMouseEnabled(false)
    SetLabelMaxOneLine(hintOne)

    local hintTwo = WINDOW_MANAGER:CreateControl(CUSTOM_QUEST_TRACKER_NAME .. "_HintTwo", root, CT_LABEL)
    hintTwo:SetFont("ZoFontGameLarge")
    hintTwo:SetColor(0.72, 0.72, 0.64, 0.92)
    hintTwo:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hintTwo:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hintTwo:SetMouseEnabled(false)
    SetLabelMaxOneLine(hintTwo)

    root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT
            and EZO_HUD:IsMoveModeEnabled("customQuestTracker")
            and not EZO_HUD.customQuestTrackerDragActive then
            control:StartMoving()
            EZO_HUD.customQuestTrackerDragActive = true
        end
    end)
    root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and EZO_HUD.customQuestTrackerDragActive then
            control:StopMovingOrResizing()
            EZO_HUD.customQuestTrackerDragActive = false
            EZO_HUD:SaveCustomQuestTrackerPosition()
        end
    end)

    return {
        root = root,
        bg = bg,
        keybind = keybind,
        title = title,
        objective = objective,
        hintsHeader = hintsHeader,
        hints = { hintOne, hintTwo },
    }
end

function EZO_HUD:ApplyCustomQuestTrackerLayout()
    if not self.customQuestTracker then return end

    local settings = GetCustomQuestTrackerSettings()
    local scale = settings.scale or 1.0
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.offsetX or 390) - (PANEL_WIDTH / 2))
    local top = zo_floor((guiHeight / 2) + (settings.offsetY or -210) - (PANEL_HEIGHT / 2))

    self.customQuestTracker.root:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    self.customQuestTracker.root:SetScale(scale)
    self.customQuestTracker.root:ClearAnchors()
    self.customQuestTracker.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.customQuestTracker.keybind:SetDimensions(36, 36)
    self.customQuestTracker.keybind:ClearAnchors()
    self.customQuestTracker.keybind:SetAnchor(TOPLEFT, self.customQuestTracker.root, TOPLEFT, 0, 10)

    self.customQuestTracker.title:SetDimensions(PANEL_WIDTH - 44, 28)
    self.customQuestTracker.title:ClearAnchors()
    self.customQuestTracker.title:SetAnchor(TOPLEFT, self.customQuestTracker.keybind, TOPRIGHT, 6, 3)

    self.customQuestTracker.objective:SetDimensions(PANEL_WIDTH, 54)
    self.customQuestTracker.objective:ClearAnchors()
    self.customQuestTracker.objective:SetAnchor(TOPLEFT, self.customQuestTracker.root, TOPLEFT, 0, 48)

    self.customQuestTracker.hintsHeader:SetDimensions(PANEL_WIDTH, 20)
    self.customQuestTracker.hintsHeader:ClearAnchors()
    self.customQuestTracker.hintsHeader:SetAnchor(TOPRIGHT, self.customQuestTracker.objective, BOTTOMRIGHT, 0, 0)

    self.customQuestTracker.hints[1]:SetDimensions(PANEL_WIDTH, 24)
    self.customQuestTracker.hints[1]:ClearAnchors()
    self.customQuestTracker.hints[1]:SetAnchor(TOPRIGHT, self.customQuestTracker.hintsHeader, BOTTOMRIGHT, 0, 0)

    self.customQuestTracker.hints[2]:SetDimensions(PANEL_WIDTH, 24)
    self.customQuestTracker.hints[2]:ClearAnchors()
    self.customQuestTracker.hints[2]:SetAnchor(TOPRIGHT, self.customQuestTracker.hints[1], BOTTOMRIGHT, 0, 0)

    self:RefreshCustomQuestTrackerMovementState()
end

function EZO_HUD:SaveCustomQuestTrackerPosition()
    if not self.customQuestTracker then return end

    local settings = GetCustomQuestTrackerSettings()
    local left = self.customQuestTracker.root:GetLeft()
    local top = self.customQuestTracker.root:GetTop()
    local width, height = self.customQuestTracker.root:GetDimensions()

    local centerX = left + (width / 2)
    local centerY = top + (height / 2)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()

    settings.offsetX = zo_floor(centerX - (guiWidth / 2))
    settings.offsetY = zo_floor(centerY - (guiHeight / 2))

    self:ApplyCustomQuestTrackerLayout()
end

function EZO_HUD:RefreshCustomQuestTrackerMovementState()
    if not self.customQuestTracker then return end

    local isMovable = self:IsMoveModeEnabled("customQuestTracker")
    if self.customQuestTrackerDragActive and not isMovable then
        self.customQuestTracker.root:StopMovingOrResizing()
        self.customQuestTrackerDragActive = false
    end
    self.customQuestTracker.root:SetMovable(false)
    self.customQuestTracker.root:SetMouseEnabled(isMovable)
    self.customQuestTracker.bg:SetHidden(not isMovable)
end

local function SetHintLabel(label, text)
    label:SetText(text or "")
    label:SetHidden(not IsStringPresent(text))
end

function EZO_HUD:RefreshCustomQuestTracker()
    if not self.customQuestTracker then return end

    local settings = GetCustomQuestTrackerSettings()
    local isHudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    local isMovable = self:IsMoveModeEnabled("customQuestTracker")

    SetNativeQuestTrackerHidden(settings.enabled == true)

    if not isHudVisible then
        self.customQuestTracker.root:SetHidden(true)
        return
    end

    if isMovable then
        self.customQuestTracker.title:SetText(GetString(EZO_HUD_CUSTOM_QUEST_TRACKER_PREVIEW_TITLE))
        self.customQuestTracker.objective:SetText(GetString(EZO_HUD_CUSTOM_QUEST_TRACKER_PREVIEW_OBJECTIVE))
        self.customQuestTracker.hintsHeader:SetText(GetHintHeaderText())
        self.customQuestTracker.hintsHeader:SetHidden(settings.showHints ~= true)
        SetHintLabel(self.customQuestTracker.hints[1], settings.showHints and GetString(EZO_HUD_CUSTOM_QUEST_TRACKER_PREVIEW_HINT) or nil)
        SetHintLabel(self.customQuestTracker.hints[2], nil)
        self.customQuestTracker.root:SetHidden(false)
        return
    end

    if not settings.enabled then
        self.customQuestTracker.root:SetHidden(true)
        return
    end

    local questIndex = GetFocusedQuestIndex()
    local questData = GetQuestDisplayData(questIndex)
    if not questData then
        self.customQuestTracker.root:SetHidden(true)
        return
    end

    self.customQuestTracker.title:SetText(questData.title)
    self.customQuestTracker.objective:SetText(questData.objective)

    local showHints = settings.showHints == true and #questData.hints > 0
    self.customQuestTracker.hintsHeader:SetText(GetHintHeaderText())
    self.customQuestTracker.hintsHeader:SetHidden(not showHints)
    SetHintLabel(self.customQuestTracker.hints[1], showHints and questData.hints[1] or nil)
    SetHintLabel(self.customQuestTracker.hints[2], showHints and questData.hints[2] or nil)

    self.customQuestTracker.root:SetHidden(false)
end

function EZO_HUD:InitializeCustomQuestTracker()
    if self.customQuestTracker then return end

    GetCustomQuestTrackerSettings()

    self.customQuestTracker = BuildCustomQuestTracker()
    self:ApplyCustomQuestTrackerLayout()
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.customQuestTracker.root)
    end

    local refresh = function()
        self:RefreshCustomQuestTracker()
    end

    local eventNamespace = self.ADDON_NAME .. "_CustomQuestTracker"
    local events = {
        EVENT_PLAYER_ACTIVATED,
        EVENT_QUEST_ADDED,
        EVENT_QUEST_REMOVED,
        EVENT_QUEST_ADVANCED,
        EVENT_QUEST_CONDITION_COUNTER_CHANGED,
        EVENT_QUEST_CONDITION_OVERRIDE_TEXT_CHANGED,
        EVENT_TRACKING_UPDATE,
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
    }

    for _, eventId in ipairs(events) do
        if eventId then
            EVENT_MANAGER:RegisterForEvent(eventNamespace, eventId, refresh)
        end
    end

    if CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        CALLBACK_MANAGER:RegisterCallback("QuestTrackerUpdatedOnScreen", refresh)
    end
    if FOCUSED_QUEST_TRACKER and type(FOCUSED_QUEST_TRACKER.RegisterCallback) == "function" then
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", refresh)
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", refresh)
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerInitialUpdate", refresh)
    end

    refresh()
end

EZOhud_LAM.RegisterSection("customQuestTracker", 62, function()
    local settings = GetCustomQuestTrackerSettings()
    return {
        EZOhud_LAM.CreateInfoHeader(
            GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER),
            GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_HEADER_TOOLTIP)
        ),
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_ENABLE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_ENABLE_TOOLTIP),
            getFunc = function() return settings.enabled end,
            setFunc = function(value)
                settings.enabled = value
                EZO_HUD:RefreshCustomQuestTrackerMovementState()
                EZO_HUD:RefreshCustomQuestTracker()
            end,
            default = EZO_HUD.defaults.customQuestTracker.enabled,
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_MOVE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_MOVE_TOOLTIP),
            getFunc = function() return EZO_HUD:IsMoveModeEnabled("customQuestTracker") end,
            setFunc = function(value)
                EZO_HUD:SetMoveModeEnabled("customQuestTracker", value)
                EZO_HUD:RefreshCustomQuestTrackerMovementState()
                EZO_HUD:RefreshCustomQuestTracker()
            end,
            disabled = function() return not settings.enabled end,
            default = false,
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_SCALE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_SCALE_TOOLTIP),
            min = 70,
            max = 180,
            step = 5,
            getFunc = function() return zo_floor((settings.scale or 1.0) * 100) end,
            setFunc = function(value)
                settings.scale = value / 100
                EZO_HUD:ApplyCustomQuestTrackerLayout()
                EZO_HUD:RefreshCustomQuestTracker()
            end,
            disabled = function() return not settings.enabled end,
            default = zo_floor(EZO_HUD.defaults.customQuestTracker.scale * 100),
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_SHOW_HINTS),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_QUEST_TRACKER_SHOW_HINTS_TOOLTIP),
            getFunc = function() return settings.showHints end,
            setFunc = function(value)
                settings.showHints = value
                EZO_HUD:RefreshCustomQuestTracker()
            end,
            disabled = function() return not settings.enabled end,
            default = EZO_HUD.defaults.customQuestTracker.showHints,
        },
    }
end)
