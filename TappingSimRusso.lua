local plr = game.Players.LocalPlayer
local char = plr.Character
local hrp = char.HumanoidRootPart
local hmn = char.Humanoid
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(game.ReplicatedStorage.Modules.Utils.Network)
local EggInformation = require(ReplicatedStorage.Modules.Information.Eggs).Eggs
local ChestInformation = require(ReplicatedStorage.Modules.Information.Chests).GeneralInfo
local WingInformation = require(game:GetService("ReplicatedStorage").Modules.Information.JumpUpgrades).GeneralInfo
local ZoneInformation = require(game:GetService("ReplicatedStorage").Modules.Information.Zones).GeneralInfo
local RebirthPetInformation = require(game:GetService("ReplicatedStorage").Modules.Information.RebirthPets).Information
local MarketInformation = require(game:GetService("ReplicatedStorage").Modules.Information.MarketInfo)
local BoostInformation = MarketInformation.Boosts
local PotionInformation = MarketInformation.Potions
local AmountOfEggs = 3
local Information = setmetatable({}, {
    __SCRIPT_VERSION = "1.1.0",
	__GAME_VERSION = workspace:GetAttribute("Version"),
    __container = {
		Wings = {},
		Eggs = {},
		Chests = {},
		Zones = {},
        Codes = {
            "launch day!",
            "1M"
        },
        RebirthPets = {},
        Rebirths = {}
	},
	__click = function()
		Network:FireServer("ClickDetect")
	end,
	__hatch = function(egg, triple)
        Network:FireServer("OpenCapsules", egg, (triple == false and 1 or triple == true and 3))
	end,
    __claimChest = function(chest)
        Network:FireServer("RewardChests", chest)
    end, 
    __teleport = function(world) 
        hrp.CFrame = game:GetService("Workspace").GameAssets.Portals.Spawns[world].CFrame
    end,
    __buyPortal = function(world)
        Network:FireServer("PurchasePortal", world)
    end,
    __redeemCode = function(code)
        Network:InvokeServer("RedeemCode", code)
    end,
    __usePotion = function(potion) 
        Network:FireServer("UsePotion", potion)
    end,
    __spinWheel = function()
        for i109,v109 in next, plr.PlayerGui.ScreenGui.Menus.Shop.Menu.SpinwheelFrame.Holder.Spinner:GetChildren() do
            if v109:IsA("ImageButton") then
                Network:FireServer("AttemptSpin", tonumber(v109.Name));    
            end
        end 
    end,
    __rebirth = function(amount)
        Network:FireServer("Rebirth", amount);
    end,
    __buyWings = function(wing)
        Network:FireServer("Purchase Wings", wing)
    end,
    __buyRebirthShopItems = function()
        Network:FireServer("PurchaseFreeAutoClicker")
    end
})

getgenv().AntiEggUI = false

game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(inst)
    if getgenv().AntiEggUI == true then
        if inst.Name == "EggEffectGui" then
            pcall(function()
                inst:Destroy()
            end)
        end
    end
end)

local metaContainer = getrawmetatable(Information).__container

for i, v in next, EggInformation do
	table.insert(metaContainer["Eggs"], i)
end

for i, v in next, ChestInformation do
	table.insert(metaContainer["Chests"], i)
end
for i, v in next, WingInformation do
	table.insert(metaContainer["Wings"], i)
end
for i,v in next, RebirthPetInformation do
    metaContainer["RebirthPets"][i] = {}
    for i2,v2 in next, v do
        table.insert(metaContainer["RebirthPets"][i], i2)
    end
end
for i,v in next, ZoneInformation do
    table.insert(metaContainer["Zones"], i)
end

local rawInformation = getrawmetatable(Information)

for i,v in next, plr.PlayerGui.ScreenGui.Menus.Rebirths.Menu.Holder:GetChildren() do
    if v:IsA("ImageButton") and v.Name:match("%d+") then
        table.insert(rawInformation.__container.Rebirths, tostring(v.Name).." Rebirths")
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

function GetPets()
    local PlayerController = require(Player.PlayerScripts.Client.ClientManager.PlayerController)
    local tbl = {}

    for i, v in pairs(PlayerController.Object.Data.PetsInfo.PetStorage) do
        if not tbl[v.Tier] then
            tbl[v.Tier] = {}
        end
    
        if not tbl[v.Tier][v.Name] then
            tbl[v.Tier][v.Name] = {}
        end
        table.insert(tbl[v.Tier][v.Name], v.UUID)
    end 
    return tbl
end

local threshold = 1

function UpgradePet(Type, RemoteName)
    local Pets = GetPets()

    for i, v in pairs(Pets) do
        if i == Type then
            for i2, v2 in pairs(v) do
                if #v2 >= threshold then
                    local str, tbl1, tbl2 = "", {}, {}
                    for i3, v3 in pairs(v2) do
                        if #tbl1 < threshold then
                            table.insert(tbl1, v3)
                            str = v3
                        end
                    end
                    for i3, v3 in pairs(tbl1) do
                        tbl2[v3] = true
                    end
                    Network:FireServer(RemoteName, str, tbl2)
                end
            end     
        end
    end
end

local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stebulous/solaris-ui-lib/main/source.lua"))()

local win = SolarisLib:New({
  Name = "Tapping Simulator - Russo",
  FolderToSave = "tsr_sgwr"
})

local tab = win:Tab("Tab")

local sec = tab:Section("Home")

sec:Label("Made By Sunken.")
sec:Label(("Script Version: %s"):format(rawInformation.__SCRIPT_VERSION))
sec:Label(("Game Version: %s"):format(rawInformation.__GAME_VERSION))
sec:Label(("Possible Bugs: %s"):format(rawInformation.__GAME_VERSION == rawInformation.__SCRIPT_VERSION and "No" or rawInformation.__GAME_VERSION ~= rawInformation.__SCRIPT_VERSION and "Yes"))

local sec = tab:Section("Clicks")

sec:Toggle("Auto Click", false, "Auto Click", function(x)
    getgenv()["Auto Click"] = x

    while getgenv()["Auto Click"] == true do task.wait()
        rawInformation.__click()
    end
end)

local sec = tab:Section("Eggs")

local triple_hatch = false
local selected_egg = ""

sec:Toggle("Auto Hatch", false, "Hatch", function(x)
    getgenv()["Auto Hatch"] = x

    while getgenv()["Auto Hatch"] == true do task.wait()
        rawInformation.__hatch(selected_egg, triple_hatch)
    end
end)

sec:Toggle("Triple Hatch", false, "Triple Hatch", function(x)
    triple_hatch = x
end)

sec:Dropdown("Select Egg", rawInformation.__container.Eggs,"Forest Egg","Select Egg", function(t)
    selected_egg = t
end)

sec:Toggle("Hide Egg UI | Breaks UI", false, "Hide Egg UI", function(x)
    getgenv().AntiEggUI = x
end)

local delay_equipbest = 0
local delay_Delete = 0

sec:Toggle("Equip Best Pets", false, "Equip Best Pets", function(x)
    getgenv()["Equip Best Pets"] = x

    while getgenv()["Equip Best Pets"] do
        task.wait(delay_equipbest)
        Network:FireServer("EquipBest")
    end
end)

sec:Toggle("Delete Unlocked Pets", false, "Delete Unlocked Pets", function(x)
    getgenv()["Delete Unlocked Pets"] = x

    while getgenv()["Delete Unlocked Pets"] do
        task.wait(delay_Delete)
        Network:FireServer("DeleteAllPets")
    end
end)

sec:Slider("Equip Best Delay", 1,60,1,1,"Equip Best Delay", function(t)
    delay_equipbest = t
end)

sec:Slider("Delete Unlocked Pets Delay", 1,60,1,1,"Delete Unlocked Pets Delay", function(t)
    delay_Delete = t
end)

local sec = tab:Section("Evolve Pets")

local shiny_threshold = 0
local rainbow_threshold = 0

sec:Toggle("Auto Convert Pets To Shiny", false, "Auto Shiny Pets", function(x)
    getgenv()["Auto Shiny Pets"] = x

    while getgenv()["Auto Shiny Pets"] do
        task.wait()
        UpgradePet(1, "ShinyCrafting")
    end
end)

sec:Toggle("Auto Convert Pets To Rainbow", false, "Auto Rainbow Pets", function(x)
    getgenv()["Auto Rainbow Pets"] = x

    while getgenv()["Auto Rainbow Pets"] do
        task.wait()
        UpgradePet(2, "RainbowCrafting")
    end
end)

sec:Slider("Convert Pets Threshold", 1,5,1,1,"Convert Pets Threshold", function(t)
    threshold = t
end)

local sec = tab:Section("Rebirths")

local rebirth_amount = 0

sec:Toggle("Rebirth", false, "Rebirth", function(x)
    getgenv()["Rebirth"] = x

    while getgenv()["Rebirth"] do
        task.wait()
        rawInformation.__rebirth(tostring(rebirth_amount))
    end
end)

sec:Toggle("Infinite Rebirth", false, "Infinite Rebirth", function(x)
    getgenv()["Infinite Rebirth"] = x

    while getgenv()["Infinite Rebirth"] do
        task.wait()
        Network:FireServer("AttemptInfRebirth")
    end
end)

local selectedRebirth = sec:Dropdown("Select Rebirth", rawInformation.__container.Rebirths,"1 Rebirths","Select Rebirth", function(t)
    rebirth_amount = (t):match("%d+")
end)

task.spawn(function()
    while task.wait(9) do
        table.clear(rawInformation.__container.Rebirths)
        task.wait(1)
        for i,v in next, plr.PlayerGui.ScreenGui.Menus.Rebirths.Menu.Holder:GetChildren() do
            if v:IsA("ImageButton") and v.Name:match("%d+") then
                table.insert(rawInformation.__container.Rebirths, tostring(v.Name).." Rebirths")
            end
        end
        selectedRebirth:Refresh(rawInformation.__container.Rebirths, true)
    end
end)

sec:Toggle("Buy Rebirth Upgrades", false, "Buy Rebirth Upgrades", function(x)
    getgenv()["Buy Rebirth Upgrades"] = x

    rawInformation.__buyRebirthShopItems()

    while getgenv()["Buy Rebirth Upgrades"] do
        task.wait()
        Network:FireServer("PurchaseRebirthButton")
    end
end)

sec:Toggle("Buy Rebirth Pets", false, "Buy Rebirth Pets", function(x)
    getgenv()["Buy Rebirth Pets"] = x

    while getgenv()["Buy Rebirth Pets"] do
        task.wait()
        for i,v in next, rawInformation.__container.RebirthPets do
            for i2,v2 in next, v do
                Network:FireServer("PurchaseRebirthPet", i, v2)
            end
        end
    end
end)

local sec = tab:Section("Purchases")

sec:Toggle("Buy Wings", false, "Buy Wings", function(x)
    getgenv()["Buy Wings"] = x

    while getgenv()["Buy Wings"] do
        task.wait()
        for i,v in next, rawInformation.__container.Wings do
            rawInformation.__buyWings(v)
        end
    end
end)

sec:Toggle("Buy Portals", false, "Buy Portals", function(x)
    getgenv()["Buy Portals"] = x

    while getgenv()["Buy Portals"] do
        task.wait()
        for i, v in next, rawInformation.__container.Zones do
            rawInformation.__buyPortal(v)
        end
    end
end)

local sec = tab:Section("Claimables")

sec:Toggle("Claim Chests", false, "Claim Chests", function(x)
    getgenv()["Claim Chests"] = x

    while getgenv()["Claim Chests"] do
        task.wait()
        for i,v in next, game:GetService("Workspace").GameAssets.Chests:GetChildren() do
            rawInformation.__claimChest(v.Name)
        end
    end
end)

sec:Toggle("Claim Codes", false, "Claim Codes", function(x)
    getgenv()["Claim Codes"] = x

    while getgenv()["Claim Codes"] do
        task.wait()
        for i,v in next, rawInformation.__container.Codes do
            rawInformation.__redeemCode(v)
        end
    end
end)

local sec = tab:Section("Boosts")

sec:Toggle("Use Auto Taps Boost", false, "Use Auto Taps Boost", function(x)
    getgenv()["Use Auto Taps Boost"] = x

    while getgenv()["Use Auto Taps Boost"] do
        task.wait()
        for i,v in next, {"15", "60", "300"} do
            Network:FireServer("UseBoost", "Auto Taps", tonumber(v))
        end
    end
end)

sec:Toggle("Use x2 Taps Boost", false, "Use x2 Taps Boost", function(x)
    getgenv()["Use x2 Taps Boost"] = x

    while getgenv()["Use x2 Taps Boost"] do
        task.wait()
        for i,v in next, {"15", "60", "300"} do
            Network:FireServer("UseBoost", "x2 Taps", tonumber(v))
        end
    end
end)

sec:Toggle("Use x2 Luck Boost", false, "Use x2 Luck Boost", function(x)
    getgenv()["Use x2 Luck Boost"] = x

    while getgenv()["Use x2 Luck Boost"] do
        task.wait()
        for i,v in next, {"15", "60", "300"} do
            Network:FireServer("UseBoost", "x2 Luck", tonumber(v))
        end
    end
end)

sec:Toggle("Use x2 Diamonds Boost", false, "Use x2 Diamonds Boost", function(x)
    getgenv()["Use x2 Diamonds Boost"] = x

    while getgenv()["Use x2 Diamonds Boost"] do
        task.wait()
        for i,v in next, {"15", "60", "300"} do
            Network:FireServer("UseBoost", "x2 Diamonds", tonumber(v))
        end
    end
end)

local sec = tab:Section("Misc")

sec:Dropdown("Teleport To World", rawInformation.__container.Zones,"","Teleport To World", function(t)
    pcall(function()
        rawInformation.__teleport(t)
    end)
end)

sec:Toggle("Spin Wheel", false, "Spin Wheel", function(x)
    getgenv()["Spin Wheel"] = x

    while getgenv()["Spin Wheel"] do
        task.wait()
        rawInformation.__spinWheel()
    end
end)
