EZOHUD_Lang = EZOHUD_Lang or {}

local function ApplyString(id, value, version)
    local globalId = _G[id]
    if globalId == nil then
        ZO_CreateStringId(id, value)
        globalId = _G[id]
    end

    if globalId ~= nil then
        SafeAddString(globalId, value, version)
    end
end

function EZOHUD_Lang.Apply(language)
    local effectiveLanguage = language
    if EZOhud and type(EZOhud.GetEffectiveLanguage) == "function" then
        effectiveLanguage = EZOhud.GetEffectiveLanguage(language)
    end

    local source = (effectiveLanguage == "es" and EZOHUD_STRINGS_ES) or EZOHUD_STRINGS_EN
    if not source then
        return
    end

    EZOHUD_Lang._stringVersion = (tonumber(EZOHUD_Lang._stringVersion) or 0) + 1
    for key, value in pairs(source) do
        ApplyString(key, value, EZOHUD_Lang._stringVersion)
    end

    EZOHUD_Lang.current = (effectiveLanguage == "es") and "es" or "en"
    EZOHUD_Lang.configured = tostring(language or "auto")
end
