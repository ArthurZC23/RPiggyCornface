local SuperUsers = require(script.Parent.SuperUsers)

local admins = {
    ["1700355376"] = "Nazmar222",
}

admins.__index = SuperUsers
setmetatable(admins, admins)

return admins