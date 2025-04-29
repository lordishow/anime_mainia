if not game:IsLoaded() then
    repeat
        task.wait(1)
    until game:IsLoaded()
end

-- bypass made by me

loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/lordishow/anime_mainia_bypass/refs/heads/main/bypass.lua'
    )
)()

getgenv().Anime_Mainia_Rayfield = nil
local RNR_ENVIRONMENT = getgenv().Anime_Mainia_Rayfield
if not RNR_ENVIRONMENT then
    getgenv().Anime_Mainia_Rayfield = {
        RUNTIME = {
            _running_ = true,
            _running_connection_ = nil,
        },
    }
    RNR_ENVIRONMENT = getgenv().Anime_Mainia_Rayfield
else
    RNR_ENVIRONMENT.RUNTIME._running_ = false
    print('cooking previous one')
    task.wait(1)
    print('cooked')
    RNR_ENVIRONMENT.RUNTIME._running_ = true
end
local RUNTIME = RNR_ENVIRONMENT.RUNTIME

local SERVICES = {
    Replicated = game:GetService('ReplicatedStorage'),
    UserInput = game:GetService('UserInputService'),
    Players = game:GetService('Players'),
    CoreGui = game:GetService('CoreGui'),
    Run = game:GetService('RunService'),
    Teleport = game:GetService('TeleportService'),
}

local this_player = {
    Player = SERVICES.Players.LocalPlayer,
    Character = SERVICES.Players.LocalPlayer.Character,
    HumanoidRootPart = SERVICES.Players.LocalPlayer.Character.HumanoidRootPart,
    Humanoid = SERVICES.Players.LocalPlayer.Character.Humanoid,
    Mouse = SERVICES.Players.LocalPlayer:GetMouse(),
    Ban = SERVICES.Players.LocalPlayer.Character.Ban,
}

this_player.Player.CharacterAdded:Connect(function(new_character)
    this_player.Character = new_characterar
    this_player.HumanoidRootPart = new_character:WaitForChild(
        'HumanoidRootPart'
    )
    this_player.Humanoid = new_character:WaitForChild('Humanoid')
    this_player.Ban = new_character:WaitForChild('Ban')
end)

-- // GENERAL VARIABLES // GENERAL STORE //
local Keep_On_Teleport = false

--|| MOVEMENT LOGIC VARIABLES // -- // LOGIC MOVEMENT VARIABLES //
local Custom_Movement = {
    toggled = false,
    walkspeed = 16,
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = 'Rayfield Mania',
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = 'Rayfield Mainia Suite',
    LoadingSubtitle = 'by | lord is a hoe |',
    Theme = 'DarkBlue', -- Check https://docs.sirius.menu/rayfield/configuration/themes

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'Anime_Mainia_Globberguk', -- Create a custom folder for your hub/game
        FileName = 'config',
    },

    Discord = {
        Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
        Invite = 'noinvitelink', -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
        RememberJoins = true, -- Set this to false to make them join the discord every time they load it up
    },

    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
        Title = 'Untitled',
        Subtitle = 'Key System',
        Note = 'No method of obtaining the key is provided', -- Use this to tell the user how to get a key
        FileName = 'Key', -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
        SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
        GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
        Key = { 'Hello' }, -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    },
})

local General_Tab = Window:CreateTab('General', 4483362458) -- Title, Image

local Keep_After_Teleport_Toggle = General_Tab:CreateToggle({
    Name = 'Keep after teleport',
    CurrentValue = false,
    Flag = 'keep after tp',
    Callback = function(Value)
       Keep_On_Teleport = Value
    end,
})

local Kill_Keybind = General_Tab:CreateKeybind({
    Name = 'Kill Logic',
    CurrentKeybind = 'L',
    HoldToInteract = false,
    Flag = 'destroy', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Keybind_Held)
        RUNTIME._running_ = false
    end,
})

-- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] --

-- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ WEAPONS TAB ]] --

local Movement_Tab = Window:CreateTab('Movement', 4483362458) -- Title, Image

-- MOVE -- MOVEMENT  --
local Section = Movement_Tab:CreateSection('Movement')
local Divider = Movement_Tab:CreateDivider()

local Movement_Speed_Slider = Movement_Tab:CreateSlider({
    Name = 'WalkSpeed',
    Range = { 16, 300 },
    Increment = 1,
    Suffix = 'Radius',
    CurrentValue = 16,
    Flag = 'Movement_Slider', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Custom_Movement.walkspeed = Value
    end,
})

local Custom_Speed_Toggle = Movement_Tab:CreateToggle({
    Name = 'Custom Speed Toggled',
    CurrentValue = false,
    Flag = 'custom_speed_togg',
    Callback = function(Value)
        Custom_Movement.toggled = Value
        if Value == false then
            this_player.Humanoid.WalkSpeed = 16
        end
    end,
})

local CustomSpeed_Keybind = Movement_Tab:CreateKeybind({
    Name = 'Custom Speed Keybind',
    CurrentKeybind = 'T',
    HoldToInteract = false,
    Flag = 'Custom_sPEED_Ke_bind', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function()
        Custom_Speed_Toggle:Set(not Custom_Movement.toggled)
    end,
})

RUNTIME._running_connection_ = SERVICES.Run.RenderStepped:Connect(
    function(__delta__)
        if RUNTIME._running_ == false then
            this_player.Humanoid.WalkSpeed = 16
            RUNTIME._running_connection_:Disconnect()
            Rayfield:Destroy()
            return
        end

        task.spawn(function() -- CUSTOM MOVEMENT LOGIC
            if Custom_Movement.toggled then
                this_player.Humanoid.WalkSpeed = Custom_Movement.walkspeed
            end
        end)
    end
)
this_player.Player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress then
    queue_on_teleport([[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/lordishow/anime_mainia/refs/heads/main/main.lua'))()
    ]])
    end
end)
