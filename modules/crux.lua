EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local WHITE_TEXTURE = "EZOhud/media/radial/white.dds"
local CRUX_ABILITY_ID = 184220
local ARCANIST_CLASS_ID = 117
local CRUX_NAME = "EZOhud_Crux"
local UPDATE_NAME = CRUX_NAME .. "_Update"
local MAX_CRUX = 3
local CRUX_COLORS = {
    [0] = { 1.00, 0.18, 0.10, 1.00 },
    [1] = { 1.00, 0.48, 0.12, 1.00 },
    [2] = { 1.00, 0.86, 0.18, 1.00 },
    [3] = { 0.20, 0.95, 0.32, 1.00 },
}

local function GetCruxDurationMs()
    if type(GetAbilityDuration) == "function" then
        local duration = GetAbilityDuration(CRUX_ABILITY_ID)
        if duration and duration > 0 then
            return duration
        end
    end

    return 30000
end

local CRUX_DURATION_MS = GetCruxDurationMs()

local function IsPlayerArcanist()
    return type(GetUnitClassId) == "function"
        and GetUnitClassId("player") == ARCANIST_CLASS_ID
end

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

local function GetCruxSettings()
    if EZO_HUD.sv and not EZO_HUD.sv.crux then
        EZO_HUD.sv.crux = DeepCopyTable(EZO_HUD.defaults.crux)
    end
    return (EZO_HUD.sv and EZO_HUD.sv.crux) or EZO_HUD.defaults.crux
end

local function GetRemainingSeconds(endTime)
    if not endTime or endTime <= 0 or not GetGameTimeSeconds then
        return 0
    end

    return math.max(0, endTime - GetGameTimeSeconds())
end

local function FindCruxBuff()
    if not (GetNumBuffs and GetUnitBuffInfo) then
        return 0, 0
    end

    for index = 1, GetNumBuffs("player") do
        local _, _, endTime, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", index)
        if abilityId == CRUX_ABILITY_ID then
            return stackCount or 0, endTime or 0
        end
    end

    return 0, 0
end

local function CreateLabel(name, parent, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetColor(0.95, 0.96, 1.0, 0.95)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    return label
end

local function BuildCruxIndicator()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CRUX_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local frame = WINDOW_MANAGER:CreateControl(CRUX_NAME .. "_Frame", root, CT_TEXTURE)
    local progressBg = WINDOW_MANAGER:CreateControl(CRUX_NAME .. "_ProgressBg", root, CT_TEXTURE)
    local progress = WINDOW_MANAGER:CreateControl(CRUX_NAME .. "_Progress", root, CT_STATUSBAR)

    frame:SetTexture(WHITE_TEXTURE)
    frame:SetMouseEnabled(false)
    progressBg:SetTexture(WHITE_TEXTURE)
    progressBg:SetColor(0.04, 0.05, 0.07, 0.84)
    progressBg:SetMouseEnabled(false)
    progress:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_tall.dds")
    progress:SetOrientation(ORIENTATION_HORIZONTAL)
    progress:SetMinMax(0, 1)
    progress:SetValue(0)
    progress:SetMouseEnabled(false)
    if type(progress.SetBarAlignment) == "function" and BAR_ALIGNMENT_NORMAL then
        progress:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end

    return {
        root = root,
        frame = frame,
        progressBg = progressBg,
        progress = progress,
        count = CreateLabel(CRUX_NAME .. "_Count", root, "ZoFontHeader4"),
        timer = CreateLabel(CRUX_NAME .. "_Timer", root, "ZoFontGameBold"),
    }
end

local function GetCruxAnchorPosition(settings, width, height)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local centerX = (guiWidth / 2) + (settings.offsetX or 0)
    local centerY = (guiHeight / 2) + (settings.offsetY or 0)
    return zo_floor(centerX - (width / 2)), zo_floor(centerY - (height / 2))
end

function EZO_HUD:RefreshCruxMovementState()
    if not self.crux then
        return
    end

    local settings = GetCruxSettings()
    local movable = self:IsMoveModeEnabled("crux")
    self.crux.root:SetMovable(movable)
    self.crux.root:SetMouseEnabled(movable)
end

function EZO_HUD:SaveCruxPosition()
    if not (self.crux and self.sv and self.sv.crux) then
        return
    end

    local left = self.crux.root:GetLeft()
    local top = self.crux.root:GetTop()
    local width = self.crux.root:GetWidth()
    local height = self.crux.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then
        return
    end

    self.sv.crux.offsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
    self.sv.crux.offsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyCruxLayout()
end

function EZO_HUD:ApplyCruxLayout()
    if not self.crux then
        return
    end

    local settings = GetCruxSettings()
    local size = settings.size or 58
    local textScale = Clamp(size / 58, 0.85, 4.2)
    local countBaseSize = 42
    local countVisualSize = zo_floor(countBaseSize * textScale)
    local progressHeight = math.max(7, zo_floor(size * 0.11))
    local progressWidth = math.max(34, zo_floor(countVisualSize * 0.78))
    local gap = Clamp(settings.barGap or EZO_HUD.defaults.crux.barGap or 1, 0, 80)
    local glyphHeight = zo_floor(countVisualSize * 0.68)
    local countTop = math.min(0, zo_floor(countVisualSize * -0.10))
    local minimumClearance = math.max(4, zo_floor(size * 0.06))
    local width = math.max(countVisualSize, progressWidth)
    local progressTop = math.max(0, countTop + glyphHeight + minimumClearance + gap)
    local height = progressTop + progressHeight
    local left, top = GetCruxAnchorPosition(settings, width, height)

    self.crux.root:SetDimensions(width, height)
    self.crux.root:ClearAnchors()
    self.crux.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.crux.frame:ClearAnchors()
    self.crux.frame:SetAnchorFill(self.crux.root)
    self.crux.frame:SetColor(0, 0, 0, 0)

    self.crux.count:ClearAnchors()
    self.crux.count:SetAnchor(TOP, self.crux.root, TOP, 0, countTop)
    self.crux.count:SetDimensions(countBaseSize, countBaseSize)
    self.crux.count:SetScale(textScale)

    self.crux.progressBg:ClearAnchors()
    self.crux.progressBg:SetAnchor(TOP, self.crux.root, TOP, 0, progressTop)
    self.crux.progressBg:SetDimensions(progressWidth, progressHeight)

    self.crux.progress:ClearAnchors()
    self.crux.progress:SetAnchorFill(self.crux.progressBg)

    self.crux.timer:ClearAnchors()
    self.crux.timer:SetAnchor(RIGHT, self.crux.progressBg, RIGHT, -2, 0)
    self.crux.timer:SetDimensions(progressWidth - 4, progressHeight)
    self.crux.timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.crux.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.crux.timer:SetScale(Clamp(size / 120, 0.55, 1.15))

    self:RefreshCruxMovementState()
    self:RefreshCruxDisplay()
end

function EZO_HUD:SetCruxState(stackCount, endTime)
    self.cruxState = self.cruxState or {}
    self.cruxState.stackCount = Clamp(stackCount or 0, 0, MAX_CRUX)
    self.cruxState.endTime = endTime or 0
    self:RefreshCruxDisplay()
end

function EZO_HUD:ScanCruxState()
    local stackCount, endTime = FindCruxBuff()
    self:SetCruxState(stackCount, endTime)
end

function EZO_HUD:RefreshCruxDisplay()
    if not self.crux then
        return
    end

    local movable = self:IsMoveModeEnabled("crux")
    if not IsPlayerArcanist() and not movable then
        self.crux.root:SetHidden(true)
        return
    end

    local settings = GetCruxSettings()
    local stackCount = (self.cruxState and self.cruxState.stackCount) or 0
    local endTime = (self.cruxState and self.cruxState.endTime) or 0
    local remaining = GetRemainingSeconds(endTime)
    local duration = math.max(1, (CRUX_DURATION_MS or 30000) / 1000)
    local ratio = Clamp(remaining / duration, 0, 1)
    local hudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    local showEmpty = settings.hideWhenZero == false

    if (settings.enabled == false and not movable) or not hudVisible then
        self.crux.root:SetHidden(true)
        return
    end

    if stackCount <= 0 and settings.hideWhenZero ~= false and not movable then
        self.crux.root:SetHidden(true)
        return
    end

    local alpha = 1.0
    local color = CRUX_COLORS[stackCount] or CRUX_COLORS[0]
    self.crux.root:SetHidden(false)
    self.crux.frame:SetColor(0, 0, 0, 0)
    self.crux.progressBg:SetColor(0.03, 0.04, 0.05, stackCount > 0 and 0.78 or 0.38)
    self.crux.progress:SetColor(color[1], color[2], color[3], stackCount > 0 and 0.96 or 0.36)
    self.crux.progress:SetValue(stackCount > 0 and ratio or 0)
    self.crux.count:SetText(stackCount > 0 and tostring(stackCount) or ((movable or showEmpty) and "0" or ""))
    self.crux.count:SetColor(color[1], color[2], color[3], alpha)

    if stackCount > 0 and remaining > 0 then
        self.crux.timer:SetText(tostring(math.ceil(remaining)))
        self.crux.timer:SetColor(0.96, 0.98, 1.0, 0.92)
        self.crux.timer:SetHidden(false)
    else
        self.crux.timer:SetText("")
        self.crux.timer:SetHidden(true)
    end
end

function EZO_HUD:OnCruxEffectChanged(_, changeType, _, _, unitTag, _, _, stackCount)
    if unitTag ~= "player" then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        self:SetCruxState(0, 0)
        return
    end

    local scannedCount, endTime = FindCruxBuff()
    self:SetCruxState(stackCount or scannedCount or 0, endTime)
end

function EZO_HUD:InitializeCrux()
    self.crux = BuildCruxIndicator()
    self.cruxState = {
        stackCount = 0,
        endTime = 0,
    }

    self.crux.root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("crux") then
            control:StartMoving()
        end
    end)
    self.crux.root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("crux") then
            control:StopMovingOrResizing()
        end
    end)
    self.crux.root:SetHandler("OnMoveStop", function()
        self:SaveCruxPosition()
    end)
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.crux.root)
    end

    self:ApplyCruxLayout()
    self:ScanCruxState()

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_CruxEffect",
        EVENT_EFFECT_CHANGED,
        function(...)
            self:OnCruxEffectChanged(...)
        end
    )
    EVENT_MANAGER:AddFilterForEvent(self.ADDON_NAME .. "_CruxEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, CRUX_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(self.ADDON_NAME .. "_CruxEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(self.ADDON_NAME .. "_CruxEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 250, function()
        self:RefreshCruxDisplay()
    end)

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_CruxActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            self:ApplyCruxLayout()
            self:ScanCruxState()
        end
    )

    if EZOhud_LAM and EZOhud_LAM.RegisterSection then
        EZOhud_LAM.RegisterSection("crux", 45, function()
            return {
                EZOhud_LAM.CreateInfoHeader(
                    GetString(EZO_HUD_OPTION_CRUX),
                    GetString(EZO_HUD_OPTION_CRUX_HEADER_TOOLTIP)
                ),
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_CRUX_ENABLE),
                    tooltip = GetString(EZO_HUD_OPTION_CRUX_ENABLE_TOOLTIP),
                    getFunc = function()
                        return GetCruxSettings().enabled ~= false
                    end,
                    setFunc = function(value)
                        GetCruxSettings().enabled = value
                        self:RefreshCruxDisplay()
                    end,
                    default = self.defaults.crux.enabled,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_CRUX_MOVE),
                    tooltip = GetString(EZO_HUD_OPTION_CRUX_MOVE_TOOLTIP),
                    getFunc = function()
                        return self:IsMoveModeEnabled("crux")
                    end,
                    setFunc = function(value)
                        self:SetMoveModeEnabled("crux", value)
                        self:RefreshCruxMovementState()
                        self:RefreshCruxDisplay()
                    end,
                    default = self.defaults.crux.movable,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_CRUX_HIDE_ZERO),
                    tooltip = GetString(EZO_HUD_OPTION_CRUX_HIDE_ZERO_TOOLTIP),
                    getFunc = function()
                        return GetCruxSettings().hideWhenZero ~= false
                    end,
                    setFunc = function(value)
                        GetCruxSettings().hideWhenZero = value
                        self:RefreshCruxDisplay()
                    end,
                    default = self.defaults.crux.hideWhenZero,
                    width = "full",
                },
                {
                    type = "slider",
                    name = GetString(EZO_HUD_OPTION_CRUX_SIZE),
                    tooltip = GetString(EZO_HUD_OPTION_CRUX_SIZE_TOOLTIP),
                    min = 36,
                    max = 220,
                    step = 5,
                    getFunc = function()
                        return GetCruxSettings().size
                    end,
                    setFunc = function(value)
                        GetCruxSettings().size = value
                        self:ApplyCruxLayout()
                    end,
                    default = self.defaults.crux.size,
                    width = "full",
                },
                {
                    type = "slider",
                    name = GetString(EZO_HUD_OPTION_CRUX_BAR_GAP),
                    tooltip = GetString(EZO_HUD_OPTION_CRUX_BAR_GAP_TOOLTIP),
                    min = 0,
                    max = 80,
                    step = 1,
                    getFunc = function()
                        return GetCruxSettings().barGap or self.defaults.crux.barGap
                    end,
                    setFunc = function(value)
                        GetCruxSettings().barGap = value
                        self:ApplyCruxLayout()
                    end,
                    default = self.defaults.crux.barGap,
                    width = "full",
                },
            }
        end)
    end
end
