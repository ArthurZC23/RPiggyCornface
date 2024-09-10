return function (fn, ...)
    task.spawn(function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            -- This error doesn't have stacktrace
            error(err)
        end
    end)
end
