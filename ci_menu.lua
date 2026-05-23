-- Combat Initiation - Matcha Menu
-- PvE wave-survival helper. Full combat suite.
-- UI by nulare | Features extended

local UILib = {}
UILib.__index = UILib

local ESP_FONTSIZE = 12
local ESP_CHAR_WIDTH = 7
local BLACK = Color3.new(0, 0, 0)
local myPlayer = game:GetService('Players').LocalPlayer
local myMouse = myPlayer:GetMouse()

local function clamp(x, a, b)
    if x > b then return b elseif x < a then return a else return x end
end

local function color3fromHSV(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    local r, g, b
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return {r * 255, g * 255, b * 255}
end

local function mixColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function getMousePos() return Vector2.new(myMouse.X, myMouse.Y) end
local function lerp(a, b, t) return a + (b - a) * t end
local function undrawAll(t) for _, d in pairs(t) do d.Visible = false end end
local function destroyAllDrawings(t) for _, d in ipairs(t) do d:Remove() end end

function UILib.new(name, size, watermarkActivity)
    repeat wait(1/9999) until isrbxactive()
    local self = setmetatable({}, UILib)
    self._inputs = {
        ['m1'] = { id = 0x01, held = false, click = false }, ['m2'] = { id = 0x02, held = false, click = false },
        ['mb'] = { id = 0x04, held = false, click = false }, ['unbound'] = { id = 0x08, held = false, click = false },
        ['tab'] = { id = 0x09, held = false, click = false }, ['enter'] = { id = 0x0D, held = false, click = false },
        ['shift'] = { id = 0x10, held = false, click = false }, ['ctrl'] = { id = 0x11, held = false, click = false },
        ['alt'] = { id = 0x12, held = false, click = false }, ['pause'] = { id = 0x13, held = false, click = false },
        ['capslock'] = { id = 0x14, held = false, click = false }, ['esc'] = { id = 0x1B, held = false, click = false },
        ['space'] = { id = 0x20, held = false, click = false }, ['pageup'] = { id = 0x21, held = false, click = false },
        ['pagedown'] = { id = 0x22, held = false, click = false }, ['end'] = { id = 0x23, held = false, click = false },
        ['home'] = { id = 0x24, held = false, click = false }, ['left'] = { id = 0x25, held = false, click = false },
        ['up'] = { id = 0x26, held = false, click = false }, ['right'] = { id = 0x27, held = false, click = false },
        ['down'] = { id = 0x28, held = false, click = false }, ['insert'] = { id = 0x2D, held = false, click = false },
        ['delete'] = { id = 0x2E, held = false, click = false },
        ['0'] = { id = 0x30, held = false, click = false }, ['1'] = { id = 0x31, held = false, click = false },
        ['2'] = { id = 0x32, held = false, click = false }, ['3'] = { id = 0x33, held = false, click = false },
        ['4'] = { id = 0x34, held = false, click = false }, ['5'] = { id = 0x35, held = false, click = false },
        ['6'] = { id = 0x36, held = false, click = false }, ['7'] = { id = 0x37, held = false, click = false },
        ['8'] = { id = 0x38, held = false, click = false }, ['9'] = { id = 0x39, held = false, click = false },
        ['a'] = { id = 0x41, held = false, click = false }, ['b'] = { id = 0x42, held = false, click = false },
        ['c'] = { id = 0x43, held = false, click = false }, ['d'] = { id = 0x44, held = false, click = false },
        ['e'] = { id = 0x45, held = false, click = false }, ['f'] = { id = 0x46, held = false, click = false },
        ['g'] = { id = 0x47, held = false, click = false }, ['h'] = { id = 0x48, held = false, click = false },
        ['i'] = { id = 0x49, held = false, click = false }, ['j'] = { id = 0x4A, held = false, click = false },
        ['k'] = { id = 0x4B, held = false, click = false }, ['l'] = { id = 0x4C, held = false, click = false },
        ['m'] = { id = 0x4D, held = false, click = false }, ['n'] = { id = 0x4E, held = false, click = false },
        ['o'] = { id = 0x4F, held = false, click = false }, ['p'] = { id = 0x50, held = false, click = false },
        ['q'] = { id = 0x51, held = false, click = false }, ['r'] = { id = 0x52, held = false, click = false },
        ['s'] = { id = 0x53, held = false, click = false }, ['t'] = { id = 0x54, held = false, click = false },
        ['u'] = { id = 0x55, held = false, click = false }, ['v'] = { id = 0x56, held = false, click = false },
        ['w'] = { id = 0x57, held = false, click = false }, ['x'] = { id = 0x58, held = false, click = false },
        ['y'] = { id = 0x59, held = false, click = false }, ['z'] = { id = 0x5A, held = false, click = false },
        ['f1'] = { id = 0x70, held = false, click = false }, ['f2'] = { id = 0x71, held = false, click = false },
        ['f3'] = { id = 0x72, held = false, click = false }, ['f4'] = { id = 0x73, held = false, click = false },
    }
    self._active_tab = nil
    self._open = true
    self._watermark = true
    self._base_opacity = 0
    self._dragging = false
    self._drag_offset = Vector2.new(0, 0)
    self._resizing = false
    self._resize_offset = Vector2.new(0, 0)
    self._active_dropdown = nil
    self._active_colorpicker = nil
    self._clipboard_color = nil
    self._tick = os.clock()
    self._pulse = 0
    self.identity = name
    self._watermark_activity = watermarkActivity
    self.x = 20
    self.y = 60
    self.w = size and size.x or 300
    self.h = size and size.y or 400
    self._target_w = self.w
    self._target_h = self.h
    self._min_w = 320
    self._min_h = 320
    self._max_w = 720
    self._max_h = 720
    self._color_accent_base = Color3.fromRGB(0, 220, 170)
    self._color_accent = self._color_accent_base
    self._color_accent_alt = Color3.fromRGB(120, 185, 255)
    self._color_text = Color3.fromRGB(255, 255, 255)
    self._color_muted = Color3.fromRGB(165, 178, 190)
    self._color_crust = Color3.fromRGB(4, 8, 14)
    self._color_border = Color3.fromRGB(33, 48, 62)
    self._color_surface = Color3.fromRGB(12, 18, 27)
    self._color_surface_2 = Color3.fromRGB(20, 29, 42)
    self._color_overlay = Color3.fromRGB(47, 66, 84)
    self._color_hover = Color3.fromRGB(31, 47, 66)
    self._title_h = 34
    self._tab_h = 28
    self._padding = 8
    self._gradient_detail = 80

    local base = Drawing.new('Square') base.Filled = true base.Color = self._color_surface
    local crust = Drawing.new('Square') crust.Filled = false crust.Thickness = 1 crust.Color = self._color_crust
    local border = Drawing.new('Square') border.Filled = false border.Thickness = 1 border.Color = self._color_border
    local navbar = Drawing.new('Square') navbar.Filled = true navbar.Color = self._color_border
    local title = Drawing.new('Text') title.Text = self.identity title.Outline = true title.Color = self._color_text title.Size = 15
    local watermarkBase = Drawing.new('Square') watermarkBase.Filled = true watermarkBase.Color = self._color_surface
    local watermarkCursor = Drawing.new('Square') watermarkCursor.Filled = true watermarkCursor.Color = self._color_accent
    local watermarkCrust = Drawing.new('Square') watermarkCrust.Filled = false watermarkCrust.Thickness = 1 watermarkCrust.Color = self._color_crust
    local watermarkBorder = Drawing.new('Square') watermarkBorder.Filled = false watermarkBorder.Thickness = 1 watermarkBorder.Color = self._color_border
    local watermarkText = Drawing.new('Text') watermarkText.Text = name watermarkText.Outline = true watermarkText.Color = self._color_text watermarkText.Size = 13
    local resizeGrip = Drawing.new('Square') resizeGrip.Filled = true resizeGrip.Color = self._color_border
    local resizeAccent = Drawing.new('Square') resizeAccent.Filled = true resizeAccent.Color = self._color_accent

    self._tree = { ['_tabs'] = {}, ['_drawings'] = { crust, border, base, navbar, title, watermarkBase, watermarkCursor, watermarkCrust, watermarkBorder, watermarkText, resizeGrip, resizeAccent } }
    return self
end

function UILib._GetTextBounds(str) return #str * ESP_CHAR_WIDTH, ESP_FONTSIZE end
function UILib._IsMouseWithinBounds(origin, size)
    local m = getMousePos()
    return m.x >= origin.x and m.x <= origin.x + size.x and m.y >= origin.y and m.y <= origin.y + size.y
end

function UILib:_RemoveDropdown()
    if self._active_dropdown then destroyAllDrawings(self._active_dropdown['_drawings']) self._active_dropdown = nil end
end

function UILib:_SpawnDropdown(default, choices, multi, callback, position, width)
    if self._active_dropdown then self:_RemoveDropdown() end
    local base = Drawing.new('Square') base.Filled = true base.Color = self._color_surface
    local crust = Drawing.new('Square') crust.Filled = false crust.Thickness = 1 crust.Color = self._color_crust
    local border = Drawing.new('Square') border.Filled = false border.Thickness = 1 border.Color = self._color_border
    local drawings = { base, crust, border }
    for _, v in ipairs(choices) do
        local e = Drawing.new('Text') e.Outline = true e.Color = self._color_text e.Text = v
        table.insert(drawings, e)
    end
    local choiceHash = {}
    for _, c in ipairs(choices) do choiceHash[c] = false end
    for _, d in ipairs(default) do choiceHash[d] = true end
    self._active_dropdown = { ['choices'] = choiceHash, ['multi'] = multi, ['callback'] = callback, ['position'] = position, ['w'] = width, ['_drawings'] = drawings }
end

function UILib:ToggleWatermark(state) self._watermark = state end
function UILib:ToggleMenu(state) self._open = state end
function UILib:IsMenuOpen() return self._open end

function UILib:Tab(name)
    local backdrop = Drawing.new('Square') backdrop.Color = self._color_border backdrop.Filled = true
    local shadow = Drawing.new('Square') shadow.Color = BLACK shadow.Filled = true
    local cursor = Drawing.new('Square') cursor.Color = self._color_accent cursor.Filled = true
    local text = Drawing.new('Text') text.Color = self._color_text text.Outline = true text.Text = name text.Size = 13
    table.insert(self._tree['_tabs'], { ['name'] = name, ['_sections'] = {}, ['_drawings'] = { backdrop, shadow, cursor, text } })
    if self._active_tab == nil then self._active_tab = name end
    return name
end

function UILib:Section(tabName, name)
    for _, tab in ipairs(self._tree['_tabs']) do
        if tab['name'] == tabName then
            local base = Drawing.new('Square') base.Filled = true base.Color = self._color_surface
            local crust = Drawing.new('Square') crust.Filled = false crust.Thickness = 1 crust.Color = self._color_crust
            local border = Drawing.new('Square') border.Filled = false border.Thickness = 1 border.Color = self._color_overlay
            local title = Drawing.new('Text') title.Text = name title.Outline = true title.Color = self._color_text title.Size = 13
            table.insert(tab._sections, { ['name'] = name, ['_items'] = {}, ['_drawings'] = { base, crust, border, title } })
            return name
        end
    end
end

function UILib:_AddToSection(tabName, sectionName, itemType, value, callback, drawings, meta)
    for _, tab in pairs(self._tree._tabs) do
        if tab.name == tabName then
            for _, section in pairs(tab._sections) do
                if section.name == sectionName then
                    local item = { ['type'] = itemType, ['value'] = value, ['callback'] = callback, ['_drawings'] = drawings }
                    if meta then for k, v in pairs(meta) do item[k] = v end end
                    table.insert(section._items, item)
                    return
                end
            end
        end
    end
end

function UILib:Checkbox(tabName, sectionName, label, defaultValue, callback)
    local outline = Drawing.new('Square') outline.Color = self._color_crust outline.Thickness = 1 outline.Filled = false
    local check = Drawing.new('Square') check.Color = self._color_accent check.Filled = true
    local checkShadow = Drawing.new('Square') checkShadow.Color = BLACK checkShadow.Filled = true
    local text = Drawing.new('Text') text.Color = self._color_text text.Outline = true text.Text = label text.Size = 13
    self:_AddToSection(tabName, sectionName, 'checkbox', defaultValue, callback, { outline, check, checkShadow, text })
end

function UILib:Slider(tabName, sectionName, label, defaultValue, callback, min, max, step, appendix)
    local outline = Drawing.new('Square') outline.Color = self._color_crust outline.Filled = true
    local fill = Drawing.new('Square') fill.Color = self._color_accent fill.Filled = true
    local fillShadow = Drawing.new('Square') fillShadow.Color = BLACK fillShadow.Filled = true
    local value = Drawing.new('Text') value.Color = self._color_text value.Outline = true value.Text = label value.Size = 13
    local text = Drawing.new('Text') text.Color = self._color_text text.Outline = true text.Text = label text.Size = 13
    self:_AddToSection(tabName, sectionName, 'slider', defaultValue, callback, { outline, fill, fillShadow, value, text }, { ['min'] = min, ['max'] = max, ['step'] = step, ['appendix'] = appendix })
end

function UILib:Button(tabName, sectionName, label, callback)
    local outline = Drawing.new('Square') outline.Color = self._color_crust outline.Thickness = 1 outline.Filled = false
    local fill = Drawing.new('Square') fill.Color = self._color_crust fill.Filled = true
    local text = Drawing.new('Text') text.Color = self._color_text text.Outline = true text.Text = label text.Size = 13
    self:_AddToSection(tabName, sectionName, 'button', nil, callback, { outline, fill, text }, { ['label'] = label })
end

function UILib:Step()
    local deltaTime = math.max(os.clock() - self._tick, 0.0035)
    self._pulse = self._pulse + deltaTime
    local pulse = (math.sin(self._pulse * 2.4) + 1) / 2
    self._color_accent = mixColor(self._color_accent_base, self._color_accent_alt, pulse)
    local mousePos = getMousePos()
    for keycode, inputData in pairs(self._inputs) do
        local keycodeId = inputData['id']
        local interacted = iskeypressed(keycodeId)
        if isrbxactive() and interacted then
            if inputData['held'] == false and inputData['click'] == false then self._inputs[keycode]['click'] = true else self._inputs[keycode]['click'] = false end
            self._inputs[keycode]['held'] = true
        else self._inputs[keycode]['held'] = false end
    end
    if self._inputs['f1'].click then self._open = not self._open end
    local menuOpen = self._open
    local clickFrame = menuOpen and self._inputs['m1'].click
    local m1Held = menuOpen and self._inputs['m1'].held
    local baseOpacity = self._base_opacity
    local childrenVisible = baseOpacity > 0.08
    self._base_opacity = clamp(lerp(baseOpacity, menuOpen == true and 1 or 0, deltaTime * 18), 0, 1)
    self.w = lerp(self.w, self._target_w, deltaTime * 20)
    self.h = lerp(self.h, self._target_h, deltaTime * 20)
    setrobloxinput(not menuOpen)

    local watermarkBase = self._tree['_drawings'][6]
    local watermarkCursor = self._tree['_drawings'][7]
    local watermarkCrust = self._tree['_drawings'][8]
    local watermarkBorder = self._tree['_drawings'][9]
    local watermarkTitle = self._tree['_drawings'][10]

    if self._watermark then
        local watermarkStates = {self.identity}
        local watermarkActivity = self._watermark_activity
        if watermarkActivity then for _, activity in ipairs(watermarkActivity) do if type(activity) == 'function' then local s = activity() if s ~= nil and #s > 0 then table.insert(watermarkStates, s) end end end end
        local watermarkText = table.concat(watermarkStates, ' | ')
        local watermarkW, watermarkH = self._GetTextBounds(watermarkText)
        local watermarkPosition = Vector2.new(20, 20)
        local watermarkSize = Vector2.new(watermarkW + self._padding * 3, watermarkH + self._padding * 3)
        watermarkBase.Position = watermarkPosition watermarkBase.Size = watermarkSize watermarkBase.Visible = true watermarkBase.Color = self._color_surface_2
        watermarkCrust.Position = watermarkPosition watermarkCrust.Size = watermarkSize watermarkCrust.Visible = true watermarkCrust.Color = self._color_crust
        watermarkBorder.Position = watermarkPosition + Vector2.new(1, 1) watermarkBorder.Size = watermarkSize + Vector2.new(-2, -2) watermarkBorder.Visible = true watermarkBorder.Color = self._color_border
        watermarkCursor.Position = watermarkPosition + Vector2.new(2, 2) watermarkCursor.Size = Vector2.new(watermarkSize.x - 4, 2) watermarkCursor.Visible = true watermarkCursor.Color = self._color_accent
        watermarkTitle.Position = watermarkPosition + Vector2.new(2 + self._padding, 2 + self._padding) watermarkTitle.Text = watermarkText watermarkTitle.Visible = true watermarkTitle.Color = self._color_text
    else watermarkBase.Visible = false watermarkCrust.Visible = false watermarkBorder.Visible = false watermarkCursor.Visible = false watermarkTitle.Visible = false end

    if self._active_dropdown then
        local dropdownChoices = self._active_dropdown['choices'] local dropdownIsMulti = self._active_dropdown['multi'] local dropdownCallback = self._active_dropdown['callback']
        local dropdownPosition = self._active_dropdown['position'] local dropdownWidth = self._active_dropdown['w'] local dropdownDraws = self._active_dropdown['_drawings']
        local dropdownBase = dropdownDraws[1] local dropdownCrust = dropdownDraws[2] local dropdownBorder = dropdownDraws[3]
        local totalDropdownY = self._padding local dropdownCancel = clickFrame local i = 1
        for choice, choiceValue in pairs(dropdownChoices) do
            local _choiceW, choiceH = self._GetTextBounds(choice) local choiceDraw = dropdownDraws[3 + i]
            local choicePos = dropdownPosition + Vector2.new(self._padding, totalDropdownY) local choiceSize = Vector2.new(dropdownWidth, choiceH + self._padding)
            choiceDraw.Position = choicePos choiceDraw.Color = choiceValue and self._color_accent or self._color_text choiceDraw.Text = choice choiceDraw.Visible = childrenVisible
            if clickFrame and self._IsMouseWithinBounds(choicePos, choiceSize) then
                dropdownCancel = not dropdownIsMulti
                if not dropdownIsMulti then for choiceName, _ in pairs(dropdownChoices) do dropdownChoices[choiceName] = false end end
                dropdownChoices[choice] = not choiceValue
                if dropdownCallback then local returnedValue = {} for choiceName, cv in pairs(dropdownChoices) do if cv == true then table.insert(returnedValue, choiceName) end end dropdownCallback(returnedValue) end
            end
            totalDropdownY = totalDropdownY + choiceH * 2 + self._padding i = i + 1
        end
        if dropdownCancel then self:_RemoveDropdown()
        else
            dropdownBase.Position = dropdownPosition dropdownBase.Size = Vector2.new(dropdownWidth, totalDropdownY) dropdownBase.Transparency = baseOpacity dropdownBase.Visible = childrenVisible dropdownBase.Color = self._color_surface
            dropdownCrust.Position = dropdownPosition dropdownCrust.Size = Vector2.new(dropdownWidth, totalDropdownY) dropdownCrust.Transparency = baseOpacity dropdownCrust.Visible = childrenVisible dropdownCrust.Color = self._color_crust
            dropdownBorder.Position = dropdownPosition + Vector2.new(1, 1) dropdownBorder.Size = Vector2.new(dropdownWidth - 2, totalDropdownY - 2) dropdownBorder.Transparency = baseOpacity dropdownBorder.Visible = childrenVisible dropdownBorder.Color = self._color_border
        end
        clickFrame = false
    end

    local uiCrust = self._tree['_drawings'][1] local uiBorder = self._tree['_drawings'][2] local uiBase = self._tree['_drawings'][3] local uiNavbar = self._tree['_drawings'][4] local uiTitle = self._tree['_drawings'][5]
    local resizeGrip = self._tree['_drawings'][11] local resizeAccent = self._tree['_drawings'][12]
    uiBase.Position = Vector2.new(self.x, self.y) uiBase.Size = Vector2.new(self.w, self.h) uiBase.Transparency = baseOpacity uiBase.Visible = childrenVisible uiBase.Color = self._color_surface
    uiBorder.Position = Vector2.new(self.x + 1, self.y + 1) uiBorder.Size = Vector2.new(self.w - 2, self.h - 2) uiBorder.Transparency = baseOpacity uiBorder.Visible = childrenVisible uiBorder.Color = self._color_border
    uiCrust.Position = Vector2.new(self.x, self.y) uiCrust.Size = Vector2.new(self.w, self.h) uiCrust.Transparency = baseOpacity uiCrust.Visible = childrenVisible uiCrust.Color = self._color_crust
    uiNavbar.Position = Vector2.new(self.x + 2, self.y + 2) uiNavbar.Size = Vector2.new(self.w - 4, self._title_h - 4) uiNavbar.Transparency = baseOpacity uiNavbar.Visible = childrenVisible uiNavbar.Color = self._color_surface_2
    local _titleW, titleH = self._GetTextBounds('') uiTitle.Position = Vector2.new(self.x + 10, self.y + self._title_h / 2 - titleH + 2) uiTitle.Transparency = baseOpacity uiTitle.Visible = childrenVisible uiTitle.Color = self._color_text
    local gripSize = Vector2.new(18, 18)
    local gripPosition = Vector2.new(self.x + self.w - gripSize.x - 4, self.y + self.h - gripSize.y - 4)
    local gripHover = self._IsMouseWithinBounds(gripPosition - Vector2.new(4, 4), gripSize + Vector2.new(8, 8))
    resizeGrip.Position = gripPosition resizeGrip.Size = gripSize resizeGrip.Transparency = 0.55 * baseOpacity resizeGrip.Visible = childrenVisible resizeGrip.Color = gripHover and self._color_hover or self._color_surface_2
    resizeAccent.Position = gripPosition + Vector2.new(6, 6) resizeAccent.Size = Vector2.new(10, 10) resizeAccent.Transparency = baseOpacity resizeAccent.Visible = childrenVisible resizeAccent.Color = self._color_accent
    if gripHover and clickFrame then
        self._resizing = true
        self._resize_offset = Vector2.new((self.x + self._target_w) - mousePos.x, (self.y + self._target_h) - mousePos.y)
    end
    if self._resizing then
        if m1Held then
            self._target_w = clamp(mousePos.x - self.x + self._resize_offset.x, self._min_w, self._max_w)
            self._target_h = clamp(mousePos.y - self.y + self._resize_offset.y, self._min_h, self._max_h)
        else
            self._resizing = false
        end
        clickFrame = false
    end
    local titleOrigin = Vector2.new(self.x, self.y) local titleSize = Vector2.new(self.w, self._title_h)
    if self._IsMouseWithinBounds(titleOrigin, titleSize) then if clickFrame then self._dragging = true self._drag_offset = mousePos - titleOrigin end end
    if self._dragging then if m1Held then self.x = mousePos.x - self._drag_offset.x self.y = mousePos.y - self._drag_offset.y else self._dragging = false end clickFrame = false end

    local numTabs = #self._tree['_tabs']
    for tabIndex, tab in ipairs(self._tree['_tabs']) do
        local tabName = tab['name'] local tabDraws = tab['_drawings'] local tabOpen = self._active_tab == tabName
        local tabBackdrop = tabDraws[1] local tabShadow = tabDraws[2] local tabCursor = tabDraws[3] local tabText = tabDraws[4]
        local tabW = (self.w - self._padding * 2 - (numTabs - 1) * 2) / numTabs local tabH = self._tab_h
        local tabPosition = Vector2.new(self.x + self._padding + (tabIndex - 1) * (tabW + 2), self.y + self._title_h + self._padding) local tabSize = Vector2.new(tabW, tabH)
        local tabHover = self._IsMouseWithinBounds(tabPosition, tabSize)
        tabBackdrop.Position = tabPosition tabBackdrop.Size = tabSize tabBackdrop.Transparency = baseOpacity tabBackdrop.Visible = childrenVisible tabBackdrop.Color = tabOpen and self._color_surface_2 or (tabHover and self._color_hover or self._color_border)
        tabShadow.Position = tabPosition + Vector2.new(0, tabH - 7) tabShadow.Size = Vector2.new(tabW, 7) tabShadow.Transparency = 0.08 * baseOpacity tabShadow.Visible = childrenVisible
        tabCursor.Position = tabPosition + Vector2.new(0, tabH - 2) tabCursor.Size = Vector2.new(tabW, 2) tabCursor.Transparency = baseOpacity tabCursor.Visible = tabOpen and childrenVisible tabCursor.Color = self._color_accent
        tabText.Position = tabPosition + Vector2.new(6, tabH / 2 - ESP_FONTSIZE / 2) tabText.Transparency = baseOpacity tabText.Visible = childrenVisible tabText.Color = tabOpen and self._color_text or self._color_muted
        if clickFrame and tabHover then self._active_tab = tabName end
        local totalSectionH_0 = self._padding local totalSectionH_1 = self._padding
        for sectionIndex, section in ipairs(tab['_sections']) do
            local sectionDraws = section['_drawings'] local sectionItems = section['_items']
            if tabOpen then
                local sectionY = self._padding * 2 local opposite = (sectionIndex+1) % 2
                local sectionW = self.w / 2 - self._padding * 1.5
                local sectionPos = Vector2.new(self.x + self._padding + self._padding * opposite + sectionW * opposite, self.y + self._title_h + self._tab_h + self._padding * 2 + (opposite==1 and totalSectionH_0 or totalSectionH_1))
                for _, sectionItem in ipairs(sectionItems) do
                    local itemType = sectionItem['type'] local itemDraws = sectionItem['_drawings'] local itemValue = sectionItem['value'] local itemCallback = sectionItem['callback']
                    local itemPosition = sectionPos + Vector2.new(10, sectionY)
                    if itemType == 'checkbox' then
                        local checkboxOutline = itemDraws[1] local checkboxCheck = itemDraws[2] local checkboxShadow = itemDraws[3] local checkboxLabel = itemDraws[4]
                        local boxSize = Vector2.new(28, 14)
                        local toggleHover = self._IsMouseWithinBounds(itemPosition, Vector2.new(sectionW - 20, boxSize.y))
                        checkboxOutline.Position = itemPosition checkboxOutline.Size = boxSize checkboxOutline.Transparency = baseOpacity checkboxOutline.Visible = childrenVisible checkboxOutline.Color = itemValue and self._color_accent or (toggleHover and self._color_overlay or self._color_border)
                        checkboxCheck.Position = itemPosition + Vector2.new(itemValue and 15 or 2, 2) checkboxCheck.Size = Vector2.new(11, 10) checkboxCheck.Transparency = baseOpacity checkboxCheck.Visible = childrenVisible checkboxCheck.Color = itemValue and self._color_accent or self._color_muted
                        checkboxShadow.Position = itemPosition + Vector2.new(2, boxSize.y - 2) checkboxShadow.Size = Vector2.new(boxSize.x - 4, 1) checkboxShadow.Transparency = 0.18 * baseOpacity checkboxShadow.Visible = childrenVisible checkboxShadow.Color = BLACK
                        checkboxLabel.Position = itemPosition + Vector2.new(boxSize.x + 9, 0) checkboxLabel.Transparency = baseOpacity checkboxLabel.Visible = childrenVisible checkboxLabel.Color = toggleHover and self._color_text or self._color_muted
                        if toggleHover then if clickFrame then sectionItem['value'] = not sectionItem['value'] if itemCallback then itemCallback(sectionItem['value']) end end end
                        sectionY = sectionY + boxSize.y + 10
                    elseif itemType == 'slider' then
                        local sliderOutline = itemDraws[1] local sliderFill = itemDraws[2] local sliderFillShadow = itemDraws[3] local sliderValue = itemDraws[4] local sliderLabel = itemDraws[5]
                        local min = sectionItem['min'] local max = sectionItem['max'] local step = sectionItem['step'] local appendix = sectionItem['appendix']
                        local sliderW = sectionW - self._padding * 3 local sliderH = 18 local sliderBoxSize = Vector2.new(sliderW, sliderH)
                        local _labelW, labelH = self._GetTextBounds('')
                        local sliderHover = self._IsMouseWithinBounds(itemPosition + Vector2.new(0, labelH + 10), sliderBoxSize)
                        sliderLabel.Position = itemPosition sliderLabel.Transparency = baseOpacity sliderLabel.Visible = childrenVisible sliderLabel.Color = sliderHover and self._color_text or self._color_muted
                        sliderOutline.Position = itemPosition + Vector2.new(0, labelH + 16) sliderOutline.Size = Vector2.new(sliderW, 6) sliderOutline.Transparency = baseOpacity sliderOutline.Visible = childrenVisible sliderOutline.Color = self._color_border
                        local fillVisible = itemValue ~= min and childrenVisible
                        local fillPercent = (itemValue - (sectionItem.min or 0)) / ((sectionItem.max or 1) - (sectionItem.min or 0)) fillPercent = clamp(fillPercent, 0, 1)
                        sliderFill.Position = itemPosition + Vector2.new(1, labelH + 17) sliderFill.Size = Vector2.new(math.max(sliderW * fillPercent - 2, 0), 4) sliderFill.Transparency = baseOpacity sliderFill.Visible = fillVisible sliderFill.Color = self._color_accent
                        sliderFillShadow.Position = itemPosition + Vector2.new(math.max(sliderW * fillPercent - 3, 1), labelH + 13) sliderFillShadow.Size = Vector2.new(4, 12) sliderFillShadow.Transparency = baseOpacity sliderFillShadow.Visible = childrenVisible sliderFillShadow.Color = self._color_text
                        local displayedValue = tostring(itemValue) .. (appendix or '') local sliderValueW, sliderValueH = self._GetTextBounds(displayedValue)
                        sliderValue.Position = itemPosition + Vector2.new(sliderW - sliderValueW - 2, 0) sliderValue.Text = displayedValue sliderValue.Transparency = baseOpacity sliderValue.Visible = childrenVisible
                        if sliderHover then sliderValue.Color = self._color_accent if m1Held then local mouseX = mousePos.x - itemPosition.x local percent = clamp(mouseX / sliderW, 0, 1) local newValue = min + (max - min) * percent newValue = math.floor((newValue / step) + 0.5) * step newValue = math.max(min, math.min(max, newValue)) if newValue ~= sectionItem['value'] then sectionItem['value'] = newValue if itemCallback then itemCallback(newValue) end end end else sliderValue.Color = self._color_text end
                        sectionY = sectionY + sliderH + 18 + labelH
                    elseif itemType == 'button' then
                        local buttonOutline = itemDraws[1] local buttonFill = itemDraws[2] local buttonLabel = itemDraws[3]
                        local buttonText = sectionItem['label'] local buttonTextW, buttonTextH = self._GetTextBounds(buttonText) local buttonBoxSize = Vector2.new(sectionW - 20, 22)
                        local buttonHover = self._IsMouseWithinBounds(itemPosition, buttonBoxSize)
                        buttonLabel.Position = itemPosition + Vector2.new(buttonBoxSize.x / 2 - buttonTextW / 2, 5) buttonLabel.Transparency = baseOpacity buttonLabel.Visible = childrenVisible buttonLabel.Color = buttonHover and self._color_text or self._color_muted
                        buttonOutline.Position = itemPosition buttonOutline.Size = buttonBoxSize buttonOutline.Transparency = baseOpacity buttonOutline.Visible = childrenVisible
                        buttonFill.Position = itemPosition + Vector2.new(2, 2) buttonFill.Size = buttonBoxSize - Vector2.new(4, 4) buttonFill.Transparency = baseOpacity buttonFill.Visible = childrenVisible buttonFill.Color = buttonHover and self._color_hover or self._color_surface_2
                        if buttonHover then if clickFrame and itemCallback then itemCallback(sectionItem['value']) end buttonOutline.Color = self._color_accent else buttonOutline.Color = self._color_border end
                        sectionY = sectionY + 22 + buttonTextH
                    end
                end
                local sectionCrust = sectionDraws[2] local sectionBorder = sectionDraws[3] local sectionTitle = sectionDraws[4]
                sectionCrust.Position = sectionPos sectionCrust.Size = Vector2.new(sectionW, sectionY) sectionCrust.Transparency = baseOpacity sectionCrust.Visible = childrenVisible sectionCrust.Color = self._color_surface_2
                sectionBorder.Position = sectionPos + Vector2.new(1, 1) sectionBorder.Size = Vector2.new(sectionW - 2, sectionY - 2) sectionBorder.Transparency = baseOpacity sectionBorder.Visible = childrenVisible sectionBorder.Color = self._color_border
                local _sectionTitleW, sectionTitleH = self._GetTextBounds('') sectionTitle.Position = sectionPos + Vector2.new(10, - sectionTitleH / 2) sectionTitle.Transparency = baseOpacity sectionTitle.Visible = childrenVisible sectionTitle.Color = self._color_text
                sectionDraws[1].Visible = false
                sectionY = sectionY + self._padding
                if opposite == 1 then totalSectionH_0 = totalSectionH_0 + sectionY else totalSectionH_1 = totalSectionH_1 + sectionY end
            else undrawAll(sectionDraws) for _, sectionItem in ipairs(sectionItems) do undrawAll(sectionItem['_drawings']) end end
        end
    end
    self._tick = os.clock()
end

function UILib:Destroy()
    for _, drawing in pairs(self._tree['_drawings']) do drawing:Remove() end
    self:_RemoveDropdown()
    for _, tab in pairs(self._tree['_tabs']) do
        if tab['_drawings'] then for _, drawing in pairs(tab['_drawings']) do drawing:Remove() end end
        if tab._sections then for _, section in pairs(tab['_sections']) do for _, drawing in pairs(section['_drawings']) do drawing:Remove() end if section._items then for _, item in pairs(section._items) do for _, drawing in pairs(item['_drawings']) do drawing:Remove() end end end end end
    end
    self._tree = nil setrobloxinput(true)
end

-- ===================================================================
--                         CONFIG
-- ===================================================================
local CONFIG = {
    statMod = {
        enabled = false,
        lifesteal = 21,
    },
    hitbox = {
        enabled = false,
        size = 40,
        markSize = 80,
    },
    damage = {
        esp = false,
        heavyForce = false,
    },
    parry = {
        auto = false,
        range = 25,
        cooldown = 0.4,
        disableFlash = false,
        forceReflector = false,
    },
    health = {
        autoHeal = false,
        threshold = 30,
        esp = false,
    },
    stamina = {
        infinite = false,
    },
}

local TARGET_NAMES = {"Head", "Main", "Storage", "KillBot", "Cannon", "killbot", "cannon"}

-- ===================================================================
--                     SERVICES & REFERENCES
-- ===================================================================
local Players        = game:GetService("Players")
local LocalPlayer    = Players.LocalPlayer
local Workspace      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService     = game:GetService("RunService")
local Lighting       = game:GetService("Lighting")
local Camera         = Workspace.CurrentCamera

-- ===================================================================
--                  INSTANCE FINDER UTILITY
-- ===================================================================
local function FindInstance(name, className, parent)
    parent = parent or ReplicatedStorage
    local result = nil
    pcall(function()
        for _, v in ipairs(parent:GetDescendants()) do
            if v.Name == name and (not className or v:IsA(className)) then
                result = v
                return
            end
        end
    end)
    if not result then
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v.Name == name and (not className or v:IsA(className)) then
                    result = v
                    return
                end
            end
        end)
    end
    return result
end

-- ===================================================================
--               CACHED REMOTES & MODULES (loaded once)
-- ===================================================================
local Remotes = {}
pcall(function()
    Remotes.RefillStamina   = FindInstance("RefillStamina",   "RemoteEvent")
    Remotes.Parry           = FindInstance("Parry",           "RemoteEvent")
    Remotes.PlayerDamage    = FindInstance("PlayerDamage",    "RemoteEvent")
    Remotes.DamageIndicator = FindInstance("DamageIndicator", "RemoteEvent")
    Remotes.AllyDamage      = FindInstance("AllyDamage",      "RemoteEvent")
end)

local Modules = {}
pcall(function()
    local healMod = FindInstance("heal", "ModuleScript")
    if healMod then pcall(function() Modules.Heal = require(healMod) end) end
    local getDmg = FindInstance("GetDamage", "ModuleScript")
    if getDmg then pcall(function() Modules.GetDamage = require(getDmg) end) end
end)

-- ===================================================================
--                ORIGINAL-STATE TRACKING (existing)
-- ===================================================================
local originalSizes      = {}
local originalAttributes = setmetatable({}, {__mode = "k"})
local statTrackedInstances = setmetatable({}, {__mode = "k"})
local STAT_TOOL_ATTRIBUTES = {"Lifesteal"}

local function RememberAttributes(instance, names)
    if not instance then return end
    local snapshot = originalAttributes[instance]
    if not snapshot then snapshot = {} originalAttributes[instance] = snapshot end
    for _, name in ipairs(names) do
        if snapshot[name] == nil then snapshot[name] = { value = instance:GetAttribute(name) } end
    end
end

local function RestoreAttributes(instance, names)
    local snapshot = instance and originalAttributes[instance]
    if not snapshot then return end
    pcall(function()
        for _, name in ipairs(names) do
            local saved = snapshot[name]
            if saved ~= nil then instance:SetAttribute(name, saved.value) end
        end
    end)
end

local function TrackStatInstance(instance, names)
    RememberAttributes(instance, names)
    statTrackedInstances[instance] = names
end

local function RestoreTrackedAttributes(tracked)
    for instance, names in pairs(tracked) do RestoreAttributes(instance, names) end
    table.clear(tracked)
end

-- ===================================================================
--               STAT MODIFIER  (existing feature)
-- ===================================================================
local function ApplyStatMod()
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        TrackStatInstance(tool, STAT_TOOL_ATTRIBUTES)
        pcall(function() tool:SetAttribute("Lifesteal", CONFIG.statMod.lifesteal) end)
    end
end
local function RestoreStatMod() RestoreTrackedAttributes(statTrackedInstances) end

-- ===================================================================
--              HITBOX EXPANDER  (existing feature)
-- ===================================================================
local function ApplyHitbox()
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local cfg = CONFIG.hitbox
    for _, enemy in ipairs(enemies:GetChildren()) do
        local enemyName = tostring(enemy.Name)
        for _, name in ipairs(TARGET_NAMES) do
            local part = enemy:FindFirstChild(name)
            if part then
                if not originalSizes[part] then originalSizes[part] = part.Size end
                pcall(function()
                    part.CanCollide = false
                    if name == "Head" and enemyName == "Mark" then
                        part.Size = Vector3.new(cfg.markSize, cfg.markSize, cfg.markSize)
                    else
                        part.Size = Vector3.new(cfg.size, cfg.size, cfg.size)
                    end
                end)
            end
        end
    end
end

local function RestoreHitbox()
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, enemy in ipairs(enemies:GetChildren()) do
            for _, name in ipairs(TARGET_NAMES) do
                local part = enemy:FindFirstChild(name)
                if part then
                    local old = originalSizes[part]
                    pcall(function()
                        part.Size = old or Vector3.new(2, 2, 1)
                        part.CanCollide = true
                    end)
                end
            end
        end
    end
    table.clear(originalSizes)
end

-- ===================================================================
--                HEAVY DAMAGE FORCE  (new)
-- Force the held tool to flag attacks as heavy/critical.
-- Works if the game reads DamageType / HeavyDamage attributes
-- from the tool (common in attribute-driven combat systems).
-- ===================================================================
local HEAVY_ATTRS = {"DamageType", "HeavyDamage", "CriticalHit", "AttackType"}
local heavyTracked = setmetatable({}, {__mode = "k"})

local function ApplyHeavyDamage()
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    RememberAttributes(tool, HEAVY_ATTRS)
    heavyTracked[tool] = HEAVY_ATTRS
    pcall(function()
        tool:SetAttribute("DamageType",  "Heavy")
        tool:SetAttribute("HeavyDamage", true)
        tool:SetAttribute("CriticalHit", true)
        tool:SetAttribute("AttackType",  "Heavy")
    end)
end

local function RestoreHeavyDamage()
    for inst, names in pairs(heavyTracked) do RestoreAttributes(inst, names) end
    table.clear(heavyTracked)
end

-- ===================================================================
--              INFINITE STAMINA  (new)
-- Fires the RefillStamina RemoteEvent every cycle.
-- ===================================================================
local function ApplyInfiniteStamina()
    if Remotes.RefillStamina then
        pcall(function() Remotes.RefillStamina:FireServer() end)
    end
end

-- ===================================================================
--                  AUTO HEAL  (new)
-- Fires the heal module or searches for a heal mechanism
-- when the player's health drops below threshold.
-- ===================================================================
local function GetPlayerHealth()
    local character = LocalPlayer.Character
    if not character then return 100, 100 end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return 100, 100 end
    return hum.Health, hum.MaxHealth
end

local function ApplyAutoHeal()
    local hp, maxHp = GetPlayerHealth()
    local threshold = (CONFIG.health.threshold / 100) * maxHp
    if hp >= threshold then return end

    -- Strategy 1: call the required heal module
    if Modules.Heal then
        pcall(function()
            if type(Modules.Heal) == "function" then
                Modules.Heal(LocalPlayer)
            elseif type(Modules.Heal) == "table" then
                local fn = Modules.Heal.heal or Modules.Heal.Heal
                    or Modules.Heal.activate or Modules.Heal.Use
                if fn then fn(LocalPlayer) end
            end
        end)
    end

    -- Strategy 2: look for a heal remote (name variations)
    local healNames = {"Heal", "heal", "UseHeal", "HealPlayer", "RequestHeal"}
    for _, n in ipairs(healNames) do
        local remote = FindInstance(n, "RemoteEvent")
        if remote then
            pcall(function() remote:FireServer() end)
            break
        end
    end
end

-- ===================================================================
--                    AUTO PARRY  (new)
-- Detects nearby enemy attack animations and fires the Parry
-- remote with a configurable cooldown.
-- ===================================================================
local ATTACK_KEYWORDS = {
    "attack", "swing", "slash", "hit", "punch", "kick",
    "smash", "strike", "combo", "heavy", "lunge", "thrust",
    "chop", "cleave", "slam", "stab",
}

local function IsEnemyAttacking(enemy)
    local ok, result = pcall(function()
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return false end
        local tracks = animator:GetPlayingAnimationTracks()
        for _, track in ipairs(tracks) do
            local lname = string.lower(track.Name or "")
            for _, kw in ipairs(ATTACK_KEYWORDS) do
                if string.find(lname, kw) then return true end
            end
            -- Also trigger on Action-priority animations (likely attacks)
            if track.Priority == Enum.AnimationPriority.Action
            or track.Priority == Enum.AnimationPriority.Action2
            or track.Priority == Enum.AnimationPriority.Action3
            or track.Priority == Enum.AnimationPriority.Action4 then
                -- But skip idle/walk/run animations
                if not string.find(lname, "idle")
                and not string.find(lname, "walk")
                and not string.find(lname, "run")
                and not string.find(lname, "jump") then
                    return true
                end
            end
        end
        return false
    end)
    return ok and result or false
end

local lastParryTime = 0

local function ApplyAutoParry()
    if not Remotes.Parry then return end
    if os.clock() - lastParryTime < CONFIG.parry.cooldown then return end

    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, enemy in ipairs(enemies:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                or enemy:FindFirstChild("Main")
                or enemy:FindFirstChild("Head")
            if eRoot then
                local dist = (rootPart.Position - eRoot.Position).Magnitude
                if dist <= CONFIG.parry.range then
                    if IsEnemyAttacking(enemy) then
                        pcall(function()
                            if CONFIG.parry.forceReflector then
                                Remotes.Parry:FireServer("Reflector")
                            else
                                Remotes.Parry:FireServer()
                            end
                        end)
                        lastParryTime = os.clock()
                        return -- one parry per cycle
                    end
                end
            end
        end
    end
end

-- ===================================================================
--             PARRY FLASH DISABLER  (new)
-- Clamps ColorCorrectionEffect brightness in Lighting so
-- screen-flash effects are suppressed without breaking normal light.
-- ===================================================================
local savedFlashStates = {}

local function ApplyParryFlashDisable()
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("ColorCorrectionEffect") then
                if not savedFlashStates[v] then
                    savedFlashStates[v] = { brightness = v.Brightness, tint = v.TintColor, contrast = v.Contrast }
                end
                if v.Brightness > 0.15 then v.Brightness = 0.15 end
            end
        end
        -- Also suppress flash inside the player's PlayerGui
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, ui in ipairs(pg:GetDescendants()) do
                if ui:IsA("Frame") and (string.find(string.lower(ui.Name), "flash") or string.find(string.lower(ui.Name), "white")) then
                    if ui.BackgroundTransparency < 0.8 then
                        ui.BackgroundTransparency = 1
                    end
                end
            end
        end
    end)
end

local function RestoreParryFlash()
    pcall(function()
        for inst, state in pairs(savedFlashStates) do
            if inst and inst.Parent then
                inst.Brightness = state.brightness
                inst.TintColor  = state.tint
                inst.Contrast   = state.contrast
            end
        end
    end)
    table.clear(savedFlashStates)
end

-- ===================================================================
--                      ESP SYSTEM  (new)
-- Drawing-based health bars + floating damage numbers over enemies.
-- ===================================================================
local ESP_POOL_SIZE = 25
local espPool = {}
local allESPDrawings = {}

local function MakeESPDrawing(drawType)
    local d = Drawing.new(drawType)
    table.insert(allESPDrawings, d)
    return d
end

for i = 1, ESP_POOL_SIZE do
    local nameText = MakeESPDrawing('Text')
    nameText.Outline = true  nameText.Size = 13  nameText.Visible = false  nameText.Color = Color3.fromRGB(255, 255, 255)

    local hpBg = MakeESPDrawing('Square')
    hpBg.Filled = true  hpBg.Visible = false  hpBg.Color = Color3.fromRGB(30, 30, 30)

    local hpFill = MakeESPDrawing('Square')
    hpFill.Filled = true  hpFill.Visible = false

    local hpText = MakeESPDrawing('Text')
    hpText.Outline = true  hpText.Size = 11  hpText.Visible = false  hpText.Color = Color3.fromRGB(200, 200, 200)

    local dmgText = MakeESPDrawing('Text')
    dmgText.Outline = true  dmgText.Size = 15  dmgText.Visible = false  dmgText.Color = Color3.fromRGB(255, 70, 70)

    espPool[i] = {
        nameText = nameText,
        hpBg     = hpBg,
        hpFill   = hpFill,
        hpText   = hpText,
        dmgText  = dmgText,
        lastHP   = nil,
        dmgAmt   = 0,
        dmgTime  = 0,
        enemy    = nil,
    }
end

local function HideESPEntry(e)
    e.nameText.Visible = false
    e.hpBg.Visible     = false
    e.hpFill.Visible   = false
    e.hpText.Visible   = false
    e.dmgText.Visible  = false
    e.enemy = nil
end

local function HideAllESP()
    for i = 1, ESP_POOL_SIZE do HideESPEntry(espPool[i]) end
end

local function UpdateESP()
    local showHealth = CONFIG.health.esp
    local showDamage = CONFIG.damage.esp
    if not showHealth and not showDamage then HideAllESP() return end

    local cam = Workspace.CurrentCamera
    if not cam then HideAllESP() return end

    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then HideAllESP() return end

    local enemyList = enemies:GetChildren()
    for i = 1, ESP_POOL_SIZE do
        local entry = espPool[i]
        local enemy = enemyList[i]

        if not enemy then
            HideESPEntry(entry)
        else
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
                or enemy:FindFirstChild("Head")
                or enemy:FindFirstChild("Main")

            if not hum or not rootPart or hum.Health <= 0 then
                HideESPEntry(entry)
                entry.lastHP = nil
            else
                local worldPos = rootPart.Position + Vector3.new(0, 3.5, 0)
                local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)

                if not onScreen then
                    HideESPEntry(entry)
                else
                    local sx, sy = screenPos.X, screenPos.Y
                    local depth = math.max(screenPos.Z, 1)
                    local barW = clamp(math.floor(800 / depth), 30, 80)
                    local barH = 4

                    if showHealth then
                        local eName = enemy.Name
                        local nameW = #eName * ESP_CHAR_WIDTH
                        entry.nameText.Text     = eName
                        entry.nameText.Position = Vector2.new(sx - nameW / 2, sy - 28)
                        entry.nameText.Visible  = true

                        entry.hpBg.Position = Vector2.new(sx - barW / 2, sy - 14)
                        entry.hpBg.Size     = Vector2.new(barW, barH)
                        entry.hpBg.Visible  = true

                        local pct = clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        entry.hpFill.Position = Vector2.new(sx - barW / 2, sy - 14)
                        entry.hpFill.Size     = Vector2.new(math.max(barW * pct, 0), barH)
                        entry.hpFill.Color    = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
                        entry.hpFill.Visible  = true

                        local hpStr = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                        local hpStrW = #hpStr * ESP_CHAR_WIDTH
                        entry.hpText.Text     = hpStr
                        entry.hpText.Position = Vector2.new(sx - hpStrW / 2, sy - 8)
                        entry.hpText.Visible  = true
                    else
                        entry.nameText.Visible = false
                        entry.hpBg.Visible     = false
                        entry.hpFill.Visible   = false
                        entry.hpText.Visible   = false
                    end

                    if showDamage then
                        if entry.lastHP and entry.lastHP > hum.Health then
                            entry.dmgAmt  = math.floor(entry.lastHP - hum.Health)
                            entry.dmgTime = os.clock()
                        end
                        entry.lastHP = hum.Health

                        local elapsed = os.clock() - entry.dmgTime
                        if entry.dmgAmt > 0 and elapsed < 1.8 then
                            local fadeT  = clamp(1 - elapsed / 1.8, 0, 1)
                            local floatY = (1 - fadeT) * 35
                            local dStr   = "-" .. tostring(entry.dmgAmt)
                            local dStrW  = #dStr * (ESP_CHAR_WIDTH + 1)
                            entry.dmgText.Text         = dStr
                            entry.dmgText.Position     = Vector2.new(sx - dStrW / 2, sy - 40 - floatY)
                            entry.dmgText.Transparency = fadeT
                            entry.dmgText.Visible      = true
                        else
                            entry.dmgText.Visible = false
                            if elapsed >= 1.8 then entry.dmgAmt = 0 end
                        end
                    else
                        entry.dmgText.Visible = false
                    end

                    entry.enemy = enemy
                end -- onScreen
            end -- hum valid
        end -- enemy exists
    end
end

local function DestroyESP()
    for _, d in ipairs(allESPDrawings) do pcall(function() d:Remove() end) end
    table.clear(allESPDrawings)
    table.clear(espPool)
end

-- ===================================================================
--                     WATERMARK STATUS
-- ===================================================================
local function GetStatus()
    local p = {}
    if CONFIG.statMod.enabled     then table.insert(p, "Stats")   end
    if CONFIG.hitbox.enabled      then table.insert(p, "Hitbox")  end
    if CONFIG.damage.esp          then table.insert(p, "DmgESP")  end
    if CONFIG.damage.heavyForce   then table.insert(p, "HvyDmg")  end
    if CONFIG.parry.auto          then table.insert(p, "AParry")  end
    if CONFIG.parry.disableFlash  then table.insert(p, "NoFlash") end
    if CONFIG.parry.forceReflector then table.insert(p, "Reflect") end
    if CONFIG.health.autoHeal     then table.insert(p, "AHeal")   end
    if CONFIG.health.esp          then table.insert(p, "HP-ESP")  end
    if CONFIG.stamina.infinite    then table.insert(p, "InfStam") end
    if #p == 0 then return "Idle" end
    return table.concat(p, " | ")
end

-- ===================================================================
--                       UI SETUP
-- ===================================================================
local myGui = UILib.new("CI // Matcha", Vector2.new(420, 480), {GetStatus})
local running = true

-- ========== TAB 1: Main ==========
local mainTab = myGui:Tab("Main")

local statSection = myGui:Section(mainTab, "Stat Modifier")
myGui:Checkbox(mainTab, statSection, "Enable", CONFIG.statMod.enabled, function(s)
    CONFIG.statMod.enabled = s
    if not s then pcall(RestoreStatMod) end
end)
myGui:Slider(mainTab, statSection, "Lifesteal", CONFIG.statMod.lifesteal, function(v) CONFIG.statMod.lifesteal = v end, 0, 200, 1, "")

local hitboxSection = myGui:Section(mainTab, "Hitbox Expander")
myGui:Checkbox(mainTab, hitboxSection, "Enable", CONFIG.hitbox.enabled, function(s)
    CONFIG.hitbox.enabled = s
    if not s then pcall(RestoreHitbox) end
end)
myGui:Slider(mainTab, hitboxSection, "Size", CONFIG.hitbox.size, function(v) CONFIG.hitbox.size = v end, 5, 100, 1, " studs")
myGui:Slider(mainTab, hitboxSection, "Mark Size", CONFIG.hitbox.markSize, function(v) CONFIG.hitbox.markSize = v end, 5, 150, 1, " studs")

-- ========== TAB 2: Combat ==========
local combatTab = myGui:Tab("Combat")

local damageSection = myGui:Section(combatTab, "Damage")
myGui:Checkbox(combatTab, damageSection, "Damage ESP", CONFIG.damage.esp, function(s)
    CONFIG.damage.esp = s
    if not s then HideAllESP() end
end)
myGui:Checkbox(combatTab, damageSection, "Heavy Damage Force", CONFIG.damage.heavyForce, function(s)
    CONFIG.damage.heavyForce = s
    if not s then pcall(RestoreHeavyDamage) end
end)

local parrySection = myGui:Section(combatTab, "Parry")
myGui:Checkbox(combatTab, parrySection, "Auto Parry", CONFIG.parry.auto, function(s) CONFIG.parry.auto = s end)
myGui:Slider(combatTab, parrySection, "Range", CONFIG.parry.range, function(v) CONFIG.parry.range = v end, 5, 60, 1, " studs")
myGui:Slider(combatTab, parrySection, "Cooldown", CONFIG.parry.cooldown, function(v) CONFIG.parry.cooldown = v end, 0.1, 2.0, 0.1, "s")
myGui:Checkbox(combatTab, parrySection, "Disable Flash", CONFIG.parry.disableFlash, function(s)
    CONFIG.parry.disableFlash = s
    if not s then pcall(RestoreParryFlash) end
end)
myGui:Checkbox(combatTab, parrySection, "Reflector Parry", CONFIG.parry.forceReflector, function(s) CONFIG.parry.forceReflector = s end)

-- ========== TAB 3: Survival ==========
local survivalTab = myGui:Tab("Survival")

local healthSection = myGui:Section(survivalTab, "Health")
myGui:Checkbox(survivalTab, healthSection, "Auto Heal", CONFIG.health.autoHeal, function(s) CONFIG.health.autoHeal = s end)
myGui:Slider(survivalTab, healthSection, "Threshold", CONFIG.health.threshold, function(v) CONFIG.health.threshold = v end, 5, 95, 5, "%")
myGui:Checkbox(survivalTab, healthSection, "Health ESP", CONFIG.health.esp, function(s)
    CONFIG.health.esp = s
    if not s then HideAllESP() end
end)

local staminaSection = myGui:Section(survivalTab, "Stamina")
myGui:Checkbox(survivalTab, staminaSection, "Infinite Stamina", CONFIG.stamina.infinite, function(s) CONFIG.stamina.infinite = s end)

-- ========== TAB 4: Utility ==========
local utilTab = myGui:Tab("Util")

local scriptSection = myGui:Section(utilTab, "Script")
myGui:Button(utilTab, scriptSection, "Restore Hitboxes", function() pcall(RestoreHitbox) end)
myGui:Button(utilTab, scriptSection, "Restore Heavy Dmg", function() pcall(RestoreHeavyDamage) end)
myGui:Button(utilTab, scriptSection, "Restore Flash FX", function() pcall(RestoreParryFlash) end)

local infoSection = myGui:Section(utilTab, "Info")
myGui:Button(utilTab, infoSection, "Print Remotes Found", function()
    for name, remote in pairs(Remotes) do
        if remote then
            print("[CI] Remote: " .. name .. " -> " .. tostring(remote:GetFullName()))
        else
            print("[CI] Remote: " .. name .. " -> NOT FOUND")
        end
    end
end)
myGui:Checkbox(utilTab, infoSection, "Unload", false, function(s)
    if s then
        running = false
        pcall(RestoreStatMod)
        pcall(RestoreHitbox)
        pcall(RestoreHeavyDamage)
        pcall(RestoreParryFlash)
        HideAllESP()
        DestroyESP()
        myGui:Destroy()
    end
end)

-- ===================================================================
--                            INIT
-- ===================================================================
print("[CI] Combat Initiation loaded.")
print("[CI] Remotes found:")
for name, remote in pairs(Remotes) do
    print("  " .. name .. ": " .. (remote and remote:GetFullName() or "NOT FOUND"))
end

-- ===================================================================
--                         MAIN LOOPS
-- ===================================================================
-- UI render (every frame)
spawn(function()
    while running do
        myGui:Step()
        task.wait()
    end
end)

-- ESP render (every frame, separate from UI for clarity)
spawn(function()
    while running do
        pcall(UpdateESP)
        task.wait()
    end
end)

-- Stat re-apply: throttled to 0.1s
spawn(function()
    while running do
        if CONFIG.statMod.enabled then pcall(ApplyStatMod) end
        task.wait(0.1)
    end
end)

-- Hitbox re-apply: throttled to 0.1s
spawn(function()
    while running do
        if CONFIG.hitbox.enabled then pcall(ApplyHitbox) end
        task.wait(0.1)
    end
end)

-- Heavy damage force: throttled to 0.1s
spawn(function()
    while running do
        if CONFIG.damage.heavyForce then pcall(ApplyHeavyDamage) end
        task.wait(0.1)
    end
end)

-- Infinite stamina: throttled to 0.2s
spawn(function()
    while running do
        if CONFIG.stamina.infinite then pcall(ApplyInfiniteStamina) end
        task.wait(0.2)
    end
end)

-- Auto heal: throttled to 0.3s
spawn(function()
    while running do
        if CONFIG.health.autoHeal then pcall(ApplyAutoHeal) end
        task.wait(0.3)
    end
end)

-- Auto parry: needs fast polling (~0.05s) for tight timing
spawn(function()
    while running do
        if CONFIG.parry.auto then pcall(ApplyAutoParry) end
        task.wait(0.05)
    end
end)

-- Parry flash disabler: throttled to 0.1s
spawn(function()
    while running do
        if CONFIG.parry.disableFlash then pcall(ApplyParryFlashDisable) end
        task.wait(0.1)
    end
end)

-- Keep-alive
while running do task.wait(0.1) end
