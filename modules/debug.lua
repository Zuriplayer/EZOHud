EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local DEFAULT_SUBTAG = "Debug"

local function SafeChat(msg)
    if EZO_HUD.Print then
        EZO_HUD.Print(tostring(msg))
    else
        d(tostring(msg))
    end
end

local function DebugEnabled()
    return EZO_HUD.sv
        and EZO_HUD.sv.general
        and EZO_HUD.sv.general.debugEnabled == true
end

function EZO_HUD:IsDebugModeEnabled()
    local _ = self
    return DebugEnabled()
end

function EZO_HUD:SetDebugModeEnabled(enabled)
    local _ = self
    if not (EZO_HUD.sv and EZO_HUD.sv.general) then
        return false
    end

    EZO_HUD.sv.general.debugEnabled = enabled == true
    if not EZO_HUD.sv.general.debugEnabled then
        EZO_HUD.sv.general.debugToChat = false
    else
        EZO_HUD:InitializeDebug()
    end
    return DebugEnabled() == (enabled == true)
end

local function DebugToChatEnabled()
    return EZO_HUD.sv
        and EZO_HUD.sv.general
        and EZO_HUD.sv.general.debugToChat == true
end

local function EnsureDebugLogger()
    EZO_HUD.runtime = EZO_HUD.runtime or {}
    if EZO_HUD.runtime.debugLogger then
        return EZO_HUD.runtime.debugLogger
    end
    if EZO_HUD.runtime.debugLoggerUnavailable == true then
        return nil
    end

    local lib = _G.LibDebugLogger
    if type(lib) ~= "function" and type(lib) ~= "table" then
        EZO_HUD.runtime.debugLoggerUnavailable = true
        return nil
    end

    local ok, logger = pcall(function()
        local created = nil
        if type(lib) == "function" then
            created = lib(EZO_HUD.ADDON_NAME or "EZOhud")
        elseif type(lib.Create) == "function" then
            created = lib:Create(EZO_HUD.ADDON_NAME or "EZOhud")
        end
        if created and type(created.SetMinLevelOverride) == "function" and type(lib) == "table" and lib.LOG_LEVEL_DEBUG ~= nil then
            created:SetMinLevelOverride(lib.LOG_LEVEL_DEBUG)
        end
        if created and type(created.SetLogTracesOverride) == "function" then
            created:SetLogTracesOverride(false)
        end
        return created
    end)

    if ok and logger then
        EZO_HUD.runtime.debugLogger = logger
        EZO_HUD.runtime.debugLoggerUnavailable = false
        return logger
    end

    EZO_HUD.runtime.debugLoggerUnavailable = true
    return nil
end

local function WriteToViewer(level, msg, subTag)
    if not DebugEnabled() then
        return false
    end

    local logger = EnsureDebugLogger()
    if not logger then
        return false
    end

    local ok = pcall(function()
        if type(logger.SetSubTag) == "function" then
            logger:SetSubTag(subTag or DEFAULT_SUBTAG)
        end

        if level == "error" and type(logger.Error) == "function" then
            logger:Error(tostring(msg))
        elseif level == "warn" and type(logger.Warn) == "function" then
            logger:Warn(tostring(msg))
        elseif level == "info" and type(logger.Info) == "function" then
            logger:Info(tostring(msg))
        elseif type(logger.Debug) == "function" then
            logger:Debug(tostring(msg))
        elseif type(logger.Info) == "function" then
            logger:Info(tostring(msg))
        end

        if type(logger.SetSubTag) == "function" then
            logger:SetSubTag(nil)
        end
    end)

    return ok
end

local function DebugLog(level, msg, subTag)
    if DebugEnabled() and DebugToChatEnabled() then
        SafeChat(msg)
    end
    WriteToViewer(level, msg, subTag)
end

local function CreateDebugBatch(subTag, level)
    return {
        subTag = subTag or DEFAULT_SUBTAG,
        level = level or "debug",
        lines = {},
    }
end

local function DebugBatchAdd(batch, msg)
    if type(batch) ~= "table" or type(batch.lines) ~= "table" then
        DebugLog("debug", msg, DEFAULT_SUBTAG)
        return
    end

    batch.lines[#batch.lines + 1] = tostring(msg)
    if DebugEnabled() and DebugToChatEnabled() then
        SafeChat(msg)
    end
end

local function DebugBatchFlush(batch)
    if type(batch) ~= "table" or type(batch.lines) ~= "table" or #batch.lines == 0 then
        return
    end

    WriteToViewer(batch.level or "debug", table.concat(batch.lines, "\n"), batch.subTag or DEFAULT_SUBTAG)
end

EZO_HUD.SafeChat = SafeChat
EZO_HUD.DebugPrint = function(msg, subTag)
    DebugLog("debug", msg, subTag)
end
EZO_HUD.DebugInfo = function(msg, subTag)
    DebugLog("info", msg, subTag)
end
EZO_HUD.DebugWarn = function(msg, subTag)
    DebugLog("warn", msg, subTag)
end
EZO_HUD.DebugError = function(msg, subTag)
    DebugLog("error", msg, subTag)
end
EZO_HUD.CreateDebugBatch = CreateDebugBatch
EZO_HUD.DebugBatchAdd = DebugBatchAdd
EZO_HUD.DebugBatchFlush = DebugBatchFlush

function EZO_HUD:InitializeDebug()
    local _ = self
    EZO_HUD.runtime = EZO_HUD.runtime or {}
    if DebugEnabled() then
        EnsureDebugLogger()
    end
end
