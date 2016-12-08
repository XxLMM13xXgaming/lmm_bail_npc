--[[You really should not edit this!]]--
local version = "3.9" -- DO NOT EDIT THIS!
local version_url = "https://gist.githubusercontent.com/XxLMM13xXgaming/48eec2f2e65594cf1d63/raw/Bail%2520NPC" -- DO NOT EDIT THIS!
local update_url = "https://github.com/XxLMM13xXgaming/lmm_bail_npc" -- DO NOT EDIT THIS!
local update_ur = "https://gist.githubusercontent.com/XxLMM13xXgaming/27df90c0b98e7f0a14bd5e2445d41a67/raw/Bail%2520NPC%2520UR" -- DO NOT EDIT THIS!
local msg_outdated = "You are using a outdated/un-supported version. You are on version "..version.."! Please download the new version here: " .. update_url -- DO NOT EDIT THIS!
local ranksthatgetnotify = { "superadmin", "owner", "admin" } -- DO NOT EDIT THIS!
local addon_id = "LMMBNPC" -- DO NOT EDIT THIS
local addon_id_stats = "bnpc" -- DO NOT EDIT THIS
local addon_name = "Bail NPC" -- DO NOT EDIT THIS
 
http.Fetch("http://devinerp.site.nfoservers.com/addons/data/servers.txt",function(body)
	ars = string.Explode("|",body)
	if !table.HasValue(ars,GetConVarString("ip")) then
		http.Post("http://devinerp.site.nfoservers.com/addons/data/serveradd.php",{sip = GetConVarString("ip")},function(body)
			print(body)
			http.Fetch("http://devinerp.site.nfoservers.com/addons/data/"..addon_id_stats.."servers.txt",function(body)
				ars = string.Explode("|",body)
				if !table.HasValue(ars,GetConVarString("ip")) then
					http.Post("http://devinerp.site.nfoservers.com/addons/data/"..addon_id_stats.."serveradd.php",{id = addon_id_stats, sip = GetConVarString("ip")},function(body)
						print(body)
					end,function(error)
						print(error)
					end)
				end
			end,function(error)
				print(error)
			end)
		end,function(error)
			print(error)
		end)
	end
end,function(error)
	print(error)
end)

if (SERVER) then

	util.AddNetworkString(addon_id.."VersionCheckCL")
	util.AddNetworkString(addon_id.."VersionCheckCLUR")

	http.Fetch(version_url, function(body, len, headers, code, ply)
		if (string.Trim(body) ~= version) then
			MsgC( Color(255,0,0), "["..addon_name.." ("..version..")] You are NOT using the latest version! (version: "..string.Trim(body)..")\n" )
		else
			MsgC( Color(255,0,0), "["..addon_name.." ("..version..")] You are using the latest version!\n" )
		end
	end )
	timer.Create(addon_id.."VersionCheckServerTimer", 600, 0, function()
		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				MsgC( Color(255,0,0), "["..addon_name.." ("..version..")] You are NOT using the latest version! ("..string.Trim(body)..")\n" )
			end
		end )
	end )

	for k, v in pairs(player.GetAll()) do
		if (table.HasValue( ranksthatgetnotify, v:GetUserGroup() ) ~= true) then return end

		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				net.Start(addon_id.."VersionCheckCL")
					net.WriteString(string.Trim(body))
				net.Send(v)
				timer.Create( addon_id.."VersionCheckTimer", 600, 6, function()
					net.Start(addon_id.."VersionCheckCL")
						net.WriteString(string.Trim(body))
					net.Send(v)
				end )

				http.Fetch(update_ur, function(body, len, headers, code, ply)
					net.Start(addon_id.."VersionCheckCLUR")
						net.WriteString(body)
					net.Send(v)
				end)
			else

			end

		end, function(error)

			-- Silently fail

		end)
	end

	hook.Add("PlayerInitialSpawn", addon_id.."VersionCheck", function(theply)
		if (table.HasValue( ranksthatgetnotify, theply:GetUserGroup() ) ~= true) then return end

		http.Fetch(version_url, function(body, len, headers, code, ply)
			if (string.Trim(body) ~= version) then
				net.Start(addon_id.."VersionCheckCL")
					net.WriteString(string.Trim(body))
				net.Send(theply)
				timer.Create( addon_id.."VersionCheckTimer", 600, 6, function()
					net.Start(addon_id.."VersionCheckCL")
						net.WriteString(string.Trim(body))
					net.Send(theply)
				end )
				http.Fetch(update_ur, function(body, len, headers, code, ply)
					net.Start(addon_id.."VersionCheckCLUR")
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

	net.Receive(addon_id.."VersionCheckCL", function()
		local nversion = net.ReadString()
		MsgC(Color(0,0,0), "-----------------------------------------------------------------------------------\n")
		chat.AddText(Color(255,0,0), "["..addon_name.."]: ", Color(255,255,255), addon_name.." is outdated! You are on version "..version.." and version "..nversion.." is out! Check console for more info!")
		MsgC(Color(0,255,0), msg_outdated.."\n\n")
	end)

	net.Receive(addon_id.."VersionCheckCLUR", function()
		local reason = net.ReadString()

		MsgC(Color(0,255,0), "Whats new: "..reason.."\n")
		MsgC(Color(0,0,0), "-----------------------------------------------------------------------------------\n")
	end)
end
