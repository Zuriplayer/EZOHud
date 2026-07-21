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

local function GetOrCreatePreviewBackdrop(control)
    if not control or not WINDOW_MANAGER then return nil end
    local backdropName = control:GetName() .. "_EZOhudPreview"
    local backdrop = _G[backdropName]
    if not backdrop then
        backdrop = WINDOW_MANAGER:CreateControl(backdropName, control, CT_BACKDROP)
        backdrop:SetAnchorFill(control)
        backdrop:SetCenterColor(0, 1, 0, 0.3)
        backdrop:SetEdgeColor(0, 1, 0, 0.8)
        backdrop:SetEdgeTexture("", 1, 1, 2, 0)
        backdrop:SetDrawLayer(DL_OVERLAY)
        backdrop:SetDrawTier(DT_HIGH)
        backdrop:SetDrawLevel(100)
    end
    return backdrop
end


local WIDGETS = {
    {
        id = "nativeQuestTracker",
        controlName = "ZO_FocusedQuestTrackerPanel",
        fallbackAnchor = { TOPRIGHT, GuiRoot, TOPRIGHT, -40, 120 },
        minScale = 0.5,
        maxScale = 1.5,
        onPreviewOpen = function(control)
            if FOCUSED_QUEST_TRACKER_FRAGMENT and SCENE_MANAGER then
                local scene = SCENE_MANAGER:GetScene("gameMenuInGame")
                if scene then scene:AddFragment(FOCUSED_QUEST_TRACKER_FRAGMENT) end
            end
            if control then 
                control:SetHidden(false) 
                control:SetAlpha(1) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(control)
            if control then
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(true) end
            end
            if FOCUSED_QUEST_TRACKER_FRAGMENT and SCENE_MANAGER then
                local scene = SCENE_MANAGER:GetScene("gameMenuInGame")
                if scene then scene:RemoveFragment(FOCUSED_QUEST_TRACKER_FRAGMENT) end
            end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_QUEST_TRACKER_RESET_TOOLTIP",
        }
    },
    {
        id = "nativeCenterScreen",
        controlName = "ZO_CenterScreenAnnounce",
        fallbackAnchor = { TOP, GuiRoot, TOP, 0, 150 },
        minScale = 0.5,
        maxScale = 1.5,
        onPreviewOpen = function(control)
            if CENTER_SCREEN_ANNOUNCE and EVENT_MANAGER then
                CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_MANAGER, CSA_CATEGORY_SMALL_TEXT, nil, GetString(_G["EZO_HUD_PREVIEW_CSA"] or EZO_HUD_PREVIEW_CSA))
            end
            if control then 
                control:SetHidden(false) 
                control:SetAlpha(1) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(control)
            if control then
                local backdrop = GetOrCreatePreviewBackdrop(control)
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
        id = "nativeSynergy",
        controlName = "ZO_SynergyTopLevel",
        fallbackAnchor = { BOTTOM, GuiRoot, BOTTOM, 0, -250 },
        minScale = 0.5,
        maxScale = 1.5,
        onPreviewOpen = function(control)
            if control then 
                control:SetHidden(false) 
                control:SetAlpha(1) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(control)
            if control then 
                control:SetHidden(true) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(true) end
            end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_SYNERGY",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_SYNERGY_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_SYNERGY_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_SYNERGY_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_SYNERGY_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_SYNERGY_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_SYNERGY_RESET_TOOLTIP",
        }
    },
    {
        id = "nativeLootHistory",
        controlName = "ZO_LootHistoryControl_Keyboard",
        fallbackAnchor = { BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -20, -100 },
        minScale = 0.5,
        maxScale = 1.5,
        onPreviewOpen = function(control)
            if control then 
                control:SetHidden(false) 
                control:SetAlpha(1) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(false) end
            end
        end,
        onPreviewClose = function(control)
            if control then 
                control:SetHidden(true) 
                local backdrop = GetOrCreatePreviewBackdrop(control)
                if backdrop then backdrop:SetHidden(true) end
            end
        end,
        stringIds = {
            header = "EZO_HUD_OPTION_NATIVE_LOOT",
            headerTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_HEADER_TOOLTIP",
            enable = "EZO_HUD_OPTION_NATIVE_LOOT_ENABLE",
            enableTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_ENABLE_TOOLTIP",
            offsetX = "EZO_HUD_OPTION_NATIVE_LOOT_OFFSET_X",
            offsetXTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_OFFSET_X_TOOLTIP",
            offsetY = "EZO_HUD_OPTION_NATIVE_LOOT_OFFSET_Y",
            offsetYTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_OFFSET_Y_TOOLTIP",
            scale = "EZO_HUD_OPTION_NATIVE_LOOT_SCALE",
            scaleTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_SCALE_TOOLTIP",
            reset = "EZO_HUD_OPTION_NATIVE_LOOT_RESET",
            resetTooltip = "EZO_HUD_OPTION_NATIVE_LOOT_RESET_TOOLTIP",
        }
    }
}

local function GetWidgetSettings(widgetId)
    if EZO_HUD.sv and not EZO_HUD.sv[widgetId] then
        EZO_HUD.sv[widgetId] = DeepCopyTable(EZO_HUD.defaults[widgetId])
    end
    return (EZO_HUD.sv and EZO_HUD.sv[widgetId]) or EZO_HUD.defaults[widgetId]
end

local function CaptureOriginalState(widget)
    if originalStates[widget.id] then return end
    local control = _G[widget.controlName]
    if not control then return end

    local state = {
        scale = control.GetScale and control:GetScale() or 1,
        anchors = {},
    }

    if control.GetNumAnchors and control.GetAnchor then
        local numAnchors = control:GetNumAnchors()
        for index = 0, numAnchors - 1 do
            local isValid, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(index)
            if isValid and point ~= nil then
                state.anchors[#state.anchors + 1] = {
                    point = point,
                    relativeTo = relativeTo,
                    relativePoint = relativePoint,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
            end
        end
    end
    
    originalStates[widget.id] = state
end

local function RestoreOriginalState(widget)
    local state = originalStates[widget.id]
    local control = _G[widget.controlName]
    if not (control and state) then return end

    control:ClearAnchors()
    if #state.anchors > 0 then
        for _, anchor in ipairs(state.anchors) do
            control:SetAnchor(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.offsetX, anchor.offsetY)
        end
    else
        control:SetAnchor(unpack(widget.fallbackAnchor))
    end
    control:SetScale(state.scale or 1)
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

    local control = _G[widget.controlName]
    if not control then return false end

    CaptureOriginalState(widget)

    local settings = GetWidgetSettings(widget.id)
    if settings.enabled ~= true then
        RestoreOriginalState(widget)
        return false
    end

    local scale = Clamp(settings.scale or self.defaults[widget.id].scale, widget.minScale, widget.maxScale)
    settings.scale = scale

    control:ClearAnchors()
    control:SetAnchor(
        widget.fallbackAnchor[1], -- point
        widget.fallbackAnchor[2], -- relativeTo
        widget.fallbackAnchor[3], -- relativePoint
        tonumber(settings.offsetX) or self.defaults[widget.id].offsetX,
        tonumber(settings.offsetY) or self.defaults[widget.id].offsetY
    )
    control:SetScale(scale)

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

    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(
            self.ADDON_NAME .. "_NativeWidgetsGamepad",
            EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
            function()
                self:ApplyAllNativeWidgetLayouts()
            end
        )
    end

    if CALLBACK_MANAGER then
        local isPanelVisible = false
        
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
            local panelRef = EZOhud_NativeWidgets_LAM_Panel
            if panelRef and not panelRef:IsHidden() then
                isPanelVisible = true
                for _, widget in ipairs(WIDGETS) do
                    local enableRef = _G["EZOhud_" .. widget.id .. "_LAM_Enable"]
                    if enableRef and not enableRef:IsHidden() and GetWidgetSettings(widget.id).enabled then
                        widget.onPreviewOpen(_G[widget.controlName])
                    end
                end
            end
        end)
        
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
            if isPanelVisible then
                isPanelVisible = false
                for _, widget in ipairs(WIDGETS) do
                    widget.onPreviewClose(_G[widget.controlName])
                end
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
                            widget.onPreviewOpen(_G[widget.controlName])
                        else
                            widget.onPreviewClose(_G[widget.controlName])
                        end
                    end,
                    default = self.defaults[widget.id].enabled,
                    width = "full",
                })
                table.insert(options, {
                    type = "slider",
                    name = GetString(_G[widget.stringIds.offsetX] or 0),
                    tooltip = GetString(_G[widget.stringIds.offsetXTooltip] or 0),
                    reference = BuildRef("OffsetX"),
                    min = -2500,
                    max = 2500,
                    step = 5,
                    getFunc = function()
                        return GetWidgetSettings(widget.id).offsetX
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).offsetX = value
                        self:ApplyNativeWidgetLayout(widget.id)
                        if GetWidgetSettings(widget.id).enabled then
                            widget.onPreviewOpen(_G[widget.controlName])
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
                    min = -1500,
                    max = 1500,
                    step = 5,
                    getFunc = function()
                        return GetWidgetSettings(widget.id).offsetY
                    end,
                    setFunc = function(value)
                        GetWidgetSettings(widget.id).offsetY = value
                        self:ApplyNativeWidgetLayout(widget.id)
                        if GetWidgetSettings(widget.id).enabled then
                            widget.onPreviewOpen(_G[widget.controlName])
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
                            widget.onPreviewOpen(_G[widget.controlName])
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
                        local refs = { "Enable", "OffsetX", "OffsetY", "Scale" }
                        for _, ref in ipairs(refs) do
                            local control = _G[BuildRef(ref)]
                            if control and control.UpdateValue then
                                control:UpdateValue()
                            end
                        end
                        widget.onPreviewClose(_G[widget.controlName])
                    end,
                    width = "half",
                })
            end

            return options
        end)
    end
end
