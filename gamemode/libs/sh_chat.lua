if (CLIENT) then
	surface.CreateFont("AFont_Chat", {
		font = "Russo One",
		size = 21,
		weight = 100
	})

	local CHAT_FADETIME = 5
	local CHAT_FADEDELAY = 5
	local OUTLINE_COLOR = Color(0, 0, 0, 150)
	local CVAR_CHATMESSAGES = CreateClientConVar("abdul_chatmessages", "100", true)

	chat.panel = chat.panel or {}
	chat.open = chat.open or false

	local PANEL = {}
		function PANEL:Init()
			self:SetDrawBackground(false)

			timer.Simple(CHAT_FADEDELAY, function()
				if (IsValid(self)) then
					self.fadeStart = CurTime()
					self.fadeFinish = self.fadeStart + CHAT_FADETIME
				end
			end)
		end

		function PANEL:SetMaxWidth(width)
			self.maxWidth = width
		end

		function PANEL:SetFont(font)
			self.font = font
		end

		function PANEL:Parse(...)
			local data = ""
			local lastColor = Color(255, 255, 255)

			if (self.font) then
				data = "<font="..self.font..">"
			end

			for k, v in ipairs({...}) do
				if (type(v) == "table" and v.r and v.g and v.b) then
					if (v != lastColor) then
						data = data.."</color>"
					end

					lastColor = v
					data = data.."<color="..v.r..","..v.g..","..v.b..">"
				elseif (type(v) == "Player") then
					local color = team.GetColor(v:Team())

					data = data.."<color="..color.r..","..color.g..","..color.b..">"..v:Name().."</color>"
				elseif (type(v) == "IMaterial" or type(v) == "table" and type(v[1]) == "IMaterial") then
					local w, h = 16, 16
					local material = v

					if (type(v) == "table" and v[2] and v[3]) then
						material = v[1]
						w = v[2]
						h = v[3]
					end

					data = data.."<img="..material:GetName()..".png,"..w.."x"..h.."> "
				else
					v = tostring(v)
					v = string.gsub(v, "&", "&amp;")
					v = string.gsub(v, "<", "&lt;")
					v = string.gsub(v, ">", "&gt;")

					data = data..v
				end
			end

			if (self.font) then
				data = data.."</font>"
			end

			self.markup = ofmarkup.Parse(data, self.maxWidth)

			function self.markup:DrawText(text, font, x, y, color, hAlign, vAlign, alpha)
				draw.SimpleTextOutlined(text, font, x, y, color, hAlign, vAlign, 1, OUTLINE_COLOR)
			end

			self:SetSize(self.markup:GetWidth(), self.markup:GetHeight())
		end

		function PANEL:SetAlignment(xAlign, yAlign)
			self.xAlign = xAlign
			self.yAlign = yAlign
		end

		function PANEL:Paint(w, h)
			if (self.markup) then
				local alpha = 255

				if (self.fadeStart and self.fadeFinish) then
					alpha = math.Clamp(255 - math.TimeFraction(self.fadeStart, self.fadeFinish, CurTime()) * 255, 0, 255)
				end

				if (chat.open) then
					alpha = 255
				end

				self:SetAlpha(alpha)

				if (alpha > 0) then
					self.markup:Draw(1, 0, self.xAlign or 0, self.yAlign or 0)
				end
			end
		end
	vgui.Register("MarkupPanel", PANEL, "DPanel")

	chat = chat or {}
	chat.messages = chat.messages or {}
	chat.panel = chat.panel or {}
	chat.history = chat.history or {}

	CVAR_CHATX = CreateClientConVar("abdul_chatx", "32", true)
	CVAR_CHATY = CreateClientConVar("abdul_chaty", "0.5", true)

	local CHAT_X, CHAT_Y = CVAR_CHATX:GetInt(), ScrH() * CVAR_CHATY:GetFloat()
	local CHAT_W, CHAT_H = ScrW() * 0.4, ScrH() * 0.375

	cvars.AddChangeCallback("abdul_chatx", function(conVar, oldValue, value)
		CHAT_X = CVAR_CHATX:GetInt()
		chat.panel.frame:SetPos(CHAT_X, CHAT_Y)
	end)

	cvars.AddChangeCallback("abdul_chaty", function(conVar, oldValue, value)
		CHAT_Y = ScrH() * CVAR_CHATY:GetFloat()
		chat.panel.frame:SetPos(CHAT_X, CHAT_Y)
	end)

	chat.AbdulAddText = chat.AbdulAddText or chat.AddText

	function chat.PushFont(font)
		chat.font = font
	end

	function chat.PopFont()
		chat.font = nil
	end

	function chat.AddText(...)
		local data = {}
		local lastColor = Color(255, 255, 255)

		for k, v in pairs({...}) do
			data[k] = v
		end

		chat.AddTextEx(unpack(data))

		surface.PlaySound("common/talk.wav")

		for k, v in ipairs(data) do
			if (type(v) == "Player") then
				local client = v
				local index = k
				
				table.remove(data, k)
				table.insert(data, index, team.GetColor(client:Team()))
				table.insert(data, index + 1, client:Name())
			end
		end

		return chat.AbdulAddText(unpack(data))
	end

	function chat.AddTextEx(...)
		local message = chat.panel.content:Add("MarkupPanel")
		message:Dock(TOP)
		message:DockPadding(4, 4, 4, 4)
		message:SetFont(chat.font or "AFont_Chat")
		message:SetMaxWidth(CHAT_W - 16)
		message:Parse(...)

		local scrollBar = chat.panel.content.VBar
		scrollBar.CanvasSize = scrollBar.CanvasSize + message:GetTall()
		scrollBar:AnimateTo(scrollBar.CanvasSize, 0.25, 0, 0.25)

		table.insert(chat.messages, message)

		if (#chat.messages > CVAR_CHATMESSAGES:GetInt()) then
			local panel = chat.messages[1]
			panel:Remove()

			table.remove(chat.messages, 1)
		end
	end

	function chat.CreatePanels()
		if (!IsValid(chat.panel.frame)) then
			local frame = vgui.Create("DPanel")
			frame:SetPos(CHAT_X, CHAT_Y)
			frame:SetSize(CHAT_W, CHAT_H)
			frame:SetDrawBackground(false)

			local content = frame:Add("DScrollPanel")
			content:Dock(FILL)
			content:DockMargin(8, 8, 8, 38)
			content.VBar:SetWide(0)

			chat.panel.frame = frame
			chat.panel.content = content
		end
	end

	function chat.Toggle(state)
		chat.CreatePanels()
		chat.open = state

		if (state) then
			local entry = vgui.Create("DTextEntry")
			entry:SetPos(CHAT_X + 8, CHAT_Y + CHAT_H - 30)
			entry:SetWide(CHAT_W - 16)
			entry:MakePopup()
			entry:RequestFocus()
			entry:SetTall(24)
			entry.History = chat.history
			entry:SetHistoryEnabled(true)
			entry:SetAllowNonAsciiCharacters(true)
			entry.OnEnter = function(panel)
				chat.Toggle(false)

				local text = panel:GetText()

				if (string.find(text, "%S")) then
					net.Start("abdul_net.PlayerSay")
						net.WriteString(text)
					net.SendToServer()
					table.insert(chat.history, text)

					hook.Run("FinishChat")
				end

				panel:SetText("")
				panel:Remove()
			end
			entry.OnKeyCodePressed = function(panel, key)
				if (key == KEY_ESCAPE) then
					chat.Toggle(false)
					panel:SetText("")
					panel:Remove()
				end
			end
			entry.Think = function(panel)
				if (gui.IsGameUIVisible()) then
					chat.Toggle(false)
					panel:SetText("")
					panel:Remove()
				end
			end
			entry.Paint = function(panel, w, h)
				surface.SetDrawColor(70, 70, 70, 245)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(25, 25, 25, 235)
				surface.DrawOutlinedRect(0, 0, w, h)

				-- For some reason, it refuses to use the main color so we
				-- have to recreate it.

				--local color = Color(highlight.r, highlight.g, highlight.b)

				panel:DrawTextEntryText(color_white, Color(140, 255, 140), color_white)
			end
			entry.OnTextChanged = function(panel)
				hook.Run("ChatTextChanged", panel:GetText())
			end

			hook.Run("ChatOpened")

			chat.panel.entry = entry
		end
	end

	function GM:StartChat()
		return true
	end

	hook.Add("PlayerBindPress", "Chat", function(client, bind, pressed)
		if (string.find(string.lower(bind), "messagemode") and pressed) then
			chat.Toggle(true)

			return true
		end
	end)
	net.Receive("abdul_net.PlayerSaySend", function()
		local client = net.ReadEntity()
		local msg = net.ReadString()


		if not IsValid(client) then
			chat.AddText(Color(150, 150, 150), "Console", color_white, ": "..msg)
			return
		end

		local tab = {}
		table.insert(tab, team.GetColor( client:Team() ))

		table.insert(tab, client:Nick())

		table.insert(tab, Color(255,255,255,255))
		table.insert(tab, ": ")
		table.insert(tab, msg)
		
		chat.AddText(unpack(tab))
	end)
	net.Receive("abdul_net.ChatReturn", function()
		local msg = net.ReadString()
		local server = Material("icon16/server.png")

		chat.AddText(server, msg)
	end)

	hook.Add("HUDShouldDraw", "Chat", function(element)
		if element == "CHudChat" then
			return false
		end
	end)

	function GM:ChatClassPreText(class, client, text)
		if class.font then
			chat.PushFont(class.font)
		end
	end

	function GM:ChatClassPostText(class, client, text)
		if class.font then
			chat.PopFont()
		end
	end

	chat.CreatePanels()
else
	util.AddNetworkString("abdul_net.PlayerSay")
	util.AddNetworkString("abdul_net.PlayerSaySend")
	util.AddNetworkString("abdul_net.ChatReturn")
	
	local function ChatReturn(ply, str)
		net.Start("abdul_net.ChatReturn")
			net.WriteString(str)
		net.Send(ply)
	end
	net.Receive("abdul_net.PlayerSay", function(len, client)
		if ((client.nextTalk or 0) < CurTime()) then
			client.nextTalk = CurTime() + 0.5

			local msg = net.ReadString()
			local len = string.utf8len(msg)
			if len > 100 then -- 1024-24 bytes muha
				ErrorNoHalt("[Chat] IGNORING TOO LONG MESSAGE: len = "..len.." from "..tostring(client).."\n")
				ChatReturn(client, "Stop spamming the chat!")
				return
			end
			net.Start("abdul_net.PlayerSaySend")
				net.WriteEntity(client)
				net.WriteString(msg)
			net.Broadcast()
		end
	end)
	
	hook.Add( "PlayerConnect", "CHAT.LIB.HOOK", function( name )
		Notify(Color( 190, 210, 190, 255 ),"Player " .. name .. " connected.")
	end)
	hook.Add( "PlayerDisconnected", "CHAT.LIB.HOOK", function( ply )
		Notify(Color( 190, 210, 190, 255 ),"Player " .. ply:Nick() .. " has left the server.")
	end)
end