local utils = {}

function utils.isCharacterNearBox(character, box)
    local boxOffset = 2 -- Avoid wall transition firing several boxes in and outs.
    local charCenter = character:GetPrimaryPartCFrame().p
    if not (character and character.Parent) then return false end
    local isInsideBox = (charCenter - box.Position).magnitude < box.Size.X + boxOffset
    return isInsideBox
end

return utils