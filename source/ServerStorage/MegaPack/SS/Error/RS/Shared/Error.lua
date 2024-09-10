local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local Error = {}
Error.__index = Error
Error.className = "Error"
Error.TAG_NAME = Error.className

function Error.new(message, kwargs)
    local self = {
        message = message,
        _maid = Maid.new(),
        kwargs = kwargs or {},
    }
    setmetatable(self, Error)

    if kwargs.protoMsg then
        self[("%sErrorMessage"):format(kwargs.protoMsg)](self)
    end

    return self
end

function Error:failedToLoadErrorMessage()

end

function Error:Destroy()
    self._maid:Destroy()
end

return Error