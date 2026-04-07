EZOhud_LAM = EZOhud_LAM or {}
local REG = EZOhud_LAM

REG.sections = REG.sections or {}

function REG.RegisterSection(name, order, provider)
    REG.sections[name] = {
        order = order or 100,
        provider = provider,
    }
end

function REG.BuildOptions()
    local ordered = {}
    for name, section in pairs(REG.sections) do
        ordered[#ordered + 1] = {
            name = name,
            order = section.order,
            provider = section.provider,
        }
    end

    table.sort(ordered, function(left, right)
        return left.order < right.order
    end)

    local options = {}
    for _, section in ipairs(ordered) do
        local ok, payload = pcall(section.provider)
        if ok and type(payload) == "table" then
            for _, option in ipairs(payload) do
                options[#options + 1] = option
            end
        end
    end

    return options
end
