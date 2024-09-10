for i, desc in ipairs(game:GetDescendants()) do
    if not desc:IsA("BasePart") then continue end
    desc.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    desc.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    desc.RightSurface = Enum.SurfaceType.SmoothNoOutlines
    desc.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
    desc.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
    desc.BackSurface = Enum.SurfaceType.SmoothNoOutlines
end