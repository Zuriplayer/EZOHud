EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local WHITE_TEXTURE = "EZOhud/media/radial/white.dds"
local ULTIMATE_SLOT = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

local ULTIMATE_BARS = {
    main = {
        hotbarCategory = HOTBAR_CATEGORY_PRIMARY,
        offsetXKey = "mainOffsetX",
        offsetYKey = "mainOffsetY",
    },
    backup = {
        hotbarCategory = HOTBAR_CATEGORY_BACKUP,
        offsetXKey = "backupOffsetX",
        offsetYKey = "backupOffsetY",
    },
}

local ULTIMATE_ORDER = { "main", "backup" }

local function Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
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

local function CreateLabel(name, parent, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetColor(0.95, 0.95, 0.98, 0.95)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    return label
end

local function GetUltimateSettings()
    if EZO_HUD.sv and not EZO_HUD.sv.ultimate then
        EZO_HUD.sv.ultimate = DeepCopyTable(EZO_HUD.defaults.ultimate)
    end
    return (EZO_HUD.sv and EZO_HUD.sv.ultimate) or EZO_HUD.defaults.ultimate
end

local function ShouldShowBar(barName)
    local settings = GetUltimateSettings()
    if not settings.enabled then
        return false
    end
    if EZO_HUD.IsHudSceneVisible and not EZO_HUD:IsHudSceneVisible() then
        return false
    end

    local mode = settings.displayMode or "both"
    if mode == "inactive" then
        local meta = ULTIMATE_BARS[barName]
        return meta and meta.hotbarCategory ~= GetActiveHotbarCategory()
    end
    return mode == "both" or mode == barName
end

local function GetBarAnchorPosition(settings, barName, width, height)
    local bar = ULTIMATE_BARS[barName]
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local centerX = (guiWidth / 2) + (settings[bar.offsetXKey] or 0)
    local centerY = (guiHeight / 2) + (settings[bar.offsetYKey] or 0)
    return zo_floor(centerX - (width / 2)), zo_floor(centerY - (height / 2))
end

local function GetUltimatePower()
    local current = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    return current or 0
end

local function BuildUltimateBar(barName)
    local root = WINDOW_MANAGER:CreateTopLevelWindow("EZOhud_Ultimate_" .. barName)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetMouseEnabled(false)

    local frame = WINDOW_MANAGER:CreateControl(root:GetName() .. "_Frame", root, CT_TEXTURE)
    local icon = WINDOW_MANAGER:CreateControl(root:GetName() .. "_Icon", root, CT_TEXTURE)
    local progressBg = WINDOW_MANAGER:CreateControl(root:GetName() .. "_ProgressBg", root, CT_TEXTURE)
    local progress = WINDOW_MANAGER:CreateControl(root:GetName() .. "_Progress", root, CT_STATUSBAR)

    frame:SetTexture(WHITE_TEXTURE)
    frame:SetMouseEnabled(false)
    icon:SetMouseEnabled(false)
    progressBg:SetTexture(WHITE_TEXTURE)
    progressBg:SetColor(0.04, 0.05, 0.06, 0.82)
    progressBg:SetMouseEnabled(false)
    progress:SetTexture(WHITE_TEXTURE)
    progress:SetColor(0.78, 0.44, 1.0, 0.95)
    progress:SetOrientation(ORIENTATION_HORIZONTAL)
    progress:SetMouseEnabled(false)

    return {
        root = root,
        frame = frame,
        icon = icon,
        progressBg = progressBg,
        progress = progress,
        barName = barName,
        value = CreateLabel(root:GetName() .. "_Value", root),
        percent = CreateLabel(root:GetName() .. "_Percent", root, "ZoFontGameBold"),
        state = CreateLabel(root:GetName() .. "_State", root),
    }
end

function EZO_HUD:RefreshUltimateMovementState()
    if not self.ultimate then
        return
    end

    local movable = self.sv and self.sv.ultimate and self.sv.ultimate.movable == true
    for _, barName in ipairs(ULTIMATE_ORDER) do
        local root = self.ultimate.bars[barName].root
        root:SetMovable(movable)
        root:SetMouseEnabled(movable)
    end
end

function EZO_HUD:SaveUltimatePosition(barName)
    local entry = self.ultimate and self.ultimate.bars and self.ultimate.bars[barName]
    local settings = self.sv and self.sv.ultimate
    local bar = ULTIMATE_BARS[barName]
    if not (entry and settings and bar) then
        return
    end

    local left = entry.root:GetLeft()
    local top = entry.root:GetTop()
    local width = entry.root:GetWidth()
    local height = entry.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then
        return
    end

    settings[bar.offsetXKey] = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings[bar.offsetYKey] = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyUltimateLayout()
end

function EZO_HUD:ApplyUltimateLayout()
    if not self.ultimate then
        return
    end

    local settings = GetUltimateSettings()
    local iconSize = settings.size or 54
    local width = iconSize
    local height = iconSize + 42
    local progressHeight = math.max(5, zo_floor(iconSize * 0.10))

    for _, barName in ipairs(ULTIMATE_ORDER) do
        local entry = self.ultimate.bars[barName]
        entry.root:SetDimensions(width, height)

        local left, top = GetBarAnchorPosition(settings, barName, width, height)
        entry.root:ClearAnchors()
        entry.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

        entry.frame:ClearAnchors()
        entry.frame:SetAnchor(TOP, entry.root, TOP, 0, 0)
        entry.frame:SetDimensions(iconSize + 6, iconSize + 6)
        entry.frame:SetColor(0.03, 0.03, 0.04, 0.72)

        entry.icon:ClearAnchors()
        entry.icon:SetAnchor(TOP, entry.root, TOP, 0, 3)
        entry.icon:SetDimensions(iconSize, iconSize)

        entry.percent:ClearAnchors()
        entry.percent:SetAnchor(CENTER, entry.icon, CENTER, 0, 0)

        entry.progressBg:ClearAnchors()
        entry.progressBg:SetAnchor(TOPLEFT, entry.icon, BOTTOMLEFT, 0, 3)
        entry.progressBg:SetDimensions(iconSize, progressHeight)

        entry.progress:ClearAnchors()
        entry.progress:SetAnchorFill(entry.progressBg)

        entry.value:ClearAnchors()
        entry.value:SetAnchor(TOP, entry.progressBg, BOTTOM, 0, 3)

        entry.state:ClearAnchors()
        entry.state:SetAnchor(TOP, entry.value, BOTTOM, 0, 1)
    end

    self:RefreshUltimateMovementState()
    self:RefreshUltimateValues()
end

function EZO_HUD:RefreshUltimateText()
end

function EZO_HUD:RefreshUltimateValues()
    if not self.ultimate then
        return
    end

    local activeHotbar = GetActiveHotbarCategory()
    local current = GetUltimatePower()

    for _, barName in ipairs(ULTIMATE_ORDER) do
        local meta = ULTIMATE_BARS[barName]
        local entry = self.ultimate.bars[barName]
        local boundId = GetSlotBoundId(ULTIMATE_SLOT, meta.hotbarCategory)
        local cost = GetSlotAbilityCost(ULTIMATE_SLOT, COMBAT_MECHANIC_FLAGS_ULTIMATE, meta.hotbarCategory) or 0
        local texture = GetSlotTexture(ULTIMATE_SLOT, meta.hotbarCategory)
        local hasAbility = boundId ~= nil and boundId ~= 0 and cost > 0
        local ratio = (hasAbility and cost > 0) and Clamp(current / cost, 0, 1) or 0
        local percentValue = zo_floor(ratio * 100)
        local isActive = activeHotbar == meta.hotbarCategory
        local isReady = hasAbility and current >= cost

        entry.icon:SetTexture((texture ~= nil and texture ~= "") and texture or WHITE_TEXTURE)
        entry.icon:SetColor(1, 1, 1, hasAbility and (isActive and 1.0 or 0.58) or 0.22)
        entry.progress:SetMinMax(0, 1)
        entry.progress:SetValue(ratio)
        entry.percent:SetText(hasAbility and string.format("%d%%", percentValue) or "")
        entry.value:SetText(hasAbility and string.format("%d / %d", zo_floor(current), zo_floor(cost)) or GetString(EZO_HUD_ULTIMATE_EMPTY))

        entry.value:SetAlpha(isActive and 1.0 or 0.62)
        entry.percent:SetAlpha(isActive and 1.0 or 0.72)
        entry.state:SetAlpha(isActive and 1.0 or 0.72)

        if isReady and isActive then
            entry.frame:SetColor(0.88, 0.50, 1.0, 1.0)
            entry.progress:SetColor(1.0, 0.78, 1.0, 1.0)
        elseif isReady then
            entry.frame:SetColor(0.48, 0.24, 0.68, 0.72)
            entry.progress:SetColor(0.80, 0.58, 0.95, 0.82)
        elseif isActive then
            entry.frame:SetColor(0.36, 0.52, 1.0, 0.76)
            entry.progress:SetColor(0.64, 0.42, 1.0, 0.95)
        else
            entry.frame:SetColor(0.03, 0.03, 0.04, 0.72)
            entry.progress:SetColor(0.55, 0.42, 0.72, 0.82)
        end

        if isReady and isActive then
            entry.state:SetText(string.format("%s · %s", GetString(EZO_HUD_ULTIMATE_ACTIVE), GetString(EZO_HUD_ULTIMATE_READY)))
        elseif isReady then
            entry.state:SetText(GetString(EZO_HUD_ULTIMATE_READY))
        elseif isActive then
            entry.state:SetText(GetString(EZO_HUD_ULTIMATE_ACTIVE))
        else
            entry.state:SetText("")
        end
    end
end

function EZO_HUD:RefreshUltimateVisibility()
    if not self.ultimate then
        return
    end

    for _, barName in ipairs(ULTIMATE_ORDER) do
        self.ultimate.bars[barName].root:SetHidden(not ShouldShowBar(barName))
    end
    self:RefreshUltimateMovementState()
end

function EZO_HUD:OnUltimatePowerUpdate(_, unitTag, _, powerType)
    if unitTag ~= "player" or powerType ~= COMBAT_MECHANIC_FLAGS_ULTIMATE then
        return
    end
    self:RefreshUltimateValues()
end

function EZO_HUD:InitializeUltimate()
    self.ultimate = { bars = {} }

    for _, barName in ipairs(ULTIMATE_ORDER) do
        local entry = BuildUltimateBar(barName)
        entry.root:SetHandler("OnMouseDown", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self.sv and self.sv.ultimate and self.sv.ultimate.movable then
                control:StartMoving()
            end
        end)
        entry.root:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self.sv and self.sv.ultimate and self.sv.ultimate.movable then
                control:StopMovingOrResizing()
            end
        end)
        entry.root:SetHandler("OnMoveStop", function()
            self:SaveUltimatePosition(barName)
        end)
        if self.RegisterHudSceneControl then
            self:RegisterHudSceneControl(entry.root)
        end
        self.ultimate.bars[barName] = entry
    end

    self:RefreshUltimateText()
    self:ApplyUltimateLayout()
    self:RefreshUltimateVisibility()

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_UltimatePower",
        EVENT_POWER_UPDATE,
        function(...)
            self:OnUltimatePowerUpdate(...)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_UltimateCost",
        EVENT_ULTIMATE_ABILITY_COST_CHANGED,
        function()
            self:RefreshUltimateValues()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_UltimateHotbar",
        EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function()
            self:RefreshUltimateVisibility()
            self:RefreshUltimateValues()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_UltimateAllHotbars",
        EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
        function()
            self:RefreshUltimateValues()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_UltimateActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            self:ApplyUltimateLayout()
            self:RefreshUltimateVisibility()
        end
    )

    if EZOhud_LAM and EZOhud_LAM.RegisterSection then
        EZOhud_LAM.RegisterSection("ultimate", 30, function()
            local choices = {
                GetString(EZO_HUD_ULTIMATE_DISPLAY_MAIN),
                GetString(EZO_HUD_ULTIMATE_DISPLAY_BACKUP),
                GetString(EZO_HUD_ULTIMATE_DISPLAY_BOTH),
                GetString(EZO_HUD_ULTIMATE_DISPLAY_INACTIVE),
            }
            local function DisplayModeChoice(mode)
                if mode == "main" then
                    return GetString(EZO_HUD_ULTIMATE_DISPLAY_MAIN)
                elseif mode == "backup" then
                    return GetString(EZO_HUD_ULTIMATE_DISPLAY_BACKUP)
                elseif mode == "inactive" then
                    return GetString(EZO_HUD_ULTIMATE_DISPLAY_INACTIVE)
                end
                return GetString(EZO_HUD_ULTIMATE_DISPLAY_BOTH)
            end

            return {
                { type = "header", name = GetString(EZO_HUD_OPTION_ULTIMATE) },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_ULTIMATE_ENABLE),
                    tooltip = GetString(EZO_HUD_OPTION_ULTIMATE_ENABLE_TOOLTIP),
                    getFunc = function()
                        return GetUltimateSettings().enabled
                    end,
                    setFunc = function(value)
                        self.sv.ultimate.enabled = value
                        self:RefreshUltimateVisibility()
                    end,
                    default = self.defaults.ultimate.enabled,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_ULTIMATE_MOVE),
                    tooltip = GetString(EZO_HUD_OPTION_ULTIMATE_MOVE_TOOLTIP),
                    getFunc = function()
                        return self.sv.ultimate.movable == true
                    end,
                    setFunc = function(value)
                        self.sv.ultimate.movable = value
                        self:RefreshUltimateMovementState()
                    end,
                    default = self.defaults.ultimate.movable,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = GetString(EZO_HUD_OPTION_ULTIMATE_DISPLAY),
                    tooltip = GetString(EZO_HUD_OPTION_ULTIMATE_DISPLAY_TOOLTIP),
                    choices = choices,
                    getFunc = function()
                        return DisplayModeChoice(self.sv.ultimate.displayMode)
                    end,
                    setFunc = function(value)
                        if value == GetString(EZO_HUD_ULTIMATE_DISPLAY_MAIN) then
                            self.sv.ultimate.displayMode = "main"
                        elseif value == GetString(EZO_HUD_ULTIMATE_DISPLAY_BACKUP) then
                            self.sv.ultimate.displayMode = "backup"
                        elseif value == GetString(EZO_HUD_ULTIMATE_DISPLAY_INACTIVE) then
                            self.sv.ultimate.displayMode = "inactive"
                        else
                            self.sv.ultimate.displayMode = "both"
                        end
                        self:RefreshUltimateVisibility()
                    end,
                    default = DisplayModeChoice(self.defaults.ultimate.displayMode),
                    width = "half",
                },
                {
                    type = "slider",
                    name = GetString(EZO_HUD_OPTION_ULTIMATE_SIZE),
                    tooltip = GetString(EZO_HUD_OPTION_ULTIMATE_SIZE_TOOLTIP),
                    min = 36,
                    max = 96,
                    step = 2,
                    getFunc = function()
                        return self.sv.ultimate.size
                    end,
                    setFunc = function(value)
                        self.sv.ultimate.size = value
                        self:ApplyUltimateLayout()
                    end,
                    default = self.defaults.ultimate.size,
                    width = "half",
                },
            }
        end)
    end
end
