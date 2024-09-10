local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local HitDetectorC = {}
HitDetectorC.__index = HitDetectorC
HitDetectorC.className = "HitDetector"
HitDetectorC.TAG_NAME = HitDetectorC.className

function HitDetectorC.new(hitDetector)
    local self = {
        hitDetector = hitDetector,
        refs = {},
    }
    setmetatable(self, HitDetectorC)

    if not self:getFields() then return end
    self:createReferenecs()

    return self
end

function HitDetectorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.hitFolder = self.hitDetector:FindFirstChild("HitDetectorF")
            if not self.hitFolder then return end
            return true
        end,
        keepTrying=function()
            return self.hitDetector.Parent
        end,
    })
    return ok
end

function HitDetectorC:createReferenecs()
    for _, objV in ipairs(self.hitFolder:GetChildren()) do
        self.refs[objV.Name] = objV.Value
    end
end

function HitDetectorC:Destroy()

end

return HitDetectorC