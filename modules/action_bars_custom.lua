EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local WHITE_TEXTURE = "EZOhud/media/radial/white.dds"
local WEAPON_ICON_UNKNOWN = "EZOhud/media/weapons/weapon_unknown.dds"
local WEAPON_ICON_ONE_HAND = "EZOhud/media/weapons/weapon_one_hand.dds"
local WEAPON_ICON_DUAL = "EZOhud/media/weapons/weapon_dual.dds"
local WEAPON_ICON_TWO_HANDED = "EZOhud/media/weapons/weapon_two_handed.dds"
local WEAPON_ICON_DESTRUCTION_STAFF = "EZOhud/media/weapons/weapon_destruction_staff.dds"
local WEAPON_ICON_RESTORATION_STAFF = "EZOhud/media/weapons/weapon_restoration_staff.dds"
local WEAPON_ICON_SWORD_SHIELD = "EZOhud/media/weapons/weapon_sword_shield.dds"
local WEAPON_ICON_BOW = "EZOhud/media/weapons/weapon_bow.dds"
local ACTION_BARS_NAME = "EZOhud_CustomActionBars"
local SLOT_FIRST = 3
local ORIENTATION_HORIZONTAL = "horizontal"
local ORIENTATION_VERTICAL = "vertical"
local DISPLAY_OFF = "off"
local DISPLAY_MAIN = "main"
local DISPLAY_BACKUP = "backup"
local DISPLAY_BOTH = "both"
local DISPLAY_ACTIVE = "active"
local LAM_REFERENCE_PREFIX = "EZOhud_CustomActionBars_LAM_"
local LAM_DEPENDENT_REFERENCES = {
    LAM_REFERENCE_PREFIX .. "Display",
    LAM_REFERENCE_PREFIX .. "Orientation",
    LAM_REFERENCE_PREFIX .. "MoveMain",
    LAM_REFERENCE_PREFIX .. "MoveBackup",
    LAM_REFERENCE_PREFIX .. "IconSize",
    LAM_REFERENCE_PREFIX .. "Spacing",
    LAM_REFERENCE_PREFIX .. "ShowTimers",
    LAM_REFERENCE_PREFIX .. "InactiveAlpha",
    LAM_REFERENCE_PREFIX .. "DimmedAlpha",
}
local TIMER_UPDATE_MS = 250

local BAR_DEFS = {
    main = {
        hotbarCategory = HOTBAR_CATEGORY_PRIMARY,
        offsetXKey = "mainOffsetX",
        offsetYKey = "mainOffsetY",
        moveSection = "customActionBarMain",
        equipSlot = EQUIP_SLOT_MAIN_HAND,
        offSlot = EQUIP_SLOT_OFF_HAND,
    },
    backup = {
        hotbarCategory = HOTBAR_CATEGORY_BACKUP,
        offsetXKey = "backupOffsetX",
        offsetYKey = "backupOffsetY",
        moveSection = "customActionBarBackup",
        equipSlot = EQUIP_SLOT_BACKUP_MAIN,
        offSlot = EQUIP_SLOT_BACKUP_OFF,
    },
}

local BAR_ORDER = { "main", "backup" }
local SLOT_ORDER = { "weapon", "slot1", "slot2", "slot3", "slot4", "slot5", "ultimate" }
local ACTION_SLOT_BY_KEY = {
    slot1 = SLOT_FIRST,
    slot2 = SLOT_FIRST + 1,
    slot3 = SLOT_FIRST + 2,
    slot4 = SLOT_FIRST + 3,
    slot5 = SLOT_FIRST + 4,
    ultimate = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1,
}

local function BuildSet(...)
    local set = {}
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if value ~= nil then
            set[value] = true
        end
    end
    return set
end

local ONE_HAND_WEAPONS = BuildSet(
    WEAPONTYPE_AXE,
    WEAPONTYPE_DAGGER,
    WEAPONTYPE_HAMMER,
    WEAPONTYPE_SWORD
)

local TWO_HANDED_WEAPONS = BuildSet(
    WEAPONTYPE_TWO_HANDED_AXE,
    WEAPONTYPE_TWO_HANDED_HAMMER,
    WEAPONTYPE_TWO_HANDED_SWORD
)

local DESTRUCTION_STAVES = BuildSet(
    WEAPONTYPE_FIRE_STAFF,
    WEAPONTYPE_FROST_STAFF,
    WEAPONTYPE_LIGHTNING_STAFF
)

local RESTORATION_STAVES = BuildSet(
    WEAPONTYPE_HEALING_STAFF,
    WEAPONTYPE_RESTORATION_STAFF
)

local SHIELD_WEAPONS = BuildSet(WEAPONTYPE_SHIELD)
local BOW_WEAPONS = BuildSet(WEAPONTYPE_BOW)

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

local function ApplyDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then return end
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = type(value) == "table" and DeepCopyTable(value) or value
        elseif type(target[key]) == "table" and type(value) == "table" then
            ApplyDefaults(target[key], value)
        end
    end
end

local function Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function GetSettings()
    if EZO_HUD.sv and not EZO_HUD.sv.customActionBars then
        EZO_HUD.sv.customActionBars = DeepCopyTable(EZO_HUD.defaults.customActionBars)
    end
    local settings = (EZO_HUD.sv and EZO_HUD.sv.customActionBars) or EZO_HUD.defaults.customActionBars
    ApplyDefaults(settings, EZO_HUD.defaults.customActionBars)
    return settings
end

local function GetDisplayMode(settings)
    local mode = settings.displayMode
    if mode == DISPLAY_OFF
        or mode == DISPLAY_MAIN
        or mode == DISPLAY_BACKUP
        or mode == DISPLAY_BOTH
        or mode == DISPLAY_ACTIVE then
        return mode
    end
    return DISPLAY_BOTH
end

local function GetOrientation(settings)
    return settings.orientation == ORIENTATION_VERTICAL and ORIENTATION_VERTICAL or ORIENTATION_HORIZONTAL
end

local function IsActiveBar(barName)
    local bar = BAR_DEFS[barName]
    return bar and GetActiveHotbarCategory and GetActiveHotbarCategory() == bar.hotbarCategory
end

local function GetNowSeconds()
    if type(GetGameTimeSeconds) == "function" then
        return GetGameTimeSeconds()
    end
    if type(GetFrameTimeSeconds) == "function" then
        return GetFrameTimeSeconds()
    end
    return 0
end

local function ShouldShowBar(barName)
    local settings = GetSettings()
    local bar = BAR_DEFS[barName]
    if not bar then return false end
    if EZO_HUD:IsMoveModeEnabled(bar.moveSection) then return true end
    if EZO_HUD.IsHudSceneVisible and not EZO_HUD:IsHudSceneVisible() then return false end
    if not settings.enabled then return false end

    local mode = GetDisplayMode(settings)
    if mode == DISPLAY_OFF then return false end
    if mode == DISPLAY_ACTIVE then return IsActiveBar(barName) end
    return mode == DISPLAY_BOTH or mode == barName
end

local function GetWeaponIcon(barName)
    local bar = BAR_DEFS[barName]
    if not (bar and BAG_WORN) then
        return WEAPON_ICON_UNKNOWN
    end

    local function getWeaponType(slot)
        if slot == nil then return nil end
        if type(GetItemWeaponType) == "function" then
            local weaponType = GetItemWeaponType(BAG_WORN, slot)
            if weaponType ~= nil and weaponType ~= WEAPONTYPE_NONE then
                return weaponType
            end
        end
        if type(GetItemLink) == "function" and type(GetItemLinkWeaponType) == "function" then
            local itemLink = GetItemLink(BAG_WORN, slot)
            if itemLink and itemLink ~= "" then
                local weaponType = GetItemLinkWeaponType(itemLink)
                if weaponType ~= nil and weaponType ~= WEAPONTYPE_NONE then
                    return weaponType
                end
            end
        end
        return nil
    end

    local mainType = getWeaponType(bar.equipSlot)
    local offType = getWeaponType(bar.offSlot)

    if ONE_HAND_WEAPONS[mainType] == true and SHIELD_WEAPONS[offType] == true then
        return WEAPON_ICON_SWORD_SHIELD
    end
    if ONE_HAND_WEAPONS[mainType] == true and ONE_HAND_WEAPONS[offType] == true then
        return WEAPON_ICON_DUAL
    end
    if TWO_HANDED_WEAPONS[mainType] == true then
        return WEAPON_ICON_TWO_HANDED
    end
    if DESTRUCTION_STAVES[mainType] == true then
        return WEAPON_ICON_DESTRUCTION_STAFF
    end
    if RESTORATION_STAVES[mainType] == true then
        return WEAPON_ICON_RESTORATION_STAFF
    end
    if BOW_WEAPONS[mainType] == true then
        return WEAPON_ICON_BOW
    end
    if ONE_HAND_WEAPONS[mainType] == true then
        return WEAPON_ICON_ONE_HAND
    end

    return WEAPON_ICON_UNKNOWN
end

local function GetActionSlotIcon(slotKey, hotbarCategory)
    local slotIndex = ACTION_SLOT_BY_KEY[slotKey]
    if not slotIndex then return WHITE_TEXTURE, false end

    local texture = GetSlotTexture(slotIndex, hotbarCategory)
    local boundId = GetSlotBoundId(slotIndex, hotbarCategory)
    local hasAbility = boundId ~= nil and boundId ~= 0
    return (texture ~= nil and texture ~= "") and texture or WHITE_TEXTURE, hasAbility
end

local function GetSlotAbilityId(slotKey, hotbarCategory)
    local slotIndex = ACTION_SLOT_BY_KEY[slotKey]
    if not slotIndex or type(GetSlotBoundId) ~= "function" then return nil end

    local boundId = GetSlotBoundId(slotIndex, hotbarCategory)
    if boundId == nil or boundId == 0 then return nil end

    local abilityId = boundId
    if type(GetSlotType) == "function"
        and ACTION_TYPE_CRAFTED_ABILITY ~= nil
        and GetSlotType(slotIndex, hotbarCategory) == ACTION_TYPE_CRAFTED_ABILITY
        and type(GetAbilityIdForCraftedAbilityId) == "function" then
        local craftedAbilityId = GetAbilityIdForCraftedAbilityId(boundId)
        if craftedAbilityId ~= nil and craftedAbilityId ~= 0 then
            abilityId = craftedAbilityId
        end
    end

    if abilityId ~= nil
        and abilityId ~= 0
        and type(GetEffectiveAbilityIdForAbilityOnHotbar) == "function" then
        local effectiveId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbarCategory)
        if effectiveId ~= nil and effectiveId ~= 0 then
            abilityId = effectiveId
        end
    end

    return abilityId
end

local function GetAbilityDurationSeconds(abilityId, beginTime, endTime)
    if beginTime ~= nil and endTime ~= nil and endTime > beginTime then
        return endTime - beginTime
    end
    if abilityId ~= nil and type(GetAbilityDuration) == "function" then
        local durationMs = GetAbilityDuration(abilityId)
        if durationMs ~= nil and durationMs > 0 then
            return durationMs / 1000
        end
    end
    return 0
end

local function AddUnitEffectsByAbility(result, unitTag, now)
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then return end

    local count = GetNumBuffs(unitTag) or 0
    for index = 1, count do
        local _, beginTime, endTime, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, index)
        abilityId = tonumber(abilityId)
        endTime = tonumber(endTime)
        if abilityId ~= nil and abilityId > 0 and endTime ~= nil and endTime > now then
            if unitTag == "player" or castByPlayer == true then
                local duration = GetAbilityDurationSeconds(abilityId, tonumber(beginTime), endTime)
                local remaining = endTime - now
                local current = result[abilityId]
                if current == nil or remaining > current.remaining then
                    result[abilityId] = {
                        remaining = remaining,
                        duration = duration,
                    }
                end
            end
        end
    end
end

local function BuildActiveEffectsByAbility()
    local now = GetNowSeconds()
    local result = {}
    AddUnitEffectsByAbility(result, "player", now)
    AddUnitEffectsByAbility(result, "reticleover", now)
    return result
end

local function FormatTimerSeconds(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    if seconds >= 60 then
        return tostring(math.ceil(seconds / 60)) .. "m"
    end
    return tostring(math.ceil(seconds))
end

local function UpdateSlotTimer(slot, effect, visible, alpha)
    if not (slot and slot.timerLabel and slot.timerBg and slot.timerBar) then return end
    if not visible or effect == nil or (effect.remaining or 0) <= 0 then
        slot.timerLabel:SetHidden(true)
        slot.timerBg:SetHidden(true)
        slot.timerBar:SetHidden(true)
        return
    end

    local remaining = math.max(0, effect.remaining or 0)
    local duration = math.max(0, effect.duration or 0)
    local ratio = duration > 0 and Clamp(remaining / duration, 0, 1) or 1
    local timerAlpha = Clamp(alpha or 1, 0.18, 1.0)

    slot.timerLabel:SetText(FormatTimerSeconds(remaining))
    slot.timerLabel:SetAlpha(timerAlpha)
    slot.timerLabel:SetHidden(false)
    slot.timerBg:SetAlpha(timerAlpha)
    slot.timerBg:SetHidden(false)
    slot.timerBar:SetValue(ratio)
    slot.timerBar:SetAlpha(timerAlpha)
    slot.timerBar:SetHidden(false)
end

local function CreateSlot(parent, name)
    local root = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    root:SetMouseEnabled(false)

    local bg = WINDOW_MANAGER:CreateControl(name .. "_Bg", root, CT_TEXTURE)
    bg:SetTexture(WHITE_TEXTURE)
    bg:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(name .. "_Icon", root, CT_TEXTURE)
    icon:SetMouseEnabled(false)

    local border = WINDOW_MANAGER:CreateControl(name .. "_Border", root, CT_BACKDROP)
    border:SetCenterColor(0, 0, 0, 0)
    border:SetMouseEnabled(false)

    local timerBg = WINDOW_MANAGER:CreateControl(name .. "_TimerBg", root, CT_TEXTURE)
    timerBg:SetTexture(WHITE_TEXTURE)
    timerBg:SetColor(0.02, 0.02, 0.025, 0.82)
    timerBg:SetMouseEnabled(false)
    timerBg:SetHidden(true)

    local timerBar = WINDOW_MANAGER:CreateControl(name .. "_TimerBar", root, CT_STATUSBAR)
    timerBar:SetTexture(WHITE_TEXTURE)
    timerBar:SetColor(0.95, 0.72, 0.22, 0.96)
    timerBar:SetOrientation(ORIENTATION_HORIZONTAL)
    timerBar:SetMinMax(0, 1)
    timerBar:SetMouseEnabled(false)
    timerBar:SetHidden(true)

    local timerLabel = WINDOW_MANAGER:CreateControl(name .. "_TimerLabel", root, CT_LABEL)
    timerLabel:SetFont("ZoFontGameSmall")
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    timerLabel:SetColor(1, 0.86, 0.30, 1)
    timerLabel:SetMouseEnabled(false)
    timerLabel:SetHidden(true)

    return {
        root = root,
        bg = bg,
        icon = icon,
        border = border,
        timerBg = timerBg,
        timerBar = timerBar,
        timerLabel = timerLabel,
    }
end

local function BuildActionBar(barName)
    local root = WINDOW_MANAGER:CreateTopLevelWindow(ACTION_BARS_NAME .. "_" .. barName)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local slots = {}
    for _, slotKey in ipairs(SLOT_ORDER) do
        slots[slotKey] = CreateSlot(root, root:GetName() .. "_" .. slotKey)
    end

    return {
        root = root,
        slots = slots,
        barName = barName,
    }
end

function EZO_HUD:RefreshCustomActionBarsMovementState()
    if not self.customActionBars then return end

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = self.customActionBars.bars[barName]
        local movable = self:IsMoveModeEnabled(bar.moveSection)
        if self.customActionBarsDragActive[barName] and not movable then
            entry.root:StopMovingOrResizing()
            self.customActionBarsDragActive[barName] = false
        end
        entry.root:SetMovable(false)
        entry.root:SetMouseEnabled(movable)
    end
end

function EZO_HUD:SaveCustomActionBarPosition(barName)
    local entry = self.customActionBars and self.customActionBars.bars and self.customActionBars.bars[barName]
    local settings = self.sv and self.sv.customActionBars
    local bar = BAR_DEFS[barName]
    if not (entry and settings and bar) then return end

    local left = entry.root:GetLeft()
    local top = entry.root:GetTop()
    local width = entry.root:GetWidth()
    local height = entry.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then return end

    settings[bar.offsetXKey] = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings[bar.offsetYKey] = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyCustomActionBarsLayout()
end

function EZO_HUD:ApplyCustomActionBarsLayout()
    if not self.customActionBars then return end

    local settings = GetSettings()
    local iconSize = Clamp(settings.iconSize, 28, 72)
    local spacing = Clamp(settings.spacing, 0, 16)
    local orientation = GetOrientation(settings)
    local count = #SLOT_ORDER
    local width = orientation == ORIENTATION_HORIZONTAL and ((iconSize * count) + (spacing * (count - 1))) or iconSize
    local height = orientation == ORIENTATION_VERTICAL and ((iconSize * count) + (spacing * (count - 1))) or iconSize

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = self.customActionBars.bars[barName]
        local guiWidth, guiHeight = GuiRoot:GetDimensions()
        local left = zo_floor((guiWidth / 2) + (settings[bar.offsetXKey] or 0) - (width / 2))
        local top = zo_floor((guiHeight / 2) + (settings[bar.offsetYKey] or 0) - (height / 2))

        entry.root:SetDimensions(width, height)
        entry.root:ClearAnchors()
        entry.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

        for index, slotKey in ipairs(SLOT_ORDER) do
            local slot = entry.slots[slotKey]
            local offset = (index - 1) * (iconSize + spacing)
            slot.root:SetDimensions(iconSize, iconSize)
            slot.root:ClearAnchors()
            if orientation == ORIENTATION_VERTICAL then
                slot.root:SetAnchor(TOPLEFT, entry.root, TOPLEFT, 0, offset)
            else
                slot.root:SetAnchor(TOPLEFT, entry.root, TOPLEFT, offset, 0)
            end

            slot.bg:ClearAnchors()
            slot.bg:SetAnchorFill(slot.root)
            slot.bg:SetColor(0.02, 0.025, 0.03, 0.82)

            slot.icon:ClearAnchors()
            slot.icon:SetAnchor(CENTER, slot.root, CENTER, 0, 0)
            slot.icon:SetDimensions(iconSize - 4, iconSize - 4)

            slot.border:ClearAnchors()
            slot.border:SetAnchorFill(slot.root)

            slot.timerBg:ClearAnchors()
            slot.timerBg:SetAnchor(BOTTOMLEFT, slot.root, BOTTOMLEFT, 3, -3)
            slot.timerBg:SetAnchor(BOTTOMRIGHT, slot.root, BOTTOMRIGHT, -3, -3)
            slot.timerBg:SetHeight(math.max(3, zo_floor(iconSize * 0.09)))

            slot.timerBar:ClearAnchors()
            slot.timerBar:SetAnchorFill(slot.timerBg)

            slot.timerLabel:ClearAnchors()
            slot.timerLabel:SetAnchor(BOTTOMRIGHT, slot.root, BOTTOMRIGHT, -4, -7)
            slot.timerLabel:SetDimensions(iconSize - 8, zo_floor(iconSize * 0.45))
        end
    end

    self:RefreshCustomActionBarsMovementState()
    self:RefreshCustomActionBars()
end

function EZO_HUD:RefreshCustomActionBars()
    if not self.customActionBars then return end

    local settings = GetSettings()
    local activeAlpha = 1.0
    local inactiveAlpha = Clamp(settings.inactiveAlpha, 0.2, 1.0)
    local dimmedAlpha = Clamp(settings.dimmedAlpha, 0.05, 1.0)
    local showTimers = settings.showTimers == true
    local activeEffects = showTimers and BuildActiveEffectsByAbility() or nil

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = self.customActionBars.bars[barName]
        local isActive = IsActiveBar(barName)
        local barAlpha = isActive and activeAlpha or inactiveAlpha
        local shouldShow = ShouldShowBar(barName)

        entry.root:SetHidden(not shouldShow)

        for _, slotKey in ipairs(SLOT_ORDER) do
            local slot = entry.slots[slotKey]
            local texture
            local hasAbility = true
            local abilityId
            if slotKey == "weapon" then
                texture = GetWeaponIcon(barName)
            else
                texture, hasAbility = GetActionSlotIcon(slotKey, bar.hotbarCategory)
                abilityId = GetSlotAbilityId(slotKey, bar.hotbarCategory)
            end

            local isDimmed = settings.dimSlots and settings.dimSlots[slotKey] == true
            local alpha = isDimmed and dimmedAlpha or barAlpha
            slot.icon:SetTexture(texture)
            slot.icon:SetColor(1, 1, 1, hasAbility and alpha or 0.18)
            slot.bg:SetAlpha(shouldShow and 1 or 0)
            local effect = abilityId and activeEffects and activeEffects[abilityId] or nil
            UpdateSlotTimer(slot, effect, shouldShow and showTimers and hasAbility, alpha)

            if slotKey == "weapon" and isActive then
                slot.border:SetEdgeColor(0.90, 0.62, 1.0, 0.95)
            elseif slotKey == "weapon" then
                slot.border:SetEdgeColor(0.28, 0.18, 0.36, 0.62)
            elseif isActive then
                slot.border:SetEdgeColor(0.24, 0.32, 0.58, 0.58)
            else
                slot.border:SetEdgeColor(0.04, 0.04, 0.05, 0.52)
            end
        end
    end

    self:RefreshCustomActionBarsMovementState()
end

local function RegisterEvents()
    local namespace = EZO_HUD.ADDON_NAME .. "_CustomActionBars"
    local function refresh()
        EZO_HUD:RefreshCustomActionBars()
    end
    local function relayout()
        EZO_HUD:ApplyCustomActionBarsLayout()
    end

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, relayout)
    end
    if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, refresh)
    end
    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, refresh)
    end
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, refresh)
        if REGISTER_FILTER_BAG_ID ~= nil and BAG_WORN ~= nil then
            EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
        end
    end
    if EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(namespace .. "_Timers", TIMER_UPDATE_MS, function()
            local settings = GetSettings()
            if settings.enabled and settings.showTimers then
                EZO_HUD:RefreshCustomActionBars()
            end
        end)
    end
end

local function BuildDisplayChoices()
    return {
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_DISPLAY_OFF),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_DISPLAY_MAIN),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_DISPLAY_BACKUP),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_DISPLAY_BOTH),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_DISPLAY_ACTIVE),
    }
end

local function BuildOrientationChoices()
    return {
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_ORIENTATION_HORIZONTAL),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_ORIENTATION_VERTICAL),
    }
end

local function RefreshLamControl(reference)
    local control = _G[reference]
    if not control then return end

    if control.UpdateValue then
        control:UpdateValue(false)
    end
    if control.UpdateDisabled then
        control:UpdateDisabled()
    end
end

function EZO_HUD.RefreshCustomActionBarsLamControls()
    local function refresh()
        for _, reference in ipairs(LAM_DEPENDENT_REFERENCES) do
            RefreshLamControl(reference)
        end
        for _, slotKey in ipairs(SLOT_ORDER) do
            RefreshLamControl(LAM_REFERENCE_PREFIX .. "Dim_" .. slotKey)
        end
    end

    if zo_callLater then
        zo_callLater(refresh, 1)
    else
        refresh()
    end
end

function EZO_HUD:InitializeCustomActionBars()
    if self.customActionBars then return end

    GetSettings()
    self.customActionBars = { bars = {} }
    self.customActionBarsDragActive = {}

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = BuildActionBar(barName)
        entry.root:SetHandler("OnMouseDown", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled(bar.moveSection) then
                self.customActionBarsDragActive[barName] = true
                control:SetMovable(true)
                control:StartMoving()
            end
        end)
        entry.root:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled(bar.moveSection) then
                control:StopMovingOrResizing()
                self.customActionBarsDragActive[barName] = false
                control:SetMovable(false)
                self:SaveCustomActionBarPosition(barName)
            end
        end)
        entry.root:SetHandler("OnMoveStop", function()
            self.customActionBarsDragActive[barName] = false
            entry.root:SetMovable(false)
            self:SaveCustomActionBarPosition(barName)
        end)
        if self.RegisterHudSceneControl then
            self:RegisterHudSceneControl(entry.root)
        end
        self.customActionBars.bars[barName] = entry
    end

    self:ApplyCustomActionBarsLayout()
    RegisterEvents()

    if EZOhud_LAM and EZOhud_LAM.RegisterSection then
        EZOhud_LAM.RegisterSection("customActionBars", 35, function()
            local settings = GetSettings()
            local options = {
                EZOhud_LAM.CreateInfoHeader(
                    GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS),
                    GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_HEADER_TOOLTIP)
                ),
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ENABLE),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ENABLE_TOOLTIP),
                    getFunc = function() return settings.enabled end,
                    setFunc = function(value)
                        settings.enabled = value == true
                        EZO_HUD:RefreshCustomActionBars()
                        EZO_HUD.RefreshCustomActionBarsLamControls()
                    end,
                    default = EZO_HUD.defaults.customActionBars.enabled,
                },
                {
                    type = "dropdown",
                    reference = LAM_REFERENCE_PREFIX .. "Display",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DISPLAY),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DISPLAY_TOOLTIP),
                    choices = BuildDisplayChoices(),
                    choicesValues = { DISPLAY_OFF, DISPLAY_MAIN, DISPLAY_BACKUP, DISPLAY_BOTH, DISPLAY_ACTIVE },
                    getFunc = function() return GetDisplayMode(settings) end,
                    setFunc = function(value)
                        settings.displayMode = GetDisplayMode({ displayMode = value })
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.displayMode,
                    width = "half",
                },
                {
                    type = "dropdown",
                    reference = LAM_REFERENCE_PREFIX .. "Orientation",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ORIENTATION),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ORIENTATION_TOOLTIP),
                    choices = BuildOrientationChoices(),
                    choicesValues = { ORIENTATION_HORIZONTAL, ORIENTATION_VERTICAL },
                    getFunc = function() return GetOrientation(settings) end,
                    setFunc = function(value)
                        settings.orientation = GetOrientation({ orientation = value })
                        EZO_HUD:ApplyCustomActionBarsLayout()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.orientation,
                    width = "half",
                },
                {
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "MoveMain",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_MAIN),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_MAIN_TOOLTIP),
                    getFunc = function() return EZO_HUD:IsMoveModeEnabled("customActionBarMain") end,
                    setFunc = function(value)
                        EZO_HUD:SetMoveModeEnabled("customActionBarMain", value)
                        EZO_HUD:RefreshCustomActionBarsMovementState()
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = false,
                    width = "half",
                },
                {
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "MoveBackup",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_BACKUP),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_BACKUP_TOOLTIP),
                    getFunc = function() return EZO_HUD:IsMoveModeEnabled("customActionBarBackup") end,
                    setFunc = function(value)
                        EZO_HUD:SetMoveModeEnabled("customActionBarBackup", value)
                        EZO_HUD:RefreshCustomActionBarsMovementState()
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = false,
                    width = "half",
                },
                {
                    type = "slider",
                    reference = LAM_REFERENCE_PREFIX .. "IconSize",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ICON_SIZE),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_ICON_SIZE_TOOLTIP),
                    min = 28,
                    max = 72,
                    step = 2,
                    getFunc = function() return settings.iconSize end,
                    setFunc = function(value)
                        settings.iconSize = value
                        EZO_HUD:ApplyCustomActionBarsLayout()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.iconSize,
                    width = "half",
                },
                {
                    type = "slider",
                    reference = LAM_REFERENCE_PREFIX .. "Spacing",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_SPACING),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_SPACING_TOOLTIP),
                    min = 0,
                    max = 16,
                    step = 1,
                    getFunc = function() return settings.spacing end,
                    setFunc = function(value)
                        settings.spacing = value
                        EZO_HUD:ApplyCustomActionBarsLayout()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.spacing,
                    width = "half",
                },
                {
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "ShowTimers",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_SHOW_TIMERS),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_SHOW_TIMERS_TOOLTIP),
                    getFunc = function() return settings.showTimers == true end,
                    setFunc = function(value)
                        settings.showTimers = value == true
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.showTimers,
                    width = "half",
                },
                {
                    type = "slider",
                    reference = LAM_REFERENCE_PREFIX .. "InactiveAlpha",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_INACTIVE_ALPHA),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_INACTIVE_ALPHA_TOOLTIP),
                    min = 20,
                    max = 100,
                    step = 5,
                    getFunc = function() return zo_floor((settings.inactiveAlpha or 0.55) * 100) end,
                    setFunc = function(value)
                        settings.inactiveAlpha = value / 100
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = zo_floor(EZO_HUD.defaults.customActionBars.inactiveAlpha * 100),
                    width = "half",
                },
                {
                    type = "slider",
                    reference = LAM_REFERENCE_PREFIX .. "DimmedAlpha",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIMMED_ALPHA),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIMMED_ALPHA_TOOLTIP),
                    min = 5,
                    max = 100,
                    step = 5,
                    getFunc = function() return zo_floor((settings.dimmedAlpha or 0.28) * 100) end,
                    setFunc = function(value)
                        settings.dimmedAlpha = value / 100
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = zo_floor(EZO_HUD.defaults.customActionBars.dimmedAlpha * 100),
                    width = "half",
                },
            }

            table.insert(options, EZOhud_LAM.CreateInfoHeader(
                GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIM_SLOTS),
                GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIM_SLOTS_TOOLTIP)
            ))

            for _, slotKey in ipairs(SLOT_ORDER) do
                table.insert(options, {
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "Dim_" .. slotKey,
                    name = GetString(_G["EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIM_" .. string.upper(slotKey)]),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_DIM_SLOT_TOOLTIP),
                    getFunc = function() return settings.dimSlots and settings.dimSlots[slotKey] == true end,
                    setFunc = function(value)
                        settings.dimSlots = settings.dimSlots or {}
                        settings.dimSlots[slotKey] = value == true
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.dimSlots[slotKey],
                    width = "half",
                })
            end

            return options
        end)
    end
end
