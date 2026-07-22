EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local SAVED_VARIABLES_NAME = "EZOhud_Saved"
local SAVED_VARIABLES_VERSION = 1
local MIGRATION_MARKER = "__ezoPreferenceScopeMigrated"

local function DeepCopy(src)
    if type(src) ~= "table" then
        return src
    end

    local out = {}
    for key, value in pairs(src) do
        out[key] = DeepCopy(value)
    end
    return out
end

local function ApplyDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then
        return
    end

    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = DeepCopy(value)
        elseif type(target[key]) == "table" and type(value) == "table" then
            ApplyDefaults(target[key], value)
        end
    end
end

local function CopySavedValues(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if key ~= MIGRATION_MARKER then
            target[key] = DeepCopy(value)
        end
    end
end

local function GetPreferenceScope()
    if EZOCore and type(EZOCore.GetPreferenceScope) == "function" then
        local ok, scope = pcall(function()
            return EZOCore:GetPreferenceScope("ezohud", "settings")
        end)
        if ok and scope == "character" then
            return "character"
        end
    end
    return "account"
end

function EZO_HUD:InitializeSavedVariables()
    local world = GetWorldName()
    local scope = GetPreferenceScope()
    self.preferenceScope = scope

    if scope == "character" then
        self.sv = ZO_SavedVars:NewCharacterIdSettings(
            SAVED_VARIABLES_NAME,
            SAVED_VARIABLES_VERSION,
            world,
            self.defaults)
        if type(self.sv) == "table" and self.sv[MIGRATION_MARKER] ~= true then
            local accountSv = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, world, nil)
            CopySavedValues(self.sv, accountSv)
            self.sv[MIGRATION_MARKER] = true
        end
    else
        self.sv = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, world, self.defaults)
    end

    ApplyDefaults(self.sv, self.defaults)
end
