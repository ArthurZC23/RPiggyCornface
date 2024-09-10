local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})

local Pooling = {}

function Pooling.new(factory, createMethod, kwargs)
    kwargs = kwargs or {}

    local self = {
        factory = factory,
        createMethod = createMethod,
        maid = Maid.new(),
	}

	setmetatable(self, Pooling)

    return self
end

function Pooling:get()

end

function Pooling:Destroy()

end

return Pooling