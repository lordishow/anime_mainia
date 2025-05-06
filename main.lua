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
    warn("Already loaded an instance, to load a new one press the 'Kill Logic' Keybind. [DEFAULT: 'L'] ")
    return
end
local RUNTIME = RNR_ENVIRONMENT.RUNTIME

local SERVICES = {
    Replicated = game:GetService('ReplicatedStorage'),
    UserInput = game:GetService('UserInputService'),
    Players = game:GetService('Players'),
    CoreGui = game:GetService('CoreGui'),
    Run = game:GetService('RunService'),
    Teleport = game:GetService('TeleportService'),
    Http = game:GetService("HttpService"),
}

local GLOBALS = {
    FX = workspace.FX,
    LIVING = workspace.Living,
    TARGET = nil,
    INPUT = SERVICES.Replicated.Remotes.Input,
    STATUS = SERVICES.Players.LocalPlayer.Status,
    ROLLX10 = SERVICES.Replicated.Remotes.Rollx10,
    INVENTORY = SERVICES.Players.LocalPlayer.PlayerGui.CharacterSelection:FindFirstChild("InventoryNew") and SERVICES.Players.LocalPlayer.PlayerGui.CharacterSelection.InventoryNew.Inventory.Inventory or nil,
    JSON_INVENTORY = SERVICES.Players.LocalPlayer.Data.Inventory,
    PLAYER_JUST_DIED = false,
    MAX_SLOTS = SERVICES.Players.LocalPlayer.Data.Slots,
    SOUNDS = SERVICES.Replicated.Assets.Sounds,
    FEEDCHARACTER = SERVICES.Replicated.Remotes.FeedCharacter,
    HIDDEN_FOLDER = Instance.new("Folder"),
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
    GLOBALS.STATUS = SERVICES.Players.LocalPlayer.Status
    GLOBALS.MAX_SLOTS = SERVICES.Players.LocalPlayer.Data.Slots
    GLOBALS.JSON_INVENTORY = SERVICES.Players.LocalPlayer.Data.Inventory
    task.delay(1, function() 
        GLOBALS.PLAYER_JUST_DIED = false
    end)
    Update_Units_In_Inventory()
end)

-- // PRESETS // -- // PRESENTS //

-- \\ NOJO \\ GOJO // 

local Char_Presets = {
    ["NOJO"] = {
        Offset_CFrame = CFrame.new(0,0,0),
        Thread_Yielded = false,
        Move_Delay = 1.5,
        Last_Time_Move_Used = 0,
        [1] = {
            
        },
        [2] = {
        },
        [3] = {
        },
        [4] = {
            Chanting = false,
            Available_Evolved_Move = 0,
        }
    },
    ["ROGER"] = {
        Offset_CFrame = CFrame.new(0,0,0),
        Thread_Yielded = false,
        Move_Delay = 2,
        Last_Time_Move_Used = 0,
        [1] = {
            Wait_For_Next = false,
        },
        [2] = {
            Wait_For_Next = false,
        },
        [3] = {
            Wait_For_Next = false,
        },
        [4] = {
            Wait_For_Next = false,
        }
    }
}


-- // GENERAL VARIABLES // GENERAL STORE //
local Keep_On_Teleport = false
local start_time = tick()
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

-- // ORBIT VARS // GOOFY AHH VARS

local Orbit_Vars = {
    Height = 50,
    Orbit_Radius = 1,
    Orbit_Speed = 1,
}

-- // FINDING TARGET VARIABLES // TARGET SPY //

local Black_List = {}

-- // INPUT REMOTE // INPUT REMOTE //

local Last_Time_Input_Was_Fired = 0

-- // GAMBLING VARIABLES 🥵🥵🥵🥵

local Gatcha_Vars = {
    Rolling_For = "", -- GOLD, GEMS (token is for nerds)
    Notify_On_Full_Inv = false,
    Used_Slots = 0,
    Volume = 1.5,
    Rolling = false,
}

-- // AUTO FEED 😱😱😱😱
local Rarity_To_Multi = {
    ["Fodder"] = 5,
    ["Common"] = 2.5,
    ["Uncommon"] = 5,
    ["Rare"] = 10,
    ["Legendary"] = 20,
    ["Mythical"] = 30,
    ["Legacy"] = 60,
    ["GOD"] = 1000,
    ["EXP"] = 15,
    ["Artifact"] = 5
}

local Auto_Feed_Vars = {
    Units_To_Feed = {},
    Every_Unit_In_Inventory = {},
    Feedables = {},
    safes = {},
    Feed_Target_List = {},
    Unit_To_Feed = "",
    Character_To_Feed = nil,
    Feed_char_in_first_slot = false,
    Rarities_Allowed_To_Be_Fed = {
        ["Fodder"] = false,
        ["Common"] = false,
        ["Uncommon"] = false,
        ["Rare"] = false,
    },
    Level_To_Reach = 0,

}

local Available_Characters_dropdown;

-- // UTILITARIAN FUNCTIONALITIES

function Feed(Feedables, Key)
    GLOBALS.FEEDCHARACTER:InvokeServer(Feedables, Key)
end

function Find_New_Feed_Targets()
            if Auto_Feed_Vars.Feed_char_in_first_slot then 
                for _,Unit in Auto_Feed_Vars.Units_To_Feed do 
                    if Unit.Equipped then
                        Auto_Feed_Vars.Character_To_Feed = Unit
                        break
                    end
                end 
            else
                for _,Unit in Auto_Feed_Vars.Units_To_Feed do 
                    if Unit.Name == Auto_Feed_Vars.Unit_To_Feed and Unit.Level < Auto_Feed_Vars.Level_To_Reach then
                        Auto_Feed_Vars.Character_To_Feed = Unit
                        break
                    end
                end 
            end

            if Auto_Feed_Vars.Character_To_Feed then 
                local Lvl_Goal = Auto_Feed_Vars.Level_To_Reach
                local Curr_Lvl = Auto_Feed_Vars.Character_To_Feed.Level
                    
                local goal_m_one = (Lvl_Goal - 1)
                local n = (goal_m_one - Curr_Lvl) + 1 
                local xp = (Curr_Lvl * 5) + (goal_m_one * 5)
                local Required_Exp = (xp * n) / 2

                local Total_Exp = 0
                local Feedable_Units = {}
                
                for _, feedable in Auto_Feed_Vars.Feedables do
                    if Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed[feedable.Rarity] then
                        local exp_value = (feedable.Level or 1) * (Rarity_To_Multi[feedable.Rarity] or 0) * 2
                        Total_Exp += exp_value
                        Feedable_Units[feedable.Key] = true
                        if Total_Exp >= Required_Exp then break end
                    end
                end
                Auto_Feed_Vars.Feed_Target_List = Feedable_Units
                return Required_Exp, Total_Exp
            end
            
end

local function Update_Units_In_Inventory()
    if GLOBALS.INVENTORY then 
        table.clear(Auto_Feed_Vars.Units_To_Feed)
        table.clear(Auto_Feed_Vars.Every_Unit_In_Inventory)
        table.clear(Auto_Feed_Vars.Feedables)
        
        for _, Unit in GLOBALS.INVENTORY:GetChildren() do 
            local Unit_Key = Unit:FindFirstChild("Key")
            if Unit_Key then
                local Level = Unit.Level 
                local Rarity = Unit.Rarity
                local Star = Unit.Star
                local Numbered_Level = Level.Text:match("%d+")

                Auto_Feed_Vars.Every_Unit_In_Inventory[Unit_Key.Value] = {
                    Key = Unit_Key.Value,
                    Name = Unit.Name,
                    Level = tonumber(Numbered_Level),
                    Rarity = Rarity.Text,
                    Favorited = Star.Visible,
                    Equipped = Unit.Equipped.Visible,
                }
            end
        end
        for _, Unit in Auto_Feed_Vars.Every_Unit_In_Inventory do 
            if Unit.Rarity ~= "Fodder" and Unit.Rarity ~= "Artifact" then 
                Auto_Feed_Vars.Units_To_Feed[Unit.Key] = Unit
            end
        end

        for _, Unit in Auto_Feed_Vars.Every_Unit_In_Inventory do 
            if Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed[Unit.Rarity] ~= nil and not Unit.Favorited then 
                Auto_Feed_Vars.Feedables[Unit.Key] = Unit
            end
        end
        for _,Unit in Auto_Feed_Vars.Units_To_Feed do 
            if not table.find(Auto_Feed_Vars.safes, Unit.Name) then 
                table.insert(Auto_Feed_Vars.safes, Unit.Name)
            end
        end
    end
end

local Best_Quality_Target = nil
local Best_Distance = nil

local function update_target()
        for _, NPC_Model in GLOBALS.LIVING:GetChildren() do
            if not SERVICES.Players:GetPlayerFromCharacter(NPC_Model) then
                local _root = NPC_Model:FindFirstChild("HumanoidRootPart")
                local _humanoid = NPC_Model:FindFirstChildOfClass("Humanoid")
                if _root and _humanoid and _humanoid.Health > 0 then
                    local _distance = (_root.Position - this_player.HumanoidRootPart.Position).Magnitude
                    if not Best_Quality_Target or (_distance < Best_Distance) then
                        Best_Quality_Target = NPC_Model
                        Best_Distance = _distance
                    else
                        local _bq_root = Best_Quality_Target and Best_Quality_Target:FindFirstChild("HumanoidRootPart")
                        if _bq_root then 
                            Best_Distance = (_bq_root.Position - this_player.HumanoidRootPart.Position).Magnitude
                        else
                            Best_Distance = math.huge 
                        end
                    end
                end
            end
        end
        GLOBALS.TARGET = Best_Quality_Target
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
        FolderName = "Lords_Anime_Mainia", -- Create a custom folder for your hub/game
        FileName = "_configuration_",
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
    Flag = 'keep_after_tp',
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
    Name = 'Custom Speed Enabled',
    CurrentValue = false,
    Flag = nil,
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
    Flag = 'Custom_Speed_Bind', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function()
        Custom_Speed_Toggle:Set(not Custom_Movement.toggled)
    end,
})

local Divider = Movement_Tab:CreateDivider()

local Zero_Vel_Toggle = Movement_Tab:CreateToggle({
    Name = 'Zero Velocity',
    CurrentValue = false,
    Flag = 'Zero_Velocity_Toggle',
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
    Flag = 'Zero_Velocity_Keybind', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
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
    Flag = nil,
    Callback = function(Value)
       Auto_Farm_Vars.Enabled = Value
    end,
})

local Auto_Farm_Bind = AutoFarm_Tab:CreateKeybind({
    Name = 'Auto Farm Keybind',
    CurrentKeybind = 'G',
    HoldToInteract = false,
    Flag = 'Auto_Farm_Keybind', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function()
        Auto_Farm_Enabled_Toggle:Set(not Auto_Farm_Vars.Enabled)
    end,
})

local Char_Preset_Dropdown = AutoFarm_Tab:CreateDropdown({
   Name = "Character Preset",
   Options = {"NOJO", "ROGER"},
   CurrentOption = "NOJO",
   MultipleOptions = false,
   Flag = "Character_Preset_Table", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
        Auto_Farm_Vars.Preset = Option[1]
   end,
})

local Divider = AutoFarm_Tab:CreateDivider()
local Section = AutoFarm_Tab:CreateSection('Orbit')

local Orbit_Height_Slider = AutoFarm_Tab:CreateSlider({
    Name = 'Orbit Height',
    Range = { 0, 100 },
    Increment = 1,
    Suffix = 'Height',
    CurrentValue = 50,
    Flag = 'Orbit Height', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Orbit_Vars.Height = Value
    end,
})

local Orbit_Speed_Slider = AutoFarm_Tab:CreateSlider({
    Name = 'Orbit Speed',
    Range = { 0, 5 },
    Increment = 0.1,
    Suffix = 'Speed',
    CurrentValue = 1,
    Flag = 'Orbit Speed', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Orbit_Vars.Orbit_Speed = Value
    end,
})

local Orbit_Radius_Slider = AutoFarm_Tab:CreateSlider({
    Name = 'Orbit Radius',
    Range = { 0, 5 },
    Increment = 0.1,
    Suffix = 'Distance',
    CurrentValue = 1,
    Flag = 'Orbit Radius', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Orbit_Vars.Orbit_Radius = Value
    end,
})


local Divider = AutoFarm_Tab:CreateDivider()
local Section = AutoFarm_Tab:CreateSection('NOJO')

local Starting_Delay_Slider = AutoFarm_Tab:CreateSlider({
    Name = 'Lapse Blue Starting Delay',
    Range = { 0, 10 },
    Increment = 1,
    Suffix = 'Delay',
    CurrentValue = 0,
    Flag = 'Lapse_Blue_Cast_Delay', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Char_Presets["NOJO"][2].Attack_Delay = Value
    end,
})

-- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] --

-- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ FARM TAB ]] --

local Gatcha_Tab = Window:CreateTab('Gatcha', 4483362458) -- Title, Image

-- MOVE -- MOVEMENT  --
local Section = Gatcha_Tab:CreateSection('Rolling')
local Divider = Gatcha_Tab:CreateDivider()

local Roll_Gold_Banner;
local Roll_Gems_Banner;

Roll_Gold_Banner = Gatcha_Tab:CreateToggle({
    Name = 'Roll x10 Gold',
    CurrentValue = false,
    Flag = nil,
    Callback = function(Value)
        if Value == true then
            Roll_Gems_Banner:Set(false)
            Gatcha_Vars.Rolling_For = "GOLD"
        else
            Gatcha_Vars.Rolling_For = ""
        end
    end,
})

Roll_Gems_Banner = Gatcha_Tab:CreateToggle({
    Name = 'Roll x10 Gems',
    CurrentValue = false,
    Flag = nil,
    Callback = function(Value)
        if Value == true then 
            Roll_Gold_Banner:Set(false)
            Gatcha_Vars.Rolling_For = "GEMS"
        else
            Gatcha_Vars.Rolling_For = ""
        end
    end,
})

local Notify_On_Full_Inv_Togg = Gatcha_Tab:CreateToggle({
    Name = 'Notify When Inventory Is Full',
    CurrentValue = false,
    Flag = "Notify_When_Inventory_Full",
    Callback = function(Value)
        Gatcha_Vars.Notify_On_Full_Inv = Value
    end,
})

local Divider = Gatcha_Tab:CreateDivider()

local Error_Volume_Slider = Gatcha_Tab:CreateSlider({
    Name = 'Full Inv Alert Volume',
    Range = { 0, 10 },
    Increment = 0.1,
    Suffix = 'Volume',
    CurrentValue = 1.5,
    Flag = 'Full_Inv_Sound_Volume', -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        Gatcha_Vars.Volume = Value
    end,
})

local Test_Volume_Button = Gatcha_Tab:CreateButton({
   Name = "Test Volume",
   Callback = function()
        Alert_User_Of_Max_Inv()
   end,
})

-- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] --

-- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ GATCHA TAB ]] -- -- [[ FARM TAB ]] --

local Feeding_Tab = Window:CreateTab('Feed', 4483362458) -- Title, Image

local Required_Exp_Label;
local Available_Exp_Label; 
-- MOVE -- MOVEMENT  --
local Section = Feeding_Tab:CreateSection('Feeding')
local Divider = Feeding_Tab:CreateDivider()

Available_Characters_dropdown = Feeding_Tab:CreateDropdown({
    Name = "Character(S) To Feed",
    Options = Auto_Feed_Vars.Units_To_Feed,
    CurrentOption = "None",
    MultipleOptions = false,
    Flag = nil, -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        print(Option[1])
        Auto_Feed_Vars.Unit_To_Feed = Option[1]
        local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local Update_List_butt = Feeding_Tab:CreateButton({
   Name = "Refresh",
   Callback = function()
        Available_Characters_dropdown:Refresh(Auto_Feed_Vars.safes)
   end,
})

local Feed_First_Slot_Char_Togg = Feeding_Tab:CreateToggle({
    Name = 'Feed Character In First Slot',
    CurrentValue = false,
    Flag = nil,
    Callback = function(Value)
        Auto_Feed_Vars.Feed_char_in_first_slot = Value

         local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})
local Divider = Feeding_Tab:CreateDivider()

local Feed_Fodder_togg  = Feeding_Tab:CreateToggle({
    Name = 'Feed [FODDERS]',
    CurrentValue = false,
    Flag = "feed_fodders",
    Callback = function(Value)
         Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed["Fodder"] = Value
local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local Feed_Common_togg  = Feeding_Tab:CreateToggle({
    Name = 'Feed [COMMONS]',
    CurrentValue = false,
    Flag = "feed_commons",
    Callback = function(Value)
     Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed["Common"] = Value
local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local Feed_Uncommon_togg = Feeding_Tab:CreateToggle({
    Name = 'Feed [UNCOMMONS]',
    CurrentValue = false,
    Flag = "feed_uncommons",
    Callback = function(Value)
        Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed["Uncommon"] = Value
local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local Feed_Uncommon_togg = Feeding_Tab:CreateToggle({
    Name = 'Feed [RARES]',
    CurrentValue = false,
    Flag = "feed_rares",
    Callback = function(Value)
        Auto_Feed_Vars.Rarities_Allowed_To_Be_Fed["Rare"] = Value
                    local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local Divider = Feeding_Tab:CreateDivider()

Required_Exp_Label = Feeding_Tab:CreateLabel("EXP Required: 0", 4483362458, Color3.fromRGB(0, 0, 0), false) -- Title, Icon, Color, IgnoreTheme
Available_Exp_Label = Feeding_Tab:CreateLabel("EXP Available: 0", 4483362458, Color3.fromRGB(0, 0, 0), false) -- Title, Icon, Color, IgnoreTheme

local Divider = Feeding_Tab:CreateDivider()

local Level_To_Reach_Input = Feeding_Tab:CreateInput({
    Name = "Level To Reach",
    CurrentValue = "0",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = nil,
    Callback = function(Text)
            local succ, result = pcall(function() 
                return tonumber(Text)
            end)
            if result then 
                Auto_Feed_Vars.Level_To_Reach = result
            end
        
                local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
    end,
})

local feed_button = Feeding_Tab:CreateButton({
    Name = "Feed",
    Callback = function()
            if GLOBALS.INVENTORY then
                local Target_Key = Auto_Feed_Vars.Character_To_Feed

                if Target_Key and Auto_Feed_Vars.Feed_Target_List then
                    Feed(Auto_Feed_Vars.Feed_Target_List, Target_Key.Key)
                    Auto_Feed_Vars.Feed_Target_List = {}
                end
local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
            end
           
    end,
})

local Auto_Feed_Toggle = Feeding_Tab:CreateToggle({
    Name = 'Auto Feed',
    CurrentValue = false,
    Flag = nil,
    Callback = function(Value)
        Auto_Feed_Vars.Enabled = Value
    end,
})

-- // GOJO'S CHILD ADDED //

local Visual_Effect_Child_Added_Functions = {
    ["NOJO"] = function(adopted) 
        -- legacy code
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

        local Active_Target = true
        if GLOBALS.TARGET == nil or GLOBALS.TARGET:FindFirstChild("HumanoidRootPart") == nil then 
            Active_Target = false
        end
        local Gojo_Chant_Status = GLOBALS.STATUS:FindFirstChild("GojoChant")

        if Gojo_Chant_Status then
            GOJO[4].Available_Evolved_Move = Gojo_Chant_Status.Value
        else
            GOJO[4].Available_Evolved_Move = 0
        end 

        local Chanting_On_CD = this_player.Cooldowns:FindFirstChild("Chanting") and true or false
        local Lapse_Blue_On_CD = this_player.Cooldowns:FindFirstChild("Lapse Blue") and true or false
        local Reversal_Red_On_CD = this_player.Cooldowns:FindFirstChild("Reversal Red") and true or false
        local Hollow_Purple_On_CD = this_player.Cooldowns:FindFirstChild("Hollow Purple") and true or false

        local Player_Is_Stunned = GLOBALS.STATUS:FindFirstChild("Stunned") and true or false

        local Enough_Elapsed_Time_To_Use_Move =  (os.clock() - GOJO.Last_Time_Move_Used) > GOJO.Move_Delay

        if not GLOBALS.PLAYER_JUST_DIED then
            if Active_Target then 
                if not Chanting_On_CD and not Player_Is_Stunned and not GOJO[4].Chanting then 
                    GOJO[4].Chanting = true
                    local args = {
                        [1] = {
                            [1] = "Skill",
                            [2] = "4"
                        }
                    }
                    
                    if Gojo_Chant_Status ~= nil then 
                         GOJO[4].Available_Evolved_Move = Gojo_Chant_Status.Value
                    end
                    if GOJO[4].Available_Evolved_Move < 2 then      
                        GLOBALS.INPUT:FireServer(unpack(args))
                    end
                    task.delay(0.1, function() 
                        GOJO[4].Chanting = false
                    end)
                end
                
                if Gojo_Chant_Status ~= nil then 
                    GOJO[4].Available_Evolved_Move = Gojo_Chant_Status.Value
                end

                if not Lapse_Blue_On_CD and not GOJO.Thread_Yielded and not Player_Is_Stunned then 
                    GOJO.Last_Time_Move_Used = os.clock()
                    local args = {
                        [1] = {
                            [1] = "Skill",
                            [2] = "2"
                        }
                    }

                    if GOJO[4].Available_Evolved_Move >= 2 then 
                        for i = 1,10 do
                            GLOBALS.INPUT:FireServer(unpack(args))
                        end
                    end
                end
                Enough_Elapsed_Time_To_Use_Move =  (os.clock() - GOJO.Last_Time_Move_Used) > GOJO.Move_Delay
                
                if Gojo_Chant_Status ~= nil then 
                    GOJO[4].Available_Evolved_Move = Gojo_Chant_Status.Value
                end
                if not Reversal_Red_On_CD and Enough_Elapsed_Time_To_Use_Move and not GOJO.Thread_Yielded and not Player_Is_Stunned and GOJO[4].Available_Evolved_Move >= 1 then 
                    GOJO.Thread_Yielded = true
                    GOJO.Last_Time_Move_Used = os.clock()
                    local args = {
                        [1] = {
                            [1] = "Skill",
                            [2] = "1"
                        }
                    }

                    for i = 1,10 do 
                        GLOBALS.INPUT:FireServer(unpack(args))
                    end

                    for i = 1,10 do 
                        GOJO.Thread_Yielded = true
                        GOJO.Offset_CFrame = CFrame.new(0,0,35)
                        task.wait(0.1)
                    end
                    task.wait(1)
                    GOJO.Thread_Yielded = false
                end
                Enough_Elapsed_Time_To_Use_Move =  (os.clock() - GOJO.Last_Time_Move_Used) > GOJO.Move_Delay
                
                if Gojo_Chant_Status ~= nil then 
                    GOJO[4].Available_Evolved_Move = Gojo_Chant_Status.Value
                end
                if not Hollow_Purple_On_CD and Enough_Elapsed_Time_To_Use_Move and not GOJO.Thread_Yielded and not Player_Is_Stunned then 
                    GOJO.Last_Time_Move_Used = os.clock()
                    local args = {
                        [1] = {
                            [1] = "Skill",
                            [2] = "3"
                        }
                    }
                    if GOJO[4].Available_Evolved_Move == 2 then 
                        for i = 1,10 do 
                            GLOBALS.INPUT:FireServer(unpack(args))
                        end
                    end
                end
            end
        else
            GOJO.Thread_Yielded = false
        end

        -- the stuff lmao (means: laughing my ass off)

        if GLOBALS.TARGET == nil or GLOBALS.TARGET:FindFirstChild("HumanoidRootPart") == nil then 
            Active_Target = false
        end
        if Active_Target then
            local Position_REMOTE = GLOBALS.FX:FindFirstChild("RemoteEvent")
            for _, NPC_Model in GLOBALS.LIVING:GetChildren() do
                if Black_List[NPC_Model] then continue end
                if not SERVICES.Players:GetPlayerFromCharacter(NPC_Model) then
                    local _humanoid = NPC_Model:FindFirstChildOfClass("Humanoid")
                    if _humanoid and _humanoid.Health > 0 then
                        if Position_REMOTE then
                            Position_REMOTE:FireServer(NPC_Model:FindFirstChild("HumanoidRootPart").CFrame)
                        end
                    end
                end
            end
            --Position_REMOTE:FireServer(GLOBALS.TARGET.HumanoidRootPart.CFrame)
        end
        
        -- doing again cuz delayes (speaking form expirience)

        if not GOJO.Thread_Yielded then 
            local elapsed_time = tick() - start_time
            local x = math.cos(elapsed_time * (2 * Orbit_Vars.Orbit_Speed)) * (25 * Orbit_Vars.Orbit_Radius)
            local y = math.sin(elapsed_time * (5 * Orbit_Vars.Orbit_Speed)) * (25 * Orbit_Vars.Orbit_Radius)
            if Active_Target then 
                GOJO.Offset_CFrame = CFrame.new(
                    x,
                    Orbit_Vars.Height,
                    y
                )
            end       
        end
        if Active_Target then 
            local offsetCFrame = GLOBALS.TARGET.HumanoidRootPart.CFrame * GOJO.Offset_CFrame

            this_player.HumanoidRootPart.CFrame = offsetCFrame
            this_player.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end

        --[[
        local offset = GOJO[2].Lapse_Blue_Spinning_Part.Position - this_player.HumanoidRootPart.Position
        local desiredHRPPosition = GLOBALS.TARGET.HumanoidRootPart.Position - offset
        this_player.HumanoidRootPart.CFrame = CFrame.new(desiredHRPPosition)
        ]]
    end,
    ["ROGER"] = function() 
        local ROGER = Char_Presets["ROGER"]
        local Active_Target = true
        if GLOBALS.TARGET == nil or GLOBALS.TARGET:FindFirstChild("HumanoidRootPart") == nil then 
            Active_Target = false
        end
        local Kamusari_On_CD = this_player.Cooldowns:FindFirstChild("Kamusari") and true or false -- slash
        local Crownbreaker_On_CD = this_player.Cooldowns:FindFirstChild("Crownbreaker") and true or false
        local Rapture_On_CD = this_player.Cooldowns:FindFirstChild("Rapture") and true or false -- rupture
        local Haoshoku_On_CD = this_player.Cooldowns:FindFirstChild("Haoshoku") and true or false

       
        local _override_offset = false
        local Player_Is_Stunned = GLOBALS.STATUS:FindFirstChild("Stunned") and true or false

            if not GLOBALS.PLAYER_JUST_DIED then
                if not Player_Is_Stunned and Active_Target then
                    if not Kamusari_On_CD and (os.clock() - ROGER.Last_Time_Move_Used) > ROGER.Move_Delay  then 
                            ROGER.Last_Time_Move_Used = os.clock()
                            local args = {
                                [1] = {
                                    [1] = "Skill",
                                    [2] = "1"
                                }
                            }
                            for i = 1,2 do 
                                GLOBALS.INPUT:FireServer(unpack(args))
                            end  
                    end
                end

                if not Player_Is_Stunned and Active_Target then
                    if not Crownbreaker_On_CD and (os.clock() - ROGER.Last_Time_Move_Used) > ROGER.Move_Delay then 
                         ROGER.Last_Time_Move_Used = os.clock()
                        _override_offset = true
                            local args = {
                                [1] = {
                                    [1] = "Skill",
                                    [2] = "2"
                                }
                            }
                        for i = 1,10 do 
                            GLOBALS.INPUT:FireServer(unpack(args))
                        end
                       
                        ROGER.Thread_Yielded = true
                        for i = 1,7 do 
                            task.wait(0.1)
                             ROGER.Offset_CFrame = CFrame.new(0,0,30)
                        end
                        task.delay(0.5, function() 
                            ROGER.Thread_Yielded = false
                        end)
                    end
                end

                if not Player_Is_Stunned and Active_Target then
                    if not Rapture_On_CD and (os.clock() - ROGER.Last_Time_Move_Used) > ROGER.Move_Delay  then 
                        ROGER.Last_Time_Move_Used = os.clock()
                        local args = {
                            [1] = {
                                [1] = "Skill",
                                [2] = "3"
                            }
                        }
                        for i = 1,10 do 
                            GLOBALS.INPUT:FireServer(unpack(args))
                        end
                    end
                end
                -- PASSIVE
                if Active_Target then 
                    local roger_remotes = {}
                    for _,remote in  GLOBALS.FX:GetChildren() do 
                        if remote:IsA("RemoteEvent") and remote.Name == "RogerSlashRemote" and roger_remotes[remote] ~= remote then 
                            roger_remotes[remote] = remote
                        end 
                    end
                    
                        for _, NPC_Model in GLOBALS.LIVING:GetChildren() do
                            if Black_List[NPC_Model] then continue end
                            if SERVICES.Players:GetPlayerFromCharacter(NPC_Model) == nil then
                                local _humanoid = NPC_Model:FindFirstChildOfClass("Humanoid")
                                if _humanoid and _humanoid.Health > 0 then
                                    for _,rog_sl_rem in roger_remotes do 
                                        rog_sl_rem:FireServer(NPC_Model, NPC_Model.HumanoidRootPart.CFrame)
                                    end
                                end
                            end
                        end

                    if _override_offset == false and not ROGER.Thread_Yielded then
                        local elapsed_time = tick() - start_time
                        local x = math.cos(elapsed_time * (2 * Orbit_Vars.Orbit_Speed)) * (25 * Orbit_Vars.Orbit_Radius)
                        local y = math.sin(elapsed_time * (5 * Orbit_Vars.Orbit_Speed)) * (25 * Orbit_Vars.Orbit_Radius)

                        ROGER.Offset_CFrame = CFrame.new(
                            x,
                            Orbit_Vars.Height,
                            y
                        )
                    end
                    if GLOBALS.TARGET == nil or GLOBALS.TARGET:FindFirstChild("HumanoidRootPart") == nil then 
                        Active_Target = false
                    end
                    if Active_Target then 
                        local offsetCFrame = GLOBALS.TARGET.HumanoidRootPart.CFrame * ROGER.Offset_CFrame

                        this_player.HumanoidRootPart.CFrame = offsetCFrame
                        this_player.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero 
                    end

                end
            end
    end,
}

local function Update_Used_Slots()
    if GLOBALS.INVENTORY then 
        local curr_slot_count = -1

        for _,char in GLOBALS.INVENTORY:GetChildren() do 
            if char:FindFirstChild("Key") 
                and char.Name ~= "Template" 
                and char.Name ~= "UIGridLayout"
                and char.Name ~= "UIPadding" then 
                
                curr_slot_count += 1
                --local decoded = SERVICES.Http:JSONDecode(GLOBALS.JSON_INVENTORY.Value)
                --print(decoded[char.Key.Value].Exp)
            end
        end
        Gatcha_Vars.Used_Slots = curr_slot_count
    end
end

function Alert_User_Of_Max_Inv()
    local Disposal = {}
    for i = 1,75 do 
        local Error_sound = GLOBALS.SOUNDS.Error:Clone()
        Error_sound.Parent = SERVICES.Replicated
        Error_sound.Volume = Gatcha_Vars.Volume 
        Error_sound:Play()
        table.insert(Disposal, Error_sound)
        task.wait(0.01)
    end
    task.delay(2, function() 
        for _,sound in Disposal do 
            sound:Destroy()
        end
    end)
end

-- gambling
local function Gamble()
    if GLOBALS.INVENTORY then 
        if Gatcha_Vars.Rolling == true then return end
        if Gatcha_Vars.Rolling_For == "GOLD" then 
            Gatcha_Vars.Rolling = true
            GLOBALS.ROLLX10:InvokeServer(true)
            local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
            
            task.delay(0.6, function() 
                Gatcha_Vars.Rolling = false
            end)
        elseif Gatcha_Vars.Rolling_For == "GEMS" then 
            Gatcha_Vars.Rolling = true
            GLOBALS.ROLLX10:InvokeServer()
            local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end

            task.delay(0.6, function() 
                Gatcha_Vars.Rolling = false
            end)
        end
        if Gatcha_Vars.Notify_On_Full_Inv and Gatcha_Vars.Rolling_For ~= "" then 
            if GLOBALS.MAX_SLOTS.Value - Gatcha_Vars.Used_Slots <= 10 then 
                Roll_Gold_Banner:Set(false)
                Roll_Gems_Banner:Set(false)
                Gatcha_Vars.Rolling_For = ""
                Alert_User_Of_Max_Inv()
            end
        end
    end
end

-- run
local execution_time_400 = 0


RUNTIME._running_connection_ = SERVICES.Run.RenderStepped:Connect(
    function(__delta__)
        if RUNTIME._running_ == false then
            this_player.Humanoid.WalkSpeed = 16
            RUNTIME._running_connection_:Disconnect()
            Rayfield:Destroy()
            getgenv().Anime_Mainia_Rayfield = nil
            return
        end
        
        if (os.clock() - execution_time_400) > 0.4 then 
            execution_time_400 = os.clock()

            Update_Units_In_Inventory()
            
            if Auto_Feed_Vars.Enabled and GLOBALS.INVENTORY then
                local Target_Key = Auto_Feed_Vars.Character_To_Feed
                if Target_Key and Auto_Feed_Vars.Feed_Target_List then
                    if Auto_Feed_Vars.Character_To_Feed.Level < Auto_Feed_Vars.Level_To_Reach then
                        Feed(Auto_Feed_Vars.Feed_Target_List, Target_Key.Key)
                        Auto_Feed_Vars.Feed_Target_List = {}
                    end
                end
                local req_exp, total_exp = Find_New_Feed_Targets()
                if req_exp and total_exp then 
                    Required_Exp_Label:Set(`EXP Required: {math.floor(req_exp)}`)
                Available_Exp_Label:Set(`EXP Available: {math.floor(total_exp)}`)
                end
            end
        end

        update_target()
        Update_Used_Slots()
        Gamble()

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
                if SERVICES.Replicated:FindFirstChild("Effect_Mods") then 
                     SERVICES.Replicated:FindFirstChild("Effect_Mods"):Destroy()
                end
                
                local auto_farm_func = Auto_Farm_Runtime[Auto_Farm_Vars.Preset]
                if auto_farm_func then 
                    auto_farm_func()
                end
            end
        end) 
    end
)


Rayfield:LoadConfiguration()
Update_Units_In_Inventory()
Available_Characters_dropdown:Refresh(Auto_Feed_Vars.safes)

local already_queued = false
this_player.Player.OnTeleport:Connect(function(State)
    if (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) and Keep_On_Teleport and already_queued == false and RUNTIME._running_ == true then
        already_queued = true
		queue_on_teleport([[
				loadstring(game:HttpGet('https://raw.githubusercontent.com/lordishow/anime_mainia/refs/heads/main/main.lua'))()
		]])
    end
end)
