--[[You really should not edit this!]]--
local version = "3.7" -- DO NOT EDIT THIS!
local version_url = "https://gist.githubusercontent.com/XxLMM13xXgaming/48eec2f2e65594cf1d63/raw/Bail%2520NPC" -- DO NOT EDIT THIS!
local update_url = "https://github.com/XxLMM13xXgaming/lmm_bail_npc" -- DO NOT EDIT THIS!
local update_ru = "https://gist.githubusercontent.com/XxLMM13xXgaming/27df90c0b98e7f0a14bd5e2445d41a67/raw/Bail%2520NPC%2520UR"
local msg_outdated = "You are using a outdated/un-supported version. You are on version "..version.."! Please download the new version here: " .. update_url -- DO NOT EDIT THIS!
local ranksthatgetnotify = { "superadmin", "owner", "admin" } -- DO NOT EDIT THIS!

if (SERVER) then

	util.AddNetworkString("BailNPCVersionCheckCL")
	util.AddNetworkString("BailNPCVersionCheckCLUR")

	http.Fetch(version_url, function(body, len, headers, code, ply)
		if (string.Trim(body) ~= version) then
			MsgC( Color(255,0,0), "[Bail NPC ("..version..")] You are NOT using the latest version! (version: "..string.Trim(body)..")\n" )
		else
			MsgC( Color(255,0,0), "[Bail NPC ("..version..")] You are using the latest version!\n" )
		end
	end )	
	timer.Create("BailNPCVersionCheckServerTimer", 600, 0, function()
		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				MsgC( Color(255,0,0), "[Bail NPC ("..version..")] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
			end
		end )
	end )
	
	for k, v in pairs(player.GetAll()) do
		if (table.HasValue( ranksthatgetnotify, v:GetUserGroup() ) ~= true) then return end
		
		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				net.Start("BailNPCVersionCheckCL")
					net.WriteString(string.Trim(body))
				net.Send(v)
				timer.Create( "BailNPCVersionCheckTimer", 600, 6, function()
					net.Start("BailNPCVersionCheckCL")
						net.WriteString(string.Trim(body))
					net.Send(v)
				end )
				
				http.Fetch(update_ru, function(body, len, headers, code, ply)
					net.Start("BailNPCVersionCheckCLUR")
						net.WriteString(body)
					net.Send(v)	
				end)				
			else

			end
			  
		end, function(error)

			-- Silently fail

		end)	
	end
	
	hook.Add("PlayerInitialSpawn", "BailNPCVersionCheck", function(theply)
		if (table.HasValue( ranksthatgetnotify, theply:GetUserGroup() ) ~= true) then return end
		
		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				net.Start("BailNPCVersionCheckCL")
					net.WriteString(string.Trim(body))
				net.Send(theply)
				timer.Create( "BailNPCVersionCheckTimer", 600, 6, function()
					net.Start("BailNPCVersionCheckCL")
						net.WriteString(string.Trim(body))
					net.Send(theply)
				end )
				http.Fetch(update_ru, function(body, len, headers, code, ply)
					net.Start("BailNPCVersionCheckCLUR")
						net.WriteString(body)
					net.Send(theply)		 
				end)								
			else

			end
			  
		end, function(error)

			-- Silently fail

		end)
	end)
	
	
end

if (CLIENT) then

	net.Receive("BailNPCVersionCheckCL", function()
		local nversion = net.ReadString()
		MsgC(Color(0,0,0), "-----------------------------------------------------------------------------------\n")
		chat.AddText(Color(255,0,0), "[Bail NPC]: ", Color(255,255,255), "Bail NPC is outdated! You are on version "..version.." and version "..nversion.." is out! Check console for more info!")		
		MsgC(Color(0,255,0), msg_outdated.."\n\n")
	end)
	
	net.Receive("BailNPCVersionCheckCLUR", function()
		local reason = net.ReadString()

		MsgC(Color(0,255,0), "Whats new: "..reason.."\n")
		MsgC(Color(0,0,0), "-----------------------------------------------------------------------------------\n")
	end)
end
