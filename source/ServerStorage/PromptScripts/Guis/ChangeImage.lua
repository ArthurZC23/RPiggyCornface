local oldImage = "rbxassetid://15305853857"
local newImage = "rbxassetid://6543591915"

print("Starting Change Image.")
for _, desc in ipairs(game:GetDescendants()) do
    if
        desc:IsA("ImageButton") or desc:IsA("ImageLabel")
    then
        if desc.Image == oldImage then
            desc.Image = newImage
        end
    end

    if
        desc:IsA("Decal") or desc:IsA("Texture")
    then
        if desc.Texture == oldImage then
            desc.Texture = newImage
        end
    end
end
print("Finished Change Image.")