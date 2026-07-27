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
local QUICK_SLOT_NAME = "EZOhud_CustomActionBars_Quickslot"
local SLOT_FIRST = 3
local LAYOUT_HORIZONTAL = "horizontal"
local LAYOUT_VERTICAL = "vertical"
local DISPLAY_OFF = "off"
local DISPLAY_MAIN = "main"
local DISPLAY_BACKUP = "backup"
local DISPLAY_BOTH = "both"
local DISPLAY_ACTIVE = "active"
local KEYBIND_MODE_OFF = "off"
local KEYBIND_MODE_AUTO = "auto"
local KEYBIND_MODE_KEYBOARD = "keyboard"
local KEYBIND_MODE_GAMEPAD = "gamepad"
local LAM_REFERENCE_PREFIX = "EZOhud_CustomActionBars_LAM_"
local LAM_DEPENDENT_REFERENCES = {
    LAM_REFERENCE_PREFIX .. "Display",
    LAM_REFERENCE_PREFIX .. "HideNativeActionBar",
    LAM_REFERENCE_PREFIX .. "Orientation",
    LAM_REFERENCE_PREFIX .. "MoveMain",
    LAM_REFERENCE_PREFIX .. "MoveBackup",
    LAM_REFERENCE_PREFIX .. "MoveQuickslot",
    LAM_REFERENCE_PREFIX .. "IconSize",
    LAM_REFERENCE_PREFIX .. "Spacing",
    LAM_REFERENCE_PREFIX .. "ShowTimers",
    LAM_REFERENCE_PREFIX .. "TimerBarColor",
    LAM_REFERENCE_PREFIX .. "TimerWarningPercent",
    LAM_REFERENCE_PREFIX .. "KeybindMode",
    LAM_REFERENCE_PREFIX .. "InactiveAlpha",
    LAM_REFERENCE_PREFIX .. "DimmedAlpha",
}
local TIMER_UPDATE_MS = 250
local MINIMUM_ACTION_BAR_TIMER_DISPLAYED_TIME_MS = 1000
local MAX_ICON_SIZE = 96
local SLOT_USE_ANIMATION_MS = 320
local SLOT_USE_SCALE = 1.15
local TIMER_WARNING_MAX_PERCENT = 75
local TIMER_LABEL_COLOR = { r = 1, g = 0.86, b = 0.30, a = 1 }
local TIMER_WARNING_LABEL_COLOR = { r = 1, g = 0.34, b = 0.24, a = 1 }
local TIMER_WARNING_BAR_COLOR = { r = 1, g = 0.18, b = 0.12, a = 1 }
local TIMER_BG_COLOR = { r = 0.02, g = 0.02, b = 0.025, a = 0.82 }
local TIMER_WARNING_BG_COLOR = { r = 0.34, g = 0.02, b = 0.015, a = 0.9 }
local QUICKSLOT_COOLDOWN_DIM_ALPHA = 0.30
local KEYBIND_BASE_ICON_SIZE = 42
local KEYBIND_BASE_SCALE_PERCENT = 150
local KEYBIND_MIN_SCALE_PERCENT = 120
local KEYBIND_MAX_SCALE_PERCENT = 320
local GAMEPAD_KEYBIND_SCALE_MULTIPLIER = 0.82
local GAMEPAD_KEYBIND_MIN_SCALE_PERCENT = 100

local BAR_DEFS = {
    main = {
        hotbarCategory = HOTBAR_CATEGORY_PRIMARY,
        weaponPair = ACTIVE_WEAPON_PAIR_MAIN,
        offsetXKey = "mainOffsetX",
        offsetYKey = "mainOffsetY",
        moveSection = "customActionBarMain",
        equipSlot = EQUIP_SLOT_MAIN_HAND,
        offSlot = EQUIP_SLOT_OFF_HAND,
    },
    backup = {
        hotbarCategory = HOTBAR_CATEGORY_BACKUP,
        weaponPair = ACTIVE_WEAPON_PAIR_BACKUP,
        offsetXKey = "backupOffsetX",
        offsetYKey = "backupOffsetY",
        moveSection = "customActionBarBackup",
        equipSlot = EQUIP_SLOT_BACKUP_MAIN,
        offSlot = EQUIP_SLOT_BACKUP_OFF,
    },
}

local BAR_ORDER = { "main", "backup" }
local SLOT_ORDER = { "weapon", "slot1", "slot2", "slot3", "slot4", "slot5", "ultimate" }
local VERTICAL_SLOT_ORDER = { "slot5", "slot4", "slot3", "slot2", "slot1", "weapon", "ultimate" }
local ACTION_SLOT_BY_KEY = {
    slot1 = SLOT_FIRST,
    slot2 = SLOT_FIRST + 1,
    slot3 = SLOT_FIRST + 2,
    slot4 = SLOT_FIRST + 3,
    slot5 = SLOT_FIRST + 4,
    ultimate = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1,
}
local SLOT_KEY_BY_ACTION_SLOT = {}
for slotKey, actionSlotIndex in pairs(ACTION_SLOT_BY_KEY) do
    SLOT_KEY_BY_ACTION_SLOT[actionSlotIndex] = slotKey
end

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
    return settings.orientation == LAYOUT_VERTICAL and LAYOUT_VERTICAL or LAYOUT_HORIZONTAL
end

local function GetLayoutSlotOrder(orientation)
    return orientation == LAYOUT_VERTICAL and VERTICAL_SLOT_ORDER or SLOT_ORDER
end

local function GetKeybindMode(settings)
    local mode = settings.keybindMode
    if mode == KEYBIND_MODE_AUTO
        or mode == KEYBIND_MODE_KEYBOARD
        or mode == KEYBIND_MODE_GAMEPAD then
        return mode
    end
    return KEYBIND_MODE_OFF
end

local function GetTimerBarColor(settings)
    local defaultColor = EZO_HUD.defaults.customActionBars.timerBarColor
    local color = type(settings.timerBarColor) == "table" and settings.timerBarColor or defaultColor
    return Clamp(color.r ~= nil and color.r or defaultColor.r, 0, 1),
        Clamp(color.g ~= nil and color.g or defaultColor.g, 0, 1),
        Clamp(color.b ~= nil and color.b or defaultColor.b, 0, 1),
        Clamp(color.a ~= nil and color.a or defaultColor.a, 0, 1)
end

local function GetTimerWarningPercent(settings)
    local defaultValue = EZO_HUD.defaults.customActionBars.timerWarningPercent or 25
    return zo_floor(Clamp(settings.timerWarningPercent or defaultValue, 0, TIMER_WARNING_MAX_PERCENT))
end

local function GetKeybindScalePercent(iconSize, mode)
    iconSize = Clamp(iconSize, 28, MAX_ICON_SIZE)
    local scalePercent = Clamp((iconSize / KEYBIND_BASE_ICON_SIZE) * KEYBIND_BASE_SCALE_PERCENT, KEYBIND_MIN_SCALE_PERCENT, KEYBIND_MAX_SCALE_PERCENT)
    local useGamepadScale = mode == KEYBIND_MODE_GAMEPAD
        or (mode == KEYBIND_MODE_AUTO and type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode())
    if useGamepadScale then
        scalePercent = Clamp(scalePercent * GAMEPAD_KEYBIND_SCALE_MULTIPLIER, GAMEPAD_KEYBIND_MIN_SCALE_PERCENT, KEYBIND_MAX_SCALE_PERCENT)
    end
    return zo_floor(scalePercent)
end

local function ShouldUseCustomActionBars(settings)
    return settings.enabled == true and GetDisplayMode(settings) ~= DISPLAY_OFF
end

local function ShouldHideNativeActionBar(settings)
    if not (settings.hideNativeActionBar == true and ShouldUseCustomActionBars(settings)) then
        return false
    end
    return EZO_HUD.IsHudSceneVisible == nil or EZO_HUD:IsHudSceneVisible()
end

local function ShouldShowCustomQuickslot(settings)
    if EZO_HUD:IsMoveModeEnabled("customActionBarQuickslot") then return true end
    if EZO_HUD.IsHudSceneVisible and not EZO_HUD:IsHudSceneVisible() then return false end
    return ShouldUseCustomActionBars(settings)
end

local function GetQuickslotState()
    if type(GetCurrentQuickslot) ~= "function"
        or type(GetSlotTexture) ~= "function"
        or HOTBAR_CATEGORY_QUICKSLOT_WHEEL == nil then
        return WHITE_TEXTURE, false, nil, 0, 0
    end

    local slotIndex = GetCurrentQuickslot()
    local slotType = type(GetSlotType) == "function" and GetSlotType(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or nil
    local hasAction = slotType ~= nil and slotType ~= ACTION_TYPE_NOTHING
    local texture = GetSlotTexture(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local count
    local cooldownRemainingMs = 0
    local cooldownDurationMs = 0

    if hasAction
        and slotType == ACTION_TYPE_ITEM
        and type(GetSlotItemCount) == "function" then
        count = GetSlotItemCount(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    end

    if hasAction and type(GetSlotCooldownInfo) == "function" then
        cooldownRemainingMs, cooldownDurationMs = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        cooldownRemainingMs = math.max(0, tonumber(cooldownRemainingMs) or 0)
        cooldownDurationMs = math.max(0, tonumber(cooldownDurationMs) or 0)
    end

    return (texture ~= nil and texture ~= "") and texture or WHITE_TEXTURE,
        hasAction,
        count,
        cooldownRemainingMs,
        cooldownDurationMs
end

local function GetNativeActiveBarName()
    if type(GetActiveWeaponPairInfo) == "function"
        and ACTIVE_WEAPON_PAIR_MAIN ~= nil
        and ACTIVE_WEAPON_PAIR_BACKUP ~= nil then
        local activeWeaponPair = GetActiveWeaponPairInfo()
        if activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN or activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
            return activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN and "main" or "backup"
        end
    end

    if type(GetActiveHotbarCategory) == "function" then
        local activeHotbarCategory = GetActiveHotbarCategory()
        if HOTBAR_CATEGORY_PRIMARY ~= nil
            and HOTBAR_CATEGORY_BACKUP ~= nil
            and (activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY or activeHotbarCategory == HOTBAR_CATEGORY_BACKUP) then
            return activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY and "main" or "backup"
        end

        if type(GetWeaponPairFromHotbarCategory) == "function"
            and ACTIVE_WEAPON_PAIR_MAIN ~= nil
            and ACTIVE_WEAPON_PAIR_BACKUP ~= nil then
            local activeWeaponPair = GetWeaponPairFromHotbarCategory(activeHotbarCategory)
            if activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN or activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
                return activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN and "main" or "backup"
            end
        end
    end

    return nil
end

local function GetActiveSlotMatchScore(barName)
    local bar = BAR_DEFS[barName]
    if not bar or type(GetSlotBoundId) ~= "function" then return 0 end

    local score = 0
    for slotKey, slotIndex in pairs(ACTION_SLOT_BY_KEY) do
        if slotKey ~= "ultimate" then
            local activeBoundId = GetSlotBoundId(slotIndex)
            local barBoundId = GetSlotBoundId(slotIndex, bar.hotbarCategory)
            if activeBoundId ~= nil and activeBoundId ~= 0 and activeBoundId == barBoundId then
                score = score + 2
            elseif type(GetSlotTexture) == "function" then
                local activeTexture = GetSlotTexture(slotIndex)
                local barTexture = GetSlotTexture(slotIndex, bar.hotbarCategory)
                if activeTexture ~= nil and activeTexture ~= "" and activeTexture == barTexture then
                    score = score + 1
                end
            end
        end
    end

    return score
end

local function GetSlotDetectedActiveBarName()
    local mainScore = GetActiveSlotMatchScore("main")
    local backupScore = GetActiveSlotMatchScore("backup")
    if mainScore > backupScore and mainScore > 0 then return "main" end
    if backupScore > mainScore and backupScore > 0 then return "backup" end
    return nil
end

local function GetActiveBarName()
    return GetSlotDetectedActiveBarName() or GetNativeActiveBarName()
end

local function IsActiveBar(barName)
    if BAR_DEFS[barName] == nil then return false end
    return GetActiveBarName() == barName
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

local function GetUltimatePower()
    if type(GetUnitPower) ~= "function" or COMBAT_MECHANIC_FLAGS_ULTIMATE == nil then return 0 end
    return GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE) or 0
end

local function GetUltimateSlotState(slotKey, hotbarCategory)
    if slotKey ~= "ultimate"
        or type(GetSlotBoundId) ~= "function"
        or type(GetSlotAbilityCost) ~= "function"
        or COMBAT_MECHANIC_FLAGS_ULTIMATE == nil then
        return nil
    end

    local slotIndex = ACTION_SLOT_BY_KEY[slotKey]
    local boundId = GetSlotBoundId(slotIndex, hotbarCategory)
    if boundId == nil or boundId == 0 then return nil end

    local cost = GetSlotAbilityCost(slotIndex, COMBAT_MECHANIC_FLAGS_ULTIMATE, hotbarCategory) or 0
    if cost <= 0 then
        cost = GetSlotAbilityCost(slotIndex, COMBAT_MECHANIC_FLAGS_ULTIMATE) or 0
    end

    local current = GetUltimatePower()
    return {
        current = current,
        cost = cost,
        ready = cost > 0 and current >= cost,
    }
end

local function ReadActionSlotEffect(slotIndex, hotbarCategory)
    local remainingMs = GetActionSlotEffectTimeRemaining(slotIndex, hotbarCategory) or 0
    if remainingMs <= MINIMUM_ACTION_BAR_TIMER_DISPLAYED_TIME_MS then return nil end

    local durationMs = remainingMs
    if type(GetActionSlotEffectDuration) == "function" then
        durationMs = GetActionSlotEffectDuration(slotIndex, hotbarCategory) or remainingMs
    end
    if durationMs <= 0 then
        durationMs = remainingMs
    end

    local stackCount = 0
    if type(GetActionSlotEffectStackCount) == "function" then
        stackCount = GetActionSlotEffectStackCount(slotIndex, hotbarCategory) or 0
    end

    return {
        remaining = remainingMs / 1000,
        duration = durationMs / 1000,
        stackCount = stackCount,
    }
end

local function GetActionSlotEffect(barName, slotKey)
    local slotIndex = ACTION_SLOT_BY_KEY[slotKey]
    local bar = BAR_DEFS[barName]
    if not slotIndex or not bar or type(GetActionSlotEffectTimeRemaining) ~= "function" then return nil end

    if IsActiveBar(barName) then
        if type(GetActiveHotbarCategory) == "function" then
            local activeHotbarCategory = GetActiveHotbarCategory()
            local effect = ReadActionSlotEffect(slotIndex, activeHotbarCategory)
            if effect then return effect end
        end

        local effect = ReadActionSlotEffect(slotIndex, nil)
        if effect then return effect end
    end

    return ReadActionSlotEffect(slotIndex, bar.hotbarCategory)
end

local function FormatTimerSeconds(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    if type(ZO_FormatTimeShowUnitOverThresholdShowDecimalUnderThreshold) == "function"
        and TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT ~= nil then
        local showUnitOverThresholdS = ZO_ONE_MINUTE_IN_SECONDS or 60
        local showDecimalUnderThresholdS = ZO_EFFECT_EXPIRATION_IMMINENCE_THRESHOLD_S or 3
        return ZO_FormatTimeShowUnitOverThresholdShowDecimalUnderThreshold(
            seconds,
            showUnitOverThresholdS,
            showDecimalUnderThresholdS,
            TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT
        )
    end
    if seconds >= 60 then
        return tostring(math.ceil(seconds / 60)) .. "m"
    end
    return tostring(math.ceil(seconds))
end

local function FormatCooldownMilliseconds(milliseconds)
    local seconds = math.ceil(math.max(0, tonumber(milliseconds) or 0) / 1000)
    if seconds >= 60 then
        return string.format("%d:%02d", zo_floor(seconds / 60), seconds % 60)
    end
    return tostring(seconds)
end

local function GetNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end
    return 0
end

local function PlaySlotUseAnimation(slot)
    if not slot then return end
    slot.useFlashExpiresMs = GetNowMs() + SLOT_USE_ANIMATION_MS
end

local function UpdateSlotUseAnimation(slot)
    if not (slot and slot.flash and slot.icon) then return end

    local remainingMs = (slot.useFlashExpiresMs or 0) - GetNowMs()
    if remainingMs <= 0 then
        slot.useFlashExpiresMs = nil
        slot.flash:SetHidden(true)
        slot.flash:SetAlpha(0)
        slot.icon:SetScale(1)
        return
    end

    local ratio = Clamp(remainingMs / SLOT_USE_ANIMATION_MS, 0, 1)
    slot.flash:SetHidden(false)
    slot.flash:SetAlpha(0.72 * ratio)
    slot.icon:SetScale(1 + ((SLOT_USE_SCALE - 1) * ratio))
end

local function UpdateSlotTimer(slot, effect, visible, alpha, warningRatio, timerR, timerG, timerB, timerA)
    if not (slot and slot.timerLabel and slot.timerBg and slot.timerBar and slot.stackLabel) then return end
    if not visible or effect == nil or (effect.remaining or 0) <= 0 then
        slot.timerLabel:SetHidden(true)
        slot.timerBg:SetHidden(true)
        slot.timerBar:SetHidden(true)
        slot.stackLabel:SetHidden(true)
        return
    end

    local remaining = math.max(0, effect.remaining or 0)
    local duration = math.max(0, effect.duration or 0)
    local ratio = duration > 0 and Clamp(remaining / duration, 0, 1) or 1
    local timerAlpha = Clamp(alpha or 1, 0.18, 1.0)
    local warningEnabled = (warningRatio or 0) > 0
    local isWarning = warningEnabled and duration > 0 and ratio <= warningRatio

    slot.timerLabel:SetText(FormatTimerSeconds(remaining))
    if isWarning then
        slot.timerLabel:SetColor(TIMER_WARNING_LABEL_COLOR.r, TIMER_WARNING_LABEL_COLOR.g, TIMER_WARNING_LABEL_COLOR.b, TIMER_WARNING_LABEL_COLOR.a)
        slot.timerBg:SetColor(TIMER_WARNING_BG_COLOR.r, TIMER_WARNING_BG_COLOR.g, TIMER_WARNING_BG_COLOR.b, TIMER_WARNING_BG_COLOR.a)
        slot.timerBar:SetColor(TIMER_WARNING_BAR_COLOR.r, TIMER_WARNING_BAR_COLOR.g, TIMER_WARNING_BAR_COLOR.b, TIMER_WARNING_BAR_COLOR.a)
    else
        slot.timerLabel:SetColor(TIMER_LABEL_COLOR.r, TIMER_LABEL_COLOR.g, TIMER_LABEL_COLOR.b, TIMER_LABEL_COLOR.a)
        slot.timerBg:SetColor(TIMER_BG_COLOR.r, TIMER_BG_COLOR.g, TIMER_BG_COLOR.b, TIMER_BG_COLOR.a)
        slot.timerBar:SetColor(timerR, timerG, timerB, timerA)
    end
    slot.timerLabel:SetAlpha(timerAlpha)
    slot.timerLabel:SetHidden(false)
    slot.timerBg:SetAlpha(timerAlpha)
    slot.timerBg:SetHidden(false)
    slot.timerBar:SetValue(ratio)
    slot.timerBar:SetAlpha(timerAlpha)
    slot.timerBar:SetHidden(false)

    if (effect.stackCount or 0) > 0 then
        slot.stackLabel:SetText(tostring(effect.stackCount))
        slot.stackLabel:SetAlpha(timerAlpha)
        slot.stackLabel:SetHidden(false)
    else
        slot.stackLabel:SetHidden(true)
    end
end

local function UpdateSlotUltimate(slot, ultimateState, visible, alpha)
    if not (slot and slot.ultimateLabel) then return end
    if not visible or ultimateState == nil or (ultimateState.cost or 0) <= 0 then
        slot.ultimateLabel:SetHidden(true)
        return
    end

    local labelAlpha = Clamp(alpha or 1, 0.25, 1.0)
    slot.ultimateLabel:SetText(string.format("%d/%d", zo_floor(ultimateState.current or 0), zo_floor(ultimateState.cost or 0)))
    slot.ultimateLabel:SetAlpha(labelAlpha)
    slot.ultimateLabel:SetHidden(false)
end

local function GetSlotKeybindActionNames(slotKey)
    local slotIndex = ACTION_SLOT_BY_KEY[slotKey]
    if not slotIndex then return nil, nil end
    return "ACTION_BUTTON_" .. tostring(slotIndex), "GAMEPAD_ACTION_BUTTON_" .. tostring(slotIndex)
end

local function RegisterSlotKeybindLabel(slot, slotKey, mode, iconSize)
    if not (slot and slot.keyLabel) then return end
    local scalePercent = GetKeybindScalePercent(iconSize, mode)
    if slot.keybindMode == mode and slot.keybindScalePercent == scalePercent then return end

    if type(ZO_Keybindings_UnregisterLabelForBindingUpdate) == "function" then
        ZO_Keybindings_UnregisterLabelForBindingUpdate(slot.keyLabel)
    end

    slot.keybindMode = mode
    slot.keybindScalePercent = scalePercent
    slot.keyLabel:SetText("")
    slot.keyLabel:SetHidden(true)

    if mode == KEYBIND_MODE_OFF or slotKey == "weapon" then return end
    if type(ZO_Keybindings_RegisterLabelForBindingUpdate) ~= "function" then return end

    local keyboardAction, gamepadAction = GetSlotKeybindActionNames(slotKey)
    if not keyboardAction then return end

    local HIDE_UNBOUND = false
    if mode == KEYBIND_MODE_KEYBOARD then
        ZO_Keybindings_RegisterLabelForBindingUpdate(
            slot.keyLabel,
            keyboardAction,
            HIDE_UNBOUND,
            nil,
            nil,
            false,
            nil,
            scalePercent
        )
    elseif mode == KEYBIND_MODE_GAMEPAD then
        ZO_Keybindings_RegisterLabelForBindingUpdate(
            slot.keyLabel,
            keyboardAction,
            HIDE_UNBOUND,
            gamepadAction,
            nil,
            true,
            nil,
            scalePercent
        )
    else
        ZO_Keybindings_RegisterLabelForBindingUpdate(
            slot.keyLabel,
            keyboardAction,
            HIDE_UNBOUND,
            gamepadAction,
            nil,
            false,
            nil,
            scalePercent
        )
    end
end

local function UpdateSlotKeybind(slot, slotKey, mode, iconSize, visible, hasAbility, alpha)
    RegisterSlotKeybindLabel(slot, slotKey, mode, iconSize)
    if not (slot and slot.keyLabel) then return end

    local shouldShow = visible and hasAbility and mode ~= KEYBIND_MODE_OFF and slotKey ~= "weapon"
    slot.keyLabel:SetHidden(not shouldShow)
    if shouldShow then
        slot.keyLabel:SetAlpha(Clamp(alpha or 1, 0.25, 1.0))
    end
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

    local flash = WINDOW_MANAGER:CreateControl(name .. "_Flash", root, CT_TEXTURE)
    flash:SetTexture(WHITE_TEXTURE)
    flash:SetColor(1, 0.78, 0.28, 1)
    flash:SetMouseEnabled(false)
    flash:SetHidden(true)

    local timerBg = WINDOW_MANAGER:CreateControl(name .. "_TimerBg", root, CT_TEXTURE)
    timerBg:SetTexture(WHITE_TEXTURE)
    timerBg:SetColor(TIMER_BG_COLOR.r, TIMER_BG_COLOR.g, TIMER_BG_COLOR.b, TIMER_BG_COLOR.a)
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
    timerLabel:SetFont("ZoFontGameLargeBold")
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    timerLabel:SetColor(TIMER_LABEL_COLOR.r, TIMER_LABEL_COLOR.g, TIMER_LABEL_COLOR.b, TIMER_LABEL_COLOR.a)
    timerLabel:SetMouseEnabled(false)
    timerLabel:SetHidden(true)

    local stackLabel = WINDOW_MANAGER:CreateControl(name .. "_StackLabel", root, CT_LABEL)
    stackLabel:SetFont("ZoFontGameLargeBold")
    stackLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    stackLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    stackLabel:SetColor(1, 1, 1, 1)
    stackLabel:SetMouseEnabled(false)
    stackLabel:SetHidden(true)

    local ultimateLabel = WINDOW_MANAGER:CreateControl(name .. "_UltimateLabel", root, CT_LABEL)
    ultimateLabel:SetFont("ZoFontGameLargeBold")
    ultimateLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ultimateLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimateLabel:SetColor(1, 0.86, 0.30, 1)
    ultimateLabel:SetMouseEnabled(false)
    ultimateLabel:SetHidden(true)

    local keyLabel = WINDOW_MANAGER:CreateControl(name .. "_KeyLabel", root, CT_LABEL)
    keyLabel:SetFont("ZoFontGameSmall")
    keyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    keyLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    keyLabel:SetColor(0.92, 0.92, 0.98, 0.95)
    keyLabel:SetMouseEnabled(false)
    keyLabel:SetHidden(true)

    return {
        root = root,
        bg = bg,
        icon = icon,
        border = border,
        flash = flash,
        timerBg = timerBg,
        timerBar = timerBar,
        timerLabel = timerLabel,
        stackLabel = stackLabel,
        ultimateLabel = ultimateLabel,
        keyLabel = keyLabel,
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

local function BuildQuickslot()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(QUICK_SLOT_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_Bg", root, CT_TEXTURE)
    bg:SetTexture(WHITE_TEXTURE)
    bg:SetColor(0.02, 0.025, 0.03, 0.82)
    bg:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_Icon", root, CT_TEXTURE)
    icon:SetMouseEnabled(false)

    local cooldownFill = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_CooldownFill", root, CT_TEXTURE)
    cooldownFill:SetMouseEnabled(false)
    cooldownFill:SetHidden(true)

    local border = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_Border", root, CT_BACKDROP)
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeColor(0.90, 0.62, 1.0, 0.95)
    border:SetMouseEnabled(false)

    local countLabel = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_Count", root, CT_LABEL)
    countLabel:SetFont("ZoFontGameLargeBold")
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    countLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    countLabel:SetColor(1, 1, 1, 1)
    countLabel:SetMouseEnabled(false)
    countLabel:SetHidden(true)

    local cooldownLabel = WINDOW_MANAGER:CreateControl(QUICK_SLOT_NAME .. "_CooldownLabel", root, CT_LABEL)
    cooldownLabel:SetFont("ZoFontGameLargeBold")
    cooldownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cooldownLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    cooldownLabel:SetColor(1, 0.86, 0.30, 1)
    cooldownLabel:SetMouseEnabled(false)
    cooldownLabel:SetHidden(true)

    return {
        root = root,
        bg = bg,
        icon = icon,
        cooldownFill = cooldownFill,
        border = border,
        countLabel = countLabel,
        cooldownLabel = cooldownLabel,
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
        entry.root:SetMovable(movable and self.customActionBarsDragActive[barName] == true)
        entry.root:SetMouseEnabled(movable)
    end
end

function EZO_HUD:RefreshCustomQuickslotMovementState()
    local quickslot = self.customActionBars and self.customActionBars.quickslot
    if not quickslot then return end

    local movable = self:IsMoveModeEnabled("customActionBarQuickslot")
    if self.customActionBarsQuickslotDragActive and not movable then
        quickslot.root:StopMovingOrResizing()
        self.customActionBarsQuickslotDragActive = false
    end
    quickslot.root:SetMovable(movable and self.customActionBarsQuickslotDragActive == true)
    quickslot.root:SetMouseEnabled(movable)
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

function EZO_HUD:SaveCustomQuickslotPosition()
    local quickslot = self.customActionBars and self.customActionBars.quickslot
    local settings = self.sv and self.sv.customActionBars
    if not (quickslot and settings) then return end

    local left = quickslot.root:GetLeft()
    local top = quickslot.root:GetTop()
    local width = quickslot.root:GetWidth()
    local height = quickslot.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then return end

    settings.quickslotOffsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
    settings.quickslotOffsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyCustomQuickslotLayout()
end

function EZO_HUD:ApplyCustomActionBarsNativeVisibility()
    local settings = GetSettings()
    local actionBar = ZO_ActionBar1
    if not (actionBar and actionBar.SetHidden) then return end

    local hudVisible = EZO_HUD.IsHudSceneVisible == nil or EZO_HUD:IsHudSceneVisible()
    if ShouldHideNativeActionBar(settings) then
        self.customActionBarsNativeHidden = true
        actionBar:SetHidden(true)
    elseif self.customActionBarsNativeHidden
        and hudVisible
        and (settings.hideNativeActionBar ~= true or not ShouldUseCustomActionBars(settings)) then
        actionBar:SetHidden(false)
        self.customActionBarsNativeHidden = false
    end
end

function EZO_HUD:ApplyCustomQuickslotLayout()
    local quickslot = self.customActionBars and self.customActionBars.quickslot
    if not quickslot then return end

    local settings = GetSettings()
    local iconSize = Clamp(settings.iconSize, 28, MAX_ICON_SIZE)
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.quickslotOffsetX or -210) - (iconSize / 2))
    local top = zo_floor((guiHeight / 2) + (settings.quickslotOffsetY or 320) - (iconSize / 2))

    quickslot.root:SetDimensions(iconSize, iconSize)
    quickslot.root:ClearAnchors()
    quickslot.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    quickslot.bg:ClearAnchors()
    quickslot.bg:SetAnchorFill(quickslot.root)

    quickslot.icon:ClearAnchors()
    quickslot.icon:SetAnchor(CENTER, quickslot.root, CENTER, 0, 0)
    quickslot.icon:SetDimensions(iconSize - 4, iconSize - 4)

    quickslot.cooldownFill:ClearAnchors()
    quickslot.cooldownFill:SetAnchor(BOTTOMLEFT, quickslot.icon, BOTTOMLEFT, 0, 0)
    quickslot.cooldownFill:SetDimensions(iconSize - 4, iconSize - 4)

    quickslot.border:ClearAnchors()
    quickslot.border:SetAnchorFill(quickslot.root)

    quickslot.countLabel:ClearAnchors()
    quickslot.countLabel:SetFont(iconSize >= 58 and "ZoFontGameLargeBold" or "ZoFontGameShadow")
    quickslot.countLabel:SetAnchor(BOTTOMRIGHT, quickslot.root, BOTTOMRIGHT, -5, -5)
    quickslot.countLabel:SetDimensions(iconSize - 10, zo_floor(iconSize * 0.45))

    quickslot.cooldownLabel:ClearAnchors()
    quickslot.cooldownLabel:SetFont(iconSize >= 58 and "ZoFontGameLargeBold" or "ZoFontGameShadow")
    quickslot.cooldownLabel:SetAnchor(CENTER, quickslot.root, CENTER, 0, 0)
    quickslot.cooldownLabel:SetDimensions(iconSize - 8, zo_floor(iconSize * 0.58))

    self:RefreshCustomQuickslotMovementState()
    self:RefreshCustomQuickslot()
end

function EZO_HUD:ApplyCustomActionBarsLayout()
    if not self.customActionBars then return end

    local settings = GetSettings()
    local iconSize = Clamp(settings.iconSize, 28, MAX_ICON_SIZE)
    local spacing = Clamp(settings.spacing, 0, 16)
    local orientation = GetOrientation(settings)
    local timerR, timerG, timerB, timerA = GetTimerBarColor(settings)
    local slotOrder = GetLayoutSlotOrder(orientation)
    local count = #slotOrder
    local width = orientation == LAYOUT_HORIZONTAL and ((iconSize * count) + (spacing * (count - 1))) or iconSize
    local height = orientation == LAYOUT_VERTICAL and ((iconSize * count) + (spacing * (count - 1))) or iconSize

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = self.customActionBars.bars[barName]
        local guiWidth, guiHeight = GuiRoot:GetDimensions()
        local left = zo_floor((guiWidth / 2) + (settings[bar.offsetXKey] or 0) - (width / 2))
        local top = zo_floor((guiHeight / 2) + (settings[bar.offsetYKey] or 0) - (height / 2))

        entry.root:SetDimensions(width, height)
        entry.root:ClearAnchors()
        entry.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

        for index, slotKey in ipairs(slotOrder) do
            local slot = entry.slots[slotKey]
            local offset = (index - 1) * (iconSize + spacing)
            slot.root:SetDimensions(iconSize, iconSize)
            slot.root:ClearAnchors()
            if orientation == LAYOUT_VERTICAL then
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

            slot.flash:ClearAnchors()
            slot.flash:SetAnchorFill(slot.root)

            slot.timerBg:ClearAnchors()
            slot.timerBg:SetAnchor(BOTTOMLEFT, slot.root, BOTTOMLEFT, 4, -4)
            slot.timerBg:SetAnchor(BOTTOMRIGHT, slot.root, BOTTOMRIGHT, -4, -4)
            slot.timerBg:SetHeight(math.max(5, zo_floor(iconSize * 0.14)))

            slot.timerBar:ClearAnchors()
            slot.timerBar:SetAnchorFill(slot.timerBg)
            slot.timerBar:SetColor(timerR, timerG, timerB, timerA)

            slot.timerLabel:ClearAnchors()
            slot.timerLabel:SetFont(iconSize >= 58 and "ZoFontGameLargeBold" or "ZoFontGameShadow")
            slot.timerLabel:SetAnchor(BOTTOMRIGHT, slot.root, BOTTOMRIGHT, -5, -10)
            slot.timerLabel:SetDimensions(iconSize - 10, zo_floor(iconSize * 0.52))

            slot.stackLabel:ClearAnchors()
            slot.stackLabel:SetFont(iconSize >= 58 and "ZoFontGameLargeBold" or "ZoFontGameShadow")
            slot.stackLabel:SetAnchor(BOTTOMLEFT, slot.root, BOTTOMLEFT, 5, -10)
            slot.stackLabel:SetDimensions(iconSize - 10, zo_floor(iconSize * 0.52))

            slot.ultimateLabel:ClearAnchors()
            slot.ultimateLabel:SetFont(iconSize >= 58 and "ZoFontGameLargeBold" or "ZoFontGameShadow")
            slot.ultimateLabel:SetAnchor(CENTER, slot.root, CENTER, 0, zo_floor(iconSize * 0.15))
            slot.ultimateLabel:SetDimensions(iconSize - 8, zo_floor(iconSize * 0.46))

            slot.keyLabel:ClearAnchors()
            slot.keyLabel:SetFont(iconSize >= 72 and "ZoFontWinH4" or iconSize >= 54 and "ZoFontGameLargeBold" or "ZoFontGameBold")
            slot.keyLabel:SetAnchor(TOP, slot.root, TOP, 0, 2)
            slot.keyLabel:SetDimensions(iconSize - 4, zo_floor(iconSize * 0.42))
        end
    end

    self:RefreshCustomActionBarsMovementState()
    self:RefreshCustomActionBars()
    self:ApplyCustomQuickslotLayout()
end

function EZO_HUD:RefreshCustomQuickslot()
    local quickslot = self.customActionBars and self.customActionBars.quickslot
    if not quickslot then return end

    local settings = GetSettings()
    local shouldShow = ShouldShowCustomQuickslot(settings)
    local texture, hasAction, count, cooldownRemainingMs, cooldownDurationMs = GetQuickslotState()
    local moving = self:IsMoveModeEnabled("customActionBarQuickslot")
    local inCooldown = hasAction and cooldownRemainingMs > 0 and cooldownDurationMs > 0
    local cooldownProgress = inCooldown and Clamp(1 - (cooldownRemainingMs / cooldownDurationMs), 0, 1) or 1

    quickslot.root:SetHidden(not shouldShow or (not hasAction and not moving))
    quickslot.icon:SetTexture(texture)
    quickslot.icon:SetColor(1, 1, 1, hasAction and (inCooldown and QUICKSLOT_COOLDOWN_DIM_ALPHA or 1) or 0.25)
    quickslot.bg:SetAlpha(hasAction and 1 or 0.45)
    quickslot.border:SetEdgeColor(0.90, 0.62, 1.0, hasAction and 0.95 or 0.45)

    if inCooldown then
        local iconWidth, iconHeight = quickslot.icon:GetDimensions()
        iconWidth = math.max(1, tonumber(iconWidth) or Clamp(settings.iconSize, 28, MAX_ICON_SIZE) - 4)
        iconHeight = math.max(1, tonumber(iconHeight) or Clamp(settings.iconSize, 28, MAX_ICON_SIZE) - 4)
        local fillHeight = math.max(1, zo_floor(iconHeight * cooldownProgress))
        local textureTop = Clamp(1 - cooldownProgress, 0, 1)

        quickslot.cooldownFill:SetTexture(texture)
        quickslot.cooldownFill:ClearAnchors()
        quickslot.cooldownFill:SetAnchor(BOTTOMLEFT, quickslot.icon, BOTTOMLEFT, 0, 0)
        quickslot.cooldownFill:SetDimensions(iconWidth, fillHeight)
        quickslot.cooldownFill:SetTextureCoords(0, 1, textureTop, 1)
        quickslot.cooldownFill:SetColor(1, 1, 1, 1)
        quickslot.cooldownFill:SetHidden(false)

        quickslot.cooldownLabel:SetText(FormatCooldownMilliseconds(cooldownRemainingMs))
        quickslot.cooldownLabel:SetHidden(false)
        quickslot.countLabel:SetHidden(true)
    else
        quickslot.cooldownFill:SetHidden(true)
        quickslot.cooldownLabel:SetHidden(true)
        if quickslot.cooldownFill.SetTextureCoords then
            quickslot.cooldownFill:SetTextureCoords(0, 1, 0, 1)
        end
    end

    if not inCooldown and count ~= nil and count >= 0 then
        local formattedCount = type(ZO_AbbreviateAndLocalizeRadialMenuEntryCount) == "function"
            and ZO_AbbreviateAndLocalizeRadialMenuEntryCount(count, false)
            or tostring(count)
        quickslot.countLabel:SetText(formattedCount)
        quickslot.countLabel:SetHidden(false)
    else
        quickslot.countLabel:SetHidden(true)
    end

    self:RefreshCustomQuickslotMovementState()
end

function EZO_HUD:RefreshCustomActionBars()
    if not self.customActionBars then return end

    local settings = GetSettings()
    local activeAlpha = 1.0
    local inactiveAlpha = Clamp(settings.inactiveAlpha, 0.2, 1.0)
    local dimmedAlpha = Clamp(settings.dimmedAlpha, 0.05, 1.0)
    local showTimers = settings.showTimers == true
    local keybindMode = GetKeybindMode(settings)
    local warningRatio = GetTimerWarningPercent(settings) / 100
    local timerR, timerG, timerB, timerA = GetTimerBarColor(settings)

    for _, barName in ipairs(BAR_ORDER) do
        local bar = BAR_DEFS[barName]
        local entry = self.customActionBars.bars[barName]
        local isActive = IsActiveBar(barName)
        local barAlpha = isActive and activeAlpha or inactiveAlpha
        local shouldShow = ShouldShowBar(barName)

        entry.root:SetHidden(not shouldShow)

        for _, slotKey in ipairs(SLOT_ORDER) do
            local slot = entry.slots[slotKey]
            local hideInactiveWeapon = slotKey == "weapon" and not isActive
            slot.root:SetHidden(hideInactiveWeapon)
            local texture
            local hasAbility = true
            if slotKey == "weapon" then
                texture = GetWeaponIcon(barName)
            else
                texture, hasAbility = GetActionSlotIcon(slotKey, bar.hotbarCategory)
            end

            local effect = showTimers and GetActionSlotEffect(barName, slotKey) or nil
            local hasActiveTimer = effect ~= nil and (effect.remaining or 0) > 0
            local isDimmed = settings.dimSlots and settings.dimSlots[slotKey] == true
            local alpha = hasActiveTimer and activeAlpha or (isDimmed and dimmedAlpha or barAlpha)
            local ultimateState = GetUltimateSlotState(slotKey, bar.hotbarCategory)
            local iconAlpha = alpha
            if slotKey == "ultimate" and ultimateState ~= nil and not ultimateState.ready then
                iconAlpha = math.min(iconAlpha, 0.38)
            end
            slot.icon:SetTexture(texture)
            slot.icon:SetColor(1, 1, 1, hasAbility and iconAlpha or 0.18)
            slot.bg:SetAlpha(shouldShow and 1 or 0)
            UpdateSlotTimer(slot, effect, shouldShow and showTimers and hasAbility, alpha, warningRatio, timerR, timerG, timerB, timerA)
            UpdateSlotUltimate(slot, ultimateState, shouldShow and hasAbility, iconAlpha)
            UpdateSlotKeybind(slot, slotKey, keybindMode, settings.iconSize, shouldShow, hasAbility, alpha)
            UpdateSlotUseAnimation(slot)

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
    self:RefreshCustomQuickslot()
    self:ApplyCustomActionBarsNativeVisibility()
end

function EZO_HUD:PlayCustomActionSlotUseAnimation(actionSlotIndex)
    if not self.customActionBars then return end
    local slotKey = SLOT_KEY_BY_ACTION_SLOT[actionSlotIndex]
    if not slotKey then return end

    local activeBarName = GetActiveBarName()
    local entry = self.customActionBars.bars and self.customActionBars.bars[activeBarName]
    local slot = entry and entry.slots and entry.slots[slotKey]
    PlaySlotUseAnimation(slot)
    self:RefreshCustomActionBars()
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
    if EVENT_HOTBAR_SLOT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_HOTBAR_SLOT_UPDATED, refresh)
    end
    if EVENT_ACTIVE_QUICKSLOT_CHANGED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTIVE_QUICKSLOT_CHANGED, refresh)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, refresh)
    end
    if EVENT_ACTION_SLOT_EFFECT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_EFFECT_UPDATE, refresh)
    end
    if EVENT_ACTION_SLOT_EFFECTS_CLEARED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_EFFECTS_CLEARED, refresh)
    end
    if EVENT_POWER_UPDATE then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_POWER_UPDATE, function(_, unitTag, _, powerType)
            if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
                refresh()
            end
        end)
    end
    if EVENT_ULTIMATE_ABILITY_COST_CHANGED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ULTIMATE_ABILITY_COST_CHANGED, refresh)
    end
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, refresh)
    end
    if EVENT_ACTION_SLOT_ABILITY_USED then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex)
            EZO_HUD:PlayCustomActionSlotUseAnimation(actionSlotIndex)
        end)
    end
    if EVENT_ACTION_UPDATE_COOLDOWNS then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_UPDATE_COOLDOWNS, refresh)
    end
    if EVENT_MANAGER.RegisterForUpdate then
        EVENT_MANAGER:RegisterForUpdate(namespace .. "_Timers", TIMER_UPDATE_MS, function()
            local settings = GetSettings()
            if settings.enabled then
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

local function BuildKeybindModeChoices()
    return {
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_KEYBIND_MODE_OFF),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_KEYBIND_MODE_AUTO),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_KEYBIND_MODE_KEYBOARD),
        GetString(EZO_HUD_CUSTOM_ACTION_BARS_KEYBIND_MODE_GAMEPAD),
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
        if EZO_HUD.RequestSettingsPanelRefresh then
            EZO_HUD:RequestSettingsPanelRefresh()
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
    self.customActionBarsQuickslotDragActive = false

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

    local quickslot = BuildQuickslot()
    quickslot.root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("customActionBarQuickslot") then
            self.customActionBarsQuickslotDragActive = true
            control:SetMovable(true)
            control:StartMoving()
        end
    end)
    quickslot.root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("customActionBarQuickslot") then
            control:StopMovingOrResizing()
            self.customActionBarsQuickslotDragActive = false
            control:SetMovable(false)
            self:SaveCustomQuickslotPosition()
        end
    end)
    quickslot.root:SetHandler("OnMoveStop", function()
        self.customActionBarsQuickslotDragActive = false
        quickslot.root:SetMovable(false)
        self:SaveCustomQuickslotPosition()
    end)
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(quickslot.root)
    end
    self.customActionBars.quickslot = quickslot

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
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "HideNativeActionBar",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_HIDE_NATIVE),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_HIDE_NATIVE_TOOLTIP),
                    getFunc = function() return settings.hideNativeActionBar == true end,
                    setFunc = function(value)
                        settings.hideNativeActionBar = value == true
                        EZO_HUD:ApplyCustomActionBarsNativeVisibility()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.hideNativeActionBar,
                    width = "half",
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
                    choicesValues = { LAYOUT_HORIZONTAL, LAYOUT_VERTICAL },
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
                    type = "checkbox",
                    reference = LAM_REFERENCE_PREFIX .. "MoveQuickslot",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_QUICKSLOT),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_MOVE_QUICKSLOT_TOOLTIP),
                    getFunc = function() return EZO_HUD:IsMoveModeEnabled("customActionBarQuickslot") end,
                    setFunc = function(value)
                        EZO_HUD:SetMoveModeEnabled("customActionBarQuickslot", value)
                        EZO_HUD:RefreshCustomQuickslotMovementState()
                        EZO_HUD:RefreshCustomQuickslot()
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
                    max = MAX_ICON_SIZE,
                    step = 2,
                    getFunc = function() return Clamp(settings.iconSize, 28, MAX_ICON_SIZE) end,
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
                    type = "colorpicker",
                    reference = LAM_REFERENCE_PREFIX .. "TimerBarColor",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_TIMER_BAR_COLOR),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_TIMER_BAR_COLOR_TOOLTIP),
                    getFunc = function()
                        return GetTimerBarColor(settings)
                    end,
                    setFunc = function(r, g, b, a)
                        settings.timerBarColor = { r = r, g = g, b = b, a = a }
                        EZO_HUD:ApplyCustomActionBarsLayout()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.timerBarColor,
                    width = "half",
                },
                {
                    type = "slider",
                    reference = LAM_REFERENCE_PREFIX .. "TimerWarningPercent",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_TIMER_WARNING_PERCENT),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_TIMER_WARNING_PERCENT_TOOLTIP),
                    min = 0,
                    max = TIMER_WARNING_MAX_PERCENT,
                    step = 5,
                    getFunc = function() return GetTimerWarningPercent(settings) end,
                    setFunc = function(value)
                        settings.timerWarningPercent = Clamp(value, 0, TIMER_WARNING_MAX_PERCENT)
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.timerWarningPercent,
                    width = "half",
                },
                {
                    type = "dropdown",
                    reference = LAM_REFERENCE_PREFIX .. "KeybindMode",
                    name = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_KEYBIND_MODE),
                    tooltip = GetString(EZO_HUD_OPTION_CUSTOM_ACTION_BARS_KEYBIND_MODE_TOOLTIP),
                    choices = BuildKeybindModeChoices(),
                    choicesValues = {
                        KEYBIND_MODE_OFF,
                        KEYBIND_MODE_AUTO,
                        KEYBIND_MODE_KEYBOARD,
                        KEYBIND_MODE_GAMEPAD,
                    },
                    getFunc = function() return GetKeybindMode(settings) end,
                    setFunc = function(value)
                        settings.keybindMode = GetKeybindMode({ keybindMode = value })
                        EZO_HUD:RefreshCustomActionBars()
                    end,
                    disabled = function() return not settings.enabled end,
                    default = EZO_HUD.defaults.customActionBars.keybindMode,
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
