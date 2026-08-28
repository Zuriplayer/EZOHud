EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local PANEL_NAME = "EZOhud_CurrencyPanel"
local ROW_HEIGHT = 28
local ICON_SIZE = 24
local TEXT_WIDTH = 132
local TEXT_GAP = 4
local ORIENTATION_HORIZONTAL = "horizontal"
local ORIENTATION_VERTICAL = "vertical"
local DISPLAY_TEXT = "text"
local DISPLAY_ICON = "icon"
local DISPLAY_BOTH = "both"
local LOCATION_PLAYER = "player"
local LOCATION_PLAYER_BANK = "playerBank"
local LOCATION_BANK = "bank"
local LOCATION_ACCOUNT = "account"

local CURRENCY_DEFINITIONS = {
    { key = "gold", currencyType = "CURT_MONEY", labelId = "EZO_HUD_CURRENCY_GOLD", fallbackLocation = LOCATION_PLAYER_BANK, order = 10 },
    { key = "alliancePoints", currencyType = "CURT_ALLIANCE_POINTS", labelId = "EZO_HUD_CURRENCY_ALLIANCE_POINTS", fallbackLocation = LOCATION_PLAYER_BANK, order = 20 },
    { key = "archivalFortunes", currencyType = "CURT_ARCHIVAL_FORTUNES", labelId = "EZO_HUD_CURRENCY_ARCHIVAL_FORTUNES", fallbackLocation = LOCATION_ACCOUNT, order = 30 },
    { key = "imperialFragments", currencyType = "CURT_IMPERIAL_FRAGMENTS", labelId = "EZO_HUD_CURRENCY_IMPERIAL_FRAGMENTS", fallbackLocation = LOCATION_ACCOUNT, order = 40 },
    { key = "telvarStones", currencyType = "CURT_TELVAR_STONES", labelId = "EZO_HUD_CURRENCY_TELVAR_STONES", fallbackLocation = LOCATION_PLAYER_BANK, order = 50 },
    { key = "tomePoints", currencyType = "CURT_TOME_POINTS", labelId = "EZO_HUD_CURRENCY_TOME_POINTS", fallbackLocation = LOCATION_ACCOUNT, order = 60 },
    { key = "tradeBars", currencyType = "CURT_TRADE_BARS", labelId = "EZO_HUD_CURRENCY_TRADE_BARS", fallbackLocation = LOCATION_ACCOUNT, order = 70 },
    { key = "transmuteCrystals", currencyType = "CURT_TRANSMUTE_CRYSTALS", labelId = "EZO_HUD_CURRENCY_TRANSMUTE_CRYSTALS", fallbackLocation = LOCATION_ACCOUNT, order = 80 },
    { key = "undauntedKeys", currencyType = "CURT_UNDAUNTED_KEYS", labelId = "EZO_HUD_CURRENCY_UNDAUNTED_KEYS", fallbackLocation = LOCATION_ACCOUNT, order = 90 },
    { key = "writVouchers", currencyType = "CURT_WRIT_VOUCHERS", labelId = "EZO_HUD_CURRENCY_WRIT_VOUCHERS", fallbackLocation = LOCATION_PLAYER_BANK, order = 100 },
    { key = "crowns", currencyType = "CURT_CROWNS", labelId = "EZO_HUD_CURRENCY_CROWNS", fallbackLocation = LOCATION_ACCOUNT, order = 110 },
}

local function GetLocalized(idName)
    local id = _G[idName]
    if id ~= nil and type(GetString) == "function" then
        return GetString(id)
    end
    return idName
end

local function GetSettings()
    if not EZO_HUD.sv then
        return EZO_HUD.defaults.currencyPanel
    end

    EZO_HUD.sv.currencyPanel = EZO_HUD.sv.currencyPanel or {}
    local settings = EZO_HUD.sv.currencyPanel
    local hadBalanceMode = settings.balanceMode ~= nil
    local defaults = EZO_HUD.defaults.currencyPanel
    for key, value in pairs(defaults) do
        if settings[key] == nil then
            if type(value) == "table" then
                settings[key] = {}
                for nestedKey, nestedValue in pairs(value) do
                    if type(nestedValue) == "table" then
                        settings[key][nestedKey] = {}
                        for leafKey, leafValue in pairs(nestedValue) do
                            settings[key][nestedKey][leafKey] = leafValue
                        end
                    else
                        settings[key][nestedKey] = nestedValue
                    end
                end
            else
                settings[key] = value
            end
        elseif type(settings[key]) == "table" and type(value) == "table" then
            for nestedKey, nestedValue in pairs(value) do
                if settings[key][nestedKey] == nil then
                    if type(nestedValue) == "table" then
                        settings[key][nestedKey] = {}
                        for leafKey, leafValue in pairs(nestedValue) do
                            settings[key][nestedKey][leafKey] = leafValue
                        end
                    else
                        settings[key][nestedKey] = nestedValue
                    end
                end
            end
        end
    end
    if not hadBalanceMode and settings.items then
        for _, itemSettings in pairs(settings.items) do
            if itemSettings.location == LOCATION_PLAYER_BANK then
                settings.balanceMode = LOCATION_PLAYER_BANK
                break
            end
        end
    end
    return settings
end

local function GetCurrencyType(definition)
    return _G[definition.currencyType]
end

local function ReadCurrencyAmount(currencyType, location)
    if currencyType == nil or location == nil or type(_G.GetCurrencyAmount) ~= "function" then
        return 0
    end
    local ok, amount = pcall(_G.GetCurrencyAmount, currencyType, location)
    if ok then
        return tonumber(amount) or 0
    end
    return 0
end

local function CanStoreCurrency(currencyType, location)
    if currencyType == nil
        or location == nil
        or type(_G.CanCurrencyBeStoredInLocation) ~= "function" then
        return false
    end
    local ok, canStore = pcall(_G.CanCurrencyBeStoredInLocation, currencyType, location)
    return ok and canStore == true
end

local function GetStorageProfile(definition)
    local currencyType = GetCurrencyType(definition)
    local profile = {
        player = CanStoreCurrency(currencyType, _G.CURRENCY_LOCATION_CHARACTER),
        bank = CanStoreCurrency(currencyType, _G.CURRENCY_LOCATION_BANK),
        account = CanStoreCurrency(currencyType, _G.CURRENCY_LOCATION_ACCOUNT),
    }

    if not profile.player and not profile.bank and not profile.account then
        local fallback = definition.fallbackLocation
        if fallback == LOCATION_PLAYER_BANK then
            profile.player = true
            profile.bank = true
        elseif fallback == LOCATION_PLAYER then
            profile.player = true
        elseif fallback == LOCATION_ACCOUNT then
            profile.account = true
        else
            profile.bank = true
        end
    end
    return profile
end

local function IsPlayerBankCurrency(definition)
    local profile = GetStorageProfile(definition)
    return profile.player and profile.bank
end

local function GetAmounts(definition, locationName)
    local currencyType = GetCurrencyType(definition)
    local player = ReadCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_CHARACTER)
    local bank = ReadCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_BANK)
    local account = ReadCurrencyAmount(currencyType, _G.CURRENCY_LOCATION_ACCOUNT)

    if locationName == LOCATION_PLAYER then
        return player, player, bank, account
    elseif locationName == LOCATION_PLAYER_BANK then
        return player, player, bank, account
    elseif locationName == LOCATION_ACCOUNT then
        return account, player, bank, account
    end
    return bank, player, bank, account
end

local function FormatAmount(amount)
    local value = tostring(math.floor(tonumber(amount) or 0))
    local sign = ""
    if value:sub(1, 1) == "-" then
        sign = "-"
        value = value:sub(2)
    end
    local formatted = value:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    return sign .. formatted
end

local function GetIconPath(currencyType)
    if currencyType == nil then
        return nil
    end

    local useGamepad = type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()
    if useGamepad and type(GetCurrencyGamepadIcon) == "function" then
        local icon = GetCurrencyGamepadIcon(currencyType)
        if icon and icon ~= "" then
            return icon
        end
    end
    if type(GetCurrencyKeyboardIcon) == "function" then
        local icon = GetCurrencyKeyboardIcon(currencyType)
        if icon and icon ~= "" then
            return icon
        end
    end
    return "EsoUI/Art/currency/currency_gold.dds"
end

local function GetDefinitionName(definition)
    return GetLocalized(definition.labelId)
end

local function GetItemSettings(definition)
    local settings = GetSettings()
    settings.items = settings.items or {}
    settings.items[definition.key] = settings.items[definition.key] or {}
    return settings.items[definition.key]
end

local function IsPlayerInCombat()
    return type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true
end

local function GetSelectedLocation(definition)
    local profile = GetStorageProfile(definition)
    if profile.player and profile.bank then
        if GetSettings().balanceMode == LOCATION_PLAYER_BANK then
            return LOCATION_PLAYER_BANK
        end
        return LOCATION_PLAYER
    end
    if profile.account then
        return LOCATION_ACCOUNT
    elseif profile.bank then
        return LOCATION_BANK
    elseif profile.player then
        return LOCATION_PLAYER
    end
    return definition.fallbackLocation
end

local function GetDisplayMode(settings)
    local mode = settings.displayMode
    if mode == DISPLAY_TEXT or mode == DISPLAY_ICON or mode == DISPLAY_BOTH then
        return mode
    end
    if type(GetString) == "function" then
        if mode == GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_TEXT) then
            return DISPLAY_TEXT
        elseif mode == GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_ICON) then
            return DISPLAY_ICON
        elseif mode == GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_BOTH) then
            return DISPLAY_BOTH
        end
    end
    return DISPLAY_BOTH
end

local function GetRowWidth(displayMode)
    if displayMode == DISPLAY_ICON then
        return ICON_SIZE
    elseif displayMode == DISPLAY_TEXT then
        return TEXT_WIDTH
    end
    return ICON_SIZE + TEXT_GAP + TEXT_WIDTH
end

local function GetDisplayText(definition, locationName)
    local amount, player, bank = GetAmounts(definition, locationName)
    if locationName == LOCATION_PLAYER_BANK then
        return FormatAmount(player) .. " / " .. FormatAmount(bank)
    end
    return FormatAmount(amount)
end

local function BuildTooltip(definition)
    local currencyType = GetCurrencyType(definition)
    local locationName = GetSelectedLocation(definition)
    local _, player, bank, account = GetAmounts(definition, locationName)
    local lines = { GetDefinitionName(definition) }

    if IsPlayerBankCurrency(definition) then
        lines[#lines + 1] = zo_strformat(GetString(EZO_HUD_CURRENCY_PLAYER_FORMAT), FormatAmount(player))
        lines[#lines + 1] = zo_strformat(GetString(EZO_HUD_CURRENCY_BANK_FORMAT), FormatAmount(bank))
    elseif locationName == LOCATION_ACCOUNT then
        lines[#lines + 1] = zo_strformat(GetString(EZO_HUD_CURRENCY_ACCOUNT_FORMAT), FormatAmount(account))
    elseif locationName == LOCATION_PLAYER then
        lines[#lines + 1] = zo_strformat(GetString(EZO_HUD_CURRENCY_PLAYER_FORMAT), FormatAmount(player))
    else
        lines[#lines + 1] = zo_strformat(GetString(EZO_HUD_CURRENCY_BANK_FORMAT), FormatAmount(bank))
    end

    if currencyType ~= nil and type(GetCurrencyDescription) == "function" then
        local description = GetCurrencyDescription(currencyType)
        if description and description ~= "" then
            lines[#lines + 1] = description
        end
    end
    return table.concat(lines, "\n")
end

local function HideTooltip(self, row)
    if self.currencyPanel and self.currencyPanel.tooltipRow == row then
        self.currencyPanel.tooltipRow = nil
        if type(ClearTooltip) == "function" and InformationTooltip then
            ClearTooltip(InformationTooltip)
        end
    end
end

local function ShowTooltip(self, definition, row)
    if self:IsMoveModeEnabled("currencyPanel")
        or type(InitializeTooltip) ~= "function"
        or type(SetTooltipText) ~= "function"
        or not InformationTooltip then
        return
    end

    local centerY = row:GetCenter()
    local height = GuiRoot:GetHeight()
    if centerY and height and centerY > height / 2 then
        InitializeTooltip(InformationTooltip, row, BOTTOM, 0, -8, TOP)
    else
        InitializeTooltip(InformationTooltip, row, TOP, 0, 8, BOTTOM)
    end
    SetTooltipText(InformationTooltip, BuildTooltip(definition))
    self.currencyPanel.tooltipRow = row
end

local function RefreshRow(self, definition)
    local row = self.currencyPanel.rows[definition.key]
    if not row then
        return
    end

    local settings = GetSettings()
    local itemSettings = GetItemSettings(definition)
    local displayMode = GetDisplayMode(settings)
    local locationName = GetSelectedLocation(definition)
    local currencyType = GetCurrencyType(definition)

    row.icon:SetTexture(GetIconPath(currencyType))
    row.icon:SetHidden(displayMode == DISPLAY_TEXT)
    row.label:SetText(GetDisplayText(definition, locationName))
    row.label:SetHidden(displayMode == DISPLAY_ICON)
    row:SetWidth(GetRowWidth(displayMode))

    if displayMode == DISPLAY_BOTH then
        row.icon:ClearAnchors()
        row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)
        row.label:ClearAnchors()
        row.label:SetAnchor(LEFT, row.icon, RIGHT, TEXT_GAP, 0)
    else
        row.label:ClearAnchors()
        row.label:SetAnchor(LEFT, row, LEFT, 0, 0)
    end

    row:SetHidden(itemSettings.enabled ~= true)
end

function EZO_HUD:RefreshCurrencyPanelVisibility()
    if not self.currencyPanel then
        return
    end
    local settings = GetSettings()
    local isHudVisible = self.IsHudSceneVisible == nil or self:IsHudSceneVisible()
    local isMovable = self:IsMoveModeEnabled("currencyPanel")
    local isHiddenByCombat = settings.hideInCombat == true and IsPlayerInCombat()
    local hasItems = false
    for _, definition in ipairs(CURRENCY_DEFINITIONS) do
        if GetItemSettings(definition).enabled == true then
            hasItems = true
            break
        end
    end
    local shouldShow = isHudVisible
        and hasItems
        and (settings.enabled == true or isMovable)
        and (not isHiddenByCombat or isMovable)
    if not shouldShow and self.currencyPanel.tooltipRow then
        HideTooltip(self, self.currencyPanel.tooltipRow)
    end
    self.currencyPanel.root:SetHidden(not shouldShow)
    self.currencyPanel.root:SetMouseEnabled(shouldShow)
end

function EZO_HUD:ApplyCurrencyPanelLayout()
    if not self.currencyPanel then
        return
    end

    local settings = GetSettings()
    local displayMode = GetDisplayMode(settings)
    local orientation = settings.orientation == ORIENTATION_VERTICAL and ORIENTATION_VERTICAL or ORIENTATION_HORIZONTAL
    local spacing = math.max(0, tonumber(settings.spacing) or 0)
    local visibleCount = 0
    local width = 0
    local height = 0

    for _, definition in ipairs(CURRENCY_DEFINITIONS) do
        local row = self.currencyPanel.rows[definition.key]
        local itemSettings = GetItemSettings(definition)
        if itemSettings.enabled == true then
            visibleCount = visibleCount + 1
            RefreshRow(self, definition)
            local rowWidth = GetRowWidth(displayMode)
            row:SetDimensions(rowWidth, ROW_HEIGHT)
            row:ClearAnchors()
            if orientation == ORIENTATION_HORIZONTAL then
                local left = width
                row:SetAnchor(TOPLEFT, self.currencyPanel.root, TOPLEFT, left, 0)
                width = width + rowWidth
                if visibleCount > 1 then
                    width = width + spacing
                end
                height = ROW_HEIGHT
            else
                local top = height
                row:SetAnchor(TOPLEFT, self.currencyPanel.root, TOPLEFT, 0, top)
                width = math.max(width, rowWidth)
                height = height + ROW_HEIGHT + (visibleCount > 1 and spacing or 0)
            end
        else
            row:SetHidden(true)
        end
    end

    width = math.max(1, width)
    height = math.max(1, height)
    self.currencyPanel.root:SetDimensions(width, height)
    self.currencyPanel.root:SetScale(tonumber(settings.scale) or 1.0)

    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local left = (guiWidth / 2) + (tonumber(settings.offsetX) or 0) - (width / 2)
    local top = (guiHeight / 2) + (tonumber(settings.offsetY) or 0) - (height / 2)
    self.currencyPanel.root:ClearAnchors()
    self.currencyPanel.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    self:RefreshCurrencyPanelMovementState()
    self:RefreshCurrencyPanelVisibility()
end

function EZO_HUD:SaveCurrencyPanelPosition()
    if not self.currencyPanel then
        return
    end
    local settings = GetSettings()
    local left = self.currencyPanel.root:GetLeft()
    local top = self.currencyPanel.root:GetTop()
    local width, height = self.currencyPanel.root:GetDimensions()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    settings.offsetX = (left + (width / 2)) - (guiWidth / 2)
    settings.offsetY = (top + (height / 2)) - (guiHeight / 2)
    self:ApplyCurrencyPanelLayout()
end

function EZO_HUD:RefreshCurrencyPanelMovementState()
    if not self.currencyPanel then
        return
    end
    local isMovable = self:IsMoveModeEnabled("currencyPanel")
    local settings = GetSettings()
    self.currencyPanel.root:SetMovable(false)
    self.currencyPanel.root:SetMouseEnabled(settings.enabled == true or isMovable)
    self.currencyPanel.background:SetCenterColor(0.05, 0.05, 0.02, isMovable and 0.62 or 0)
    self.currencyPanel.background:SetEdgeColor(0.8, 0.8, 0.2, isMovable and 1 or 0)
    for _, row in pairs(self.currencyPanel.rows) do
        row:SetMouseEnabled(not isMovable)
    end
end

function EZO_HUD:RefreshCurrencyPanelValues()
    if not self.currencyPanel then
        return
    end
    for _, definition in ipairs(CURRENCY_DEFINITIONS) do
        RefreshRow(self, definition)
    end
    self:RefreshCurrencyPanelVisibility()
end

function EZO_HUD:InitializeCurrencyPanel()
    if self.currencyPanel then
        return
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow(PANEL_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_MEDIUM)
    root:SetHidden(true)

    local background = WINDOW_MANAGER:CreateControl(PANEL_NAME .. "_Background", root, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetCenterColor(0, 0, 0, 0)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetMouseEnabled(false)

    self.currencyPanel = {
        root = root,
        background = background,
        rows = {},
    }

    for _, definition in ipairs(CURRENCY_DEFINITIONS) do
        local row = WINDOW_MANAGER:CreateControl(PANEL_NAME .. "_" .. definition.key, root, CT_CONTROL)
        row:SetDimensions(TEXT_WIDTH, ROW_HEIGHT)
        row:SetMouseEnabled(true)

        local icon = WINDOW_MANAGER:CreateControl(row:GetName() .. "_Icon", row, CT_TEXTURE)
        icon:SetDimensions(ICON_SIZE, ICON_SIZE)
        icon:SetAnchor(LEFT, row, LEFT, 0, 0)
        icon:SetMouseEnabled(false)

        local label = WINDOW_MANAGER:CreateControl(row:GetName() .. "_Label", row, CT_LABEL)
        label:SetDimensions(TEXT_WIDTH, ROW_HEIGHT)
        label:SetAnchor(LEFT, row, LEFT, 0, 0)
        label:SetFont("ZoFontGameSmall")
        label:SetColor(1, 1, 1, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetMouseEnabled(false)

        row.icon = icon
        row.label = label
        row:SetHandler("OnMouseEnter", function()
            ShowTooltip(EZO_HUD, definition, row)
        end)
        row:SetHandler("OnMouseExit", function()
            HideTooltip(EZO_HUD, row)
        end)
        self.currencyPanel.rows[definition.key] = row
    end

    root:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT and self:IsMoveModeEnabled("currencyPanel") then
            self.currencyPanelDragActive = true
            control:SetMovable(true)
            control:StartMoving()
        end
    end)
    root:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT and self:IsMoveModeEnabled("currencyPanel") then
            control:StopMovingOrResizing()
            self.currencyPanelDragActive = false
            control:SetMovable(false)
            self:SaveCurrencyPanelPosition()
        end
    end)
    root:SetHandler("OnMoveStop", function()
        root:SetMovable(false)
        self.currencyPanelDragActive = false
        self:SaveCurrencyPanelPosition()
    end)

    if self.RegisterHudSceneControl then
        self:RegisterHudSceneControl(root)
    end

    EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelCurrency", EVENT_CURRENCY_UPDATE, function()
        self:RefreshCurrencyPanelValues()
    end)
    if EVENT_BANKED_CURRENCY_UPDATE then
        EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelBank", EVENT_BANKED_CURRENCY_UPDATE, function()
            self:RefreshCurrencyPanelValues()
        end)
    end
    if EVENT_OPEN_BANK then
        EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelOpenBank", EVENT_OPEN_BANK, function()
            self:RefreshCurrencyPanelValues()
        end)
    end
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelInputMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
            self:RefreshCurrencyPanelValues()
        end)
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelCombat", EVENT_PLAYER_COMBAT_STATE, function()
            self:RefreshCurrencyPanelVisibility()
        end)
    end
    EVENT_MANAGER:RegisterForEvent("EZOhud_CurrencyPanelActivated", EVENT_PLAYER_ACTIVATED, function()
        self:ApplyCurrencyPanelLayout()
    end)

    self:ApplyCurrencyPanelLayout()
end

EZOhud_LAM.RegisterSection("currencyPanel", 46, function()
    local options = {
        EZOhud_LAM.CreateInfoHeader(
            GetString(EZO_HUD_OPTION_CURRENCY_PANEL),
            GetString(EZO_HUD_OPTION_CURRENCY_PANEL_HEADER_TOOLTIP)
        ),
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_ENABLE),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_ENABLE_TOOLTIP),
            getFunc = function() return GetSettings().enabled == true end,
            setFunc = function(value)
                GetSettings().enabled = value == true
                EZO_HUD:ApplyCurrencyPanelLayout()
                EZO_HUD:RequestSettingsPanelRefresh(true)
            end,
            default = EZO_HUD.defaults.currencyPanel.enabled,
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_HIDE_COMBAT),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_HIDE_COMBAT_TOOLTIP),
            getFunc = function() return GetSettings().hideInCombat == true end,
            setFunc = function(value)
                GetSettings().hideInCombat = value == true
                EZO_HUD:RefreshCurrencyPanelVisibility()
            end,
            default = EZO_HUD.defaults.currencyPanel.hideInCombat,
            disabled = function() return not GetSettings().enabled end,
        },
        {
            type = "dropdown",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_ORIENTATION),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_ORIENTATION_TOOLTIP),
            choices = {
                GetString(EZO_HUD_CURRENCY_PANEL_HORIZONTAL),
                GetString(EZO_HUD_CURRENCY_PANEL_VERTICAL),
            },
            choicesValues = { ORIENTATION_HORIZONTAL, ORIENTATION_VERTICAL },
            getFunc = function() return GetSettings().orientation end,
            setFunc = function(value)
                GetSettings().orientation = value
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = EZO_HUD.defaults.currencyPanel.orientation,
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        },
        {
            type = "dropdown",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_DISPLAY),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_DISPLAY_TOOLTIP),
            choices = {
                GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_TEXT),
                GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_ICON),
                GetString(EZO_HUD_CURRENCY_PANEL_DISPLAY_BOTH),
            },
            choicesValues = { DISPLAY_TEXT, DISPLAY_ICON, DISPLAY_BOTH },
            getFunc = function() return GetDisplayMode(GetSettings()) end,
            setFunc = function(value)
                GetSettings().displayMode = GetDisplayMode({ displayMode = value })
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = EZO_HUD.defaults.currencyPanel.displayMode,
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        },
        {
            type = "dropdown",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_BALANCE_MODE),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_BALANCE_MODE_TOOLTIP),
            choices = {
                GetString(EZO_HUD_CURRENCY_LOCATION_PLAYER),
                GetString(EZO_HUD_CURRENCY_LOCATION_PLAYER_BANK),
            },
            choicesValues = { LOCATION_PLAYER, LOCATION_PLAYER_BANK },
            getFunc = function() return GetSettings().balanceMode end,
            setFunc = function(value)
                GetSettings().balanceMode = value
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = EZO_HUD.defaults.currencyPanel.balanceMode,
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        },
        {
            type = "checkbox",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_MOVE),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_MOVE_TOOLTIP),
            getFunc = function() return EZO_HUD:IsMoveModeEnabled("currencyPanel") end,
            setFunc = function(value)
                EZO_HUD:SetMoveModeEnabled("currencyPanel", value)
                EZO_HUD:RefreshCurrencyPanelMovementState()
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = false,
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_SCALE),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_SCALE_TOOLTIP),
            min = 70,
            max = 180,
            step = 5,
            getFunc = function() return zo_floor((GetSettings().scale or 1) * 100) end,
            setFunc = function(value)
                GetSettings().scale = value / 100
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = zo_floor(EZO_HUD.defaults.currencyPanel.scale * 100),
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        },
        {
            type = "slider",
            name = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_SPACING),
            tooltip = GetString(EZO_HUD_OPTION_CURRENCY_PANEL_SPACING_TOOLTIP),
            min = 0,
            max = 20,
            step = 1,
            getFunc = function() return GetSettings().spacing or 0 end,
            setFunc = function(value)
                GetSettings().spacing = value
                EZO_HUD:ApplyCurrencyPanelLayout()
            end,
            default = EZO_HUD.defaults.currencyPanel.spacing,
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        },
    }

    for _, definition in ipairs(CURRENCY_DEFINITIONS) do
        local itemSettings = GetItemSettings(definition)
        local itemNameId = definition.labelId
        local itemTooltipId = definition.labelId .. "_TOOLTIP"
        options[#options + 1] = {
            type = "checkbox",
            name = GetString(_G[itemNameId]),
            tooltip = GetString(_G[itemTooltipId]),
            getFunc = function() return GetItemSettings(definition).enabled == true end,
            setFunc = function(value)
                GetItemSettings(definition).enabled = value == true
                EZO_HUD:ApplyCurrencyPanelLayout()
                EZO_HUD:RequestSettingsPanelRefresh(true)
            end,
            default = itemSettings.enabled == true,
            disabled = function() return not GetSettings().enabled end,
            width = "half",
        }
    end
    return options
end)
