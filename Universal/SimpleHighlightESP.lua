--[[
   Credit to Polarrr#0001 for original script (it's been moddied quite a bit to support loadstrings)
   https://v3rmillion.net/member.php?action=profile&uid=2340618
--]]

local lib = {}
local Folder = Instance.new("Folder", game:GetService("CoreGui"))

function lib:AddOutline(Character, OutlineFill)
   local OutlineFill = OutlineFill or false;
   local Highlight = Instance.new("Highlight", Folder)
   
   Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
   Highlight.Adornee = Character
   
   if OutlineFill == true then
       Highlight.FillColor = Color3.fromRGB(255, 255, 255)
       Highlight.FillTransparency = 1
   else
       Highlight.FillTransparency = 1
   end
end

function lib:AddAIOutline(Character, OutlineFill)
   local OutlineFill = OutlineFill or false;
   local Highlight = Instance.new("Highlight", Folder)
   
   Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
   Highlight.Adornee = Character
   
   if OutlineFill then
       Highlight.FillColor = Color3.fromRGB(255, 0, 0)
       Highlight.FillTransparency = 0
   else
       Highlight.FillTransparency = 1
   end
end

function lib:AddNameTag(Character)
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
   TextLabel.Font = Enum.Font.RobotoMono
   TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
   TextLabel.TextScaled = false
end

function lib:ClearESP()
   for i,v in pairs(Folder:GetChildren()) do
      v:Destroy();
   end
end

return lib;
