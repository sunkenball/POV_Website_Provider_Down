local ohString1 = "getmoney"
local ohNumber2 = getgenv().Amount

game:GetService("ReplicatedStorage").Remotes.NoobEvent:FireServer(ohString1, ohNumber2)
