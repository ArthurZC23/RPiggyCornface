local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Queue = Mod:find({"DataStructures", "Queue"})

local CharClonerC = {}
CharClonerC.__index = CharClonerC
CharClonerC.className = "CharCloner"
CharClonerC.TAG_NAME = CharClonerC.className

function CharClonerC.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        lastCloneTimestamp = -math.huge
    }
    setmetatable(self, CharClonerC)

    return self
end

function CharClonerC:Clone()
    local t1 = Cronos:getTime()
    if t1 - self.lastCloneTimestamp > 1 then
        self.char.Archivable = true
        self.clone = self.char:Clone()
        self.lastCloneTimestamp = Cronos:getTime()
        self.char.Archivable = false
    end
    return self.clone
end

-- Deprecated
function CharClonerC:keepTrackOfCharDescendants()
    local function addToJobQueue()
        self.saveScheduler:pushJob({})
    end

    self._maid:Add(self.char.DescendantRemoving:Connect(function(desc)
        addToJobQueue()
    end))
    self._maid:Add(self.char.DescendantAdded:Connect(function(desc)
        addToJobQueue()
    end))
    for _, desc in ipairs(self.char:GetDescendants()) do
        if desc.ClassName == "Part" then
            -- Doesn't work with tween
            local props = {"Color", "Material", "MaterialVariant", "Reflectance", "Transparency"}
            for i, prop in ipairs(props) do
                self._maid:Add(desc:GetPropertyChangedSignal(prop):Connect(function()
                    addToJobQueue()
                end))
            end
        end
    end
end

function CharClonerC:Destroy()
    self._maid:Destroy()
end

return CharClonerC