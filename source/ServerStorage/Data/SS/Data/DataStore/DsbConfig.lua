local RunService = game:GetService("RunService")

local Data = script:FindFirstAncestor("Data")
local TimeUnits = require(Data.Date.TimeUnits)

local savingMethod = "Standard"
if RunService:IsStudio() then
    --savingMethod = "Error"
    --savingMethod = "SetError"
end

local module = {
    SessionLockTimeout = 2 * TimeUnits.minute, -- 2 min is better than 10 min than is better than 30 minutes for Ux and solve most of the problem IMO.
    SaveInStudio = true,
    Debug = true,
    SAVING_METHOD = savingMethod,
    backupValues = {
        getAttempts = 3,
        cooldown = 6,
    },
    -- dataValidationBadge = "",
    OrderedBackups = {
        RetryCooldown = 3,
        MaxTries = 3,
    },
    LimitedBackups = {
        LIMITED_BACKUP_SIZE = 20,
        ARCHIVE_THRESHOLD = 100,
        ARCHIVE_SIZE = 2,
        MaxTries = 3,
    },
}

if not module.dataValidationBadge then
    warn("Add Data Validation badge!")
end

return module