local module = {}

function module.formatSecondsToPretty(seconds)
    local minutes = (seconds - seconds % 60)/60
    if minutes == 0 then
        return string.format("%02i", seconds)
    end
    seconds = seconds - 60 * minutes
    local hours = (minutes - minutes % 60)/60
    if hours == 0 then
        return string.format("%02i:%02i", minutes, seconds)
    end
    minutes = minutes - 60 * hours
    local days = (hours - hours % 24)/24
	hours = hours - 24 * days
	if days == 0 then
		return string.format("%02i:%02i:%02i", hours, minutes, seconds)
	end
    return string.format("%02i:%02i:%02i:%02i", days, hours, minutes, seconds)
end

function module.formatToHHMMSS(seconds)
	local minutes = (seconds - seconds % 60)/60

	seconds = seconds - 60 * minutes
	local hours = (minutes - minutes % 60)/60

	minutes = minutes - 60 * hours

	return string.format("%02i:%02i:%02i", hours, minutes, seconds)
end

function module.formatSecondsToMMSS(seconds)
	local minutes = (seconds - seconds % 60)/60
	if minutes == 0 then

	end
	seconds = seconds - 60 * minutes
	return string.format("%02i:%02i", minutes, seconds)
end

function module.formatSecondsWithOneDecimalToPretty(seconds)
    return string.format("%02.1f", seconds)
end

return module