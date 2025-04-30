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

local GLOBALS = {
    FX = workspace.FX,
    LIVING = workspace.Living,
    TARGET = nil,
    INPUT = SERVICES.Replicated.Remotes.Input,
    STATUS = SERVICES.Players.LocalPlayer.Status,
    PLAYER_JUST_DIED = false,
}

local this_player = {
    Player = SERVICES.Players.LocalPlayer,
    Character = SERVICES.Players.LocalPlayer.Character,
    HumanoidRootPart = SERVICES.Players.LocalPlayer.Character.HumanoidRootPart,
    Humanoid = SERVICES.Players.LocalPlayer.Character.Humanoid,
    Mouse = SERVICES.Players.LocalPlayer:GetMouse(),
    Cooldowns = SERVICES.Players.LocalPlayer.Cooldowns,
    Ban = SERVICES.Players.LocalPlayer.Character.Ban,
}

this_player.Player.CharacterAdded:Connect(function(new_character)
    this_player.Character = new_character
    this_player.HumanoidRootPart = new_character:WaitForChild(
        'HumanoidRootPart'
    )
    this_player.Humanoid = new_character:WaitForChild('Humanoid')
    this_player.Ban = new_character:WaitForChild('Ban')
    GLOBALS.PLAYER_JUST_DIED = true
    task.delay(3, function() 
        GLOBALS.PLAYER_JUST_DIED = false
    end)
end)
-- // PRESETS // -- // PRESENTS //

-- \\ NOJO \\ GOJO // 
local Char_Presets = {
    ["NOJO"] = {
        [1] = nil,
        [2] = {
            Wait_For_Next = false,
            Lapse_Blue_Spinning_Part = nil,
            Elapsed_time_since_new_part = 0,
            Elapsed_time_since_last_remote_fired = 0
        },
        [3] = nil,
        [4] = {
            Wait_For_Next = false,
            Available_Evolved_Move = 0,
            Last_Time_Chanted = 0,
        }
    }
}


-- // GENERAL VARIABLES // GENERAL STORE //
local Keep_On_Teleport = false

local Zero_Velocity = false

--|| MOVEMENT LOGIC VARIABLES // -- // LOGIC MOVEMENT VARIABLES //
local Custom_Movement = {
    toggled = false,
    walkspeed = 16,
}

-- // AUTO FARM VARIABLES // // FARMING SIMULATOR //
local Auto_Farm_Vars = {
    Enabled = false,
    Preset = "NOJO"
}

-- // FINDING TARGET VARIABLES // TARGET SPY //

local Black_List = {}

-- // INPUT REMOTE // INPUT REMOTE //

local Last_Time_Input_Was_Fired = 0

-- // UTILITARIAN FUNCTIONALITIES

local function update_target()
    if not GLOBALS.TARGET then
        local Best_Quality_Target = nil
        local Best_Humanoid = nil
        for _, NPC_Model in GLOBALS.LIVING:GetChildren() do
            if Black_List[NPC_Model] then continue end
            if not SERVICES.Players:GetPlayerFromCharacter(NPC_Model) then
                local _humanoid = NPC_Model:FindFirstChildOfClass("Humanoid")
                if _humanoid and _humanoid.Health > 0 then
                    if not Best_Quality_Target or (_humanoid.Health < Best_Humanoid.Health) then
                        Best_Quality_Target = NPC_Model
                        Best_Humanoid = _humanoid
                    end
                end
            end
        end
        GLOBALS.TARGET = Best_Quality_Target
    else
        local should_blacklist_target = false
        local _humanoid = GLOBALS.TARGET:FindFirstChildOfClass("Humanoid")
        if not _humanoid or _humanoid.Health <= 0 then
            should_blacklist_target = true
        end
        if should_blacklist_target then
            Black_List[GLOBALS.TARGET] = true
            GLOBALS.TARGET = nil
        end
    end
end

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
    Range = { 0, 300 },
    Increment = 1,
    Suffix = 'Radius',
    CurrentValue = 0,
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

local Divider = Movement_Tab:CreateDivider()

local Zero_Vel_Toggle = Movement_Tab:CreateToggle({
    Name = 'Zero Velocity',
    CurrentValue = false,
    Flag = 'custom_speed_togg',
    Callback = function(Value)
        Zero_Velocity = Value
        if Value == false then 
            this_player.HumanoidRootPart.Anchored = false
        end
    end,
})

local Zero_Velocity_Keybind = Movement_Tab:CreateKeybind({
    Name = 'Zero Velocity Keybind',
    CurrentKeybind = 'F',
    HoldToInteract = false,
    Flag = 'ZerO_vel', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function()
        Zero_Vel_Toggle:Set(not Zero_Velocity)
    end,
})

-- [[ FARM TAB ]] -- -- [[FARM TAB ]] -- -- [[FARM TAB ]] -- -- [[FARM TAB ]] -- -- [[FARM TAB ]] --

-- [[FARM TAB ]] -- -- [[FARM TAB ]] -- -- [[FARM TAB ]] -- -- [[ MOVEMENT TAB ]] -- -- [[ FARM TAB ]] --

local AutoFarm_Tab = Window:CreateTab('Auto Farm', 4483362458) -- Title, Image

-- MOVE -- MOVEMENT  --
local Section = AutoFarm_Tab:CreateSection('Char Selection')
local Divider = AutoFarm_Tab:CreateDivider()

local Auto_Farm_Enabled_Toggle = AutoFarm_Tab:CreateToggle({
    Name = 'Auto Farm',
    CurrentValue = false,
    Flag = 'Auto_Farm_Togg',
    Callback = function(Value)
        if Value == false then 
            Char_Presets["NOJO"][2].Elapsed_time_since_new_part = 10
        end

       Auto_Farm_Vars.Enabled = Value
    end,
})

local Dropdown = AutoFarm_Tab:CreateDropdown({
   Name = "Character Preset",
   Options = {"NOJO"},
   CurrentOption = "NOJO",
   MultipleOptions = false,
   Flag = "Character_Preset", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
        Auto_Farm_Vars.Preset = Option[1]
   end,
})

-- // GOJO'S CHILD ADDED //

local Visual_Effect_Child_Added_Functions = {
    ["NOJO"] = function(adopted) 
        if adopted.Name == "LapseBlue" then
            local GOJO = Char_Presets[Auto_Farm_Vars.Preset] 
            GOJO[2].Lapse_Blue_Spinning_Part = adopted
            GOJO[2].Elapsed_time_since_new_part = os.clock()
        end
    end
}

GLOBALS.FX.ChildAdded:Connect(function(adopted) 
    local VECAF_Func = Visual_Effect_Child_Added_Functions[Auto_Farm_Vars.Preset]
    if VECAF_Func then 
        VECAF_Func(adopted)
    end
end)

local Auto_Farm_Runtime = {
    ["NOJO"] = function() -- GOJO // NOJO // GOJO
        local GOJO = Char_Presets["NOJO"]
        if GLOBALS.TARGET == nil then 
            return
        end
        this_player.HumanoidRootPart.CFrame = GLOBALS.TARGET.HumanoidRootPart.CFrame * CFrame.new(0,0,35)
        local Lapse_Blue_On_CD = this_player.Cooldowns:FindFirstChild("Lapse Blue") and true or false
        local Chanting_On_CD = this_player.Cooldowns:FindFirstChild("Chanting") and true or false
        
        local Player_Is_Stunned = GLOBALS.STATUS:FindFirstChild("Stunned") and true or false

        if not Chanting_On_CD then
            if GLOBALS.PLAYER_JUST_DIED then 
                GOJO[4].Available_Evolved_Move = 0
                GOJO[4].Wait_For_Next = false
            else
                if ((os.clock() - Last_Time_Input_Was_Fired) > 0.1) then
                        if GOJO[4].Wait_For_Next == false and not Player_Is_Stunned then 
                            local args = {
                                [1] = {
                                    [1] = "Skill",
                                    [2] = "4"
                                }
                            }
                            GOJO[4].Wait_For_Next = true
                            GOJO[4].Last_Time_Chanted = os.clock()
                            GOJO[4].Available_Evolved_Move += 1
                            print(GOJO[4].Available_Evolved_Move)
                            Last_Time_Input_Was_Fired = os.clock()
                            
                            GLOBALS.INPUT:FireServer(unpack(args))
                            
                            if GOJO[4].Available_Evolved_Move == 4 then 
                                task.delay(8, function() 
                                    if not GLOBALS.PLAYER_JUST_DIED then 
                                        print('reset')
                                        GOJO[4].Wait_For_Next = false
                                        GOJO[4].Available_Evolved_Move = 0
                                    end
                                end)
                            else
                                Chanting_On_CD = this_player.Cooldowns:WaitForChild("Chanting", 10)
                                task.spawn(function() 
                                    if Chanting_On_CD then 
                                        repeat 
                                            task.wait(0.2)
                                        until this_player.Cooldowns:FindFirstChild("Chanting") == nil or GLOBALS.PLAYER_JUST_DIED
                                        GOJO[4].Wait_For_Next = false
                                    end
                                end)
                            end
                        end
                end
            end 
        end

        if not Lapse_Blue_On_CD then 
            if not GLOBALS.PLAYER_JUST_DIED then 
                if ((os.clock() - Last_Time_Input_Was_Fired) > 0.1) and GOJO[4].Available_Evolved_Move >= 2 then
                    if not GOJO[2].Wait_For_Next and not Player_Is_Stunned then 
                    
                        local args = {
                            [1] = {
                                [1] = "Skill",
                                [2] = "2"
                            }
                        }
                        GOJO[2].Wait_For_Next = true
                        Last_Time_Input_Was_Fired = os.clock()
                        GLOBALS.INPUT:FireServer(unpack(args))
                        print("FIRED")
                        Lapse_Blue_On_CD = this_player.Cooldowns:WaitForChild("Lapse Blue", 5)
                        if Lapse_Blue_On_CD then 
                            print("waiting")
                            repeat 
                                task.wait(0.2)
                            until (this_player.Cooldowns:FindFirstChild("Lapse Blue") == nil) or GLOBALS.PLAYER_JUST_DIED
                            print('dont_wait_no_moore')
                            GOJO[2].Wait_For_Next = false
                        else
                            GOJO[2].Wait_For_Next = false
                        end
                    end 
                end
            else
                GOJO[2].Wait_For_Next = false
            end
        else
            if (GOJO[2].Lapse_Blue_Spinning_Part and GOJO[2].Lapse_Blue_Spinning_Part:IsDescendantOf(GLOBALS.FX)) then 
                if (os.clock() - GOJO[2].Elapsed_time_since_new_part) < 3 then 
                    local Position_REMOTE = GLOBALS.FX:FindFirstChild("RemoteEvent")
                    if Position_REMOTE then
                        if (os.clock() - GOJO[2].Elapsed_time_since_last_remote_fired) > 0.1 then 
                            GOJO[2].Elapsed_time_since_last_remote_fired = os.clock()
                            Position_REMOTE:FireServer(GLOBALS.TARGET.HumanoidRootPart.CFrame)
                        end 
                    end
                end
            end
        end
        
        
        --[[
        local offset = GOJO[2].Lapse_Blue_Spinning_Part.Position - this_player.HumanoidRootPart.Position
        local desiredHRPPosition = GLOBALS.TARGET.HumanoidRootPart.Position - offset
        this_player.HumanoidRootPart.CFrame = CFrame.new(desiredHRPPosition)
        ]]
    end,
}

-- run
RUNTIME._running_connection_ = SERVICES.Run.RenderStepped:Connect(
    function(__delta__)
        if RUNTIME._running_ == false then
            this_player.Humanoid.WalkSpeed = 16
            RUNTIME._running_connection_:Disconnect()
            Rayfield:Destroy()
            return
        end
        
        update_target()

        task.spawn(function() -- CUSTOM MOVEMENT LOGIC
            if Custom_Movement.toggled then
                this_player.Humanoid.WalkSpeed = Custom_Movement.walkspeed
            end
        end)

        task.spawn(function() -- ZERO VELOCITY 
            if Zero_Velocity then
                this_player.HumanoidRootPart.Anchored = true
                this_player.HumanoidRootPart.Velocity = Vector3.zero
                 this_player.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end)

        task.spawn(function() -- GOJO LAPSE BLUE 
            if Auto_Farm_Vars.Enabled then 
                local auto_farm_func = Auto_Farm_Runtime[Auto_Farm_Vars.Preset]
                if auto_farm_func then 
                    auto_farm_func()
                end
            end
        end) 
    end
)

this_player.Player.OnTeleport:Connect(function(State)
    if (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) and Keep_On_Teleport then
    queue_on_teleport([[
            loadstring(game:HttpGet('https://raw.githubusercontent.com/lordishow/anime_mainia/refs/heads/main/main.lua'))()
    ]])
    end
end)
