-- Only gets first error
local module = function(fn, ...)
    coroutine.wrap(fn)(...)
end

return module