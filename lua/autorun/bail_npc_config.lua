BailNPCConfig = {}
BailNPCConfig.DevMode = false -- Do not touch this.. its not a playable version.. (its for testing LEAVE TO FALSE)
/*
  ____        _ _   _   _ _____   _____                                                    
 |  _ \      (_) | | \ | |  __ \ / ____|                                                   
 | |_) | __ _ _| | |  \| | |__) | |                                                        
 |  _ < / _` | | | | . ` |  ___/| |                                                        
 | |_) | (_| | | | | |\  | |    | |____                                                    
 |____/_\__,_|_|_| |_| \_|_|____ \_____|                                                   
 |  \/  |         | |      |  _ \       _                                                  
 | \  / | __ _  __| | ___  | |_) |_   _(_)                                                 
 | |\/| |/ _` |/ _` |/ _ \ |  _ <| | | |                                                   
 | |  | | (_| | (_| |  __/ | |_) | |_| |_                                                  
 |_|  |_|\__,_|\__,_|\___| |____/ \__, (_)                                                 
                                   __/ |                                                   
 __   __      _      __  __ __  __|___/___       __   __                     _             
 \ \ / /     | |    |  \/  |  \/  /_ |___ \      \ \ / /                    (_)            
  \ V / __  _| |    | \  / | \  / || | __) |_  __ \ V / __ _  __ _ _ __ ___  _ _ __   __ _ 
   > <  \ \/ / |    | |\/| | |\/| || ||__ <\ \/ /  > < / _` |/ _` | '_ ` _ \| | '_ \ / _` |
  / . \  >  <| |____| |  | | |  | || |___) |>  <  / . \ (_| | (_| | | | | | | | | | | (_| |
 /_/ \_\/_/\_\______|_|  |_|_|  |_||_|____//_/\_\/_/ \_\__, |\__,_|_| |_| |_|_|_| |_|\__, |
                                                        __/ |                         __/ |
                                                       |___/                         |___/ 
*/

--NOTE: If you see (BETA) next to the option it may not work! You should leave it alone... Or mess with it and report errors!
-- Vector for the NPC to spawn
BailNPCConfig.PosToSpawn = Vector( -1426.662720, 27.279352, -131.968750 )
BailNPCConfig.AngleToSpawn = Angle( -1.639990, 0.640245, 0.000000 )

BailNPCConfig.CopsGetMoney = true -- Should police get money when people bail out anyone (BETA)

BailNPCConfig.DefaultBailPrice = 1000 -- When a police member does not set the players bail this is what it will be...

BailNPCConfig.AllowedToBailSelfOut = true -- Should a player be allowed to bail themself out using !bail?

BailNPCConfig.MaxSetBailPrice = true -- Should there be a max setbail price?

BailNPCConfig.MaxSetBailPriceValue = 25000 --What should be the max bail price for !setbail?

BailNPCConfig.NotifyOnArrest = true --Should cops get a notification upon arresting someone?