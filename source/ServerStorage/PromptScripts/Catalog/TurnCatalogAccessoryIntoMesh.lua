local InsertService = game:GetService("InsertService")

local OriginFolderF = workspace.Studio.Catalog.Accessories
local TargetFolderF = workspace.Studio.Catalog.Meshes

for i, Model in ipairs(OriginFolderF:GetChildren()) do
    local Accessory = Model:FindFirstChildOfClass("Accessory") or Model:FindFirstChildOfClass("Tool")
    local OriginalMesh =
        Model:FindFirstChild("Mesh", true)
        or Model:FindFirstChild("SpecialMesh", true)
        or Model:FindFirstChild("Handle", true)
    local Mesh = InsertService:CreateMeshPartAsync(OriginalMesh.MeshId, Enum.CollisionFidelity.Box, Enum.RenderFidelity.Performance)
    if OriginalMesh.ClassName == "SpecialMesh" then
        Mesh.TextureID = OriginalMesh.TextureId
    elseif OriginalMesh.ClassName == "MeshPart" then
        Mesh.TextureID = OriginalMesh.TextureID
    end
    Mesh.CastShadow = false
    Mesh.CanCollide = false
    Mesh.CanQuery = false
    Mesh.CanTouch = false
    Mesh.Massless = true
    Mesh.Name = Accessory.Name
    Mesh:PivotTo(Model:GetPivot())

    local WeldConstraint = Instance.new("WeldConstraint")
    WeldConstraint.Part0 = Mesh
    WeldConstraint.Enabled = true
    WeldConstraint.Parent = Mesh

    Mesh.Parent = TargetFolderF
end