EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local WHITE_TEXTURE = "EZOhud/media/radial/white.dds"
local EXECUTE_SLOT_MIN = 3
local EXECUTE_SLOT_MAX = 7
local EXECUTE_NAME = "EZOhud_Execute"

local EXECUTE_MODE_ACTIVE = "active"

local EXECUTE_BY_ID = {
    [34838] = { threshold = 25 }, -- Assassin's Blade
    [34851] = { threshold = 25 }, -- Impale
    [63029] = { threshold = 33 }, -- Radiant Destruction
    [63044] = { threshold = 33 }, -- Radiant Glory
    [63046] = { threshold = 40 }, -- Radiant Oppression
}

local EXECUTE_BY_NAME = {
    ["assassin's blade"] = 25,
    ["impale"] = 25,
    ["killer's blade"] = 50,
    ["mages' fury"] = 20,
    ["endless fury"] = 20,
    ["mages' wrath"] = 20,
    ["reverse slash"] = 50,
    ["reverse slice"] = 50,
    ["executioner"] = 50,
    ["radiant destruction"] = 33,
    ["radiant glory"] = 33,
    ["radiant oppression"] = 40,
    ["poison injection"] = 50,
    ["whirlwind"] = 50,
    ["steel tornado"] = 50,
    ["whirling blades"] = 50,
    ["gnash"] = 25,
    ["bloody gnash"] = 25,
    ["rip and tear"] = 25,
    ["vengeance assassin's blade"] = 25,
    ["vengeance radiant destruction"] = 33,
    ["vengeance mages' fury"] = 20,
    ["vengeance reverse slash"] = 50,
    ["vengeance whirlwind"] = 50,
    ["hoja del asesino"] = 25,
    ["empalar"] = 25,
    ["hoja asesina"] = 50,
    ["furia del mago"] = 20,
    ["furia infinita"] = 20,
    ["ira del mago"] = 20,
    ["corte inverso"] = 50,
    ["ejecutor"] = 50,
    ["destruccion radiante"] = 33,
    ["destrucción radiante"] = 33,
    ["gloria radiante"] = 33,
    ["opresion radiante"] = 40,
    ["opresión radiante"] = 40,
    ["inyeccion de veneno"] = 50,
    ["inyección de veneno"] = 50,
    ["torbellino"] = 50,
    ["tornado de acero"] = 50,
    ["cuchillas giratorias"] = 50,
}

local EXECUTE_DESCRIPTION_PATTERNS = {
    "enemies?[^%.;]*below%s+(%d+)%%%s+health",
    "enemies?[^%.;]*less%s+than%s+(%d+)%%%s+health",
    "enemies?[^%.;]*under%s+(%d+)%%%s+health",
    "enemy[^%.;]*was%s+below%s+(%d+)%%%s+health",
    "enemy[^%.;]*falls%s+to%s+or%s+below%s+(%d+)%%%s+health",
    "target[^%.;]*falls%s+to%s+or%s+below%s+(%d+)%%%s+health",
    "cae[^%.;]*por%s+debajo%s+de?l?%s*(%d+)%%[^%.;]*salud",
    "enemig[oa]s?[^%.;]*por%s+debajo%s+de?l?%s*(%d+)%%[^%.;]*salud",
    "enemig[oa]s?[^%.;]*menos%s+de?l?%s*(%d+)%%[^%.;]*salud",
    "objetivo[^%.;]*por%s+debajo%s+de?l?%s*(%d+)%%[^%.;]*salud",
    "objetivo[^%.;]*menos%s+de?l?%s*(%d+)%%[^%.;]*salud",
}

local executeThresholdCache = {}

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

local function NormalizeName(value)
    value = zo_strlower(tostring(value or ""))
    value = value:gsub("%^%a+", "")
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

local function ExtractExecuteThresholdFromDescription(description)
    description = NormalizeName(description)
    if description == "" then
        return nil
    end

    for _, pattern in ipairs(EXECUTE_DESCRIPTION_PATTERNS) do
        local value = description:match(pattern)
        value = tonumber(value)
        if value and value > 0 and value <= 100 then
            return value
        end
    end
end

local function GetAbilityExecuteThreshold(abilityId)
    if not (abilityId and type(GetAbilityDescription) == "function") then
        return nil
    end

    local cached = executeThresholdCache[abilityId]
    if cached ~= nil then
        return cached or nil
    end

    local ok, description = pcall(GetAbilityDescription, abilityId)
    if not (ok and description and description ~= "") then
        executeThresholdCache[abilityId] = false
        return nil
    end

    local threshold = ExtractExecuteThresholdFromDescription(description)
    executeThresholdCache[abilityId] = threshold or false
    return threshold
end

local function GetExecuteSettings()
    if EZO_HUD.sv and not EZO_HUD.sv.execute then
        EZO_HUD.sv.execute = DeepCopyTable(EZO_HUD.defaults.execute)
    end
    return (EZO_HUD.sv and EZO_HUD.sv.execute) or EZO_HUD.defaults.execute
end

local function ResolveCraftedAbilityId(slotIndex, hotbarCategory)
    local abilityId = GetSlotBoundId(slotIndex, hotbarCategory)
    if ACTION_TYPE_CRAFTED_ABILITY ~= nil
        and type(GetSlotType) == "function"
        and type(GetAbilityIdForCraftedAbilityId) == "function" then
        local slotType = GetSlotType(slotIndex, hotbarCategory)
        if slotType == ACTION_TYPE_CRAFTED_ABILITY then
            return GetAbilityIdForCraftedAbilityId(abilityId)
        end
    end
    return abilityId
end

local function GetEffectiveSlotAbilityId(slotIndex, hotbarCategory)
    local abilityId = ResolveCraftedAbilityId(slotIndex, hotbarCategory)
    if abilityId and type(GetEffectiveAbilityIdForAbilityOnHotbar) == "function" then
        local effectiveId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, hotbarCategory)
        if effectiveId and effectiveId ~= 0 then
            return effectiveId, abilityId
        end
    end
    return abilityId, abilityId
end

local function GetSlotAbilityName(slotIndex, hotbarCategory, abilityId)
    if abilityId and type(GetAbilityName) == "function" then
        local abilityName = GetAbilityName(abilityId)
        if abilityName and abilityName ~= "" then
            return abilityName
        end
    end
    return GetSlotName(slotIndex, hotbarCategory)
end

local function GetExecuteForSlot(slotIndex, hotbarCategory)
    local abilityId, rawAbilityId = GetEffectiveSlotAbilityId(slotIndex, hotbarCategory)
    local data = abilityId and EXECUTE_BY_ID[abilityId]
    if data then
        local dynamicThreshold = GetAbilityExecuteThreshold(abilityId)
        return {
            abilityId = abilityId,
            rawAbilityId = rawAbilityId,
            name = GetSlotAbilityName(slotIndex, hotbarCategory, abilityId),
            threshold = dynamicThreshold or data.threshold,
            slotIndex = slotIndex,
        }
    end

    local name = GetSlotAbilityName(slotIndex, hotbarCategory, abilityId)
    local threshold = GetAbilityExecuteThreshold(abilityId) or EXECUTE_BY_NAME[NormalizeName(name)]
    if threshold then
        return {
            abilityId = abilityId,
            rawAbilityId = rawAbilityId,
            name = name,
            threshold = threshold,
            slotIndex = slotIndex,
        }
    end
end

local function FindActiveBarExecute()
    local hotbarCategory = GetActiveHotbarCategory()
    local best
    for slotIndex = EXECUTE_SLOT_MIN, EXECUTE_SLOT_MAX do
        local candidate = GetExecuteForSlot(slotIndex, hotbarCategory)
        if candidate and (not best or candidate.threshold > best.threshold) then
            best = candidate
        end
    end
    return best
end

local function GetTargetHealthRatio()
    if not DoesUnitExist("reticleover") then
        return nil
    end

    local current, maximum, effectiveMaximum = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    maximum = effectiveMaximum or maximum or 0
    current = current or 0
    if maximum <= 0 then
        return nil
    end
    return Clamp(current / maximum, 0, 1), current, maximum
end

local function BuildExecuteIndicator()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(EXECUTE_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(EXECUTE_NAME .. "_Bg", root, CT_TEXTURE)
    bg:SetTexture(WHITE_TEXTURE)
    bg:SetColor(0.05, 0.02, 0.02, 0.76)
    bg:SetMouseEnabled(false)

    local text = WINDOW_MANAGER:CreateControl(EXECUTE_NAME .. "_Text", root, CT_LABEL)
    text:SetFont("ZoFontWinH3")
    text:SetColor(1.0, 0.86, 0.32, 1.0)
    text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    text:SetMouseEnabled(false)

    local detail = WINDOW_MANAGER:CreateControl(EXECUTE_NAME .. "_Detail", root, CT_LABEL)
    detail:SetFont("ZoFontGameSmall")
    detail:SetColor(0.95, 0.95, 0.98, 0.92)
    detail:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    detail:SetMouseEnabled(false)

    return {
        root = root,
        bg = bg,
        text = text,
        detail = detail,
    }
end

function EZO_HUD:ApplyExecuteLayout()
    if not self.execute then
        return
    end

    local settings = GetExecuteSettings()
    local size = settings.size or 42
    local width = math.max(150, zo_floor(size * 4.0))
    local height = math.max(56, zo_floor(size * 1.45))
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = zo_floor((guiWidth / 2) + (settings.offsetX or 0) - (width / 2))
    local top = zo_floor((guiHeight / 2) + (settings.offsetY or 0) - (height / 2))

    self.execute.root:SetDimensions(width, height)
    self.execute.root:ClearAnchors()
    self.execute.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    self.execute.bg:ClearAnchors()
    self.execute.bg:SetAnchorFill(self.execute.root)

    self.execute.text:ClearAnchors()
    self.execute.text:SetAnchor(TOP, self.execute.root, TOP, 0, 7)

    self.execute.detail:ClearAnchors()
    self.execute.detail:SetAnchor(TOP, self.execute.text, BOTTOM, 0, -1)

    self:RefreshExecuteMovementState()
    self:RefreshExecute()
end

function EZO_HUD:RefreshExecuteMovementState()
    if not self.execute then
        return
    end

    local movable = self:IsMoveModeEnabled("execute")
    self.execute.root:SetMovable(movable)
    self.execute.root:SetMouseEnabled(movable)
end

function EZO_HUD:SaveExecutePosition()
    if not (self.execute and self.sv and self.sv.execute) then
        return
    end

    local left = self.execute.root:GetLeft()
    local top = self.execute.root:GetTop()
    local width = self.execute.root:GetWidth()
    local height = self.execute.root:GetHeight()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    if not (left and top and width and height) then
        return
    end

    self.sv.execute.offsetX = zo_floor((left + (width / 2)) - (guiWidth / 2))
    self.sv.execute.offsetY = zo_floor((top + (height / 2)) - (guiHeight / 2))
    self:ApplyExecuteLayout()
end

function EZO_HUD:RefreshExecuteText()
    if self.execute then
        self.execute.text:SetText(GetString(EZO_HUD_EXECUTE_READY))
    end
end

function EZO_HUD:RefreshExecute()
    if not self.execute then
        return
    end

    local settings = GetExecuteSettings()
    if self.IsHudSceneVisible and not self:IsHudSceneVisible() then
        self.execute.root:SetHidden(true)
        return
    end

    local movable = self:IsMoveModeEnabled("execute")
    if (settings.enabled == false and not movable) or (settings.mode or EXECUTE_MODE_ACTIVE) ~= EXECUTE_MODE_ACTIVE then
        self.execute.root:SetHidden(true)
        return
    end

    local execute = FindActiveBarExecute()
    local ratio = GetTargetHealthRatio()
    if not (execute and ratio) then
        if movable then
            self.execute.text:SetText(GetString(EZO_HUD_EXECUTE_MOVE_PREVIEW))
            self.execute.detail:SetText(GetString(EZO_HUD_EXECUTE_MOVE_PREVIEW_DETAIL))
            self.execute.root:SetHidden(false)
        else
            self.execute.root:SetHidden(true)
        end
        return
    end

    local targetPercent = zo_floor(ratio * 100)
    if targetPercent > execute.threshold then
        if movable then
            self.execute.text:SetText(GetString(EZO_HUD_EXECUTE_MOVE_PREVIEW))
            self.execute.detail:SetText(string.format("%s · %d%% / %d%%", execute.name or GetString(EZO_HUD_EXECUTE_UNKNOWN), targetPercent, execute.threshold))
            self.execute.root:SetHidden(false)
        else
            self.execute.root:SetHidden(true)
        end
        return
    end

    self.execute.text:SetText(GetString(EZO_HUD_EXECUTE_READY))
    self.execute.detail:SetText(string.format("%s · %d%% / %d%%", execute.name or GetString(EZO_HUD_EXECUTE_UNKNOWN), targetPercent, execute.threshold))
    self.execute.root:SetHidden(false)
end

function EZO_HUD:OnExecutePowerUpdate(_, unitTag, _, powerType)
    if unitTag ~= "reticleover" or powerType ~= POWERTYPE_HEALTH then
        return
    end
    self:RefreshExecute()
end

function EZO_HUD:InitializeExecute()
    self.execute = BuildExecuteIndicator()

    self.execute.root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("execute") then
            control:StartMoving()
        end
    end)
    self.execute.root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self:IsMoveModeEnabled("execute") then
            control:StopMovingOrResizing()
        end
    end)
    self.execute.root:SetHandler("OnMoveStop", function()
        self:SaveExecutePosition()
    end)
    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(self.execute.root)
    end

    self:ApplyExecuteLayout()

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_ExecuteReticle",
        EVENT_RETICLE_TARGET_CHANGED,
        function()
            self:RefreshExecute()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_ExecutePower",
        EVENT_POWER_UPDATE,
        function(...)
            self:OnExecutePowerUpdate(...)
        end
    )

    EVENT_MANAGER:AddFilterForEvent(
        self.ADDON_NAME .. "_ExecutePower",
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE,
        POWERTYPE_HEALTH,
        REGISTER_FILTER_UNIT_TAG,
        "reticleover"
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_ExecuteHotbar",
        EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function()
            self:RefreshExecute()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_ExecuteAllHotbars",
        EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
        function()
            self:RefreshExecute()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.ADDON_NAME .. "_ExecuteActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            self:ApplyExecuteLayout()
        end
    )

    if EZOhud_LAM and EZOhud_LAM.RegisterSection then
        EZOhud_LAM.RegisterSection("execute", 40, function()
            return {
                { type = "header", name = GetString(EZO_HUD_OPTION_EXECUTE) },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_EXECUTE_ENABLE),
                    tooltip = GetString(EZO_HUD_OPTION_EXECUTE_ENABLE_TOOLTIP),
                    getFunc = function()
                        return GetExecuteSettings().enabled ~= false
                    end,
                    setFunc = function(value)
                        GetExecuteSettings().enabled = value
                        self:RefreshExecute()
                    end,
                    default = self.defaults.execute.enabled,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = GetString(EZO_HUD_OPTION_EXECUTE_MOVE),
                    tooltip = GetString(EZO_HUD_OPTION_EXECUTE_MOVE_TOOLTIP),
                    getFunc = function()
                        return self:IsMoveModeEnabled("execute")
                    end,
                    setFunc = function(value)
                        self:SetMoveModeEnabled("execute", value)
                        self:RefreshExecuteMovementState()
                        self:RefreshExecute()
                    end,
                    default = self.defaults.execute.movable,
                    width = "full",
                },
                {
                    type = "description",
                    text = GetString(EZO_HUD_OPTION_EXECUTE_MODE_ACTIVE),
                    width = "full",
                },
                {
                    type = "slider",
                    name = GetString(EZO_HUD_OPTION_EXECUTE_SIZE),
                    tooltip = GetString(EZO_HUD_OPTION_EXECUTE_SIZE_TOOLTIP),
                    min = 28,
                    max = 72,
                    step = 2,
                    getFunc = function()
                        return self.sv.execute.size or self.defaults.execute.size
                    end,
                    setFunc = function(value)
                        GetExecuteSettings().size = value
                        self:ApplyExecuteLayout()
                    end,
                    default = self.defaults.execute.size,
                    width = "half",
                },
            }
        end)
    end
end
