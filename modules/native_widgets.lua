EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local originalStates = {}

local function Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
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

local function AnchorPreviewBackdrop(backdrop, control, widget)
    backdrop:ClearAnchors()
    if widget.previewAnchorToGuiRoot and widget.fallbackAnchor then
        local defaults = (EZO_HUD.defaults and EZO_HUD.defaults[widget.id]) or {}
        local settings = (EZO_HUD.sv and EZO_HUD.sv[widget.id]) or defaults
        local guiWidth, guiHeight = GuiRoot:GetDimensions()
        local width, height = backdrop:GetDimensions()
        local offsetX = tonumber(settings.offsetX) or defaults.offsetX or 0
        local offsetY = tonumber(settings.offsetY) or defaults.offsetY or 0
        local left = zo_floor((guiWidth / 2) + offsetX - (width / 2))
        local top = zo_floor(guiHeight + offsetY - height)
        backdrop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        backdrop:SetAnchor(CENTER, control or GuiRoot, CENTER, 0, 0)
    end
end

local function GetOrCreatePreviewBackdrop(control, widget)
    if not WINDOW_MANAGER or not widget then return nil end
    local controlName = control and control:GetName() or ("EZOhud_" .. widget.id)
    local backdropName = controlName .. "_EZOhudPreview"
    local previewRoot = _G[backdropName .. "_Root"]
    if not previewRoot then
        previewRoot = WINDOW_MANAGER:CreateTopLevelWindow(backdropName .. "_Root")
        previewRoot:SetClampedToScreen(true)
        previewRoot:SetDrawLayer(DL_OVERLAY)
        previewRoot:SetDrawTier(DT_HIGH)
        previewRoot:SetDrawLevel(1000)
        previewRoot:SetMouseEnabled(true)
        previewRoot:SetMovable(false)

        local previewDimensions = widget.previewDimensions or { width = 300, height = 100 }
        previewRoot:SetDimensions(previewDimensions.width, previewDimensions.height)

        local backdrop = WINDOW_MANAGER:CreateControl(backdropName, previewRoot, CT_BACKDROP)
        backdrop:SetAnchorFill()
        backdrop:SetCenterColor(0, 1, 0, 0.5)
        backdrop:SetEdgeColor(0, 1, 0, 1)
        backdrop:SetEdgeTexture("", 1, 1, 2, 0)
        backdrop:SetMouseEnabled(false)

        local label = WINDOW_MANAGER:CreateControl(backdropName .. "_Label", previewRoot, CT_LABEL)
        label:SetAnchorFill()
        label:SetFont("ZoFontWinH3")
        label:SetColor(1, 1, 1, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetMouseEnabled(false)
        label:SetText(GetString(_G[widget.stringIds.header] or 0) .. "\n" .. GetString(_G["EZO_HUD_NATIVE_WIDGET_MOVE_HANDLE"] or 0))

        previewRoot:SetHandler("OnMouseDown", function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                self.ezohudStartCenterX, self.ezohudStartCenterY = self:GetCenter()
                self:SetMovable(true)
                self:StartMoving()
            end
        end)

        previewRoot:SetHandler("OnMouseUp", function(self, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                self:StopMovingOrResizing()
                self:SetMovable(false)
            end
        end)

        previewRoot:SetHandler("OnMoveStop", function(self)
            local newCx, newCy = self:GetCenter()
            local oldCx = self.ezohudStartCenterX
            local oldCy = self.ezohudStartCenterY
            if not oldCx or not oldCy then
                if control then
                    oldCx, oldCy = control:GetCenter()
                else
                    oldCx, oldCy = newCx, newCy
                end
            end

            local diffX = newCx - oldCx
            local diffY = newCy - oldCy

            local settings = EZO_HUD.sv[widget.id]
            if settings then
                if widget.previewAnchorToGuiRoot then
                    local left = self:GetLeft()
                    local top = self:GetTop()
                    local width, height = self:GetDimensions()
                    local guiWidth, guiHeight = GuiRoot:GetDimensions()
                    if left and top and width and height then
                        settings.offsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
                        settings.offsetY = zo_floor((top + height) - guiHeight)
                    end
                else
                    settings.offsetX = (settings.offsetX or 0) + diffX
                    settings.offsetY = (settings.offsetY or 0) + diffY
                end
                if EZO_HUD.ApplyNativeWidgetLayout then
                    EZO_HUD:ApplyNativeWidgetLayout(widget.id)
                end
            end

            AnchorPreviewBackdrop(self, control, widget)
            self:SetMovable(false)
            self.ezohudStartCenterX, self.ezohudStartCenterY = nil, nil

            local refX = _G["EZOhud_" .. widget.id .. "_LAM_OffsetX"]
            if refX and refX.UpdateValue then refX:UpdateValue() end

            local refY = _G["EZOhud_" .. widget.id .. "_LAM_OffsetY"]
            if refY and refY.UpdateValue then refY:UpdateValue() end
        end)
    end
    local label = _G[backdropName .. "_Label"]
    if label then
        label:SetText(GetString(_G[widget.stringIds.header] or 0) .. "\n" .. GetString(_G["EZO_HUD_NATIVE_WIDGET_MOVE_HANDLE"] or 0))
    end
    AnchorPreviewBackdrop(previewRoot, control, widget)
    return previewRoot
end


local WIDGETS = {
    {
        id = "nativeCenterScreen",
        controlName = "ZO_CenterScreenAnnounce",
        fallbackAnchor = { TOP, GuiRoot, TOP, 0, 150 },
        minScale = 0.5,
        maxScale = 1.5,
        onPreviewOpen = function(self, control)
            if CENTER_SCREEN_ANNOUNCE then
                CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_SMALL_TEXT, nil, GetString(_G["EZO_HUD_PREVIEW_CSA"] or EZO_HUD_PREVIEW_CSA))
            end
            if control then
                control:SetHidden(false)
                control:SetAlpha(1)
                local backdrop = GetOrCreatePreviewBackdrop(control, self)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(self, control)
            if control then
                local backdrop = GetOrCreatePreviewBackdrop(control, self)
                if backdrop then backdrop:SetHidden(true) end
            end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_CSA",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_CSA_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_CSA_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_CSA_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_CSA_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_CSA_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_CSA_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_CSA_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_CSA_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_CSA_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_CSA_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_CSA_RESET_TOOLTIP",
        }
    },
    {
        id = "nativeCombatTips",
        controlName = { "ZO_ActiveCombatTip", "ZO_ActiveCombatTips", "ZO_ActiveCombatTipTopLevel", "ZO_ActiveCombatTipsTopLevel", "ACTIVE_COMBAT_TIP_SYSTEM" },
        fallbackAnchor = { BOTTOM, GuiRoot, BOTTOM, 0, -150 },
        minScale = 0.5,
        maxScale = 2.0,
        onPreviewOpen = function(self, control)
            if control then
                control:SetHidden(false)
                control:SetAlpha(1)
                local backdrop = GetOrCreatePreviewBackdrop(control, self)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(self, control)
            if control then
                local backdrop = GetOrCreatePreviewBackdrop(control, self)
                if backdrop then backdrop:SetHidden(true) end
            end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_COMBAT_TIPS_RESET_TOOLTIP",
        }
    },
    {
        id = "nativeDeathPrompt",
        controlName = "ZO_Death",
        fallbackAnchor = { BOTTOM, GuiRoot, BOTTOM, 0, -16 },
        minScale = 0.5,
        maxScale = 1.5,
        previewDimensions = { width = 800, height = 116 },
        previewAnchorToGuiRoot = true,
        allowPreviewWithoutControl = true,
        onPreviewOpen = function(self, control)
            local backdrop = GetOrCreatePreviewBackdrop(control, self)
            if backdrop then backdrop:SetHidden(false) end
        end,
        onPreviewClose = function(self, control)
            local backdrop = GetOrCreatePreviewBackdrop(control, self)
            if backdrop then backdrop:SetHidden(true) end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_DEATH_PROMPT_RESET_TOOLTIP",
        }
    }
}

local NATIVE_WIDGET_PREVIEW_DURATION_MS = 3000
local nativePreviewToken = 0

local function FindWidget(widgetId)
    for _, widget in ipairs(WIDGETS) do
        if widget.id == widgetId then
            return widget
        end
    end
    return nil
end

local function GetWidgetSettings(widgetId)
    if EZO_HUD.sv and not EZO_HUD.sv[widgetId] then
        EZO_HUD.sv[widgetId] = DeepCopyTable(EZO_HUD.defaults[widgetId])
    end
    return (EZO_HUD.sv and EZO_HUD.sv[widgetId]) or EZO_HUD.defaults[widgetId]
end

local function GetWidgetControls(widget)
    local controls = {}
    local function AddControl(name)
        local obj = _G[name]
        if not obj then return end
        if type(obj) == "userdata" and type(obj.GetScale) == "function" then
            table.insert(controls, {name = name, control = obj})
        elseif type(obj) == "table" and type(obj.control) == "userdata" and type(obj.control.GetScale) == "function" then
            table.insert(controls, {name = name, control = obj.control})
        end
    end

    if type(widget.controlName) == "table" then
        for _, name in ipairs(widget.controlName) do
            AddControl(name)
        end
    else
        AddControl(widget.controlName)
    end
    return controls
end

local function RunOnWidgetControls(widget, func)
    if not func then return end
    local controls = GetWidgetControls(widget)
    if #controls == 0 and widget.allowPreviewWithoutControl then
        func(widget, nil)
    end
    for _, wc in ipairs(controls) do
        func(widget, wc.control)
    end
end

local function CloseAllNativeWidgetPreviews()
    for _, widget in ipairs(WIDGETS) do
        RunOnWidgetControls(widget, widget.onPreviewClose)
    end
end

local function CloseTransientNativeWidgetPreviews()
    for _, widget in ipairs(WIDGETS) do
        if not EZO_HUD:IsMoveModeEnabled(widget.id) then
            RunOnWidgetControls(widget, widget.onPreviewClose)
        end
    end
end

function EZO_HUD:IsNativeWidget(widgetId)
    return FindWidget(widgetId) ~= nil
end

function EZO_HUD:RefreshNativeWidgetMovementState(widgetId)
    local widget = FindWidget(widgetId)
    if not widget then return false end

    local settings = GetWidgetSettings(widget.id)
    if self:IsMoveModeEnabled(widget.id) and settings.enabled == true then
        CloseAllNativeWidgetPreviews()
        RunOnWidgetControls(widget, widget.onPreviewOpen)
        return true
    end

    RunOnWidgetControls(widget, widget.onPreviewClose)
    return false
end

function EZO_HUD:SetNativeWidgetMoveMode(widgetId, enabled)
    local widget = FindWidget(widgetId)
    if not widget then return false end

    if enabled == true then
        for _, candidate in ipairs(WIDGETS) do
            if candidate.id ~= widget.id and self:IsMoveModeEnabled(candidate.id) then
                self:SetMoveModeEnabled(candidate.id, false)
                RunOnWidgetControls(candidate, candidate.onPreviewClose)
            end
        end
    end

    local settings = GetWidgetSettings(widget.id)
    local shouldEnable = enabled == true and settings.enabled == true
    self:SetMoveModeEnabled(widget.id, shouldEnable)
    self:RefreshNativeWidgetMovementState(widget.id)
    return shouldEnable
end

function EZO_HUD:ShowNativeWidgetPreview(widgetId)
    local widget = FindWidget(widgetId)
    if not widget then return false end

    local settings = GetWidgetSettings(widget.id)
    if settings.enabled ~= true then return false end

    self:ApplyNativeWidgetLayout(widget.id)
    if self:IsMoveModeEnabled(widget.id) then
        return self:RefreshNativeWidgetMovementState(widget.id)
    end

    CloseAllNativeWidgetPreviews()
    RunOnWidgetControls(widget, widget.onPreviewOpen)
    nativePreviewToken = nativePreviewToken + 1
    local token = nativePreviewToken
    if zo_callLater then
        zo_callLater(function()
            if token == nativePreviewToken and not EZO_HUD:IsMoveModeEnabled(widget.id) then
                RunOnWidgetControls(widget, widget.onPreviewClose)
            end
        end, NATIVE_WIDGET_PREVIEW_DURATION_MS)
    end
    return true
end

local function CaptureOriginalState(widget)
    if originalStates[widget.id] then return end

    local widgetControls = GetWidgetControls(widget)
    if #widgetControls == 0 then return end

    local state = {}

    for _, wc in ipairs(widgetControls) do
        local control = wc.control
        state[wc.name] = {
            scale = control.GetScale and control:GetScale() or 1,
            anchors = {},
        }

        if control.GetNumAnchors and control.GetAnchor then
            local numAnchors = control:GetNumAnchors()
            for index = 0, numAnchors - 1 do
                local isValid, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(index)
                if isValid and point ~= nil then
                    table.insert(state[wc.name].anchors, {
                        point = point,
                        relativeTo = relativeTo,
                        relativePoint = relativePoint,
                        offsetX = offsetX,
                        offsetY = offsetY,
                    })
                end
            end
        end
    end

    originalStates[widget.id] = state
end

local function RestoreOriginalState(widget)
    local state = originalStates[widget.id]
    if not state then return end

    local widgetControls = GetWidgetControls(widget)

    for _, wc in ipairs(widgetControls) do
        local control = wc.control
        local controlState = state[wc.name]

        if controlState then
            control:ClearAnchors()
            if #controlState.anchors > 0 then
                for _, anchor in ipairs(controlState.anchors) do
                    control:SetAnchor(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
                end
            else
                control:SetAnchor(unpack(widget.fallbackAnchor))
            end
            control:SetScale(controlState.scale or 1)
        end
    end

    if widget.onRestoreLayout then
        widget:onRestoreLayout()
    end
end

function EZO_HUD:ApplyNativeWidgetLayout(widgetId)
    local widget = nil
    for _, w in ipairs(WIDGETS) do
        if w.id == widgetId then
            widget = w
            break
        end
    end
    if not widget then return false end

    local widgetControls = GetWidgetControls(widget)
    if #widgetControls == 0 then return false end

    CaptureOriginalState(widget)

    local settings = GetWidgetSettings(widget.id)
    if settings.enabled ~= true then
        RestoreOriginalState(widget)
        return false
    end

    local scale = Clamp(settings.scale or self.defaults[widget.id].scale, widget.minScale, widget.maxScale)
    settings.scale = scale

    for _, wc in ipairs(widgetControls) do
        local control = wc.control
        control:ClearAnchors()
        control:SetAnchor(
            widget.fallbackAnchor[1], -- point
            widget.fallbackAnchor[2], -- relativeTo
            widget.fallbackAnchor[3], -- relativePoint
            tonumber(settings.offsetX) or self.defaults[widget.id].offsetX,
            tonumber(settings.offsetY) or self.defaults[widget.id].offsetY
        )
        control:SetScale(scale)
    end

    if widget.onApplyLayout then
        widget:onApplyLayout(settings, self.defaults[widget.id])
    end

    return true
end

function EZO_HUD:ApplyAllNativeWidgetLayouts()
    for _, widget in ipairs(WIDGETS) do
        self:ApplyNativeWidgetLayout(widget.id)
    end
end

function EZO_HUD:ResetNativeWidgetDefaults(widgetId)
    if self.sv then
        self.sv[widgetId] = DeepCopyTable(self.defaults[widgetId])
    end
    self:ApplyNativeWidgetLayout(widgetId)
end

function EZO_HUD:InitializeNativeWidgets()
    for _, widget in ipairs(WIDGETS) do
        GetWidgetSettings(widget.id)
    end

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_NativeWidgetsActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            self:ApplyAllNativeWidgetLayouts()
            if zo_callLater then
                zo_callLater(function()
                    self:ApplyAllNativeWidgetLayouts()
                end, 500)
            end
        end
    )

    local deathPromptEvents = {
        EVENT_PLAYER_DEAD,
        EVENT_PLAYER_ALIVE,
        EVENT_RESURRECT_REQUEST,
        EVENT_RESURRECT_REQUEST_REMOVED,
        EVENT_PLAYER_DEATH_INFO_UPDATE,
    }
    for _, eventCode in pairs(deathPromptEvents) do
        if eventCode then
            EVENT_MANAGER:RegisterForEvent(
                self.ADDON_NAME .. "_NativeDeathPrompt",
                eventCode,
                function()
                    self:ApplyNativeWidgetLayout("nativeDeathPrompt")
                end
            )
        end
    end

    local sharedInformationArea = SHARED_INFORMATION_AREA
    if not EZO_HUD.synergyAbilityHooked and sharedInformationArea and sharedInformationArea.SetHidden then
        local originalSetHidden = sharedInformationArea.SetHidden
        sharedInformationArea.SetHidden = function(manager, element, hidden)
            if element == ZO_Synergy and EZO_HUD.sv and EZO_HUD.sv.customSynergy and EZO_HUD.sv.customSynergy.enabled then
                if ZO_SynergyTopLevel then
                    ZO_SynergyTopLevel:SetHidden(true)
                end
                return
            end
            originalSetHidden(manager, element, hidden)
        end
        EZO_HUD.synergyAbilityHooked = true
    end

    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(
            self.ADDON_NAME .. "_NativeWidgetsGamepad",
            EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
            function()
                self:ApplyAllNativeWidgetLayouts()
            end
        )
    end

    -- Force Keyboard Loot History to be used universally
    local gamepadLootHistory = LOOT_HISTORY_GAMEPAD
    local keyboardLootHistory = LOOT_HISTORY_KEYBOARD
    if gamepadLootHistory and keyboardLootHistory then
        gamepadLootHistory.AddLoot = function(_, ...)
            return keyboardLootHistory:AddLoot(...)
        end
        if ZO_LootHistoryControl_Gamepad then
            ZO_LootHistoryControl_Gamepad:SetHidden(true)
        end
    end

    if CALLBACK_MANAGER then
        local isPanelVisible = false

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function()
            local panelRef = EZOhud_NativeWidgets_LAM_Panel
            if panelRef and not panelRef:IsHidden() then
                isPanelVisible = true
            end
        end)

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function()
            if isPanelVisible then
                isPanelVisible = false
                CloseTransientNativeWidgetPreviews()
            end
        end)
    end

    if EZOhud_LAM and EZOhud_LAM.RegisterSection then
        EZOhud_LAM.RegisterSection("nativeWidgets", 50, function()
            local options = {
                EZOhud_LAM.CreateInfoHeader(
                    GetString(EZO_HUD_OPTION_NATIVE_TWEAKS),
                    GetString(EZO_HUD_OPTION_NATIVE_TWEAKS_HEADER_TOOLTIP)
                )
            }

            -- Control invisible para detectar cuándo es visible esta sección específica de LAM
            table.insert(options, {
                type = "custom",
                reference = "EZOhud_NativeWidgets_LAM_Panel",
            })

            for _, widget in ipairs(WIDGETS) do
                local function BuildRef(suffix)
                    return "EZOhud_" .. widget.id .. "_LAM_" .. suffix
                end

                table.insert(options, {
                    type = "header",
                    name = GetString(_G[widget.stringIds.header] or 0),
                    tooltip = GetString(_G[widget.stringIds.headerTooltip] or 0)
                })
                table.insert(options, {
                    type = "checkbox",
                    name = GetString(_G[widget.stringIds.enable] or 0),
                    tooltip = GetString(_G[widget.stringIds.enableTooltip] or 0),
                    reference = BuildRef("Enable"),
                    getFunc = function()
                        return GetWidgetSettings(widget.id).enabled == true
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).enabled = value == true
                        self:ApplyNativeWidgetLayout(widget.id)
                        if value == true then
                            self:ShowNativeWidgetPreview(widget.id)
                        else
                            self:SetNativeWidgetMoveMode(widget.id, false)
                        end
                        self:RequestSettingsPanelRefresh()
                    end,
                    default = self.defaults[widget.id].enabled,
                    width = "full",
                })
                table.insert(options, {
                    type = "checkbox",
                    name = GetString(_G["EZO_HUD_OPTION_NATIVE_WIDGET_MOVE_HANDLE"] or 0),
                    tooltip = GetString(_G["EZO_HUD_OPTION_NATIVE_WIDGET_MOVE_HANDLE_TOOLTIP"] or 0),
                    reference = BuildRef("MoveHandle"),
                    getFunc = function()
                        return self:IsMoveModeEnabled(widget.id)
                    end,
                    setFunc = function(value)
                        self:SetNativeWidgetMoveMode(widget.id, value)
                        self:RequestSettingsPanelRefresh()
                    end,
                    disabled = function()
                        return GetWidgetSettings(widget.id).enabled ~= true
                    end,
                    width = "half",
                })
                table.insert(options, {
                    type = "slider",
                    name = GetString(_G[widget.stringIds.offsetX] or 0),
                    tooltip = GetString(_G[widget.stringIds.offsetXTooltip] or 0),
                    reference = BuildRef("OffsetX"),
                    min = -4000,
                    max = 4000,
                    step = 5,
                    getFunc = function()
                        return GetWidgetSettings(widget.id).offsetX
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).offsetX = value
                        self:ApplyNativeWidgetLayout(widget.id)
                        if GetWidgetSettings(widget.id).enabled then
                            self:ShowNativeWidgetPreview(widget.id)
                        end
                    end,
                    default = self.defaults[widget.id].offsetX,
                    width = "half",
                })
                table.insert(options, {
                    type = "slider",
                    name = GetString(_G[widget.stringIds.offsetY] or 0),
                    tooltip = GetString(_G[widget.stringIds.offsetYTooltip] or 0),
                    reference = BuildRef("OffsetY"),
                    min = -4000,
                    max = 4000,
                    step = 5,
                    getFunc = function()
                        return GetWidgetSettings(widget.id).offsetY
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).offsetY = value
                        self:ApplyNativeWidgetLayout(widget.id)
                        if GetWidgetSettings(widget.id).enabled then
                            self:ShowNativeWidgetPreview(widget.id)
                        end
                    end,
                    default = self.defaults[widget.id].offsetY,
                    width = "half",
                })
                table.insert(options, {
                    type = "slider",
                    name = GetString(_G[widget.stringIds.scale] or 0),
                    tooltip = GetString(_G[widget.stringIds.scaleTooltip] or 0),
                    reference = BuildRef("Scale"),
                    min = math.floor(widget.minScale * 100),
                    max = math.floor(widget.maxScale * 100),
                    step = 5,
                    getFunc = function()
                        return math.floor((GetWidgetSettings(widget.id).scale or 1) * 100)
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).scale = value / 100
                        self:ApplyNativeWidgetLayout(widget.id)
                        if GetWidgetSettings(widget.id).enabled then
                            self:ShowNativeWidgetPreview(widget.id)
                        end
                    end,
                    default = math.floor(self.defaults[widget.id].scale * 100),
                    width = "half",
                })
                table.insert(options, {
                    type = "button",
                    name = GetString(_G[widget.stringIds.reset] or 0),
                    tooltip = GetString(_G[widget.stringIds.resetTooltip] or 0),
                    func = function()
                        self:ResetNativeWidgetDefaults(widget.id)
                        self:SetNativeWidgetMoveMode(widget.id, false)
                        local refs = { "Enable", "MoveHandle", "OffsetX", "OffsetY", "Scale" }
                        for _, ref in ipairs(refs) do
                            local control = _G[BuildRef(ref)]
                            if control and control.UpdateValue then
                                control:UpdateValue()
                            end
                        end
                        self:ShowNativeWidgetPreview(widget.id)
                    end,
                    width = "half",
                })
            end

            return options
        end)
    end
end
