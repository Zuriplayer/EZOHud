EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CRUX_ABILITY_ID = 184220
local EVENT_NAMESPACE = "EZOhud_CruxDebug"
local UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_Update"
local SLASH_COMMAND = "/ezohudcrux"

local cruxDebugEnabled = false
local lastReportedSecond = nil

local function Chat(message)
    if EZO_HUD.SafeChat then
        EZO_HUD.SafeChat(message)
    elseif EZO_HUD.Print then
        EZO_HUD.Print(message)
    else
        d(message)
    end
end

local function Log(message)
    Chat(message)
    if EZO_HUD.DebugInfo then
        EZO_HUD.DebugInfo(message, "Crux")
    end
end

local function FormatRemaining(endTime)
    if not endTime or endTime <= 0 or not GetGameTimeSeconds then
        return "0.0s"
    end

    return string.format("%.1fs", math.max(0, endTime - GetGameTimeSeconds()))
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

local function GetRemainingSeconds(endTime)
    if not endTime or endTime <= 0 or not GetGameTimeSeconds then
        return 0
    end

    return math.max(0, endTime - GetGameTimeSeconds())
end

local function ReportCrux(prefix, stackCount, endTime)
    Log(string.format(
        GetString(EZO_HUD_CRUX_DEBUG_REPORT),
        prefix,
        stackCount or 0,
        FormatRemaining(endTime),
        CRUX_ABILITY_ID
    ))
end

local function ScanCrux()
    local stackCount, endTime = FindCruxBuff()
    ReportCrux(GetString(EZO_HUD_CRUX_DEBUG_SCAN), stackCount, endTime)
end

local function ShouldReportTick(remainingSeconds)
    local rounded = zo_floor(remainingSeconds + 0.5)
    if rounded == lastReportedSecond then
        return false
    end

    lastReportedSecond = rounded
    return rounded <= 5 or rounded % 5 == 0
end

local function OnCruxDebugUpdate()
    local stackCount, endTime = FindCruxBuff()
    if stackCount <= 0 then
        lastReportedSecond = nil
        return
    end

    if ShouldReportTick(GetRemainingSeconds(endTime)) then
        ReportCrux(GetString(EZO_HUD_CRUX_DEBUG_TICK), stackCount, endTime)
    end
end

local function OnCruxEffectChanged(_, changeType, _, _, unitTag, _, _, stackCount)
    if unitTag ~= "player" then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        ReportCrux(GetString(EZO_HUD_CRUX_DEBUG_EVENT_FADED), 0, 0)
        return
    end

    local _, endTime = FindCruxBuff()
    lastReportedSecond = nil
    ReportCrux(GetString(EZO_HUD_CRUX_DEBUG_EVENT_CHANGED), stackCount or 0, endTime)
end

local function EnableCruxDebug()
    if cruxDebugEnabled then
        ScanCrux()
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, OnCruxEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, CRUX_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, 1000, OnCruxDebugUpdate)

    cruxDebugEnabled = true
    lastReportedSecond = nil
    Log(GetString(EZO_HUD_CRUX_DEBUG_ENABLED))
    ScanCrux()
end

local function DisableCruxDebug(silent)
    if cruxDebugEnabled then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
    end

    cruxDebugEnabled = false
    lastReportedSecond = nil
    if silent ~= true then
        Log(GetString(EZO_HUD_CRUX_DEBUG_DISABLED))
    end
end

function EZO_HUD:IsCruxDebugEnabled()
    local _ = self
    return cruxDebugEnabled == true
end

function EZO_HUD:SetCruxDebugEnabled(enabled, silent)
    local _ = self
    if enabled == true then
        EnableCruxDebug()
    else
        DisableCruxDebug(silent == true)
    end
    return cruxDebugEnabled == (enabled == true)
end

local function PrintUsage()
    Chat(GetString(EZO_HUD_CRUX_DEBUG_USAGE))
end

function EZO_HUD:InitializeCruxDebug()
    local _ = self
    SLASH_COMMANDS[SLASH_COMMAND] = function(args)
        args = zo_strlower(tostring(args or ""))
        if args == "on" or args == "1" or args == "enable" then
            EnableCruxDebug()
        elseif args == "off" or args == "0" or args == "disable" then
            DisableCruxDebug(false)
        elseif args == "scan" or args == "status" then
            ScanCrux()
        else
            PrintUsage()
        end
    end
end
