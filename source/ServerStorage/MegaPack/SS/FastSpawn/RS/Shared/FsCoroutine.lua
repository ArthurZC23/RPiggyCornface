local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Sherlock could make it easy to swap this for a mockup.
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

-- Only gets first error
local module = function(fn, ...)
    local thread = coroutine.create(fn)
    local ok, err = coroutine.resume(thread, ...)
    if not ok then
        ErrorReport.report(
            nil,
            ("Coroutine Connection\nError: %s\nTraceback: %s"):format(err, debug.traceback(thread)),
            "error"
        )
    end
end

return module