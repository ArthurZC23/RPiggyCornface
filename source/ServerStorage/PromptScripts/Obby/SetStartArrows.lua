for _, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("Decal") then
        if
            desc.Texture == "rbxassetid://13364570588"
            or desc.Texture == "http://www.roblox.com/asset/?id=13364570588"
            or desc.Texture == "rbxassetid://13970468556"
        then
            desc.Name = "Decal"
            desc.Texture = "rbxassetid://13970468499"
        end
    end
end


