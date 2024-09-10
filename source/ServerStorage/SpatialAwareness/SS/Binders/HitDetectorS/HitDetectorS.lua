local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local HitDetectorS = {}
HitDetectorS.__index = HitDetectorS
HitDetectorS.className = "HitDetector"
HitDetectorS.TAG_NAME = HitDetectorS.className

function HitDetectorS.new(hitDetector)
    local self = {
        hitDetector = hitDetector,
        refs = {},
    }
    setmetatable(self, HitDetectorS)

    if not self:getFields() then return end
    self:createReferenecs()

    return self
end

function HitDetectorS:getFields()
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

function HitDetectorS:createReferenecs()
    for _, objV in ipairs(self.hitFolder:GetChildren()) do
        self.refs[objV.Name] = objV.Value
    end
end

function HitDetectorS:Destroy()

end

return HitDetectorS