EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CUSTOM_SYNERGY_NAME = "EZOhud_CustomSynergy"
local PREVIEW_ICON = "EsoUI/Art/Icons/ability_templar_purifying_ritual.dds"

local function GetCustomSynergySettings()
    return EZO_HUD.sv and EZO_HUD.sv.customSynergy or EZO_HUD.defaults.customSynergy
end

local function BuildCustomSynergyIndicator()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CUSTOM_SYNERGY_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(CUSTOM_SYNERGY_NAME .. "_Bg", root, CT_TEXTURE)
    bg:SetTexture("EZOhud/media/radial/white.dds")
    bg:SetColor(0.05, 0.02, 0.02, 0.6)
    bg:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(CUSTOM_SYNERGY_NAME .. "_Icon", root, CT_TEXTURE)
    icon:SetMouseEnabled(false)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetDrawLevel(1)

    local frame = WINDOW_MANAGER:CreateControl(CUSTOM_SYNERGY_NAME .. "_Frame", root, CT_TEXTURE)
    frame:SetTexture("EsoUI/Art/ActionBar/abilityFrame64_up.dds")
    frame:SetMouseEnabled(false)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawLevel(2)

    local text = WINDOW_MANAGER:CreateControl(CUSTOM_SYNERGY_NAME .. "_Text", root, CT_LABEL)
    text:SetFont("ZoFontWinH3")
    text:SetColor(1.0, 0.86, 0.32, 1.0)
    text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    text:SetMouseEnabled(false)

    local keybind = WINDOW_MANAGER:CreateControlFromVirtual(CUSTOM_SYNERGY_NAME .. "_Keybind", root, "ZO_KeybindButton")
    keybind:SetKeybind("USE_SYNERGY")

    return {
        root = root,
        bg = bg,
        icon = icon,
        frame = frame,
        text = text,
        keybind = keybind,
    }
end

function EZO_HUD:ApplyCustomSynergyLayout()
    if not self.customSynergy then return end

    local settings = GetCustomSynergySettings()
    local size = settings.size or 50
    local width = math.max(200, zo_floor(size * 4.0))
    local height = math.max(64, zo_floor(size * 1.5))

    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.offsetX or 0) - (width / 2))
    local top = zo_floor((guiHeight / 2) + (settings.offsetY or 0) - (height / 2))

    self.customSynergy.root:SetDimensions(width, height)
    self.customSynergy.root:ClearAnchors()
    self.customSynergy.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.customSynergy.bg:ClearAnchors()
    self.customSynergy.bg:SetAnchorFill(self.customSynergy.root)

    -- Icon centered at the top
    local iconSize = zo_floor(size)
    self.customSynergy.icon:SetDimensions(iconSize, iconSize)
    self.customSynergy.icon:ClearAnchors()
    self.customSynergy.icon:SetAnchor(TOP, self.customSynergy.root, TOP, 0, 5)

    self.customSynergy.frame:SetDimensions(iconSize, iconSize)
    self.customSynergy.frame:ClearAnchors()
    self.customSynergy.frame:SetAnchor(CENTER, self.customSynergy.icon, CENTER, 0, 0)

    -- Text centered below icon
    self.customSynergy.text:ClearAnchors()
    self.customSynergy.text:SetAnchor(TOP, self.customSynergy.icon, BOTTOM, 0, 2)

    -- Keybind below text
    self.customSynergy.keybind:ClearAnchors()
    self.customSynergy.keybind:SetAnchor(TOP, self.customSynergy.text, BOTTOM, 0, 0)

    self:RefreshCustomSynergyMovementState()
end

function EZO_HUD:RefreshCustomSynergyMovementState()
    if not self.customSynergy then return end

    local isMovable = self:IsMoveModeEnabled("customSynergy")
    self.customSynergy.root:SetMovable(isMovable)
    self.customSynergy.root:SetMouseEnabled(isMovable)

    if isMovable then
        if ZO_SynergyTopLevel then
            ZO_SynergyTopLevel:SetAlpha(0)
        end
        self.customSynergy.icon:SetTexture(PREVIEW_ICON)
        self.customSynergy.text:SetText(zo_strformat(GetString(EZO_HUD_SYNERGY_PROMPT), GetString(EZO_HUD_SYNERGY_PREVIEW)))
        self.customSynergy.bg:SetHidden(false)
        self.customSynergy.root:SetHidden(false)
    else
        self.customSynergy.bg:SetHidden(true)
        self:RefreshCustomSynergy()
    end
end

function EZO_HUD:SaveCustomSynergyPosition()
    if not self.customSynergy then return end

    local settings = GetCustomSynergySettings()
    local left = self.customSynergy.root:GetLeft()
    local top = self.customSynergy.root:GetTop()
    local width, height = self.customSynergy.root:GetDimensions()

    local centerX = left + (width / 2)
    local centerY = top + (height / 2)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()

    settings.offsetX = zo_floor(centerX - (guiWidth / 2))
    settings.offsetY = zo_floor(centerY - (guiHeight / 2))

    self:ApplyCustomSynergyLayout()
end

function EZO_HUD:RefreshCustomSynergy()
    if not self.customSynergy then return end

    local settings = GetCustomSynergySettings()
    local isHudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()

    if not isHudVisible then
        self.customSynergy.root:SetHidden(true)
        return
    end

    if self:IsMoveModeEnabled("customSynergy") then
        self.customSynergy.root:SetHidden(false)
        return
    end

    if not settings.enabled then
        self.customSynergy.root:SetHidden(true)
        if ZO_SynergyTopLevel then
            ZO_SynergyTopLevel:SetAlpha(1)
        end
        return
    end

    if ZO_SynergyTopLevel then
        ZO_SynergyTopLevel:SetAlpha(0)
    end

    local hasSynergy, synergyName, iconFilename = GetCurrentSynergyInfo()
    if hasSynergy and synergyName and synergyName ~= "" then
        self.customSynergy.icon:SetTexture(iconFilename)
        self.customSynergy.text:SetText(zo_strformat(GetString(EZO_HUD_SYNERGY_PROMPT), synergyName))

        self.customSynergy.root:SetHidden(false)
    else
        self.customSynergy.root:SetHidden(true)
    end
end

function EZO_HUD:InitializeCustomSynergy()
    if self.customSynergy then return end

    self.customSynergy = BuildCustomSynergyIndicator()
    self:ApplyCustomSynergyLayout()
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.customSynergy.root)
    end

    local function OnSynergyAbilityChanged()
        self:RefreshCustomSynergy()
    end

    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomSynergy", EVENT_SYNERGY_ABILITY_CHANGED, OnSynergyAbilityChanged)
    EVENT_MANAGER:RegisterForEvent(self.ADDON_NAME .. "_CustomSynergy", EVENT_PLAYER_ACTIVATED, OnSynergyAbilityChanged)
end

EZOhud_LAM.RegisterSection("customSynergy", 65, function()
    local settings = GetCustomSynergySettings()
    return {
        EZOhud_LAM.CreateInfoHeader(GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY), GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_HEADER_TOOLTIP)),
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_ENABLE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_ENABLE_TOOLTIP),
            getFunc = function() return settings.enabled end,
            setFunc = function(value)
                settings.enabled = value
                EZO_HUD:RefreshCustomSynergy()
            end,
            default = EZO_HUD.defaults.customSynergy.enabled,
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_MOVE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_MOVE_TOOLTIP),
            getFunc = function() return EZO_HUD:IsMoveModeEnabled("customSynergy") end,
            setFunc = function(value)
                EZO_HUD:SetMoveModeEnabled("customSynergy", value)
                EZO_HUD:RefreshCustomSynergyMovementState()
            end,
            disabled = function() return not settings.enabled end,
            default = false,
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_SIZE),
            tooltip = GetString(EZO_HUD_OPTION_CUSTOM_SYNERGY_SIZE_TOOLTIP),
            min = 20,
            max = 120,
            step = 1,
            getFunc = function() return settings.size end,
            setFunc = function(value)
                settings.size = value
                EZO_HUD:ApplyCustomSynergyLayout()
            end,
            disabled = function() return not settings.enabled end,
            default = EZO_HUD.defaults.customSynergy.size,
        },
    }
end)
