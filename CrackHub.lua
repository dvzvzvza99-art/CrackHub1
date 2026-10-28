--[[
	╔═══════════════════════════════════════════════╗
	║               C R A C K H U B                 ║
	║      Красивая UI-библиотека для Roblox        ║
	╚═══════════════════════════════════════════════╝

	LocalScript: положи в StarterPlayer → StarterPlayerScripts.
	Библиотека и пример окна — в одном файле (пример в самом конце).

	Элементы: Section, Label, Paragraph, Button, Toggle, Slider,
	Dropdown (одиночный / мульти), Textbox, Keybind, ColorPicker, Notify
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local CrackHub = {
	Version = "2.0.0",
	Flags = {},
	Theme = {
		Background   = Color3.fromRGB(13, 13, 19),
		Element      = Color3.fromRGB(22, 22, 32),
		ElementHover = Color3.fromRGB(30, 30, 44),
		Stroke       = Color3.fromRGB(44, 44, 62),
		Text         = Color3.fromRGB(242, 242, 250),
		SubText      = Color3.fromRGB(145, 145, 172),
		Accent       = Color3.fromRGB(140, 90, 255),
		Accent2      = Color3.fromRGB(60, 160, 255),
		Danger       = Color3.fromRGB(255, 85, 105),
	},
}

-- Готовые темы: CreateWindow({ Theme = "Sakura" })
CrackHub.Themes = {
	CrackHub  = { Accent = Color3.fromRGB(140, 90, 255), Accent2 = Color3.fromRGB(60, 160, 255) },
	Sakura  = { Accent = Color3.fromRGB(255, 105, 180), Accent2 = Color3.fromRGB(255, 175, 120) },
	Ocean   = { Accent = Color3.fromRGB(0, 205, 255),  Accent2 = Color3.fromRGB(50, 90, 255) },
	Emerald = { Accent = Color3.fromRGB(40, 225, 140), Accent2 = Color3.fromRGB(0, 170, 210) },
	Sunset  = { Accent = Color3.fromRGB(255, 125, 60), Accent2 = Color3.fromRGB(255, 60, 125) },
	Crimson = { Accent = Color3.fromRGB(255, 60, 85),  Accent2 = Color3.fromRGB(150, 45, 255) },
}

local Theme = CrackHub.Theme
local Mac = false

-- Палитра в стиле macOS (тёмная тема)
local MacTheme = {
	Background   = Color3.fromRGB(30, 30, 32),
	Sidebar      = Color3.fromRGB(40, 40, 43),
	Element      = Color3.fromRGB(44, 44, 46),
	Card         = Color3.fromRGB(21, 21, 25), -- карточки-группы темнее окна
	ElementHover = Color3.fromRGB(54, 54, 57),
	Stroke       = Color3.fromRGB(64, 64, 68),
	Text         = Color3.fromRGB(245, 245, 247),
	SubText      = Color3.fromRGB(162, 162, 168),
	Accent       = Color3.fromRGB(10, 132, 255),
	Accent2      = Color3.fromRGB(10, 132, 255),
	Danger       = Color3.fromRGB(255, 69, 58),
	Success      = Color3.fromRGB(48, 209, 88),
}
local FONT = "rbxasset://fonts/families/GothamSSm.json"
local Fonts = {
	Regular = Font.new(FONT, Enum.FontWeight.Regular),
	Medium  = Font.new(FONT, Enum.FontWeight.Medium),
	Bold    = Font.new(FONT, Enum.FontWeight.Bold),
}

local Container = {}
Container.__index = Container

--==============================================================
-- Утилиты
--==============================================================

local function Create(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then inst.Parent = parent end
	return inst
end

local function Tween(obj, props, time, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function Corner(r)
	return Create("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end

local function Stroke(color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function Padding(t, r, b, l)
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0),
	})
end

local function List(padding)
	return Create("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function AccentGradient(rotation)
	return Create("UIGradient", {
		Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
		Rotation = rotation or 0,
	})
end

local function IconLine(parent, x, y, len, rot, color, thick)
	return Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, x, 0.5, y),
		Size = UDim2.fromOffset(len, thick or 2),
		Rotation = rot,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
end

-- Иконка, нарисованная из линий: "chevron", "check", "x", "search"
local function Icon(kind, parent, color, size)
	local h = Create("Frame", {
		Size = UDim2.fromOffset(size or 14, size or 14),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	if kind == "chevron" then
		IconLine(h, -2.3, -0.5, 7, 45, color)
		IconLine(h, 2.3, -0.5, 7, -45, color)
	elseif kind == "check" then
		IconLine(h, -2.6, 1.4, 5, 45, color)
		IconLine(h, 1.4, -0.4, 9, -52, color)
	elseif kind == "x" then
		IconLine(h, 0, 0, 10, 45, color)
		IconLine(h, 0, 0, 10, -45, color)
	elseif kind == "search" then
		Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -1.5, 0.5, -1.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
			Parent = h,
		}, {
			Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Create("UIStroke", { Color = color, Thickness = 1.5 }),
		})
		IconLine(h, 3.6, 3.6, 4.5, 45, color, 1.5)
	end
	return h
end

local function IconColor(h, color, time)
	for _, d in ipairs(h:GetDescendants()) do
		if d:IsA("Frame") and d.BackgroundTransparency < 1 then
			TweenService:Create(d, TweenInfo.new(time or 0.2), { BackgroundColor3 = color }):Play()
		elseif d:IsA("UIStroke") then
			TweenService:Create(d, TweenInfo.new(time or 0.2), { Color = color }):Play()
		end
	end
end

local function IconAlpha(h, alpha, time)
	for _, d in ipairs(h:GetChildren()) do
		if d:IsA("Frame") then
			TweenService:Create(d, TweenInfo.new(time or 0.2), { BackgroundTransparency = alpha }):Play()
		end
	end
end

local function Label(props)
	local p = {
		BackgroundTransparency = 1,
		FontFace = Fonts.Regular,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}
	for k, v in pairs(props) do p[k] = v end
	-- В macOS-стиле текст на 1px крупнее: так он чётче и читается как системный
	if Mac and not props._exact then p.TextSize += 1 end
	p._exact = nil
	return Create("TextLabel", p)
end

local order = 0
local function NextOrder()
	order += 1
	return order
end

local function SafeCall(fn, ...)
	if typeof(fn) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(fn, table.unpack(args, 1, args.n))
		if not ok then
			warn("[CrackHub] Ошибка в callback: " .. tostring(err))
		end
	end)
end

local function IsClick(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function Ripple(frame)
	local mouse = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local rel = mouse - frame.AbsolutePosition
	local size = math.max(frame.AbsoluteSize.X, frame.AbsoluteSize.Y) * 2.2
	local circle = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(rel.X, rel.Y),
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.7,
		ZIndex = 5,
		Parent = frame,
	}, { Corner(999) })
	Tween(circle, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }, 0.6)
	task.delay(0.6, function() circle:Destroy() end)
end

local function MakeDraggable(handle, target, conns)
	local dragging, startInput, startPos
	handle.InputBegan:Connect(function(input)
		if IsClick(input) then
			dragging = true
			startInput = input.Position
			startPos = target.Position
			local c
			c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					c:Disconnect()
				end
			end)
		end
	end)
	table.insert(conns, UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then
			local d = input.Position - startInput
			Tween(target, {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y),
			}, 0.12)
		end
	end))
end

local function OnDrag(button, conns, onUpdate, onEnd)
	local dragging = false
	button.InputBegan:Connect(function(input)
		if IsClick(input) then
			dragging = true
			onUpdate(input.Position)
		end
	end)
	table.insert(conns, UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then onUpdate(input.Position) end
	end))
	table.insert(conns, UserInputService.InputEnded:Connect(function(input)
		if dragging and IsClick(input) then
			dragging = false
			if onEnd then onEnd() end
		end
	end))
end

local function Hover(button, frame, normal, hover)
	local st = frame:FindFirstChildOfClass("UIStroke")
	if frame:GetAttribute("InGroup") then
		-- строка внутри карточки: мягкая светлая подсветка
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		button.MouseEnter:Connect(function() Tween(frame, { BackgroundTransparency = 0.93 }, 0.2) end)
		button.MouseLeave:Connect(function() Tween(frame, { BackgroundTransparency = 1 }, 0.2) end)
		return
	end
	button.MouseEnter:Connect(function()
		Tween(frame, { BackgroundColor3 = hover or Theme.ElementHover }, 0.2)
		if st then Tween(st, { Color = Theme.Accent, Transparency = 0.55 }, 0.25) end
	end)
	button.MouseLeave:Connect(function()
		Tween(frame, { BackgroundColor3 = normal or Theme.Element }, 0.2)
		if st then Tween(st, { Color = Theme.Stroke, Transparency = 0.35 }, 0.25) end
	end)
end

local function FirstChar(str)
	return str:match("^[%z\1-\127\194-\244][\128-\191]*") or "N"
end

--==============================================================
-- Окно
--==============================================================

-- ====================================================================
-- Бинды: маленькая «плашка клавиши» (— / Press... / W / MB1)
-- ====================================================================
local KeyShort = {
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
	LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter", Backspace = "Bksp", Escape = "Esc",
	CapsLock = "Caps", Delete = "Del", Insert = "Ins", PageUp = "PgUp", PageDown = "PgDn",
	Backquote = "`", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]",
	Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", BackSlash = "\\",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
	Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
}
local MouseShort = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local function NormalizeBind(v)
	if typeof(v) ~= "EnumItem" then return nil end
	if v.EnumType == Enum.KeyCode then return { Key = v } end
	if MouseShort[v] then return { Mouse = v } end
	return nil
end

local function BindName(b)
	if not b then return "—" end
	if b.Mouse then return MouseShort[b.Mouse] or b.Mouse.Name end
	return KeyShort[b.Key.Name] or b.Key.Name
end

local function BindMatches(b, input)
	if not b then return false end
	if b.Key then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == b.Key
	end
	return input.UserInputType == b.Mouse
end

-- parent — строка, x — смещение от правого края, initial — Enum.KeyCode / Enum.UserInputType / nil
-- cfg: OnChange(bind), OnPress(), KeyboardOnly
local function AddBindChip(parent, conns, x, initial, cfg)
	cfg = cfg or {}
	local bind = NormalizeBind(initial)
	local binding = false
	local lastAction = 0

	local chip = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, x, 0.5, 0),
		Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Background,
		AutoButtonColor = false,
		Text = "",
		FontFace = Fonts.Medium,
		TextSize = 11,
		TextColor3 = Theme.SubText,
		ZIndex = 3,
		Parent = parent,
	}, {
		Corner(6),
		Padding(0, 8, 0, 8),
		Create("UISizeConstraint", { MinSize = Vector2.new(32, 22) }),
	})
	local st = Stroke(Theme.Stroke, 1, 0.1)
	st.Parent = chip

	local function refresh()
		chip.Text = binding and "Press..." or BindName(bind)
		Tween(chip, { TextColor3 = binding and Theme.Accent or (bind and Theme.Text or Theme.SubText) }, 0.15)
		Tween(st, { Color = binding and Theme.Accent or Theme.Stroke }, 0.15)
	end

	local obj = { Frame = chip }
	function obj:Get() return bind end
	function obj:Set(v, silent)
		bind = NormalizeBind(v)
		refresh()
		if not silent and cfg.OnChange then SafeCall(cfg.OnChange, bind) end
	end

	chip.MouseEnter:Connect(function()
		if not binding then Tween(st, { Color = Theme.Accent, Transparency = 0.5 }, 0.15) end
	end)
	chip.MouseLeave:Connect(function()
		if not binding then Tween(st, { Color = Theme.Stroke, Transparency = 0.1 }, 0.15) end
	end)

	chip.MouseButton1Click:Connect(function()
		if binding or os.clock() - lastAction < 0.25 then return end
		binding = true
		refresh()
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gp)
			local t = input.UserInputType
			local finish, changed = false, false
			if t == Enum.UserInputType.Keyboard then
				if gp then return end
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					bind = nil
				else
					bind = { Key = input.KeyCode }
				end
				finish, changed = true, true
			elseif MouseShort[t] then
				if gp then
					finish = true -- клик по интерфейсу: отмена без изменений
				elseif not cfg.KeyboardOnly then
					bind = { Mouse = t }
					finish, changed = true, true
				end
			end
			if finish then
				binding = false
				lastAction = os.clock()
				conn:Disconnect()
				refresh()
				if changed and cfg.OnChange then SafeCall(cfg.OnChange, bind) end
			end
		end)
		table.insert(conns, conn)
	end)

	if cfg.OnPress then
		table.insert(conns, UserInputService.InputBegan:Connect(function(input, gp)
			if gp or binding or not bind then return end
			if os.clock() - lastAction < 0.15 then return end
			if BindMatches(bind, input) then SafeCall(cfg.OnPress) end
		end))
	end

	refresh()
	return obj
end

-- Плашка бинда сразу после названия (для слайдеров, списков, полей и т.д.)
local function AttachTitleBind(f, titleLbl, window, yOffset, cfg)
	local chip = AddBindChip(f, window.Connections, 0, cfg.Initial, cfg)
	chip.Frame.AnchorPoint = Vector2.new(0, 0.5)
	local function place()
		chip.Frame.Position = UDim2.fromOffset(14 + math.min(titleLbl.TextBounds.X, 220) + 10, yOffset)
	end
	titleLbl:GetPropertyChangedSignal("TextBounds"):Connect(place)
	place()
	return chip
end

-- Бинд включён у всех элементов по умолчанию.
-- Bind = false — выключить у одного; CreateWindow({ AutoBind = false }) — только там, где задан Bind.
local function WantsBind(window, o)
	if o.Bind == false then return false end
	if o.Bind == nil and window.AutoBind == false then return false end
	return true
end

local function MakeBind(self, o, obj, f, titleLbl, yOffset, onPress)
	if not WantsBind(self.Window, o) then return end
	obj.BindChip = AttachTitleBind(f, titleLbl, self.Window, yOffset, {
		Initial = (o.Bind ~= true and o.Bind) or nil,
		OnChange = function(b)
			obj.BindValue = b
			SafeCall(o.BindChanged, b)
		end,
		OnPress = onPress,
	})
	obj.BindValue = obj.BindChip:Get()
end

-- Нижний регистр с кириллицей (string.lower её не понимает)
local function Lower(s)
	local ok, res = pcall(function()
		local t = {}
		for _, c in utf8.codes(s) do
			if c >= 65 and c <= 90 then
				c += 32
			elseif c >= 0x410 and c <= 0x42F then
				c += 32
			elseif c == 0x401 then
				c = 0x451
			end
			t[#t + 1] = utf8.char(c)
		end
		return table.concat(t)
	end)
	return ok and res or string.lower(s)
end

function CrackHub:CreateWindow(opts)
	opts = opts or {}

	-- Style = "macOS" (по умолчанию) или "Neon"
	Mac = (opts.Style or "macOS") ~= "Neon"
	if Mac then
		for k, v in pairs(MacTheme) do Theme[k] = v end
		-- Чуть плотнее веса, чем по умолчанию: тонкий текст в Roblox мылится
		local SF = "rbxasset://fonts/families/BuilderSans.json"
		Fonts.Regular = Font.new(SF, Enum.FontWeight.Medium)
		Fonts.Medium  = Font.new(SF, Enum.FontWeight.SemiBold)
		Fonts.Bold    = Font.new(SF, Enum.FontWeight.Bold)
	end
	-- Свой шрифт: Font = "BuilderSans" / "Montserrat" / "Roboto" / "GothamSSm"
	if type(opts.Font) == "string" then
		local fam = "rbxasset://fonts/families/" .. opts.Font .. ".json"
		Fonts.Regular = Font.new(fam, Enum.FontWeight.Medium)
		Fonts.Medium  = Font.new(fam, Enum.FontWeight.SemiBold)
		Fonts.Bold    = Font.new(fam, Enum.FontWeight.Bold)
	end

	local themeOpt = opts.Theme
	if type(themeOpt) == "string" then themeOpt = CrackHub.Themes[themeOpt] end
	if type(themeOpt) == "table" then
		for k, v in pairs(themeOpt) do Theme[k] = v end
	end

	-- Цвет карточек-групп (отдельно от окна): CardColor = Color3
	if typeof(opts.CardColor) == "Color3" then Theme.Card = opts.CardColor end

	-- Цвет ТОЛЬКО элементов управления (тогглы, слайдеры, галочки и т.д.),
	-- не трогая цвет самого окна. ControlColor = Color3 или { Color3, Color3 }.
	local cc = opts.ControlColor
	if cc then
		if typeof(cc) == "Color3" then
			Theme.Accent, Theme.Accent2 = cc, cc
			Theme.ToggleOn = cc
		elseif type(cc) == "table" then
			Theme.Accent  = cc[1] or cc.Accent or Theme.Accent
			Theme.Accent2 = cc[2] or cc.Accent2 or Theme.Accent
			Theme.ToggleOn = Theme.Accent
		end
	end

	local title = opts.Title or "CrackHub"
	local subtitle = opts.Subtitle or "UI Library"
	local size = opts.Size or UDim2.fromOffset(600, 420)
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	local Window = { Tabs = {}, Connections = {}, Visible = true, Minimized = false }
	local conns = Window.Connections

	local Gui = Create("ScreenGui", {
		Name = "CrackHub",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})
	Window.Gui = Gui

	local Root = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.5, -size.Y.Offset / 2),
		Size = size,
		BackgroundTransparency = 1,
		Parent = Gui,
	})
	local Scale = Create("UIScale", { Scale = 0, Parent = Root })
	Window.ScaleObj = Scale
	Window.Cards = opts.Cards ~= false
	Window.AutoBind = opts.AutoBind ~= false
	Scale:GetPropertyChangedSignal("Scale"):Connect(function()
		local t = Window.ActiveTab
		if t and t._sync then t._sync() end
	end)

	-- Неоновое свечение акцентом (только в стиле Neon)
	if not Mac then
		for i = 1, 5 do
			Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, i * 6, 1, i * 6),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.965,
				BorderSizePixel = 0,
				ZIndex = 0,
				Parent = Root,
			}, { Corner(12 + i * 3) })
		end
	end

	local Main = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Background,
		ClipsDescendants = true,
		Parent = Root,
	}, {
		Corner(12),
		Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 200, 212)),
		}),
	})

	-- Переливающаяся градиентная рамка
	local MainStroke = Stroke(Color3.new(1, 1, 1), 1.5, 0.1)
	MainStroke.Parent = Main
	if Mac then
		MainStroke.Thickness = 1
		MainStroke.Color = Color3.fromRGB(88, 88, 92)
		MainStroke.Transparency = 0.2
	end
	local StrokeGrad = Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.Accent),
			ColorSequenceKeypoint.new(0.5, Theme.Stroke),
			ColorSequenceKeypoint.new(1, Theme.Accent2),
		}),
		Enabled = not Mac,
		Parent = MainStroke,
	})

	-- Внутренний блик по верхнему краю (эффект стекла)
	Create("Frame", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = Main,
	}, {
		Create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	})

	-- Мягкие цветные пятна на фоне
	local function Orb(color, pos, sz)
		return Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = pos,
			Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6015897843",
			ImageColor3 = color,
			ImageTransparency = 0.86,
			ZIndex = 0,
			Parent = Main,
		})
	end
	local Orb1 = Orb(Theme.Accent, UDim2.fromScale(0.85, 0.1), 420)
	local Orb2 = Orb(Theme.Accent2, UDim2.fromScale(0.15, 0.9), 360)
	local Orb3 = Orb(Theme.Accent, UDim2.fromScale(0.5, 0.5), 260)
	Orb3.ImageTransparency = 0.93
	if Mac then
		Orb1.Visible, Orb2.Visible, Orb3.Visible = false, false, false
	end

	-- Верхняя панель
	local Topbar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	local Logo = Create("Frame", {
		Position = UDim2.fromOffset(14, 11),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = Topbar,
	}, { Corner(8), AccentGradient(45) })
	Label({
		Text = FirstChar(title):upper(),
		FontFace = Fonts.Bold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = Logo,
	})

	local TitleLabel = Label({
		Text = title,
		FontFace = Fonts.Bold,
		TextSize = 14,
		Position = UDim2.fromOffset(52, 9),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = Topbar,
	})
	Create("UIGradient", {
		Color = ColorSequence.new(Theme.Text, Theme.Accent),
		Enabled = not Mac,
		Parent = TitleLabel,
	})
	local LogoGrad = Logo:FindFirstChildOfClass("UIGradient")
	local SubLabel = Label({
		Text = subtitle,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(52, 27),
		Size = UDim2.new(1, -150, 0, 14),
		Parent = Topbar,
	})

	-- macOS: название по центру, без логотипа
	if Mac then
		Logo.Visible = false
		TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
		TitleLabel.Position = UDim2.new(0.5, 0, 0, 9)
		TitleLabel.TextSize = 13
		SubLabel.AnchorPoint = Vector2.new(0.5, 0)
		SubLabel.Position = UDim2.new(0.5, 0, 0, 27)
		SubLabel.Size = UDim2.fromOffset(260, 14)
		SubLabel.TextXAlignment = Enum.TextXAlignment.Center
		SubLabel.TextSize = 11
	end

	local function TopButton(text, x, hoverColor)
		local b = Create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, x, 0.5, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = text,
			FontFace = Fonts.Medium,
			TextSize = 18,
			TextColor3 = Theme.SubText,
			Parent = Topbar,
		}, { Corner(8) })
		b.MouseEnter:Connect(function()
			Tween(b, { BackgroundTransparency = 0, TextColor3 = hoverColor or Theme.Text }, 0.2)
		end)
		b.MouseLeave:Connect(function()
			Tween(b, { BackgroundTransparency = 1, TextColor3 = Theme.SubText }, 0.2)
		end)
		return b
	end

	local CloseBtn = TopButton("×", -12, Theme.Danger)
	local MinBtn = TopButton("–", -44)

	-- macOS «светофор»: закрыть / свернуть / развернуть
	if Mac then
		CloseBtn.Visible, MinBtn.Visible = false, false
		local Lights = Create("Frame", {
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(0, 60, 1, 0),
			BackgroundTransparency = 1,
			Parent = Topbar,
		}, {
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local symbols = {}
		local function Light(color, sym, ord, cb)
			local b = Create("TextButton", {
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = color,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = ord,
				Parent = Lights,
			}, { Corner(6), Stroke(Color3.new(0, 0, 0), 1, 0.8) })
			local l = Label({
				Text = sym,
				FontFace = Fonts.Bold,
				TextSize = 11,
				TextColor3 = Color3.fromRGB(60, 25, 15),
				TextTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, 0, 1, -1),
				Parent = b,
			})
			table.insert(symbols, l)
			local sc = Create("UIScale", { Parent = b })
			b.MouseButton1Down:Connect(function() Tween(sc, { Scale = 0.85 }, 0.1) end)
			b.MouseButton1Up:Connect(function() Tween(sc, { Scale = 1 }, 0.25, Enum.EasingStyle.Back) end)
			b.MouseButton1Click:Connect(cb)
		end
		local zoomed = false
		Light(Color3.fromRGB(255, 95, 87), "×", 1, function() Window:Destroy() end)
		Light(Color3.fromRGB(254, 188, 46), "–", 2, function() Window:Hide() end)
		Light(Color3.fromRGB(40, 200, 64), "+", 3, function()
			if Window.Minimized then return end
			zoomed = not zoomed
			Tween(Root, {
				Size = zoomed and UDim2.fromOffset(size.X.Offset * 1.2, size.Y.Offset * 1.2) or size,
			}, 0.45)
		end)
		Lights.MouseEnter:Connect(function()
			for _, l in ipairs(symbols) do Tween(l, { TextTransparency = 0.2 }, 0.15) end
		end)
		Lights.MouseLeave:Connect(function()
			for _, l in ipairs(symbols) do Tween(l, { TextTransparency = 1 }, 0.15) end
		end)
	end

	-- Поиск по элементам текущей вкладки
	local Search = Create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, Mac and -12 or -80, 0.5, 0),
		Size = UDim2.fromOffset(150, 28),
		BackgroundColor3 = Theme.Element,
		Text = "",
		PlaceholderText = "Поиск",
		PlaceholderColor3 = Theme.SubText,
		TextColor3 = Theme.Text,
		FontFace = Fonts.Regular,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		Parent = Topbar,
	}, { Corner(8), Padding(0, 10, 0, 28) })
	local SearchIcon = Icon("search", Search, Theme.SubText, 14)
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.Position = UDim2.new(0, -20, 0.5, 0)
	local SearchStroke = Stroke(Theme.Stroke, 1, 0.3)
	SearchStroke.Parent = Search
	Search.Focused:Connect(function()
		Tween(SearchStroke, { Color = Theme.Accent, Transparency = 0 }, 0.2)
		Tween(Search, { Size = UDim2.fromOffset(180, 28) }, 0.3)
	end)
	Search.FocusLost:Connect(function()
		Tween(SearchStroke, { Color = Theme.Stroke, Transparency = 0.3 }, 0.2)
		Tween(Search, { Size = UDim2.fromOffset(150, 28) }, 0.3)
	end)

	-- Фильтр работает по реестру элементов вкладки (tab._reg), а не по всем потомкам.
	-- Сворачивание больше не использует Visible, поэтому фильтр ничего не «воскрешает».
	local function ApplyFilter()
		local tab = Window.ActiveTab
		if not tab or not tab._reg then return end
		local q = Lower(Search.Text)
		local reg = tab._reg
		for i = 1, #reg do
			local e = reg[i]
			local want = q == "" or string.find(e[2], q, 1, true) ~= nil
			if e[1].Visible ~= want then e[1].Visible = want end
		end
	end
	Search:GetPropertyChangedSignal("Text"):Connect(ApplyFilter)

	-- Линия под шапкой с градиентным свечением
	Create("Frame", {
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = Main,
	})
	Create("Frame", {
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 2,
		Visible = not Mac,
		Parent = Main,
	}, {
		Create("UIGradient", {
			Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	})

	MakeDraggable(Topbar, Root, conns)

	-- Индикатор FPS в шапке
	local FpsLabel, FpsDot
	if opts.ShowFPS ~= false then
		local Chip = Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, Mac and -172 or -240, 0.5, 0),
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Element,
			Parent = Topbar,
		}, { Corner(12), Stroke(Theme.Stroke, 1, 0.4), Padding(0, 10, 0, 22) })
		FpsDot = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -13, 0.5, 0),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = Color3.fromRGB(70, 220, 140),
			Parent = Chip,
		}, { Corner(3) })
		FpsLabel = Label({
			Text = "60 FPS",
			FontFace = Fonts.Medium,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = Chip,
		})
	end

	-- Живой фон: вращающиеся градиенты, плавающие пятна, FPS
	local spin, t, frames, fpsTimer = 0, 0, 0, 0
	table.insert(conns, RunService.Heartbeat:Connect(function(dt)
		if not Root.Visible or Window.Minimized then return end
		t += dt
		spin = (spin + dt * 45) % 360
		StrokeGrad.Rotation = spin
		LogoGrad.Rotation = spin
		Orb1.Position = UDim2.fromScale(0.85 + math.sin(t * 0.4) * 0.12, 0.1 + math.cos(t * 0.33) * 0.15)
		Orb2.Position = UDim2.fromScale(0.15 + math.cos(t * 0.35) * 0.12, 0.9 + math.sin(t * 0.45) * 0.12)
		Orb3.Position = UDim2.fromScale(0.5 + math.sin(t * 0.25) * 0.25, 0.5 + math.cos(t * 0.3) * 0.2)

		if FpsLabel then
			frames += 1
			fpsTimer += dt
			FpsDot.BackgroundTransparency = 0.25 + math.sin(t * 4) * 0.25
			if fpsTimer >= 0.5 then
				local fps = math.floor(frames / fpsTimer + 0.5)
				frames, fpsTimer = 0, 0
				FpsLabel.Text = fps .. " FPS"
				FpsDot.BackgroundColor3 = fps >= 50 and Color3.fromRGB(70, 220, 140)
					or fps >= 30 and Color3.fromRGB(255, 190, 70)
					or Theme.Danger
			end
		end
	end))

	-- Боковая панель
	local Sidebar = Create("Frame", {
		Position = UDim2.fromOffset(0, 51),
		Size = UDim2.new(0, 170, 1, -51),
		BackgroundColor3 = Theme.Sidebar or Theme.Background,
		BackgroundTransparency = Mac and 0 or 1,
		BorderSizePixel = 0,
		Parent = Main,
	})
	Create("Frame", {
		Position = UDim2.fromOffset(170, 51),
		Size = UDim2.new(0, 1, 1, -51),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = Main,
	})

	local TabList = Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -100),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 2,
		Parent = Sidebar,
	}, { List(4), Padding(10, 10, 10, 10) })

	-- Скользящая подсветка активной вкладки
	local TabHighlight = Create("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(150, 36),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = Sidebar,
	}, {
		Corner(8),
		Create("UIGradient", {
			Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
			Transparency = NumberSequence.new(0.72, 0.96),
		}),
	})
	local THStroke = Stroke(Color3.new(1, 1, 1), 1, 1)
	THStroke.Parent = TabHighlight
	Create("UIGradient", {
		Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
		Transparency = NumberSequence.new(0.2, 0.9),
		Parent = THStroke,
	})
	local THIndicator = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 18),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = TabHighlight,
	}, { Corner(2), AccentGradient(90) })

	if Mac then
		local g = TabHighlight:FindFirstChildOfClass("UIGradient")
		g.Enabled = false
		TabHighlight.BackgroundColor3 = Theme.Accent
		THStroke.Enabled = false
		THIndicator.Visible = false
	end

	local function MoveHighlight(index)
		local target = UDim2.fromOffset(10, 10 + (index - 1) * 40 - TabList.CanvasPosition.Y)
		if TabHighlight.BackgroundTransparency >= 0.99 then
			TabHighlight.Position = target
		end
		Tween(TabHighlight, { Position = target, BackgroundTransparency = 0 }, 0.45)
		Tween(THStroke, { Transparency = 0 }, 0.3)
		THIndicator.BackgroundTransparency = 0
		THIndicator.Size = UDim2.fromOffset(3, 4)
		Tween(THIndicator, { Size = UDim2.fromOffset(3, 18) }, 0.55, Enum.EasingStyle.Back)
	end

	-- Карточка игрока
	local UserCard = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10),
		Size = UDim2.new(1, -20, 0, 44),
		BackgroundColor3 = Theme.Element,
		Parent = Sidebar,
	}, { Corner(10), Stroke(Theme.Stroke, 1, 0.3) })
	local Avatar = Create("ImageLabel", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Background,
		Parent = UserCard,
	}, { Corner(16), Stroke(Theme.Accent, 1.5, 0.2) })
	Label({
		Text = LocalPlayer.DisplayName,
		FontFace = Fonts.Bold,
		TextSize = 12,
		Position = UDim2.fromOffset(46, 7),
		Size = UDim2.new(1, -52, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = UserCard,
	})
	Label({
		Text = "@" .. LocalPlayer.Name,
		TextSize = 11,
		TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(46, 23),
		Size = UDim2.new(1, -52, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = UserCard,
	})
	task.spawn(function()
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok then Avatar.Image = img end
	end)

	-- Плашка «клавиша меню» над карточкой игрока (клик — переназначить)
	local MenuChip
	local MenuRow = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -62),
		Size = UDim2.new(1, -20, 0, 26),
		BackgroundTransparency = 1,
		Parent = Sidebar,
	})
	Label({
		Text = "Клавиша меню",
		TextSize = 11,
		TextColor3 = Theme.SubText,
		Size = UDim2.new(1, -64, 1, 0),
		Parent = MenuRow,
	})
	MenuChip = AddBindChip(MenuRow, conns, 0, toggleKey, {
		KeyboardOnly = true,
		OnChange = function(b)
			if b and b.Key then
				Window:SetToggleKey(b.Key)
			else
				MenuChip:Set(toggleKey, true) -- очистка не разрешена: возвращаем текущую
			end
		end,
	})

	-- Область контента
	local Content = Create("CanvasGroup", {
		Position = UDim2.fromOffset(171, 51),
		Size = UDim2.new(1, -171, 1, -51),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		Parent = Main,
	})

	--------------------------------------------------------------
	-- Поведение окна
	--------------------------------------------------------------

	-- Размытие. BlurMode = "Window" (по умолчанию): стекло только за окном
	--           BlurMode = "Screen": размывается весь экран
	-- BlurSize = 0..56 (или Blur = true → 14)
	local Lighting = game:GetService("Lighting")
	local blurMode = opts.BlurMode or "Window"
	local blurSize = math.clamp(opts.BlurSize or (opts.Blur and 14 or 0), 0, 56)
	local blurActive = false
	local BlurFx, DofFx, GlassPart

	if blurMode == "Screen" then
		BlurFx = Create("BlurEffect", { Size = 0, Name = "CrackHubBlur", Parent = Lighting })
	else
		DofFx = Create("DepthOfFieldEffect", {
			Name = "CrackHubDOF",
			FarIntensity = 0,
			NearIntensity = 0,
			FocusDistance = 0.5,
			InFocusRadius = 0.1,
			Parent = Lighting,
		})
		GlassPart = Create("Part", {
			Name = "CrackHubGlass",
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			Locked = true,
			CastShadow = false,
			Material = Enum.Material.Glass,
			Color = Color3.new(0, 0, 0),
			Transparency = 0.98,
			Size = Vector3.new(1, 1, 0.001),
		})
	end

	-- Подгоняем стеклянную деталь под окно прямо перед камерой
	local function UpdateGlass()
		local cam = workspace.CurrentCamera
		if not cam or not GlassPart then return end
		local inset = GuiService:GetGuiInset()
		local pad = 8
		local tl = Main.AbsolutePosition + inset + Vector2.new(pad, pad)
		local br = Main.AbsolutePosition + Main.AbsoluteSize + inset - Vector2.new(pad, pad)
		if br.X <= tl.X or br.Y <= tl.Y then return end

		local okN, np = pcall(function() return cam.NearPlaneZ end)
		local dist = (okN and math.abs(np) or 0.1) + 0.05
		DofFx.FocusDistance = dist + 0.5

		local cf = cam.CFrame
		local look = cf.LookVector
		local function toWorld(v)
			local ray = cam:ViewportPointToRay(v.X, v.Y)
			local d = ray.Direction
			return cf.Position + d * (dist / d:Dot(look))
		end
		local a, b = toWorld(tl), toWorld(br)
		local diag = b - a
		GlassPart.Size = Vector3.new(
			math.max(math.abs(diag:Dot(cf.RightVector)), 0.001),
			math.max(math.abs(diag:Dot(cf.UpVector)), 0.001),
			0.001
		)
		GlassPart.CFrame = CFrame.new((a + b) / 2) * cf.Rotation
	end

	local function ApplyBlur(active, time)
		blurActive = active
		if blurMode == "Screen" then
			Tween(BlurFx, { Size = active and blurSize or 0 }, time or 0.4)
		else
			local on = active and blurSize > 0
			if on then
				GlassPart.Parent = workspace.CurrentCamera
				UpdateGlass()
			end
			Tween(DofFx, { NearIntensity = on and math.clamp(blurSize / 30, 0, 1) or 0 }, time or 0.4)
			if not on then
				task.delay((time or 0.4) + 0.05, function()
					if not blurActive or blurSize <= 0 then GlassPart.Parent = nil end
				end)
			end
		end
	end

	table.insert(conns, RunService.RenderStepped:Connect(function()
		if blurActive and GlassPart and GlassPart.Parent and Root.Visible then
			UpdateGlass()
		end
	end))

	function Window:SetBlur(n)
		blurSize = math.clamp(n, 0, 56)
		if self.Visible and Root.Visible then ApplyBlur(true, 0.25) end
	end

	-- Прозрачность фона окна: Transparency = 0 (сплошное) .. 0.9 (почти стекло)
	local glass = 0
	function Window:SetTransparency(v)
		glass = math.clamp(v, 0, 0.9)
		Tween(Main, { BackgroundTransparency = glass }, 0.2)
		if Mac then Tween(Sidebar, { BackgroundTransparency = glass }, 0.2) end
	end
	if opts.Transparency then
		Window:SetTransparency(opts.Transparency)
	elseif blurSize > 0 then
		Window:SetTransparency(0.18) -- чтобы размытие было видно сквозь окно
	end

	local HudArrow, HudKeyLabel

	function Window:SetToggleKey(key)
		toggleKey = key
		if MenuChip then MenuChip:Set(key, true) end
		if HudKeyLabel then HudKeyLabel.Text = BindName({ Key = key }) end
	end

	function Window:SetVisible(state)
		self.Visible = state
		if HudArrow then Tween(HudArrow, { Rotation = state and 180 or 0 }, 0.3) end
		ApplyBlur(state, 0.4)
		if state then
			Root.Visible = true
			Tween(Scale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
		else
			local t = Tween(Scale, { Scale = 0 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			t.Completed:Connect(function()
				if not self.Visible then Root.Visible = false end
			end)
		end
	end

	function Window:Toggle()
		self:SetVisible(not self.Visible)
	end

	-- Полностью скрыть окно (вернуть: клавиша ToggleKey, по умолчанию RightShift)
	local hintShown = false
	function Window:Hide()
		self:SetVisible(false)
		if not hintShown then
			hintShown = true
			CrackHub:Notify({
				Title = "Меню скрыто",
				Content = "Нажми " .. BindName({ Key = toggleKey }) .. ", чтобы открыть снова",
				Duration = 3,
			})
		end
	end

	function Window:Minimize()
		self.Minimized = not self.Minimized
		Tween(Root, {
			Size = self.Minimized and UDim2.new(size.X.Scale, size.X.Offset, 0, 50) or size,
		}, 0.4)
		MinBtn.Text = self.Minimized and "+" or "–"
	end

	function Window:Destroy()
		for _, c in ipairs(conns) do c:Disconnect() end
		Tween(Scale, { Scale = 0 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		ApplyBlur(false, 0.3)
		task.delay(0.32, function()
			Gui:Destroy()
			if BlurFx then BlurFx:Destroy() end
			if DofFx then DofFx:Destroy() end
			if GlassPart then GlassPart:Destroy() end
		end)
	end

	function Window:Notify(o)
		return CrackHub:Notify(o)
	end

	CloseBtn.MouseButton1Click:Connect(function() Window:Destroy() end)
	MinBtn.MouseButton1Click:Connect(function() Window:Hide() end)

	table.insert(conns, UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == toggleKey then
			Window:Toggle()
		end
	end))

	-- HUD-плашка слева сверху: название, клавиша меню, кнопка показать/скрыть
	if opts.HUD ~= false and not UserInputService.TouchEnabled then
		local Hud = Create("Frame", {
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 0.12,
			Parent = Gui,
		}, {
			Corner(10),
			Stroke(Theme.Stroke, 1, 0.2),
			Padding(0, 6, 0, 6),
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local HudLogo = Create("Frame", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Color3.new(1, 1, 1),
			LayoutOrder = 1,
			Parent = Hud,
		}, { Corner(6), AccentGradient(45) })
		Label({
			Text = FirstChar(title):upper(),
			FontFace = Fonts.Bold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = HudLogo,
		})
		Label({
			Text = title,
			FontFace = Fonts.Medium,
			TextSize = 12,
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Parent = Hud,
		})
		local KeyBox = Create("Frame", {
			Size = UDim2.fromOffset(0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Element,
			LayoutOrder = 3,
			Parent = Hud,
		}, { Corner(6), Stroke(Theme.Stroke, 1, 0.2), Padding(0, 7, 0, 7) })
		HudKeyLabel = Label({
			Text = BindName({ Key = toggleKey }),
			FontFace = Fonts.Medium,
			TextSize = 10,
			TextColor3 = Theme.SubText,
			Size = UDim2.fromOffset(0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = KeyBox,
		})
		local ArrowBtn = Create("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Theme.Element,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = 4,
			Parent = Hud,
		}, { Corner(6), Stroke(Theme.Stroke, 1, 0.2) })
		HudArrow = Icon("chevron", ArrowBtn, Theme.Accent, 14)
		HudArrow.AnchorPoint = Vector2.new(0.5, 0.5)
		HudArrow.Position = UDim2.fromScale(0.5, 0.5)
		HudArrow.Rotation = 180
		ArrowBtn.MouseButton1Click:Connect(function() Window:Toggle() end)
		ArrowBtn.MouseEnter:Connect(function() Tween(ArrowBtn, { BackgroundColor3 = Theme.ElementHover }, 0.15) end)
		ArrowBtn.MouseLeave:Connect(function() Tween(ArrowBtn, { BackgroundColor3 = Theme.Element }, 0.15) end)
	end

	-- Плавающая кнопка для телефонов
	if opts.MobileButton ~= false and UserInputService.TouchEnabled then
		local MobileBtn = Create("TextButton", {
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.fromOffset(46, 46),
			BackgroundColor3 = Color3.new(1, 1, 1),
			AutoButtonColor = false,
			Text = FirstChar(title):upper(),
			FontFace = Fonts.Bold,
			TextSize = 18,
			TextColor3 = Color3.new(1, 1, 1),
			Parent = Gui,
		}, { Corner(23), AccentGradient(45), Stroke(Color3.new(1, 1, 1), 1.5, 0.6) })
		MakeDraggable(MobileBtn, MobileBtn, conns)
		MobileBtn.MouseButton1Click:Connect(function() Window:Toggle() end)
	end

	--------------------------------------------------------------
	-- Вкладки
	--------------------------------------------------------------

	-- Вкладка конфигов (сохранить / загрузить / удалить / импорт по коду)
	function Window:CreateConfigTab(o)
		return CrackHub._BuildConfigTab(self, o or {})
	end

	function Window:CreateTab(name, icon)
		local Tab = setmetatable({ Window = Window, Name = name, Active = false }, Container)
		local index = #Window.Tabs + 1

		local Btn = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = NextOrder(),
			Parent = TabList,
		}, { Corner(8) })
		local BtnStroke = Stroke(Theme.Stroke, 1, 1)
		BtnStroke.Parent = Btn

		local Indicator = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = Btn,
		}, { Corner(2), AccentGradient(90) })

		local textX = 14
		local Icon
		if icon then
			Icon = Create("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				BackgroundTransparency = 1,
				Image = icon,
				ImageColor3 = Theme.SubText,
				Parent = Btn,
			})
			textX = 36
		end

		local TabLabel = Label({
			Text = name,
			FontFace = Fonts.Medium,
			TextSize = 13,
			TextColor3 = Theme.SubText,
			Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -textX - 8, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = Btn,
		})

		local Page = Create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarImageColor3 = Mac and Color3.fromRGB(150, 150, 156) or Theme.Accent,
			ScrollBarImageTransparency = 0.45,
			ScrollBarThickness = 4,
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Visible = false,
			Parent = Content,
		}, { List(8), Padding(16, 16, 16, 16) })
		Tab.Holder = Page
		Tab._isTab = true
		Tab._reg = {}

		-- Размер холста считаем сами по высоте контента. AutomaticCanvasSize у вложенных
		-- AutomaticSize-блоков иногда не уменьшается после сворачивания и оставляет
		-- пустой «хвост». Так холст каждый кадр следует за плавной анимацией.
		local PageLayout = Page:FindFirstChildOfClass("UIListLayout")
		local function SyncCanvas()
			local sc = Window.ScaleObj and Window.ScaleObj.Scale or 1
			if sc < 0.05 then sc = 1 end
			Page.CanvasSize = UDim2.fromOffset(0, PageLayout.AbsoluteContentSize.Y / sc + 32)
		end
		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncCanvas)
		Tab._sync = SyncCanvas
		SyncCanvas()

		local PageTitle = Label({
			Text = name,
			FontFace = Fonts.Bold,
			TextSize = 22,
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = NextOrder(),
			Parent = Page,
		})
		Create("UIGradient", {
			Color = ColorSequence.new(Theme.Text, Theme.Accent),
		Enabled = not Mac,
			Parent = PageTitle,
		})

		function Tab:_SetActive(active)
			self.Active = active
			if active then
				Window.ActiveTab = Tab
				ApplyFilter()
				if Tab._sync then Tab._sync() end
				Content.GroupTransparency = 1
				Tween(Content, { GroupTransparency = 0 }, 0.35)
				Page.Visible = true
				Page.Position = UDim2.fromOffset(0, 16)
				Tween(Page, { Position = UDim2.new() }, 0.4)
			else
				Page.Visible = false
			end
			if active then
				MoveHighlight(index)
				Tween(Btn, { BackgroundTransparency = 1 }, 0.2)
			end
			Tween(TabLabel, { TextColor3 = active and Theme.Text or Theme.SubText }, 0.25)
			if Icon then
				Tween(Icon, { ImageColor3 = active and (Mac and Theme.Text or Theme.Accent) or Theme.SubText }, 0.25)
			end
		end

		function Tab:Select()
			for _, t in ipairs(Window.Tabs) do
				if t ~= Tab and t.Active then t:_SetActive(false) end
			end
			if not Tab.Active then Tab:_SetActive(true) end
		end

		Btn.MouseButton1Click:Connect(function() Tab:Select() end)
		Btn.BackgroundColor3 = Color3.new(1, 1, 1)
		Btn.MouseEnter:Connect(function()
			if not Tab.Active then
				Tween(TabLabel, { TextColor3 = Theme.Text }, 0.2)
				Tween(Btn, { BackgroundTransparency = 0.93 }, 0.2)
			end
		end)
		Btn.MouseLeave:Connect(function()
			Tween(Btn, { BackgroundTransparency = 1 }, 0.2)
			if not Tab.Active then Tween(TabLabel, { TextColor3 = Theme.SubText }, 0.2) end
		end)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then Tab:Select() end
		return Tab
	end

	-- Интро-заставка
	local function PlayIntro()
		local Splash = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Name = "CrackHubSplash",
			Size = UDim2.fromOffset(260, 124),
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 1,
			Parent = Gui,
		}, { Corner(14) })
		local sStroke = Stroke(Theme.Accent, 1.5, 1)
		sStroke.Parent = Splash
		local sScale = Create("UIScale", { Scale = 0.9, Parent = Splash })
		local sLogo = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 20),
			Size = UDim2.fromOffset(42, 42),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Parent = Splash,
		}, { Corner(12), AccentGradient(45) })
		local sLetter = Label({
			Text = FirstChar(title):upper(),
			FontFace = Fonts.Bold,
			TextSize = 20,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = sLogo,
		})
		local sTitle = Label({
			Text = title,
			FontFace = Fonts.Bold,
			TextSize = 15,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(0, 70),
			Size = UDim2.new(1, 0, 0, 18),
			Parent = Splash,
		})
		local track = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 100),
			Size = UDim2.fromOffset(160, 3),
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 1,
			Parent = Splash,
		}, { Corner(2) })
		local bar = Create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = track,
		}, { Corner(2), AccentGradient(0) })

		Tween(Splash, { BackgroundTransparency = 0 }, 0.4)
		Tween(sStroke, { Transparency = 0.4 }, 0.4)
		Tween(sScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
		Tween(sLogo, { BackgroundTransparency = 0 }, 0.4)
		Tween(sLetter, { TextTransparency = 0 }, 0.4)
		Tween(sTitle, { TextTransparency = 0 }, 0.4)
		Tween(track, { BackgroundTransparency = 0 }, 0.4)
		task.wait(0.3)
		Tween(bar, { Size = UDim2.fromScale(1, 1) }, 1.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
		task.wait(1.2)

		for _, obj in ipairs({ Splash, sLogo, track, bar }) do
			Tween(obj, { BackgroundTransparency = 1 }, 0.3)
		end
		Tween(sLetter, { TextTransparency = 1 }, 0.3)
		Tween(sTitle, { TextTransparency = 1 }, 0.3)
		Tween(sStroke, { Transparency = 1 }, 0.3)
		Tween(sScale, { Scale = 1.08 }, 0.3)
		task.wait(0.3)
		Splash:Destroy()
	end

	-- Анимация появления (после интро)
	Root.Visible = false
	task.spawn(function()
		-- Если интро упадёт с ошибкой, окно всё равно откроется
		if opts.Intro ~= false then
			local ok, err = pcall(PlayIntro)
			if not ok then
				warn("[CrackHub] Интро пропущено: " .. tostring(err))
				local leftover = Gui:FindFirstChild("CrackHubSplash")
				if leftover then leftover:Destroy() end
			end
		end
		Root.Visible = Window.Visible
		if Window.Visible then
			Tween(Scale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
			ApplyBlur(true, 0.6)
		end
	end)

	return Window
end

--==============================================================
-- Элементы
--==============================================================

local function ElementBase(container, height, name, desc)
	local inGroup = container._group
	if container._isTab then container._cols = nil end
	local children = { Corner(8) }
	if not inGroup then
		table.insert(children, Stroke(Theme.Stroke, 1, 0.35))
		table.insert(children, Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(226, 226, 232)),
		}))
	end
	local f = Create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = inGroup and 1 or 0,
		LayoutOrder = NextOrder(),
		Parent = container.Holder,
	}, children)
	f:SetAttribute("CrackHubName", name or "")
	f:SetAttribute("InGroup", inGroup and true or false)
	if container._reg then
		table.insert(container._reg, { f, Lower(name or "") })
	end

	local title = Label({
		Text = name or "",
		FontFace = Fonts.Medium,
		TextSize = 13,
		Position = UDim2.fromOffset(14, desc and 9 or 0),
		Size = UDim2.new(1, inGroup and -70 or -170, 0, desc and 18 or height),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = f,
	})
	if desc then
		Label({
			Text = desc,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			Position = UDim2.fromOffset(14, 28),
			Size = UDim2.new(1, inGroup and -70 or -170, 0, 15),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = f,
		})
	end
	return f, title
end

local function ClickArea(parent, height)
	return Create("TextButton", {
		Size = height and UDim2.new(1, 0, 0, height) or UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = parent,
	})
end

local function RegisterFlag(o, obj)
	if o.Flag then CrackHub.Flags[o.Flag] = obj end
end

-- Разделитель --------------------------------------------------
function Container:AddDivider()
	Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		LayoutOrder = NextOrder(),
		Parent = self.Holder,
	})
end

-- Прогресс-бар -------------------------------------------------
function Container:AddProgress(o)
	o = o or {}
	local P = { Value = o.Default or 0 }
	local f = ElementBase(self, 46, o.Name)
	f:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -90, 0, 28)
	local pct = Label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 0),
		Size = UDim2.fromOffset(70, 28),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		Parent = f,
	})
	local bar = Create("Frame", {
		Position = UDim2.new(0, 14, 1, -14),
		Size = UDim2.new(1, -28, 0, 6),
		BackgroundColor3 = Theme.Background,
		Parent = f,
	}, { Corner(3) })
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = bar,
	}, { Corner(3), AccentGradient(0) })
	function P:Set(v)
		v = math.clamp(v, 0, 1)
		self.Value = v
		Tween(fill, { Size = UDim2.fromScale(v, 1) }, 0.4)
		pct.Text = math.floor(v * 100 + 0.5) .. "%"
	end
	P:Set(P.Value)
	RegisterFlag(o, P)
	return P
end

-- Плавно сворачиваемый блок.
-- Анимируется высота ВНЕШНЕГО контейнера (outer: карточка или секция). Пока блок свёрнут
-- или анимируется, у него жёсткий размер — поэтому «хвост» от вложенных AutomaticSize
-- (тёмный пустой промежуток) остаться не может. После раскрытия возвращается авторазмер,
-- и выпадающие списки внутри раздвигают блок как обычно.
--   collapsedH — высота свёрнутого блока (шапка), gap — отступ между шапкой и контентом
local function CollapsibleBody(window, outer, collapsedH, gap, holderProps, bodyChildren)
	outer.ClipsDescendants = true

	local cfg = {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}
	for k, v in pairs(holderProps or {}) do cfg[k] = v end
	local holder = Create("Frame", cfg)
	local body = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = holder,
	}, bodyChildren)

	local ctl = { Collapsed = false }
	local token = 0

	-- AbsoluteSize учитывает UIScale окна, а Size.Offset — нет
	local function unscale(px)
		local sc = window and window.ScaleObj and window.ScaleObj.Scale or 1
		return px / math.max(sc, 0.01)
	end

	function ctl:Set(collapsed)
		if collapsed == self.Collapsed then return end
		self.Collapsed = collapsed
		token += 1
		local my = token

		outer.Size = UDim2.new(1, 0, 0, unscale(outer.AbsoluteSize.Y))
		outer.AutomaticSize = Enum.AutomaticSize.None
		local target = collapsed and collapsedH or (collapsedH + gap + unscale(body.AbsoluteSize.Y))

		local tw = Tween(outer, { Size = UDim2.new(1, 0, 0, target) }, collapsed and 0.28 or 0.34, Enum.EasingStyle.Quint)
		tw.Completed:Connect(function()
			if my ~= token or collapsed then return end
			outer.Size = UDim2.new(1, 0, 0, 0)
			outer.AutomaticSize = Enum.AutomaticSize.Y
		end)
	end

	return holder, body, ctl
end

-- Секция -------------------------------------------------------
-- На вкладке секция — это карточка (как AddGroup), поэтому везде одинаковый вид.
-- Старый плоский вариант: AddPlainSection. Отключить: CreateWindow({ Cards = false })
function Container:AddSection(name, fullWidth)
	if self._isTab and self.Window.Cards ~= false then
		return self:AddGroup(name, fullWidth)
	end
	return self:AddPlainSection(name)
end

function Container:AddPlainSection(name)
	if self._isTab then self._cols = nil end
	local sec = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextOrder(),
		Parent = self.Holder,
	}, { List(6), Padding(6, 0, 0, 0) })

	local head = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = 0,
		Parent = sec,
	})
	Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = head,
	}, { Corner(3), AccentGradient(45) })
	Label({
		Text = string.upper(name),
		FontFace = Fonts.Bold,
		TextSize = 11,
		TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = head,
	})
	local chevron = Icon("chevron", head, Theme.SubText, 14)
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -4, 0.5, 0)
	local _, body, ctl = CollapsibleBody(self.Window, sec, 28, 6, { LayoutOrder = 1, Parent = sec }, { List(6) })
	head.MouseEnter:Connect(function() IconColor(chevron, Theme.Text) end)
	head.MouseLeave:Connect(function() IconColor(chevron, Theme.SubText) end)
	head.MouseButton1Click:Connect(function()
		ctl:Set(not ctl.Collapsed)
		Tween(chevron, { Rotation = ctl.Collapsed and -90 or 0 }, 0.3, Enum.EasingStyle.Back)
	end)

	return setmetatable({ Holder = body, Window = self.Window, _reg = self._reg }, Container)
end

-- Колонки: вернёт массив контейнеров, стоящих в ряд
-- local left, right = tab:AddColumns(2)
function Container:AddColumns(n)
	n = n or 2
	local gap = 12
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextOrder(),
		Parent = self.Holder,
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),
	})
	local cols = {}
	for i = 1, n do
		local col = Create("Frame", {
			Size = UDim2.new(1 / n, -gap * (n - 1) / n, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = i,
			Parent = row,
		}, { List(10) })
		cols[i] = setmetatable({ Holder = col, Window = self.Window, _reg = self._reg }, Container)
	end
	return table.unpack(cols)
end

-- Группа-карточка: панель другого цвета с заголовком; внутри — строки
-- local g = col:AddGroup("World");  g:AddToggle(...)
function Container:AddGroup(name, fullWidth)
	-- На вкладке группы сами раскладываются в 2 столбца (fullWidth = true → на всю ширину)
	local parentHolder = self.Holder
	if self._isTab and not fullWidth then
		if not self._cols then
			local a, b = self:AddColumns(2)
			self._cols = { a, b }
			self._colN = 0
		end
		self._colN += 1
		parentHolder = self._cols[(self._colN - 1) % 2 + 1].Holder
	elseif self._isTab then
		self._cols = nil
	end

	local card = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card or Theme.Element,
		BackgroundTransparency = 0.12,
		LayoutOrder = NextOrder(),
		Parent = parentHolder,
	}, { Corner(12), Stroke(Theme.Stroke, 1, 0.3) })

	local head = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = card,
	})
	Label({
		Text = name,
		FontFace = Fonts.Bold,
		TextSize = 13,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -44, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = head,
	})
	local chevron = Icon("chevron", head, Theme.SubText, 14)
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -14, 0.5, 0)

	local _, body, ctl = CollapsibleBody(
		self.Window,
		card, 40, 0,
		{ Position = UDim2.fromOffset(0, 40), Parent = card },
		{ List(2), Padding(0, 12, 12, 12) }
	)
	head.MouseEnter:Connect(function() IconColor(chevron, Theme.Text) end)
	head.MouseLeave:Connect(function() IconColor(chevron, Theme.SubText) end)
	head.MouseButton1Click:Connect(function()
		ctl:Set(not ctl.Collapsed)
		Tween(chevron, { Rotation = ctl.Collapsed and -90 or 0 }, 0.3, Enum.EasingStyle.Back)
	end)

	return setmetatable({ Holder = body, Window = self.Window, _group = true, _reg = self._reg }, Container)
end

-- Текст --------------------------------------------------------
function Container:AddLabel(text)
	local f = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 0.5,
		LayoutOrder = NextOrder(),
		Parent = self.Holder,
	}, { Corner(8), Padding(10, 14, 10, 14) })
	if self._group then f.BackgroundTransparency = 1 end
	local l = Label({
		Text = text or "",
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = f,
	})
	local obj = {}
	function obj:Set(t) l.Text = t end
	return obj
end

function Container:AddParagraph(o)
	local f = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Element,
		LayoutOrder = NextOrder(),
		Parent = self.Holder,
	}, { Corner(8), Stroke(Theme.Stroke, 1, 0.35), List(4), Padding(12, 14, 12, 14) })
	if self._group then
		f.BackgroundTransparency = 1
		local st = f:FindFirstChildOfClass("UIStroke")
		if st then st.Enabled = false end
	end
	local t = Label({ Text = o.Title or "", FontFace = Fonts.Bold, TextSize = 14, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = f })
	local c = Label({
		Text = o.Content or "",
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = f,
	})
	local obj = {}
	function obj:Set(title, content)
		if title then t.Text = title end
		if content then c.Text = content end
	end
	return obj
end

-- Кнопка -------------------------------------------------------
function Container:AddButton(o)
	o = o or {}
	local f = ElementBase(self, o.Description and 52 or 40, o.Name, o.Description)
	f.ClipsDescendants = true
	local s = Create("UIScale", { Parent = f })

	-- Style = "Primary" — яркая градиентная кнопка
	local primary = o.Style == "Primary"
	if primary then
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		AccentGradient(0).Parent = f
		for _, d in ipairs(f:GetChildren()) do
			if d:IsA("TextLabel") then
				d.TextColor3 = Color3.new(1, 1, 1)
				d.FontFace = Fonts.Bold
			end
		end
	end

	local arrow = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.85,
		Parent = f,
	}, { Corner(7) })
	Label({
		Text = "›",
		FontFace = Fonts.Bold,
		TextSize = 20,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 1, -2),
		Parent = arrow,
	})

	local btn = ClickArea(f)
	if primary then
		Hover(btn, f, Color3.new(1, 1, 1), Color3.fromRGB(215, 215, 230))
	else
		Hover(btn, f)
	end
	btn.MouseButton1Down:Connect(function() Tween(s, { Scale = 0.97 }, 0.12) end)
	btn.MouseButton1Up:Connect(function() Tween(s, { Scale = 1 }, 0.3, Enum.EasingStyle.Back) end)
	btn.MouseLeave:Connect(function() Tween(s, { Scale = 1 }, 0.3, Enum.EasingStyle.Back) end)
	btn.MouseButton1Click:Connect(function()
		Ripple(f)
		Tween(arrow, { Position = UDim2.new(1, -8, 0.5, 0) }, 0.12).Completed:Connect(function()
			Tween(arrow, { Position = UDim2.new(1, -12, 0.5, 0) }, 0.3, Enum.EasingStyle.Back)
		end)
		SafeCall(o.Callback)
	end)

	local Btn = { Type = "Button" }
	RegisterFlag(o, Btn)
	return Btn
end

-- Переключатель ------------------------------------------------
-- Можно вызывать коротко: Tab:AddToggle("Название", false, function(state) end)
-- или таблицей: Tab:AddToggle({ Name = "...", Default = false, Callback = ... })
function Container:AddToggle(o, default, callback)
	if type(o) ~= "table" then
		o = { Name = o, Default = default, Callback = callback }
	end
	local Toggle = { Value = o.Default and true or false, Type = "Toggle" }
	local f, titleLbl = ElementBase(self, o.Description and 52 or (Mac and 40 or 36), o.Name, o.Description)
	local setVisual

	if Mac then
		local off = Color3.fromRGB(72, 72, 76)
		local sw = Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(40, 24),
			BackgroundColor3 = off,
			Parent = f,
		}, { Corner(12) })
		local knob = Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = sw,
		}, { Corner(10), Stroke(Color3.new(0, 0, 0), 1, 0.85) })
		setVisual = function(on, animate)
			Tween(sw, { BackgroundColor3 = on and (Theme.ToggleOn or Theme.Success or Theme.Accent) or off }, 0.25)
			if animate then
				knob.Size = UDim2.fromOffset(25, 20)
				Tween(knob, { Size = UDim2.fromOffset(20, 20) }, 0.35)
			end
			Tween(knob, {
				Position = on and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
			}, 0.3)
		end
	else

	-- Простой квадратный чекбокс
	local box = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Theme.Background,
		Parent = f,
	}, { Corner(5), Stroke(Theme.Stroke, 1, 0) })
	local fill = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = box,
	}, { Corner(5), AccentGradient(45) })
	local check = Icon("check", box, Color3.new(1, 1, 1), 18)
	check.ZIndex = 2
	IconAlpha(check, 1, 0)
	local pop = Create("UIScale", { Parent = box })
	setVisual = function(on, animate)
		Tween(fill, { BackgroundTransparency = on and 0 or 1 }, 0.15)
		IconAlpha(check, on and 0 or 1, 0.15)
		if animate then
			pop.Scale = 0.75
			Tween(pop, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
		end
	end
	end

	function Toggle:Set(v, silent)
		self.Value = v and true or false
		setVisual(self.Value, not silent)
		if not silent then SafeCall(o.Callback, self.Value) end
	end

	local btn = ClickArea(f)
	Hover(btn, f)
	btn.MouseButton1Click:Connect(function()
		Toggle:Set(not Toggle.Value)
	end)

	-- Бинд: Bind = true (пустая плашка), Enum.KeyCode.F или Enum.UserInputType.MouseButton1
	if WantsBind(self.Window, o) then
		local x = Mac and -60 or -38
		titleLbl.Size = UDim2.new(1, -(self._group and 140 or 240), titleLbl.Size.Y.Scale, titleLbl.Size.Y.Offset)
		Toggle.BindChip = AddBindChip(f, self.Window.Connections, x, o.Bind ~= true and o.Bind or nil, {
			OnChange = function(b)
				Toggle.BindValue = b
				SafeCall(o.BindChanged, b)
			end,
			OnPress = function() Toggle:Set(not Toggle.Value) end,
		})
		Toggle.BindValue = Toggle.BindChip:Get()
	end

	Toggle:Set(Toggle.Value, true)
	RegisterFlag(o, Toggle)
	return Toggle
end

-- Слайдер ------------------------------------------------------
function Container:AddSlider(o)
	o = o or {}
	local min, max = o.Min or 0, o.Max or 100
	local inc = o.Increment or 1
	local suffix = o.Suffix or ""
	local Slider = { Value = o.Default or min, Type = "Slider" }

	local f, titleLbl = ElementBase(self, 56, o.Name)
	f:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -120, 0, 34)

	local valueBox = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 8),
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Background,
		Parent = f,
	}, { Corner(6), Padding(0, 8, 0, 8) })
	local valueLabel = Label({
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = valueBox,
	})

	local bar = Create("Frame", {
		Position = UDim2.new(0, 14, 1, -16),
		Size = UDim2.new(1, -28, 0, 6),
		BackgroundColor3 = Theme.Background,
		Parent = f,
	}, { Corner(3) })
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = bar,
	}, { Corner(3), AccentGradient(0) })
	local knob = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
		Parent = bar,
	}, { Corner(7), Stroke(Theme.Accent, 2, 0) })

	local function fmt(v)
		if inc % 1 == 0 then return tostring(math.floor(v + 0.5)) end
		local s = string.format("%.3f", v)
		s = s:gsub("0+$", ""):gsub("%.$", "")
		return s
	end

	function Slider:Set(v, silent)
		v = math.clamp(math.floor((v - min) / inc + 0.5) * inc + min, min, max)
		local changed = v ~= self.Value
		self.Value = v
		local pct = (max == min) and 0 or (v - min) / (max - min)
		Tween(fill, { Size = UDim2.fromScale(pct, 1) }, 0.12)
		Tween(knob, { Position = UDim2.fromScale(pct, 0.5) }, 0.12)
		valueLabel.Text = fmt(v) .. suffix
		if changed and not silent then SafeCall(o.Callback, v) end
	end

	local hit = Create("TextButton", {
		Position = UDim2.new(0, 0, 1, -28),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = "",
		Parent = f,
	})
	Hover(hit, f)

	OnDrag(hit, self.Window.Connections, function(pos)
		Tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.2)
		local pct = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		Slider:Set(min + (max - min) * pct)
	end, function()
		Tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.25, Enum.EasingStyle.Back)
	end)

	Slider.Value = nil
	Slider:Set(o.Default or min, true)
	-- Бинд: сброс к значению по умолчанию (или свой BindCallback)
	MakeBind(self, o, Slider, f, titleLbl, 17, function()
		if o.BindCallback then
			SafeCall(o.BindCallback, Slider.Value)
		else
			Slider:Set(o.Default or min)
		end
	end)
	RegisterFlag(o, Slider)
	return Slider
end

-- Выпадающий список --------------------------------------------
function Container:AddDropdown(o)
	o = o or {}
	local multi = o.Multi == true
	local DD = { Options = o.Options or {}, Open = false, Type = "Dropdown" }
	if multi then
		DD.Value = {}
		if type(o.Default) == "table" then
			for _, v in ipairs(o.Default) do table.insert(DD.Value, v) end
		end
	else
		DD.Value = o.Default
	end

	local f, titleLbl = ElementBase(self, 40, o.Name)
	f.ClipsDescendants = true

	local valueLabel = Label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -36, 0, 0),
		Size = UDim2.new(0.5, -30, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = f,
	})
	local arrow = Icon("chevron", f, Theme.Accent, 14)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.Position = UDim2.new(1, -14, 0, 13)

	local header = ClickArea(f, 40)
	Hover(header, f)

	local list = Create("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 44),
		Size = UDim2.new(1, -16, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = f,
	}, { List(4) })

	local optionViews = {}

	local function isSelected(opt)
		if multi then return table.find(DD.Value, opt) ~= nil end
		return DD.Value == opt
	end

	local function updateDisplay()
		if multi then
			local names = {}
			for _, v in ipairs(DD.Value) do table.insert(names, tostring(v)) end
			valueLabel.Text = #names > 0 and table.concat(names, ", ") or "Нет"
		else
			valueLabel.Text = DD.Value ~= nil and tostring(DD.Value) or "Нет"
		end
		for opt, view in pairs(optionViews) do
			local sel = isSelected(opt)
			Tween(view.Label, { TextColor3 = sel and Theme.Text or Theme.SubText }, 0.2)
			Tween(view.Bar, { BackgroundTransparency = sel and 0 or 1 }, 0.2)
			Tween(view.Button, { BackgroundTransparency = sel and 0 or 0.4 }, 0.2)
		end
	end

	local function listHeight()
		local n = math.min(#DD.Options, 5)
		return n * 30 + math.max(n - 1, 0) * 4
	end

	function DD:SetOpen(state)
		self.Open = state
		local h = listHeight()
		Tween(f, { Size = UDim2.new(1, 0, 0, state and (40 + 4 + h + 8) or 40) }, 0.35)
		Tween(list, { Size = UDim2.new(1, -16, 0, state and h or 0) }, 0.35)
		Tween(arrow, { Rotation = state and 180 or 0 }, 0.35)
	end

	local function build()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		table.clear(optionViews)

		for i, opt in ipairs(DD.Options) do
			local ob = Create("TextButton", {
				Size = UDim2.new(1, -4, 0, 30),
				BackgroundColor3 = Theme.Background,
				BackgroundTransparency = 0.4,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = i,
				Parent = list,
			}, { Corner(6) })
			local bar = Create("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				Size = UDim2.fromOffset(3, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Parent = ob,
			}, { Corner(2), AccentGradient(90) })
			local l = Label({
				Text = tostring(opt),
				TextSize = 12,
				TextColor3 = Theme.SubText,
				Position = UDim2.fromOffset(16, 0),
				Size = UDim2.new(1, -20, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = ob,
			})
			optionViews[opt] = { Button = ob, Label = l, Bar = bar }

			ob.MouseEnter:Connect(function()
				if not isSelected(opt) then Tween(l, { TextColor3 = Theme.Text }, 0.15) end
			end)
			ob.MouseLeave:Connect(function()
				if not isSelected(opt) then Tween(l, { TextColor3 = Theme.SubText }, 0.15) end
			end)
			ob.MouseButton1Click:Connect(function()
				if multi then
					local idx = table.find(DD.Value, opt)
					if idx then table.remove(DD.Value, idx) else table.insert(DD.Value, opt) end
					updateDisplay()
					SafeCall(o.Callback, DD.Value)
				else
					DD.Value = opt
					updateDisplay()
					DD:SetOpen(false)
					SafeCall(o.Callback, opt)
				end
			end)
		end
		updateDisplay()
	end

	function DD:Set(v, silent)
		if multi then
			self.Value = type(v) == "table" and v or { v }
		else
			self.Value = v
		end
		updateDisplay()
		if not silent then SafeCall(o.Callback, self.Value) end
	end

	function DD:Refresh(options, keepValue)
		self.Options = options or {}
		if not keepValue then self.Value = multi and {} or nil end
		build()
		if self.Open then self:SetOpen(true) end
	end

	header.MouseButton1Click:Connect(function()
		DD:SetOpen(not DD.Open)
	end)

	build()
	-- Бинд: следующий вариант (для мульти-списка нужен свой BindCallback)
	if not multi or o.BindCallback then
		MakeBind(self, o, DD, f, titleLbl, 20, function()
			if o.BindCallback then
				SafeCall(o.BindCallback, DD.Value)
				return
			end
			local idx = table.find(DD.Options, DD.Value) or 0
			DD:Set(DD.Options[idx % #DD.Options + 1])
		end)
	end
	RegisterFlag(o, DD)
	return DD
end

-- Поле ввода ---------------------------------------------------
function Container:AddTextbox(o)
	o = o or {}
	local TB = { Value = o.Default or "", Type = "Textbox" }
	local f, titleLbl = ElementBase(self, o.Description and 52 or 40, o.Name, o.Description)

	local box = Create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 26),
		BackgroundColor3 = Theme.Background,
		Text = TB.Value,
		PlaceholderText = o.Placeholder or "Введите текст...",
		PlaceholderColor3 = Theme.SubText,
		TextColor3 = Theme.Text,
		FontFace = Fonts.Regular,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = o.ClearOnFocus or false,
		ClipsDescendants = true,
		Parent = f,
	}, { Corner(6), Padding(0, 8, 0, 8) })
	local st = Stroke(Theme.Stroke, 1, 0)
	st.Parent = box

	if o.Numeric then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = box.Text:gsub("[^%d%.%-]", "")
			if clean ~= box.Text then box.Text = clean end
		end)
	end

	box.Focused:Connect(function()
		Tween(st, { Color = Theme.Accent }, 0.2)
		Tween(box, { Size = UDim2.fromOffset(170, 26) }, 0.25)
	end)
	box.FocusLost:Connect(function(enter)
		Tween(st, { Color = Theme.Stroke }, 0.2)
		Tween(box, { Size = UDim2.fromOffset(150, 26) }, 0.25)
		TB.Value = box.Text
		SafeCall(o.Callback, box.Text, enter)
	end)

	TB.Box = box
	function TB:Set(text)
		box.Text = tostring(text)
		self.Value = box.Text
	end

	RegisterFlag(o, TB)
	return TB
end

-- Бинд клавиши -------------------------------------------------
function Container:AddKeybind(o)
	o = o or {}
	local KB = { Value = o.Default, Binding = false, Type = "Keybind" }
	local f = ElementBase(self, o.Description and 52 or 40, o.Name, o.Description)

	local box = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Background,
		AutoButtonColor = false,
		Text = "",
		FontFace = Fonts.Medium,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Parent = f,
	}, { Corner(6), Padding(0, 10, 0, 10) })
	local st = Stroke(Theme.Stroke, 1, 0)
	st.Parent = box

	local function display()
		box.Text = KB.Binding and "..." or (KB.Value and KB.Value.Name or "Нет")
		Tween(st, { Color = KB.Binding and Theme.Accent or Theme.Stroke }, 0.2)
	end

	box.MouseButton1Click:Connect(function()
		KB.Binding = true
		display()
	end)

	table.insert(self.Window.Connections, UserInputService.InputBegan:Connect(function(input, gp)
		if KB.Binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					KB.Value = nil
				else
					KB.Value = input.KeyCode
				end
				KB.Binding = false
				display()
				SafeCall(o.ChangedCallback, KB.Value)
			end
			return
		end
		if not gp and KB.Value and input.KeyCode == KB.Value then
			SafeCall(o.Callback)
		end
	end))

	function KB:Set(key)
		self.Value = key
		display()
	end

	display()
	RegisterFlag(o, KB)
	return KB
end

-- Выбор цвета --------------------------------------------------
function Container:AddColorPicker(o)
	o = o or {}
	local CP = { Value = o.Default or Color3.fromRGB(140, 90, 255), Open = false, Type = "ColorPicker" }
	local h, s, v = CP.Value:ToHSV()

	local f, titleLbl = ElementBase(self, 40, o.Name)
	f.ClipsDescendants = true

	local swatch = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = CP.Value,
		Parent = f,
	}, { Corner(6), Stroke(Color3.new(1, 1, 1), 1, 0.8) })

	local header = ClickArea(f, 40)
	Hover(header, f)

	local area = Create("Frame", {
		Position = UDim2.fromOffset(14, 48),
		Size = UDim2.new(1, -28, 0, 120),
		BackgroundTransparency = 1,
		Parent = f,
	})

	local sv = Create("TextButton", {
		Size = UDim2.new(1, -28, 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		AutoButtonColor = false,
		Text = "",
		Parent = area,
	}, { Corner(6) })
	Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = sv,
	}, { Corner(6), Create("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
	Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		Parent = sv,
	}, { Corner(6), Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
	local svCursor = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = sv,
	}, { Corner(6), Stroke(Color3.new(1, 1, 1), 2, 0) })

	local rainbow = {}
	for i = 0, 6 do
		table.insert(rainbow, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
	end
	local hue = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 16, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		Text = "",
		Parent = area,
	}, { Corner(6), Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(rainbow) }) })
	local hueCursor = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 6, 0, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
		Parent = hue,
	}, { Corner(3), Stroke(Color3.new(0, 0, 0), 1, 0.5) })

	local info = Label({
		Position = UDim2.fromOffset(14, 176),
		Size = UDim2.new(1, -28, 0, 18),
		TextSize = 12,
		FontFace = Fonts.Medium,
		TextColor3 = Theme.SubText,
		Parent = f,
	})

	local function update(silent)
		CP.Value = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		swatch.BackgroundColor3 = CP.Value
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.fromScale(0.5, h)
		info.Text = string.format("#%s   ·   RGB %d, %d, %d",
			CP.Value:ToHex():upper(),
			math.floor(CP.Value.R * 255 + 0.5),
			math.floor(CP.Value.G * 255 + 0.5),
			math.floor(CP.Value.B * 255 + 0.5))
		if not silent then SafeCall(o.Callback, CP.Value) end
	end

	local conns = self.Window.Connections
	OnDrag(sv, conns, function(pos)
		s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
		update()
	end)
	OnDrag(hue, conns, function(pos)
		h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
		update()
	end)

	function CP:SetOpen(state)
		self.Open = state
		Tween(f, { Size = UDim2.new(1, 0, 0, state and 204 or 40) }, 0.35)
	end

	function CP:Set(color, silent)
		h, s, v = color:ToHSV()
		update(silent)
	end

	header.MouseButton1Click:Connect(function()
		CP:SetOpen(not CP.Open)
	end)

	update(true)
	-- Бинд: открыть/закрыть палитру
	MakeBind(self, o, CP, f, titleLbl, 20, function() CP:SetOpen(not CP.Open) end)
	RegisterFlag(o, CP)
	return CP
end

--==============================================================
-- Конфиги
--==============================================================
-- Код конфига — это ДАННЫЕ (JSON в base64), а не скрипт: при импорте ничего
-- не исполняется, просто выставляются значения элементов с Flag.

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64Index = {}
for i = 1, 64 do B64Index[B64:sub(i, i)] = i - 1 end

local function Base64Encode(str: string): string
	local out = {}
	for i = 1, #str, 3 do
		local a, b, c = str:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1 = math.floor(n / 262144) % 64
		local c2 = math.floor(n / 4096) % 64
		local c3 = math.floor(n / 64) % 64
		local c4 = n % 64
		table.insert(out, B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
			.. (b and B64:sub(c3 + 1, c3 + 1) or "=")
			.. (c and B64:sub(c4 + 1, c4 + 1) or "="))
	end
	return table.concat(out)
end

local function Base64Decode(str: string): string
	str = str:gsub("[^%w%+/]", "")
	local out = {}
	for i = 1, #str, 4 do
		local chunk = str:sub(i, i + 3)
		local n, count = 0, #chunk
		for j = 1, 4 do
			n = n * 64 + (B64Index[chunk:sub(j, j)] or 0)
		end
		local a = math.floor(n / 65536) % 256
		local b = math.floor(n / 256) % 256
		local c = n % 256
		if count >= 2 then table.insert(out, string.char(a)) end
		if count >= 3 then table.insert(out, string.char(b)) end
		if count >= 4 then table.insert(out, string.char(c)) end
	end
	return table.concat(out)
end

local CONFIG_PREFIX = "CH1:"

local function EncodeBind(b)
	if not b then return "" end
	if b.Key then return "K:" .. b.Key.Name end
	return "M:" .. b.Mouse.Name
end

local function DecodeBind(str)
	if type(str) ~= "string" or str == "" then return nil end
	local kind, name = str:match("^(%a):(%w+)$")
	if not kind then return nil end
	local ok, item = pcall(function()
		return kind == "K" and Enum.KeyCode[name] or Enum.UserInputType[name]
	end)
	return ok and item or nil
end

-- Снимок всех элементов с Flag
function CrackHub:SnapshotConfig(saveBinds)
	local values, binds = {}, {}
	for flag, obj in pairs(self.Flags) do
		local t, v = obj.Type, obj.Value
		if t == "ColorPicker" and typeof(v) == "Color3" then
			values[flag] = { c = v:ToHex() }
		elseif t == "Keybind" then
			values[flag] = { k = v and v.Name or "" }
		elseif t == "Toggle" or t == "Slider" or t == "Textbox" or t == "Dropdown" then
			if v ~= nil then values[flag] = v end
		end
		if saveBinds ~= false and obj.BindChip then
			binds[flag] = EncodeBind(obj.BindChip:Get())
		end
	end
	return values, binds
end

-- Применить данные конфига к элементам (колбэки срабатывают — эффекты включаются)
function CrackHub:ApplyConfig(cfg)
	local applied = 0
	for flag, v in pairs(cfg.Values or {}) do
		local obj = self.Flags[flag]
		if obj and obj.Set then
			local t = obj.Type
			local ok = pcall(function()
				if t == "Toggle" and type(v) == "boolean" then
					obj:Set(v)
				elseif t == "Slider" and type(v) == "number" then
					obj:Set(v)
				elseif t == "Textbox" and type(v) == "string" then
					obj:Set(v)
				elseif t == "Dropdown" and (type(v) == "string" or type(v) == "table") then
					obj:Set(v)
				elseif t == "ColorPicker" and type(v) == "table" and type(v.c) == "string" then
					obj:Set(Color3.fromHex(v.c))
				elseif t == "Keybind" and type(v) == "table" then
					obj:Set(DecodeBind("K:" .. tostring(v.k)))
				else
					return
				end
				applied += 1
			end)
			if not ok then warn("[CrackHub] не удалось применить", flag) end
		end
	end
	for flag, b in pairs(cfg.Binds or {}) do
		local obj = self.Flags[flag]
		if obj and obj.BindChip then obj.BindChip:Set(DecodeBind(b)) end
	end
	return applied
end

function CrackHub:EncodeConfig(cfg)
	local json = HttpService:JSONEncode({
		v = 1, n = cfg.Name, a = cfg.Author, f = cfg.Values, b = cfg.Binds,
	})
	return CONFIG_PREFIX .. Base64Encode(json)
end

function CrackHub:DecodeConfig(code)
	if type(code) ~= "string" then return nil, "пусто" end
	code = code:gsub("^%s+", ""):gsub("%s+$", "")
	if code:sub(1, #CONFIG_PREFIX) ~= CONFIG_PREFIX then
		return nil, "код должен начинаться с " .. CONFIG_PREFIX
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(Base64Decode(code:sub(#CONFIG_PREFIX + 1)))
	end)
	if not ok or type(data) ~= "table" or type(data.f) ~= "table" then
		return nil, "код повреждён"
	end
	local name = type(data.n) == "string" and data.n:sub(1, 40) or "Без названия"
	if name:gsub("%s", "") == "" then name = "Без названия" end
	return {
		Name = name,
		Author = type(data.a) == "string" and data.a:sub(1, 30) or "?",
		Values = data.f,
		Binds = type(data.b) == "table" and data.b or {},
	}
end


-- Принимает обычную raw-ссылку или loadstring(game:HttpGet("URL", true))().
-- Обёртка нужна только для получения URL: код из поля не исполняется.
local function ConfigURL(input)
	local text = input:match("^%s*(.-)%s*$")
	if text:match("^https?://") then return text end
	local quote, url, tail = text:match([[^loadstring%s*%(%s*game%s*:%s*HttpGet%s*%(%s*(['"])(.-)%1%s*(.-)%)%s*%)%s*%(%s*%)%s*;?$]])
	if not quote then return nil end
	tail = tail:match("^%s*(.-)%s*$")
	if tail ~= "" and not tail:match("^,%s*true$") and not tail:match("^,%s*false$") then
		return nil
	end
	return url
end

function CrackHub:ResolveConfigInput(input)
	if type(input) ~= "string" then return nil, "Вставь код конфига или ссылку" end
	local text = input:match("^%s*(.-)%s*$")
	if text:sub(1, #CONFIG_PREFIX) == CONFIG_PREFIX then return text end
	local url = ConfigURL(text)
	if not url or not url:match("^https?://[^/%s]+") or url:find([=[[%s"'<>\]]=]) then
		return nil, "Вставь CH1:..., raw-ссылку или loadstring(game:HttpGet(\"URL\", true))()"
	end
	local ok, body
	if type(self.FetchConfig) == "function" then
		-- Сохраняем поддержку существующего провайдера: FetchConfig(url).
		ok, body = pcall(self.FetchConfig, url)
	else
		ok, body = pcall(function() return game:HttpGet(url, true) end)
		if not ok then
			ok, body = pcall(function() return HttpService:GetAsync(url, true) end)
		end
	end
	if not ok then
		return nil, "Не удалось скачать конфиг. Проверь raw-ссылку и доступ к HTTP в этой среде."
	end
	if type(body) ~= "string" or #body == 0 then return nil, "Провайдер вернул пустой ответ" end
	if #body > 1024 * 1024 then return nil, "Файл конфига слишком большой (максимум 1 МБ)" end
	-- Некоторые хостинги добавляют UTF-8 BOM.
	if body:sub(1, 3) == "\239\187\191" then body = body:sub(4) end
	body = body:match("^%s*(.-)%s*$")
	if body:sub(1, #CONFIG_PREFIX) ~= CONFIG_PREFIX then
		return nil, "По ссылке должен быть сам код CH1:... из поля «Код», а не HTML-страница или скрипт"
	end
	return body
end

-- Локальное хранилище: отдельный файл для игры и аккаунта.
-- Файловые функции предоставляет среда запуска, если она их поддерживает.
local function CreateFileConfigStorage()
	if type(readfile) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" then
		return nil, "Файловое сохранение недоступно: нужны readfile, writefile и isfile. Конфиги останутся только до перезапуска."
	end
	local fileName = "CrackHub_Configs_" .. tostring(game.GameId) .. "_" .. tostring(LocalPlayer.UserId) .. ".json"
	return {
		Load = function()
			if not isfile(fileName) then return {} end
			local data = HttpService:JSONDecode(readfile(fileName))
			if type(data) ~= "table" or data.Version ~= 1 or type(data.Configs) ~= "table" then
				error("Неверный формат файла конфигов")
			end
			local list = {}
			for _, encoded in ipairs(data.Configs) do
				local cfg, err = CrackHub:DecodeConfig(encoded)
				if not cfg then error(err or "Повреждённый конфиг") end
				table.insert(list, cfg)
			end
			return list
		end,
		Save = function(list)
			local encoded = {}
			for _, cfg in ipairs(list) do
				table.insert(encoded, CrackHub:EncodeConfig(cfg))
			end
			writefile(fileName, HttpService:JSONEncode({ Version = 1, Configs = encoded }))
		end,
	}, fileName
end

function CrackHub._BuildConfigTab(window, o)
	local storage = o.Storage -- Пользовательское хранилище имеет приоритет.
	local storageInfo
	if not storage then storage, storageInfo = CreateFileConfigStorage() end
	local saveBinds = o.SaveBinds ~= false
	local configs = {}
	local loadFailed = false
	if storage and storage.Load then
		local ok, list = pcall(storage.Load)
		if ok and type(list) == "table" then
			configs = list
		else
			loadFailed = true -- Не перезаписываем файл, который не удалось прочитать.
			storageInfo = "Не удалось прочитать конфиги. Исходный файл сохранён; запись отключена до исправления файла."
			warn("[CrackHub] Ошибка чтения конфигов:", list)
		end
	end

	local function find(name)
		for i, c in ipairs(configs) do
			if c.Name == name then return i, c end
		end
		return nil, nil
	end
	local function uniqueName(name)
		if not find(name) then return name end
		local i = 2
		while find(name .. " (" .. i .. ")") do i += 1 end
		return name .. " (" .. i .. ")"
	end
	local function persist()
		if loadFailed or not storage or type(storage.Save) ~= "function" then return false end
		-- Записываем сразу после сохранения, импорта и удаления.
		local ok, result = pcall(storage.Save, configs)
		if not ok or result == false then
			CrackHub:Notify({ Title = "Ошибка записи", Content = "Конфиг есть в памяти, но сохранить файл не удалось.", Type = "Error", Duration = 6 })
			warn("[CrackHub] Ошибка записи конфигов:", result)
			return false
		end
		return true
	end
	local function notify(title, text, kind)
		CrackHub:Notify({ Title = title, Content = text, Type = kind, Duration = 3 })
	end

	local Tab = window:CreateTab(o.Name or "Конфиг", o.Icon)
	local NB = false -- на этой вкладке без плашек бинда

	-- Создание
	local Create_ = Tab:AddGroup("Сохранить")
	if loadFailed or not storage then
		Create_:AddLabel(storageInfo or "Постоянное хранилище недоступно")
	elseif storageInfo then
		Create_:AddLabel("Автосохранение: " .. storageInfo)
	end
	local NameBox = Create_:AddTextbox({ Name = "Название", Placeholder = "Мой конфиг", Bind = NB })
	local AuthorBox = Create_:AddTextbox({ Name = "Автор", Default = LocalPlayer and LocalPlayer.Name or "", Bind = NB })
	local CodeBox -- создаётся ниже

	local List, Info, refreshList

	local function showCode(cfg)
		local code = CrackHub:EncodeConfig(cfg)
		CodeBox:Set(code)
		CodeBox.Code = code
		return code
	end

	Create_:AddButton({
		Name = "Сохранить",
		Description = "Создаст конфиг и код для заливки",
		Style = "Primary",
		Bind = NB,
		Callback = function()
			local name = NameBox.Box.Text:gsub("^%s+", ""):gsub("%s+$", "")
			if name == "" then name = "Конфиг " .. (#configs + 1) end
			local values, binds = CrackHub:SnapshotConfig(saveBinds)
			local cfg = { Name = name:sub(1, 40), Author = AuthorBox.Box.Text:sub(1, 30), Values = values, Binds = binds }
			local i = find(cfg.Name)
			if i then configs[i] = cfg else table.insert(configs, cfg) end
			local saved = persist()
			refreshList(cfg.Name)
			showCode(cfg)
			notify(saved and "Сохранено" or "Сохранено в памяти", "«" .. cfg.Name .. "» — код в поле «Код», скопируй Ctrl+C", saved and "Success" or "Warning")
		end,
	})

	-- Код
	local CodeGroup = Tab:AddGroup("Код конфига")
	CodeBox = CodeGroup:AddTextbox({
		Name = "Код",
		Description = "Нажми, Ctrl+A → Ctrl+C",
		Placeholder = "Сначала сохрани конфиг",
		Bind = NB,
	})
	CodeBox.Box.TextEditable = false
	CodeBox.Box.Focused:Connect(function()
		task.defer(function()
			CodeBox.Box.SelectionStart = 1
			CodeBox.Box.CursorPosition = #CodeBox.Box.Text + 1
		end)
	end)
	CodeGroup:AddLabel("Залей код CH1:... из этого поля на GitHub / Pastebin / другой хостинг. В «Импорт» вставь raw-ссылку или loadstring(game:HttpGet(\"URL\", true))().")

	-- Мои конфиги
	local Mine = Tab:AddGroup("Мои конфиги")
	List = Mine:AddDropdown({
		Name = "Конфиг",
		Options = {},
		Bind = NB,
		Callback = function(name)
			local _, c = find(name)
			Info:Set(c and ("Автор: " .. (c.Author ~= "" and c.Author or "?")) or "Конфигов пока нет")
		end,
	})
	Info = Mine:AddLabel("Конфигов пока нет")

	refreshList = function(select)
		local names = {}
		for _, c in ipairs(configs) do table.insert(names, c.Name) end
		List:Refresh(names)
		if select and find(select) then
			List:Set(select)
		elseif names[1] then
			List:Set(names[1])
		else
			Info:Set("Конфигов пока нет")
		end
	end

	local function selected()
		local _, c = find(List.Value)
		if not c then notify("Конфиг", "Сначала выбери конфиг", "Warning") end
		return c
	end

	Mine:AddButton({
		Name = "Загрузить",
		Description = "Применить выбранный конфиг",
		Style = "Primary",
		Bind = NB,
		Callback = function()
			local c = selected()
			if not c then return end
			local n = CrackHub:ApplyConfig(c)
			notify("Загружено", "«" .. c.Name .. "» · применено настроек: " .. n, "Success")
		end,
	})
	Mine:AddButton({
		Name = "Показать код",
		Bind = NB,
		Callback = function()
			local c = selected()
			if c then showCode(c); notify("Код", "Код «" .. c.Name .. "» в поле «Код»") end
		end,
	})
	Mine:AddButton({
		Name = "Удалить",
		Bind = NB,
		Callback = function()
			local c = selected()
			if not c then return end
			table.remove(configs, (find(c.Name)))
			persist()
			refreshList()
			notify("Удалено", "«" .. c.Name .. "»", "Error")
		end,
	})

	-- Импорт
	local Import = Tab:AddGroup("Импорт")
	local ImportBox = Import:AddTextbox({ Name = "Код / ссылка", Placeholder = "CH1:... / https://... / loadstring(...)", Bind = NB })
	local importing = false
	Import:AddButton({
		Name = "Импортировать",
		Description = "Появится в «Мои конфиги»",
		Style = "Primary",
		Bind = NB,
		Callback = function()
			if importing then return end
			importing = true
			local ok, text, fetchError = pcall(CrackHub.ResolveConfigInput, CrackHub, ImportBox.Box.Text)
			importing = false
			if not ok or not text then
				notify("Ошибка импорта", ok and fetchError or "Не удалось получить конфиг", "Error")
				return
			end
			local cfg, err = CrackHub:DecodeConfig(text)
			if not cfg then
				notify("Ошибка импорта", err, "Error")
				return
			end
			cfg.Name = uniqueName(cfg.Name)
			table.insert(configs, cfg)
			persist()
			refreshList(cfg.Name)
			ImportBox:Set("")
			CrackHub:ApplyConfig(cfg)
			notify("Импортирован", "«" .. cfg.Name .. "» от " .. cfg.Author .. " · загружен", "Success")
		end,
	})

	refreshList()
	Tab.Configs = configs
	return Tab
end

--==============================================================
-- Уведомления
--==============================================================

function CrackHub:Notify(o)
	o = o or {}
	if not (self._notifyHolder and self._notifyHolder.Parent) then
		local gui = Create("ScreenGui", {
			Name = "CrackHubNotifications",
			ResetOnSpawn = false,
			DisplayOrder = 200,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = LocalPlayer:WaitForChild("PlayerGui"),
		})
		self._notifyHolder = Create("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 300, 1, -32),
			BackgroundTransparency = 1,
			Parent = gui,
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
		})
	end

	local duration = o.Duration or 4

	local Wrap = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = NextOrder(),
		Parent = self._notifyHolder,
	})
	local Card = Create("Frame", {
		Position = UDim2.new(1, 40, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Background,
		Parent = Wrap,
	}, { Corner(10), Stroke(Theme.Stroke, 1, 0) })

	-- Тип уведомления: Success / Error / Warning (или без типа — градиент)
	local typeColors = {
		Success = Color3.fromRGB(70, 220, 140),
		Error = Theme.Danger,
		Warning = Color3.fromRGB(255, 190, 70),
	}
	local tc = typeColors[o.Type]
	local iconChildren = { Corner(13) }
	if not tc then table.insert(iconChildren, AccentGradient(45)) end
	local NotifIcon = Create("Frame", {
		Position = UDim2.fromOffset(12, 13),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = tc or Color3.new(1, 1, 1),
		Parent = Card,
	}, iconChildren)
	if o.Type == "Success" or o.Type == "Error" then
		local ic = Icon(o.Type == "Success" and "check" or "x", NotifIcon, Color3.new(1, 1, 1), 26)
		ic.Size = UDim2.fromScale(1, 1)
	else
		Label({
			Text = o.Type == "Warning" and "!" or "i",
			FontFace = Fonts.Bold,
			TextSize = 14,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = NotifIcon,
		})
	end
	local iconScale = Create("UIScale", { Scale = 0.3, Parent = NotifIcon })
	task.delay(0.15, function()
		Tween(iconScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
	end)

	local Body = Create("Frame", {
		Position = UDim2.fromOffset(50, 0),
		Size = UDim2.new(1, -62, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = Card,
	}, { List(4), Padding(12, 0, 16, 0) })

	Label({
		Text = o.Title or "Уведомление",
		FontFace = Fonts.Bold,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = Body,
	})
	Label({
		Text = o.Content or "",
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = Body,
	})

	local Progress = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -5),
		Size = UDim2.new(1, -20, 0, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = Card,
	}, { Corner(1), AccentGradient(0) })

	Tween(Card, { Position = UDim2.new() }, 0.5, Enum.EasingStyle.Back)
	Tween(Progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		Tween(Card, { Position = UDim2.new(1, 40, 0, 0) }, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.36)
		Wrap:Destroy()
	end)
end

-- =============================================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ (можно удалить, если нужна только библиотека)
-- =============================================================

local Window = CrackHub:CreateWindow({
	Title = "CrackHub",
	Subtitle = "v2.0",
	Blur = true, -- матовое размытие фона за окном
	Style = "macOS", -- или "Neon" (старый неоновый стиль, к нему подходят Theme = "Sakura", "Ocean" и т.д.)
	-- Окно нейтрально-серое, а элементы управления своего цвета:
	ControlColor = Color3.fromRGB(150, 95, 255), -- одна Color3, либо { c1, c2 } для градиента
	Size = UDim2.fromOffset(780, 480),
	ToggleKey = Enum.KeyCode.RightShift, -- скрыть/показать окно (жёлтая кнопка тоже скрывает)
	-- CardColor = Color3.fromRGB(21, 21, 25), -- цвет карточек (отдельно от окна)
	-- BlurMode = "Screen", -- размыть весь экран вместо области за окном
})

-- Везде карточки: AddGroup (или AddSection — на вкладке это то же самое).
-- Карточки сами встают в два столбца; второй аргумент true — карточка на всю ширину.

-- ВКЛАДКА: Игрок
local Main = Window:CreateTab("Игрок")

local Basic = Main:AddGroup("Основное")
Basic:AddSlider({
	Name = "Значение",
	Min = 0, Max = 100, Default = 50, Increment = 1,
	Flag = "Value",
	Callback = function(v) print("Значение:", v) end,
})
Basic:AddToggle({
	Name = "Опция",
	Description = "Описание опции",
	Bind = true,
	Flag = "Option",
	Callback = function(state) print("Опция:", state) end,
})
Basic:AddKeybind({
	Name = "Быстрое действие",
	Default = Enum.KeyCode.F,
	Flag = "QuickKey",
	Callback = function()
		CrackHub:Notify({ Title = "Бинд", Content = "Ты нажал клавишу!", Duration = 2 })
	end,
})

local Misc = Main:AddGroup("Разное")
Misc:AddButton({
	Name = "Показать уведомление",
	Description = "Проверка всплывашек",
	Style = "Primary", -- яркая градиентная кнопка
	Callback = function()
		CrackHub:Notify({ Title = "Привет!", Content = "Это уведомление из CrackHub.", Duration = 4 })
		task.wait(0.4)
		CrackHub:Notify({ Title = "Успех", Content = "Всё сохранено", Type = "Success", Duration = 4 })
		task.wait(0.4)
		CrackHub:Notify({ Title = "Внимание", Content = "Это предупреждение", Type = "Warning", Duration = 4 })
	end,
})
Misc:AddTextbox({
	Name = "Никнейм",
	Placeholder = "Введи ник...",
	Flag = "Nick",
	Callback = function(text, enterPressed)
		print("Введено:", text, enterPressed)
	end,
})

-- ВКЛАДКА: Визуалы
local Visuals = Window:CreateTab("Визуалы")

local G1 = Visuals:AddGroup("Группа A")
G1:AddToggle({ Name = "Опция 1", Flag = "Opt1", Bind = true, Callback = function(v) print("Опция 1:", v) end })
G1:AddSlider({ Name = "Значение", Flag = "Amount", Min = 0, Max = 100, Default = 55, Suffix = "%" })
G1:AddToggle({ Name = "Опция 2", Flag = "Opt2", Bind = Enum.KeyCode.G, Callback = function(v) print("Опция 2:", v) end })
G1:AddButton({ Name = "Действие", Bind = true, Callback = function() print("Нажато") end })

local G2 = Visuals:AddGroup("Группа B")
G2:AddToggle({ Name = "Переключатель 1", Flag = "Sw1", Default = true, Bind = Enum.UserInputType.MouseButton3 })
G2:AddToggle({ Name = "Переключатель 2", Flag = "Sw2", Default = true, Bind = true })
G2:AddSlider({ Name = "Дистанция", Flag = "Distance", Min = 0, Max = 3000, Default = 3000 })

local Colors = Visuals:AddGroup("Цвета")
Colors:AddColorPicker({
	Name = "Цвет",
	Flag = "Color",
	Default = Color3.fromRGB(140, 90, 255),
	Callback = function(color) print("Цвет:", color) end,
})
Colors:AddDropdown({
	Name = "Режим",
	Flag = "Mode",
	Options = { "Первый", "Второй", "Третий" },
	Default = "Первый",
	Callback = function(option) print("Режим:", option) end,
})

local Lists = Visuals:AddGroup("Списки")
Lists:AddDropdown({
	Name = "Показывать",
	Flag = "Show",
	Options = { "Имя", "Здоровье", "Дистанция", "Команда" },
	Multi = true,
	Default = { "Имя", "Здоровье" },
	Callback = function(list) print("Выбрано:", table.concat(list, ", ")) end,
})

-- ВКЛАДКА: Инфо
local Info = Window:CreateTab("Инфо")

local About = Info:AddGroup("О меню")
About:AddParagraph({
	Title = "CrackHub",
	Content = "Нажми RightShift, чтобы спрятать меню. Окно можно таскать за верхнюю панель.",
})
About:AddLabel("Значения элементов с Flag лежат в CrackHub.Flags, например CrackHub.Flags.Value.Value")

local Status = Info:AddGroup("Статус")
local Prog = Status:AddProgress({ Name = "Прогресс загрузки" })
task.spawn(function()
	for i = 0, 10 do
		Prog:Set(i / 10)
		task.wait(0.15)
	end
end)
Status:AddDivider()
Status:AddLabel("Карточки сворачиваются по клику на заголовок.")

-- ВКЛАДКА: Настройки окна
local Settings = Window:CreateTab("Настройки")

local Look = Settings:AddGroup("Внешний вид")
Look:AddSlider({
	Name = "Прозрачность окна",
	Flag = "WinTransparency",
	Min = 0, Max = 90, Default = 0, Increment = 1,
	Suffix = "%",
	Callback = function(v) Window:SetTransparency(v / 100) end,
})
Look:AddSlider({
	Name = "Размытие фона",
	Flag = "WinBlur",
	Min = 0, Max = 40, Default = 14, Increment = 1,
	Callback = function(v) Window:SetBlur(v) end,
})

local MenuGroup = Settings:AddGroup("Меню")
MenuGroup:AddButton({
	Name = "Скрыть меню",
	Description = "Вернуть: клавиша меню",
	Callback = function() Window:Hide() end,
})
MenuGroup:AddLabel("Клавишу меню можно сменить плашкой внизу слева.")

-- ВКЛАДКА: Конфиг (сохранить / загрузить / удалить / импорт по коду)
-- Сохраняются все элементы с Flag (+ их бинды). SaveBinds = false — без биндов.
-- Storage = { Load = function() return list end, Save = function(list) end } — своё хранилище
-- По умолчанию используется JSON-файл, если среда поддерживает файловые функции.
Window:CreateConfigTab({ Name = "Конфиг" })

CrackHub:Notify({ Title = "CrackHub загружена", Content = "Добро пожаловать!", Duration = 3 })
