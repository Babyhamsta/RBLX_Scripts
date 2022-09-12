-- Wait for game
repeat task.wait() until game:IsLoaded();

messagebox("This script has been patched, do not use without updating");

-- Game Globals
local _Network = getrenv()._G.Network;
local _Player = getrenv()._G.Player;
local _Character = getrenv()._G.Character;
local _Camera = getrenv()._G.Camera;

-- Locals
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Camera = game:GetService("Workspace").Camera;
local Mouse = LocalPlayer:GetMouse();

-- Aimbot
getgenv()._Aimbot = {
    Enabled = false,
    AimSmooth = 3,
    X_Offset = 0,
    Y_Offset = 0
}

getgenv()._SilentAim = {
    Enabled = false,
    Silent_Target = nil,
    X_Offset = 0,
    Y_Offset = 0
}

getgenv().ASSettings = {
    AimType = "To Cursor",
    AimDis = 200,
    AimSleepers = false,
    VisibleCheck = false
}


-- Toggles
getgenv()._Toggles = {
    ESP = false,
    Noclip = false,
    OreESP = false
}

getgenv().Settings = {
    CameraZoom = 0,
    OreMaxDis = 300
}

-- Free Cam Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/FreeCam.lua", true))()

-- Simple ESP (HamstaGang)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua", true))()

-- Linoria Lib
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua", true))()

-- Add Credits
Library:SetWatermarkVisibility(true);
Library:SetWatermark("Created by HamstaGang and LabGuy94 | Last Updated 09/05/2022");

-- Create Window
local Window = Library:CreateWindow({
    Title = "Trident Survival [FREE - DO NOT PAY FOR THIS!]",
    Center = true,
    AutoShow = true,
});

-- Setup Tabs
local Main = Window:AddTab("Main");
local ESP_Window = Window:AddTab("ESP");
local UI_Settings = Window:AddTab('UI Settings');

-- Setup Groups
local Aimbot = Main:AddLeftGroupbox('[Aimbot Settings]');
local SilentAim = Main:AddRightGroupbox('[SilentAim Settings]');
local AS_Settings = Main:AddRightGroupbox('[Aimbot/Silent Settings]');
local GunSettings = Main:AddRightGroupbox('[Gun Settings]');
local GeneralBinds = Main:AddLeftGroupbox('[General Keybinds]');

-- ESP Groups
local OreESP = ESP_Window:AddLeftGroupbox('[Ore ESP]');

-- // Functions \\ --

-- Block Free Cam / Camera Bans
local anticam
anticam = hookmetamethod(game, "__index", newcclosure(function(...)
    local self, k = ...

    if not checkcaller() and k == "CFrame" and self.Name == "Camera" and self == Camera then
        return _Camera.GetCFrame()
    end

    return anticam(...)
end))

-- Sleeping Check
local function IsSleeping(head)
    return (head.Rotation == Vector3.new(0, 0, -75) or head.Rotation == Vector3.new(0, 0, 45)) -- Jank
end

-- Check if Visible
function isPartVisible(part)
    local ignore = workspace.Ignore:GetDescendants();
    local castPoints = {part.Position}
    return Camera:GetPartsObscuringTarget(castPoints, ignore)
end

-- Get Closest to mouse
function getClosestPlayerToCursor()
    local closestPlayer = nil;
    local shortestDistance = ASSettings["AimDis"];

    for i, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= "Player" then
            if v.Humanoid.Health ~= 0 and v.PrimaryPart ~= nil and v:FindFirstChild("Head") then
                if (not isPartVisible(v.PrimaryPart) and not ASSettings["VisibleCheck"]) or (IsSleeping(v.Head) and not ASSettings["AimSleepers"]) then
                    return nil;
                end

                local pos = Camera.WorldToViewportPoint(Camera, v.PrimaryPart.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude

                if magnitude < shortestDistance then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end

    return closestPlayer
end

-- Get Closest to LocalPlayer
function getClosestPlayerToPlayer()
    local closestPlayer = nil;
    local shortestDistance = ASSettings["AimDis"];

    for i, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= "Player" then
            if v.Humanoid.Health ~= 0 and v.PrimaryPart ~= nil and v:FindFirstChild("Head") then
                if (not isPartVisible(v.PrimaryPart) and not ASSettings["VisibleCheck"]) or (IsSleeping(v.Head) and not ASSettings["AimSleepers"]) then
                    return nil;
                end

                local magnitude = (_Character.character.Middle.Position - v.PrimaryPart.Position).magnitude
                if magnitude < shortestDistance then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end

    return closestPlayer
end

-- // Silent Aim \\ --

-- Silent Toggle
SilentAim:AddToggle('SilentAim_Enabled', {
    Text = 'Enable SilentAim',
    Default = false,
    Tooltip = 'Turns on/off silent aim.',
})

Toggles.SilentAim_Enabled:OnChanged(function()
    if Toggles.SilentAim_Enabled.Value then
        _Aimbot["Enabled"] = false;
        Toggles.Aim_Enabled.Value = false;
    end

    _SilentAim["Enabled"] = Toggles.SilentAim_Enabled.Value;
end)

-- Aimbot Keybind
SilentAim:AddLabel('SilentAim Keybind'):AddKeyPicker('SilentAimbot_Bind', {
    Default = 'MB2',
    Text = 'SilentAim Keybind',
    Tooltip = 'Keybind to silent aimbot.',
    NoUI = false,
    Mode = 'Hold',
})

-- Replace Camera function
local OrginalGetCFrame = _Camera.GetCFrame;
_Camera.GetCFrame = function()
    if _SilentAim["Enabled"] and _SilentAim["Silent_Target"] then
        return CFrame.new(OrginalGetCFrame().p, _SilentAim["Silent_Target"].Position + Vector3.new((_SilentAim["X_Offset"]), (_SilentAim["Y_Offset"]), 0.001));
    else
        return OrginalGetCFrame();
    end
end

task.spawn(function()
    while task.wait() do
        local state = Options.SilentAimbot_Bind:GetState()
        if state and _SilentAim["Enabled"] then
            local Target;
            if AS_Settings["AimType"] == "To Cursor" then
                Target = getClosestPlayerToCursor();
            else
                Target = getClosestPlayerToPlayer();
            end
            if Target then
                local Head = Target:FindFirstChild("Head");
                if Head then
                    _SilentAim["Silent_Target"] = Head;
                end
            end
        else
            _SilentAim["Silent_Target"] = nil;
        end

        if Library.Unloaded then break end
    end
end)

-- Silent X Offset
SilentAim:AddSlider('Silent_X', {
    Text = 'X Offset',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

Options.Silent_X:OnChanged(function()
    _SilentAim["X_Offset"] = Options.Silent_X.Value;
end)

-- Silent Y Offset
SilentAim:AddSlider('Silent_Y', {
    Text = 'Y Offset',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

Options.Silent_Y:OnChanged(function()
    _SilentAim["Y_Offset"] = Options.Silent_Y.Value;
end)


-- // Aimbot \\ --

-- Aimbot Toggle
Aimbot:AddToggle('Aim_Enabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Tooltip = 'Turns on/off the aimbot.',
})

Toggles.Aim_Enabled:OnChanged(function()
    if Toggles.Aim_Enabled.Value then
        _SilentAim["Enabled"] = false;
        Toggles.SilentAim_Enabled.Value = false;
    end

    _Aimbot["Enabled"] = Toggles.Aim_Enabled.Value;
end)

-- Aimbot Keybind
Aimbot:AddLabel('Aimbot Keybind'):AddKeyPicker('Aimbot_Bind', {
    Default = 'MB2',
    Text = 'Aimbot Keybind',
    Tooltip = 'Keybind to aimbot.',
    NoUI = false,
    Mode = 'Hold',
})

task.spawn(function()
    while task.wait() do
        local state = Options.Aimbot_Bind:GetState()
        if state and _Aimbot["Enabled"] then
            local Target;
            if AS_Settings["AimType"] == "To Cursor" then
                Target = getClosestPlayerToCursor();
            else
                Target = getClosestPlayerToPlayer();
            end
            if Target then
                local Head = Target:FindFirstChild("Head");
                if Head then
                    local pos, _ = Camera:WorldToScreenPoint(Head.Position)
                    mousemoverel((pos.X - (Mouse.X + _Aimbot["X_Offset"]))/_Aimbot["AimSmooth"], (pos.Y - (Mouse.Y + _Aimbot["Y_Offset"]))/_Aimbot["AimSmooth"])
                end
            end
        end

        if Library.Unloaded then break end
    end
end)

-- Aim Smoothing
Aimbot:AddSlider('Aim_Smooth', {
    Text = 'Smoothing',
    Default = 1,
    Min = 1,
    Max = 85,
    Rounding = 0,
    Compact = false,
})

Options.Aim_Smooth:OnChanged(function()
    ASSettings["AimSmooth"] = Options.Aim_Smooth.Value;
end)

-- Aimbot X Offset
Aimbot:AddSlider('Aimbot_X', {
    Text = 'X Offset',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

Options.Aimbot_X:OnChanged(function()
    Aimbot["X_Offset"] = Options.Aimbot_X.Value;
end)

-- Aimbot Y Offset
Aimbot:AddSlider('Aimbot_Y', {
    Text = 'Y Offset',
    Default = 0,
    Min = -100,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

Options.Aimbot_Y:OnChanged(function()
    Aimbot["Y_Offset"] = Options.Aimbot_Y.Value;
end)


-- // Aimbot/Silent Settings \\ --

AS_Settings:AddDropdown('AimTypeDrop', {
    Values = {"To Cursor", "To Player"},
    Default = 1,
    Multi = false,

    Text = 'Target Closest',
    Tooltip = 'Changes how the aimbot/silent aim selects a target.',
})

Options.AimTypeDrop:OnChanged(function()
    AS_Settings["AimType"] = Options.AimTypeDrop.Value;
end)

-- Aim Distance
AS_Settings:AddSlider('Aim_Distance', {
    Text = 'Max Distance',
    Default = 200,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
})

Options.Aim_Distance:OnChanged(function()
    ASSettings["AimDis"] = Options.Aim_Distance.Value;
end)

-- Visible Check
AS_Settings:AddToggle('Aim_Visible', {
    Text = 'Visible Check',
    Default = false,
    Tooltip = 'Toggles aiming only if player is visible.',
})

Toggles.Aim_Visible:OnChanged(function()
    ASSettings["VisibleCheck"] = Toggles.Aim_Visible.Value;
end)

-- Sleeping Aim
AS_Settings:AddToggle('Aim_Sleepers', {
    Text = 'Aim at Sleepers',
    Default = false,
    Tooltip = 'Toggles aiming at sleeping players.',
})

Toggles.Aim_Sleepers:OnChanged(function()
    ASSettings["AimSleepers"] = Toggles.Aim_Sleepers.Value;
end)


-- // Gun Settings \\ --

-- No Recoil
GunSettings:AddToggle('No_Recoil', {
    Text = 'No Recoil (Bows/Guns)',
    Default = false,
    Tooltip = 'Disables recoil for bows/guns',
})

-- Store Orginal Recoil function
local RecoilFunc = _Camera.Recoil;

Toggles.No_Recoil:OnChanged(function()
    local Bool = Toggles.No_Recoil.Value;

    if Bool then
        _Camera.Recoil = function()
            return;
        end
    else
        _Camera.Recoil = RecoilFunc;
    end
end)


-- // Keybinds \\ --

-- Grab All
GeneralBinds:AddLabel('Grab All'):AddKeyPicker('Grab_All', {
    Default = 'F',
    Text = 'Grab All',
    Tooltip = 'Auto grabs all items in chest/inventory.',
    NoUI = false,
})

Options.Grab_All:OnClick(function()
    for i = 1, 20 do
        task.wait()
        _Network.Send("QuickMove", i, true);
    end
end)

-- Camera Zoom Out
GeneralBinds:AddLabel('Camera Zoom Out'):AddKeyPicker('Camera_Zoom_Out', {
    Default = 'LeftBracket',
    Text = 'Camera Zoom Out',
    Tooltip = 'Zooms the camera out.',
    NoUI = false,
})

Options.Camera_Zoom_Out:OnClick(function()
    if (Settings["CameraZoom"] - 1) < 0 then return; end
    Settings["CameraZoom"] = Settings["CameraZoom"] - 1;
    _Camera.SetZoom(Settings["CameraZoom"]);
end)

-- Camera Zoom In
GeneralBinds:AddLabel('Camera Zoom In'):AddKeyPicker('Camera_Zoom_In', {
    Default = 'RightBracket',
    Text = 'Camera Zoom In',
    Tooltip = 'Zooms the camera in.',
    NoUI = false,
})

Options.Camera_Zoom_In:OnClick(function()
    Settings["CameraZoom"] = Settings["CameraZoom"] + 1;
    _Camera.SetZoom(Settings["CameraZoom"]);
end)

-- Free Cam
GeneralBinds:AddLabel('Free Cam'):AddKeyPicker('Free_Cam', {
    Default = 'B',
    Text = 'Free Cam',
    Tooltip = 'Allows you to go into a free cam mode.',
    NoUI = false,
})

Options.Free_Cam:OnClick(function()
    ToggleFreecam();
end)

-- ESP Toggle
GeneralBinds:AddLabel('Name ESP'):AddKeyPicker('ESP_Toggle', {
    Default = 'Semicolon',
    Text = 'Toggle ESP',
    Tooltip = 'Abuses the built in ESP.',
    NoUI = false,
})

Options.ESP_Toggle:OnClick(function()
    if not _Toggles["ESP"] then
        _Toggles["ESP"] = true;
        _Player.SetEsp(true);
    else
        _Toggles["ESP"] = false;
        _Player.SetEsp(false);
    end
end)

-- Noclip Toggle
GeneralBinds:AddLabel('Noclip (CAN BAN)'):AddKeyPicker('Noclip_Toggle', {
    Default = 'V',
    Text = 'Toggle Noclip',
    Tooltip = 'CAN BAN IF ABUSED!',
    NoUI = false,
})

Options.Noclip_Toggle:OnClick(function()
    if not _Toggles["Noclip"] then
        _Toggles["Noclip"] = true;
        _Character.SetNoclipping(true);
    else
        _Toggles["Noclip"] = false;
        _Character.SetNoclipping(false);
    end
end)


--  // [[ ESP Window ]] \\ --

-- Ore ESP Toggle
OreESP:AddToggle('Ore_Toggle', {
    Text = 'Ore ESP',
    Default = false,
    Tooltip = 'Turns on/off Ore ESP.',
})

Toggles.Ore_Toggle:OnChanged(function()
    _Toggles["OreESP"] = Toggles.Ore_Toggle.Value;
end)

task.spawn(function()
    while task.wait(0.1) do
        if _Toggles["OreESP"] then
            SESP_Clear("OreESP");
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and v.Name == "Model" and v:FindFirstChild("Meshes/rock") and _Character.character then
                    local OreType = ""
                    local FunnyColor = nil
                    for _, v2 in pairs(v:GetChildren()) do
                        if v2:IsA("MeshPart") then
                            if v2.BrickColor == BrickColor.new(352) then
                                OreType = "Iron Ore"
                                FunnyColor = Color3.fromRGB(199, 172, 120)
                            end
                            if v2.BrickColor == BrickColor.new(1001) then
                                OreType = "Nitrate Ore"
                                FunnyColor = Color3.fromRGB(248, 248, 248)
                            end
                        end
                    end
                    if #v:GetChildren() == 1 then
                        OreType = "Stone Ore"
                        FunnyColor = Color3.fromRGB(205, 205, 205)
                    end
                    local Dist = math.floor((_Character.character.Middle.Position - v:FindFirstChild("Meshes/rock").Position).magnitude);
                    if Dist < Settings["OreMaxDis"] then
                        SESP_Create(v:FindFirstChild("Meshes/rock"), OreType, "OreESP", FunnyColor, Dist)
                    end
                end
            end
        else
            SESP_Clear("OreESP");
        end
    end
end)

-- Ore ESP Distance
OreESP:AddSlider('Ore_Distance', {
    Text = 'Max Distance',
    Default = 300,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Compact = false,
})

Options.Ore_Distance:OnChanged(function()
    Settings["OreMaxDis"] = Options.Ore_Distance.Value;
end)


--  // [[ UI Settings]] \\ --

-- Toggle UI
local MenuGroup = UI_Settings:AddLeftGroupbox('Menu')

-- Setup Toggle
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind;
