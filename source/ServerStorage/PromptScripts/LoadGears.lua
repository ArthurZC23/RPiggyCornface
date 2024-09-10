InsertService = game:GetService("InsertService")

local assets = {
    1981813154, 7212288576
}
for _, asset in ipairs(assets) do
    InsertService:LoadAsset(asset).Parent = game:GetService("ReplicatedStorage").Tmp
end