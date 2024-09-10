local module = {}

function module.tracePcall(func, ...)
    local extraTrace = debug.traceback(nil, 2)
	return xpcall(
		func,
		function(err)
			err = ("%s\n%s\n%s"):format(err, debug.traceback(), extraTrace)
			return err
		end,
		...
	)
end

function module.tracePcallV2(func, creationTraceback, ...)
	return xpcall(
		func,
		function(err)
			err = ("%s\nTraceback: %s\nCreation Traceback: %s ")
                :format(err, debug.traceback(), creationTraceback)
			return err
		end,
		...
	)
end

return module