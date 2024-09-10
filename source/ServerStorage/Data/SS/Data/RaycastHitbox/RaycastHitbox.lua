local module = {}

module.DetectionMode = {
	Default = 1,
	PartMode = 2,
	Bypass = 3,
}

module.SignalType = {
	Default = 1,
	Single = 2, --- Defaults to Single connections only for legacy purposes
}

module.debug = {
    SHOW_DEBUG_RAY_LINES = true,
    SHOW_OUTPUT_MESSAGES = true,
    DEBUGGER_RAY_DURATION = 0.25,
    DEFAULT_DEBUG_LOGGER_PREFIX = "[ B Raycast Hitbox V4 ]\n",
    DEFAULT_MISSING_ATTACHMENTS = "No attachments found in object: %s. Can be safely ignored if using SetPoints.",
    DEFAULT_ATTACH_COUNT_NOTICE = "%s attachments found in object: %s.",
    DEFAULT_DEBUGGER_RAY_COLOUR = Color3.fromRGB(255, 0, 0),
    DEFAULT_DEBUGGER_RAY_WIDTH = 4,
    DEFAULT_DEBUGGER_RAY_NAME = "_RaycastHitboxDebugLine",
    DEFAULT_FAR_AWAY_CFRAME = CFrame.new(0, math.huge, 0),
}

module.default = {
    DEFAULT_ATTACHMENT_INSTANCE = "DmgPoint",
    DEFAULT_GROUP_NAME_INSTANCE = "Group",
    DEFAULT_DEBUGGER_RAY_DURATION = 0.25
}

module.hitbox = {
    MINIMUM_SECONDS_SCHEDULER = 1 / 60,
    DEFAULT_SIMULATION_TYPE = "Heartbeat",
}

module.castModes = {
	LinkAttachments = 1,
	Attachment = 2,
	Vector3 = 3,
	Bone = 4,
}

return module