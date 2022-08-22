--[[
   Credit to Polarrr#0001 for original script
   https://v3rmillion.net/member.php?action=profile&uid=2340618
--]]


local Outlines = true
local OutlineColoring = Color3.fromRGB(255, 255, 255)
local OutlineFill = false
local FillOpacity = 1
local FillColoring = Color3.fromRGB(255, 255, 255)

local NameTags = true
local TextFont = Enum.Font.RobotoMono
local NameColor = Color3.fromRGB(255, 255, 255)
local NamePositioning = false

local Folder = Instance.new("Folder", game:GetService("CoreGui"))
Folder.Name = "highlights_oof"

AddOutline = function(Character)
   local Highlight = Instance.new("Highlight", Folder)
   
   Highlight.OutlineColor = OutlineColoring
   Highlight.Adornee = Character
   
   if OutlineFill == true then
       Highlight.FillColor = FillColoring
       Highlight.FillTransparency = FillOpacity
   else
       Highlight.FillTransparency = 1
   end
end

AddNameTag = function(Character)
   local BGui = Instance.new("BillboardGui", Folder)
   local Frame = Instance.new("Frame", BGui)
   local TextLabel = Instance.new("TextLabel", Frame)
   
   BGui.Adornee = Character:WaitForChild("Head")
   BGui.StudsOffset = Vector3.new(0, 3, 0)
   BGui.AlwaysOnTop = true
   
   BGui.Size = UDim2.new(4, 0, 0.5, 0)
   Frame.Size = UDim2.new(1, 0, 1, 0)
   TextLabel.Size = UDim2.new(1, 0, 1, 0)
   
   Frame.BackgroundTransparency = 1
   TextLabel.BackgroundTransparency = 1
   
   TextLabel.Text = Character.Name
   TextLabel.Font = TextFont
   TextLabel.TextColor3 = NameColor
   TextLabel.TextScaled = NamePositioning
end

ClearESP = function()
   for i,v in pairs(Folder:GetChildren())
      v:Destroy();
   end
end
