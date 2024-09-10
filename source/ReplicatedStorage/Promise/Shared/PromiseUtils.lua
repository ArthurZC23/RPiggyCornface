local RootF = script:FindFirstAncestor("Shared")
local Promise = require(RootF:WaitForChild("Promise"))

local module = {}

function module.eachMethod(methodArray, kwargs)
    kwargs = kwargs or {}
    return Promise.each(methodArray, function(tbl)
        local arg1 = tbl[1]
        if typeof(arg1) == "string" then
            local _kwargs = tbl[2]
            if arg1 == "maidRemove" then
                kwargs.maid:Remove(_kwargs.maidName)
            end
        else
            local rootTbl, method, args = tbl[1], tbl[2], tbl[3]
            local res = rootTbl[method](rootTbl, unpack(args))
            if not res then return end

            if typeof(res) == "table" then
                if kwargs.maid and res.maid then
                    kwargs.maid:Add2(res.maid, res.maidName)
                end
                return res.promise
            end

            return res
        end
    end)
end

function module.getCanceledPromise()
    local promise = Promise.defer(function() end)
    promise:cancel()
    print(promise:getStatus())
    return promise
end

function module.retryGenerator(times, cd)
    return function(callback, ...)
        assert(type(callback) == "function", "Parameter #1 to Promise.retry must be a function")
        assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")

        local args, length = {...}, select("#", ...)

        return Promise.resolve(callback(...)):catch(function(...)
            if times > 0 then
                task.wait(cd)
                return Promise.retry(callback, times - 1, unpack(args, 1, length))
            else
                return Promise.reject(...)
            end
        end)
    end
end

return module