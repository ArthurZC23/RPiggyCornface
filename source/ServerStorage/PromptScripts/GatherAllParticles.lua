local ServerStorage = game:GetService("ServerStorage")

local Assets = ServerStorage.Assets
local ParticleDisplayPartProto = Assets.Parts.ParticleDisplayPart

local model = Instance.new("Model")
model.Name = "Particles"

local _ignore = {
    ["rbxassetid://7504090561"] = true,
    ["rbxassetid://8466767701"] = true,
    ["rbxassetid://2977044760"] = true,
    ["rbxassetid://8529175248"] = true,
    ["rbxassetid://8120749500"] = true,
    ["rbxassetid://243664672"] = true,
    ["rbxassetid://9766459355"] = true,
    ["rbxassetid://8494034818"] = true,
    ["rbxassetid://8189326437"] = true,
    ["rbxassetid://8030746658"] = true,
    ["rbxassetid://9958883762"] = true,
    ["rbxassetid://838367768"] = true,
    ["rbxassetid://8030734851"] = true,
    ["rbxassetid://9956130694"] = true,
    ["rbxassetid://10192255655"] = true,
    ["rbxassetid://9504165696"] = true,
    ["rbxassetid://11163755167"] = true,
    ["rbxassetid://8542091200"] = true,
    ["rbxassetid://243098098"] = true,
    ["rbxassetid://4223179996"] = true,
    ["rbxassetid://1084955012"] = true,
    ["rbxassetid://358965513"] = true,
    ["rbxassetid://917180351"] = true,
    ["rbxassetid://10375968326"] = true,
}
local ignore = {}

for id in pairs(_ignore) do
    local number = id:match("%d+")
    ignore[number] = true
end

local origin = Vector3.new(0, 0, 0)
local idx = 0
for _, desc in ipairs(game:GetDescendants()) do
    if not desc:IsA("ParticleEmitter") then continue end
    local texture = desc.Texture
    local textureNumberId = texture:match("%d+")
    if ignore[textureNumberId] then continue end
    if textureNumberId then
        ignore[textureNumberId] = true
    end

    local particlePart = ParticleDisplayPartProto:Clone()
    particlePart.Position = origin + idx * 10 * Vector3.xAxis
    particlePart.Name = desc.Name
    particlePart.Particle.Face = Enum.NormalId.Top
    particlePart.Particle.Texture = texture
    particlePart.Parent = model
    idx += 1
end

model.Parent = workspace.Studio