local CollectionService = game:GetService("CollectionService")

local Obby = Instance.new("Model")
Obby.Name = "Obby"

for _, desc in ipairs(game:GetDescendants()) do
    if not CollectionService:HasTag(desc, "CSS") then continue end
    local cssClass = desc:GetAttribute("CSSClass")
    if not cssClass then
        CollectionService:RemoveTag(desc, "CSS")
    end
end