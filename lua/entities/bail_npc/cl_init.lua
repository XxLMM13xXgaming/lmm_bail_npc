include('shared.lua')

surface.CreateFont( "fontclose", {
        font = "Lato Light",
        size = 25,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
surface.CreateFont( "BailTitleFont", {
        font = "Lato Light",
        size = 30,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
surface.CreateFont( "BailNameFont", {
        font = "Lato Light",
        size = 46,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
surface.CreateFont( "BailNameFontSmall", {
        font = "Lato Light",
        size = 34,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
surface.CreateFont( "BailJobFont", {
        font = "Lato Light",
        size = 20,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
surface.CreateFont( "BailNPCTextBounce", {
        font = "Lato Light",
        size = 80,
        weight = 250,
        antialias = true,
        strikeout = false,
        additive = true,
} )
 
local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount) --Panel blur function
        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, 6 do
                blur:SetFloat("$blur", (i / 3) * (amount or 6))
                blur:Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
end
 
local function drawRectOutline( x, y, w, h, color )
        surface.SetDrawColor( color )
        surface.DrawOutlinedRect( x, y, w, h )
end

net.Receive("OpenBailMenuNEW", function()
	local ArrestFee
	local arrestedplayers = {}
	local AllowToUse = false
	local peopletosend = net.ReadTable()
	
	for key, value in pairs( player.GetAll() ) do
		if value:getDarkRPVar( "Arrested" ) then
			table.insert( arrestedplayers, value )
		end
	end
	
	
	
	local BailMain = vgui.Create( "DFrame" )
	BailMain:SetSize( 610, 450 )
	BailMain:Center()
	BailMain:SetDraggable( false )
	BailMain:MakePopup()
	BailMain:SetTitle( "" )
	BailMain:ShowCloseButton( false )
	BailMain.Paint = function( self, w, h )
		DrawBlur(BailMain, 2)
		drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
		drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
		draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
		draw.SimpleText( "BAIL NPC", "BailTitleFont", BailMain:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	local frameclose = vgui.Create( "DButton", BailMain )
	frameclose:SetSize( 35, 35 )
	frameclose:SetPos( BailMain:GetWide() - 36,9 )
	frameclose:SetText( "X" )
	frameclose:SetFont( "fontclose" )
	frameclose:SetTextColor( Color( 255, 255, 255 ) )
	frameclose.Paint = function()
		
	end
	frameclose.DoClick = function()
		BailMain:Close()
		BailMain:Remove()
	end
	local noPlayers = false
	
	local function NoArrestedPlayers()
		noPlayers = true
		local NoPlayers = vgui.Create( "DLabel", BailMain )
		NoPlayers:SetText( "The jail is currently empty!" )
		NoPlayers:SetFont( "BailNameFont" )
		NoPlayers:SetTextColor( Color( 200, 200, 200 ) )
		NoPlayers:SizeToContents()
		NoPlayers:Center()
	end
	
	local BailList = vgui.Create( "DPanelList", BailMain )
	BailList:SetPos( 10, 60 )
	BailList:SetSize( BailMain:GetWide() - 20, BailMain:GetTall() - 80 )
	BailList:SetSpacing( 2 )
	BailList:EnableVerticalScrollbar( true )
	BailList.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	BailList.VBar.btnUp.Paint = function( s, w, h ) end
	BailList.VBar.btnDown.Paint = function( s, w, h ) end
	BailList.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end
	
	if table.Count( peopletosend ) != 0 then
		for k, v in pairs( peopletosend ) do
			if v[1]:isArrested() then
				local PlayerMain = vgui.Create( "DFrame" )
				PlayerMain:SetSize( BailList:GetWide(), 120 )
				PlayerMain:ShowCloseButton( false )
				PlayerMain:SetTitle( "" )
				PlayerMain.Paint = function( self, w, h )
					drawRectOutline( 2, 2, w - 2, h - 2, Color( 0, 0, 0, 85 ) )
					draw.RoundedBox(0, 2, 2, w , h , Color(0,0,0,125))
				end
				
				local NameLabel = vgui.Create("DLabel", PlayerMain)
				NameLabel:SetPos(84, 22)
				NameLabel:SetSize(9999, 30)
				NameLabel:SetFont("BailNameFontSmall")
				NameLabel:SetText(v[1]:Name())
				NameLabel:SetTextColor(Color(255,255,255))

				local ArrestedByLabel = vgui.Create("DLabel", PlayerMain)
				ArrestedByLabel:SetPos(84, 44)
				ArrestedByLabel:SetSize(9999, 30)
				ArrestedByLabel:SetFont("BailJobFont")
				ArrestedByLabel:SetText("Arrested By: "..v[4])
				ArrestedByLabel:SetTextColor(Color(255,255,255))

				local TimeRemainingLabel = vgui.Create("DLabel", PlayerMain)
				TimeRemainingLabel:SetPos(84, 58)
				TimeRemainingLabel:SetSize(9999, 30)
				TimeRemainingLabel:SetFont("BailJobFont")
				TimeRemainingLabel:SetText("Jail time remaining: "..tostring(math.Round(GAMEMODE.Config.jailtimer - (math.abs(v[3] - CurTime())))).." (not live)")
				TimeRemainingLabel:SetTextColor(Color(255,255,255))
				
				local BailFeeLabel = vgui.Create("DLabel", PlayerMain)
				BailFeeLabel:SetPos(84, 75)
				BailFeeLabel:SetSize(9999, 30)
				BailFeeLabel:SetFont("BailJobFont")
				BailFeeLabel:SetText("Bail price: "..DarkRP.formatMoney(tonumber(v[2])))
				BailFeeLabel:SetTextColor(Color(255,255,255))				
				
				local ava = vgui.Create( "AvatarImage", PlayerMain )
				ava:SetPos( 15, 30 )
				ava:SetSize( 64, 64 )
				ava:SetPlayer( v[1], 64 )
					
				local BailButton = vgui.Create( "DButton", PlayerMain )
				BailButton:SetPos( PlayerMain:GetWide() - 114, PlayerMain:GetTall() - 26 )
				BailButton:SetSize( 80, 20 )
				BailButton:SetDrawOnTop( true )
				BailButton:SetTextColor( Color( 255, 255, 255 ) )
				BailButton:SetText( "Bail Out" )
				BailButton.Paint = function( self, w, h )
					DrawBlur(BailButton, 2)
					drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
				end
				BailButton.DoClick = function( self )
					net.Start( "BailNPCUsedToBail" )
						net.WriteEntity( v[1] )
					net.SendToServer()
					BailMain:Close()
				end				
				BailList:AddItem( PlayerMain )
				
				PlayerMain.Think = function()
					if not v[1]:getDarkRPVar( "Arrested" ) then
						BailList:RemoveItem( PlayerMain )
					end
				end				
			end
		end
	else
		NoArrestedPlayers()
	end
end)

net.Receive("BailNPCBailed", function()
	local ply = net.ReadEntity()
	chat.AddText( Color(255,0,0), "[Bail NPC] ", Color(255,255,255), "You have been bailed out of jail by "..ply:Nick().."!" )
end)
net.Receive("BailNPCBailer", function()
	local ply = net.ReadEntity()
	chat.AddText( Color(255,0,0), "[Bail NPC] ", Color(255,255,255), "You have bailed "..ply:Nick().." out of jail!" )
end)
net.Receive("BailNPCBailChanged", function()
	local ply = net.ReadEntity()
	local price = net.ReadFloat()
	chat.AddText( Color( 0, 255, 0 ), "You changed the bail price of "..ply:Nick().." to $"..price.."!" )
end)
net.Receive("BailNPCMessage", function()
	local message = net.ReadString()
	chat.AddText(Color(255,0,0), "[Bail NPC] ", Color(255,255,255), message)
end)

local function BailNPCTextBounceCL()
        for k, v in pairs( ents.FindByClass( "bail_npc" ) ) do
               
                local p
                
               
                        p = v:GetPos() + Vector(0,0,90 + math.sin(CurTime()*3)*5)
               
               
       
                for _,yaw in pairs({0, 180}) do
       
                        local a = Angle(0, 0, 0)
                        a:RotateAroundAxis(a:Forward(), 90)
                        a:RotateAroundAxis(a:Right(), yaw)
                       
                                a:RotateAroundAxis(a:Right(), CurTime() * 15)
                 
               
                        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
                        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                        cam.Start3D2D(p, a, 0.1)
                                draw.DrawText("Bail NPC", "BailNPCTextBounce", 0, 0, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        cam.End3D2D()
                        render.PopFilterMag()
                        render.PopFilterMin()
                end
        end
end
hook.Add( "PostDrawOpaqueRenderables", "BailNPCTextBounceCL", BailNPCTextBounceCL)