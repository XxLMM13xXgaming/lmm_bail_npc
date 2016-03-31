ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Bail NPC"
ENT.Category = "Bail NPC"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true 
 
function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end