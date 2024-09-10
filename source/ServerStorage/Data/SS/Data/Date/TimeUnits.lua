-- base unit is second

local module = {}

module.minute = 60
module.hour = 60 * module.minute
module.day = 24 * module.hour
module.week = 7 * module.day
module.monthSmall = 28 * module.day
module.monthBig = 31 * module.day
module.month = 30 * module.day
module.year = 365 * module.day

return module