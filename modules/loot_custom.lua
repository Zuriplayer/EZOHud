EZOhud = EZOhud or {}
local EZO_HUD = EZOhud

local CUSTOM_LOOT_NAME = "EZOhud_CustomLoot"

local function GetCustomLootSettings()
    return EZO_HUD.sv and EZO_HUD.sv.customLoot or EZO_HUD.defaults.customLoot
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

local function BuildCustomLootIndicator()
    local root = WINDOW_MANAGER:CreateTopLevelWindow(CUSTOM_LOOT_NAME)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_MEDIUM)
    root:SetHidden(false) -- Keep root visible, buffer fades internally

    local bg = WINDOW_MANAGER:CreateControl(CUSTOM_LOOT_NAME .. "_Bg", root, CT_BACKDROP)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetAnchorFill()

    local buffer = WINDOW_MANAGER:CreateControl(CUSTOM_LOOT_NAME .. "_Buffer", root, CT_TEXTBUFFER)
    buffer:SetAnchorFill()
    buffer:SetMaxHistoryLines(30)
    buffer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    -- Scrollbar
    local scrollbar = WINDOW_MANAGER:CreateControl(CUSTOM_LOOT_NAME .. "_Scrollbar", root, CT_SLIDER)
    scrollbar:SetDimensions(16, 0)
    scrollbar:SetAnchor(TOPRIGHT, root, TOPRIGHT, 0, 0)
    scrollbar:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
    scrollbar:SetThumbTexture("EsoUI/Art/ChatWindow/chat_scrollbar_thumb.dds", "EsoUI/Art/ChatWindow/chat_scrollbar_thumb.dds", "EsoUI/Art/ChatWindow/chat_scrollbar_thumb.dds", 16, 50, 0, 0, 1, 1)
    scrollbar:SetBackgroundMiddleTexture("EsoUI/Art/ChatWindow/chat_scrollbar_track.dds")
    scrollbar:SetValueStep(1)
    scrollbar:SetHidden(true)
    
    buffer:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    buffer:SetAnchor(BOTTOMRIGHT, scrollbar, BOTTOMLEFT, -5, 0)

    -- Wiring scrollbar
    local function UpdateScrollbar()
        local numHistoryLines = buffer:GetNumHistoryLines()
        local numVisibleLines = buffer:GetNumVisibleLines()
        
        if numHistoryLines > numVisibleLines then
            scrollbar:SetMinMax(0, numHistoryLines - numVisibleLines)
            scrollbar:SetValue(buffer:GetScrollPosition())
            if root.isHovered then
                scrollbar:SetHidden(false)
            else
                scrollbar:SetHidden(true)
            end
        else
            scrollbar:SetHidden(true)
        end
    end

    buffer:SetHandler("OnScrollPositionChanged", UpdateScrollbar)
    buffer:SetHandler("OnTextChanged", UpdateScrollbar)
    
    scrollbar:SetHandler("OnValueChanged", function(self, value, eventReason)
        if eventReason == EVENT_REASON_HARDWARE then
            buffer:SetScrollPosition(value)
        end
    end)

    root:SetHandler("OnMouseEnter", function()
        root.isHovered = true
        bg:SetCenterColor(0, 0, 0, 0.4)
        bg:SetEdgeColor(0.2, 0.2, 0.2, 0.8)
        UpdateScrollbar()
        buffer:SetTimeBeforeFade(999999) -- Stop fading while hovering
    end)

    root:SetHandler("OnMouseExit", function()
        root.isHovered = false
        bg:SetCenterColor(0, 0, 0, 0)
        bg:SetEdgeColor(0, 0, 0, 0)
        UpdateScrollbar()
        buffer:SetTimeBeforeFade(GetCustomLootSettings().fadeTime or 5)
    end)

    root:SetHandler("OnMouseWheel", function(self, delta)
        local newPos = buffer:GetScrollPosition() - delta
        buffer:SetScrollPosition(newPos)
    end)

    root:SetHandler("OnMoveStop", function(self)
        if EZO_HUD.SaveCustomLootPosition then
            EZO_HUD:SaveCustomLootPosition()
        end
    end)

    return {
        root = root,
        bg = bg,
        buffer = buffer,
        scrollbar = scrollbar,
    }
end

function EZO_HUD:ApplyCustomLootLayout()
    if not self.customLoot then return end

    local settings = GetCustomLootSettings()
    
    local width = settings.width or 350
    local height = settings.height or 400
    local scale = settings.scale or 1.0

    self.customLoot.root:SetDimensions(width, height)
    self.customLoot.root:SetScale(scale)

    local guiWidth, guiHeight = GuiRoot:GetDimensions()
    local defaultLeft = guiWidth - width - 20
    local defaultTop = guiHeight - height - 100

    local left = defaultLeft
    local top = defaultTop
    if settings.offsetX and settings.offsetY then
        left = (guiWidth / 2) + settings.offsetX
        top = (guiHeight / 2) + settings.offsetY
    end

    self.customLoot.root:ClearAnchors()
    self.customLoot.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    local font = settings.font or "ZoFontWinH3"
    self.customLoot.buffer:SetFont(font)
    self.customLoot.buffer:SetTimeBeforeFade(settings.fadeTime or 5)
    self.customLoot.buffer:SetFadeDuration(1)

    self:RefreshCustomLootMovementState()
end

function EZO_HUD:SaveCustomLootPosition()
    if not self.customLoot then return end

    local settings = GetCustomLootSettings()
    local left = self.customLoot.root:GetLeft()
    local top = self.customLoot.root:GetTop()
    local guiWidth, guiHeight = GuiRoot:GetDimensions()

    settings.offsetX = left - (guiWidth / 2)
    settings.offsetY = top - (guiHeight / 2)

    self:ApplyCustomLootLayout()
end

function EZO_HUD:RefreshCustomLootMovementState()
    if not self.customLoot then return end

    local isMovable = self:IsMoveModeEnabled("customLoot")
    self.customLoot.root:SetMovable(isMovable)

    if isMovable then
        self.customLoot.bg:SetCenterColor(0.05, 0.05, 0.02, 0.6)
        self.customLoot.bg:SetEdgeColor(0.8, 0.8, 0.2, 1)
        self.customLoot.buffer:AddMessage("Posición de prueba...", 1, 1, 1, 0)
    else
        self.customLoot.bg:SetCenterColor(0, 0, 0, 0)
        self.customLoot.bg:SetEdgeColor(0, 0, 0, 0)
    end
end

function EZO_HUD:InitializeCustomLoot()
    if self.customLoot then return end

    -- Register defaults
    if not self.defaults.customLoot then
        self.defaults.customLoot = {
            enabled = true,
            width = 350,
            height = 400,
            scale = 1.0,
            fadeTime = 5,
            font = "ZoFontWinH3"
        }
    end
    if not self.sv.customLoot then
        self.sv.customLoot = DeepCopyTable(self.defaults.customLoot)
    end

    self.customLoot = BuildCustomLootIndicator()
    self:ApplyCustomLootLayout()

    local settings = GetCustomLootSettings()

    -- Intercept Loot to our custom buffer
    if LOOT_HISTORY_KEYBOARD then
        local origAddLoot = LOOT_HISTORY_KEYBOARD.AddLoot
        LOOT_HISTORY_KEYBOARD.AddLoot = function(historySelf, lootType, itemLink, quantity, itemSound, isPickpocketLoot, questItemIcon, itemId, isStolen, ...)
            if EZO_HUD.sv.customLoot and EZO_HUD.sv.customLoot.enabled then
                local icon, name, _, _, _ = GetItemLinkInfo(itemLink)
                if not name or name == "" then
                    origAddLoot(historySelf, lootType, itemLink, quantity, itemSound, isPickpocketLoot, questItemIcon, itemId, isStolen, ...)
                    return
                end

                local color = GetItemLinkColor(itemLink)
                local coloredName = color:Colorize(zo_strformat("<<1>>", name))
                local formattedIcon = zo_iconFormat(icon, 32, 32)
                
                local message = ""
                if quantity > 1 then
                    message = string.format("%s %s x%d", coloredName, formattedIcon, quantity)
                else
                    message = string.format("%s %s", coloredName, formattedIcon)
                end
                
                -- Add to our text buffer
                self.customLoot.buffer:AddMessage(message, 1, 1, 1, 0)
                
                return -- Block native UI
            else
                return origAddLoot(historySelf, lootType, itemLink, quantity, itemSound, isPickpocketLoot, questItemIcon, itemId, isStolen, ...)
            end
        end
    end

    -- LAM Menu
    EZOhud_LAM.RegisterSection("customLoot", 70, function()
        local s = GetCustomLootSettings()
        return {
            EZOhud_LAM.CreateInfoHeader(GetString(EZO_HUD_OPTION_CUSTOM_LOOT) or "Historial de Botín", "Reemplaza el historial de botín nativo por un panel moderno y personalizable con memoria y desplazamiento."),
            {
                type = "checkbox",
                name = "Activar historial personalizado",
                tooltip = "Oculta el botín del juego y usa este panel mejorado.",
                getFunc = function() return s.enabled end,
                setFunc = function(v) s.enabled = v end,
                default = true,
            },
            {
                type = "checkbox",
                name = "Habilitar movimiento",
                tooltip = "Permite arrastrar el cuadro de botín.",
                getFunc = function() return EZO_HUD:IsMoveModeEnabled("customLoot") end,
                setFunc = function(v)
                    EZO_HUD:SetMoveModeEnabled("customLoot", v)
                    EZO_HUD:RefreshCustomLootMovementState()
                end,
                disabled = function() return not s.enabled end,
                default = false,
            },
            {
                type = "slider",
                name = "Tiempo de desvanecimiento",
                tooltip = "Segundos antes de que el texto desaparezca.",
                min = 2, max = 20, step = 1,
                getFunc = function() return s.fadeTime end,
                setFunc = function(v)
                    s.fadeTime = v
                    EZO_HUD:ApplyCustomLootLayout()
                end,
                disabled = function() return not s.enabled end,
                default = 5,
            },
            {
                type = "slider",
                name = "Escala",
                tooltip = "Tamaño general del texto e iconos.",
                min = 50, max = 150, step = 5,
                getFunc = function() return math.floor(s.scale * 100) end,
                setFunc = function(v)
                    s.scale = v / 100
                    EZO_HUD:ApplyCustomLootLayout()
                end,
                disabled = function() return not s.enabled end,
                default = 100,
            },
        }
    end)
end
