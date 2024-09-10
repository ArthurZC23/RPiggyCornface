local date = {}

--[[
Date fields
hour
min
wday (1 - Sunday)
day
month (1 - Jan)
year
sec
yday - equal to day I think
isdst - day light saving
]]--

function date.getDate()
    local d = os.date("!*t")
    return d
end

function date.isFirstDateAfterSecond(date_1, date_2)
	if date_1.year > date_2.year then
		return true
	elseif (date_1.year == date_2.year) and date_1.month > date_2.month then
		return true
	elseif (date_1.year == date_2.year) and (date_1.month == date_2.month) and date_1.day > date_2.day then
		return true
	end
	return false
end

return date