EZOHUD_Lang = EZOHUD_Lang or {}

local function ApplyString(id, value)
    local globalId = _G[id]
    if globalId == nil then
        ZO_CreateStringId(id, value)
    else
        SafeAddString(globalId, value, 1)
    end
end

function EZOHUD_Lang.Apply(language)
    local source = (language == "es" and EZOHUD_STRINGS_ES) or EZOHUD_STRINGS_EN
    if not source then
        return
    end

    for key, value in pairs(source) do
        ApplyString(key, value)
    end

    EZOHUD_Lang.current = (language == "es") and "es" or "en"
end
