local Prometheus = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenixRoblox/Prometheus/refs/heads/main/Prometheus.lua"))()

local window = Prometheus.createWindow("Legends Of Speed")
local mainTab = window.addTab("Main")
local farmingSection = mainTab.addSection("Farming")

local orbFarm = mainTab.addToggle(farmingSection,"Orb Farm", false, function(toggled)
    _G.Farm1 = toggled
    if not toggled then return end
    while _G.Farm1 do
        if not _G.Farm1 then break end
        for i, v in pairs(game.Workspace.orbFolder.City:GetChildren()) do
            if not _G.Farm1 then break end
            if v.Name ~= "Gem" then
                v.outerOrb.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        wait()
    end
end)

local gemFarm = mainTab.addToggle(farmingSection,"Gem Farm", false, function(toggled)
    _G.Farm2 = toggled
    if not toggled then return end
    while _G.Farm2 do
        if not _G.Farm2 then break end
        for i, v in pairs(game.Workspace.orbFolder.City:GetChildren()) do
            if not _G.Farm2 then break end
            if v.Name == "Gem" then
                v.outerGem.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        wait()
    end
end)

local hoopFarm = mainTab.addToggle(farmingSection,"Hoop Farm", false, function(toggled)
    _G.Farm3 = toggled
    if not toggled then return end
    while _G.Farm3 do
        if not _G.Farm3 then break end
        for i, v in pairs(game.Workspace.Hoops:GetChildren()) do
            if not _G.Farm3 then break end
            v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        wait()
    end
end)

local miscSection = mainTab.addSection("Miscellaneous")

local autoRebirth = mainTab.addToggle(miscSection,"Auto Rebirth", false, function(toggled)
    _G.Rebirth = toggled
    if not toggled then return end
    while _G.Rebirth do
        if not _G.Rebirth then break end
        local tbl_main = {"rebirthRequest"}
        game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer(unpack(tbl_main))
        wait(5)
    end
end)

local autoCollect = mainTab.addToggle(miscSection,"Auto Collect Orbs", true, function(toggled)
    _G.Loll = toggled
    if not toggled then return end
    while _G.Loll do
        if not _G.Loll then break end
        for i = 1, 500 do
            if not _G.Loll then break end
            local orbTypes = {"Red Orb", "Yellow Orb", "Gem", "Orange Orb"}
            for _, orbType in ipairs(orbTypes) do
                game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", orbType, "City")
            end
            game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
        end
        wait(0.01)
    end
end)

local creditsSection = mainTab.addSection("Credits")

mainTab.addButton(creditsSection,"Made By Ree", function()
    window.notify("Credits: This script was originally made by Ree", "Info", 5)
end)

window.notify("Legends of Speed Script Loaded", "Info", 5)
