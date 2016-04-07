AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
util.AddNetworkString( "OpenBailMenuNEW" )
util.AddNetworkString( "BailNPCUsedToBail" )
util.AddNetworkString( "BailNPCBailChanged" )
util.AddNetworkString( "BailNPCBailer" )
util.AddNetworkString( "BailNPCBailed" )
util.AddNetworkString( "BailNPCMessage" )

function ENT:Initialize()
	self:SetModel( "models/humans/group03/male_01.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE, CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	self.health = 100
	self:SetMaxYawSpeed( 90 )
end

--[[
Don't see much point in these checks. Maybe make a config option that lets you disable the command entirely but still allow players to bail themselves out?
This way you could create a simple kind of jailbreak system, if the player gets out of the jail and presses e on the bailer, bailprace is set to 0 and player unarrested.
]]
local function BailSystemCommandToOpen(ply, text)
	local text = string.lower(text)
	if(string.sub(text, 0, 5)== "!bail" or string.sub(text, 0, 5)== "/bail") then
		if BailNPCConfig.AllowedToBailSelfOut then
			if ply:isArrested() then
				BailNPCOpenMenu(ply, false)
			else
				net.Start("BailNPCMessage")
					net.WriteString("You will need to visit the bail npc!")
				net.Send(ply)
			end
			return ''
		end
		return ''		
	end
end 
hook.Add("PlayerSay", "BailSystemCommandToOpen", BailSystemCommandToOpen)

function BailNPCOpenMenu(ply, yesorno)
	if yesorno then
		local peopletosend = {}
		for k, v in pairs(player.GetAll()) do
			if v:isArrested() then
				local BA = v.BailAmount
				local TA = v.TimeArrested
				local BC = v.BailCop
				
				table.insert(peopletosend, {v, BA, TA, BC})
			end
		end		
		net.Start( "OpenBailMenuNEW" )
			net.WriteTable(peopletosend)
		net.Send(ply)
	else
		local peopletosend = {}
		for k, v in pairs(player.GetAll()) do
			if v:isArrested() and v == ply then
				local BA = v.BailAmount
				local TA = v.TimeArrested
				local BC = v.BailCop
				
				table.insert(peopletosend, {v, BA, TA, BC})
			end
		end		
		net.Start( "OpenBailMenuNEW" )
			net.WriteTable(peopletosend)
		net.Send(ply)	
	end
end

function playerArrestedSetBail(criminal, time, actor)
--	criminal:SetNWInt( "BailAmount", BailNPCConfig.DefaultBailPrice )
--	criminal:SetNWFloat( "TimeArrested", CurTime() )
--	criminal:SetNWString( "BailCop", tostring(actor:Nick()) )

    criminal.BailAmount = BailNPCConfig.DefaultBailPrice
	criminal.TimeArrested = CurTime()
	criminal.BailCop = tostring(actor:Nick())

	if BailNPCConfig.AllowedToBailSelfOut then
		net.Start("BailNPCMessage")
			net.WriteString("You can type !bail to bail yourself out!")
		net.Send(criminal)
	end
	//Checks if NotifyOnArrest ->and<- MaxSetBailPrice are set to true, if so will send the player a message including the max bail price, else it will display a message without it.
	if BailNPCConfig.NotifyOnArrest and BailNPCConfig.MaxSetBailPrice then
	net.Start("BailNPCMessage")
		net.WriteString("You can type '!setbail <player name> <price>' to reset this players bailprice (default is: $"..BailNPCConfig.DefaultBailPrice..") Max bailprice is "..BailNPCConfig.MaxSetBailPriceValue.."."))
	net.Send(actor)
	elseif BailNPCConfig.NotifyOnArrest then
	net.Start("BailNPCMessage")
		net.WriteString("You can type '!setbail <player name> <price>' to reset this players bailprice (default is: $"..BailNPCConfig.DefaultBailPrice..".)"))
	net.Send(actor)
	end
end
hook.Add( "playerArrested", "playerArrestedSetBail", playerArrestedSetBail )

function GetPlayerByName( ply )
	local Players = player.GetAll()
	for i=1, table.Count( Players ) do
		if string.find( string.lower( Players[i]:Nick() ), string.lower( ply ) ) then
			return Players[i]
		end
	end
	return nil
end
 
net.Receive( "BailNPCUsedToBail", function( len, ply )
	local ArrestedPly = net.ReadEntity()
	local BailPly = ply
	local BailPrice = ArrestedPly.BailAmount

	if ply:getDarkRPVar("money") < BailPrice then
		net.Start("BailNPCMessage")
			net.WriteString("You do not have enough money!")
		net.Send(BailPly)
		return
	end
	//Checks if the arrested player's bailprice is over the max if turned on. If it is, refuse bail.
	if BailPrice > BailNPCConfig.MaxSetBailPriceValue and BailNPCConfig.MaxSetBailPrice then
		net.Start("BailNPCMessage")
			net.WriteString("This players bail is set over the max bailprice! Cannot Bail.")
		net.Send(BailPly)
		return
	end
	
	if !ArrestedPly:isArrested() then
		return
	end
	
	if !BailNPCConfig.DevMode and !BailNPCConfig.AllowedToBailSelfOut then
		if ArrestedPly == BailPly then
			net.Start( "BailNPCMessage" )
				net.WriteString("You can not bail yourself!")
			net.Send(BailPly)
			return
		end
	end
	
	if BailPly:getDarkRPVar( "money" ) < tonumber(BailPrice) then
		return
	end

	if !ply:IsPlayer() then
		return
	end

	BailPly:addMoney( -BailPrice ) 

	ArrestedPly:unArrest( ArrestedPly )

	net.Start( "BailNPCBailed" )
		net.WriteEntity( BailPly )
	net.Send(ArrestedPly)

	net.Start( "BailNPCBailer" )
		net.WriteEntity( ArrestedPly )
	net.Send(BailPly)
end )	

function GiveBailPrice(ply, text, price)
	local text = string.lower(text)
	if(string.sub(text, 0, 8)== "/setbail" or string.sub(text, 0, 8)== "!setbail") then
		local text = string.Explode(' ', text)
		local jailer = GetPlayerByName( text[2] )
		local price = text[3]
		
		//If price is over maxbailprice(if turned on) return false and notify the player.
		if (BailNPCConfig.MaxSetBailPrice and price > BailNPCConfig.MaxSetBailPriceValue) then
			net.Start( "BailNPCMessage" )
				net.WriteString("The max setbail price is "..BailNPCConfig.MaxSetBailPriceValue.."!")
			net.Send(ply)
			return false
		end

		if(!jailer) then
			net.Start( "BailNPCMessage" )
				net.WriteString("No person found! (!setbail <player> <price>)")
			net.Send(ply)
			return false
		end
		if(!price) then
			net.Start( "BailNPCMessage" )
				net.WriteString("No price found! (!setbail <player> <price>)")
			net.Send(ply)
			return false
		end
		if (!ply:isCP()) then
			net.Start( "BailNPCMessage" )
				net.WriteString("You need to be a cop to set a bail price!!")
			net.Send(ply)
			return false
		end
		if (!jailer:isArrested()) then
			net.Start( "BailNPCNoArrestedCommand" )
				net.WriteString("This player is not arrested!")
			net.Send(ply)
			return false
		end
		
		jailer.BailAmount = price
		
		net.Start( "BailNPCBailChanged" )
			net.WriteEntity( jailer )
			net.WriteFloat( tonumber(price) )
		net.Send(ply)
		
		return ''
	end
end
hook.Add("PlayerSay", "GiveBailPrice", GiveBailPrice)

function SpawnBailNPC()
	local npc = ents.Create("bail_npc")
	npc:Spawn()
	npc:SetPos( BailNPCConfig.PosToSpawn )
	npc:SetAngles( BailNPCConfig.AngleToSpawn)
	npc:SetMoveType( MOVETYPE_NONE )
	npc:DropToFloor()	
end
hook.Add( "InitPostEntity", "SpawnBailNPC", SpawnBailNPC)

function ENT:OnTakeDamage(dmg)
	return false
end

function ENT:AcceptInput( Name, Activator, Caller )	
	if Name == "Use" and Caller:IsPlayer() then
		if Caller:isCP() and !BailNPCConfig.DevMode then
			net.Start( "BailNPCMessage" )
				net.WriteString("Your a cop! You can not bail people out!")
			net.Send(Caller)
			return 
		else
			BailNPCOpenMenu(Caller, true)
		end
	end
end