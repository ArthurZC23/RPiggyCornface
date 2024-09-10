local module = {}

module = {}

module.Zoom = {
    ["Default"] = {
        ["CameraMinZoomDistance"]=5,
        ["CameraMaxZoomDistance"]=30,
    },
}

module.lock = {
    -- cursorImage = "rbxasset://textures/MouseLockedCursor.png",
    cursorImage = "rbxassetid://12777107587",
    cameraOffset = Vector3.new(1.75,0,0) -- Default value
    -- cameraOffset = Vector3.new(2, 0, 0),
    -- cameraOffset = Vector3.new(0, 1.5, 0),
}

return module