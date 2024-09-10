--[[

	NOTE: This script should be in game.ServerScriptService

--]]

local ServerStorage = game:GetService("ServerStorage")
local GameAnalytics = require(ServerStorage.GameAnalytics)

GameAnalytics:initialize({
	build = "0.1.0";

	gameKey = "f675f1acdea06737176a1c54aa3cb824";
	secretKey = "4e47d5b070bf089d053611352cc411bb2ef160fd";

	enableInfoLog = false;
	enableVerboseLog = false;

	--debug is by default enabled in studio only
	enableDebugLog = false;

	automaticSendBusinessEvents = true;
	reportErrors = true;

	availableCustomDimensions01 = {};
	availableCustomDimensions02 = {};
	availableCustomDimensions03 = {};
	availableResourceCurrencies = {"MoneyOne"};
	availableResourceItemTypes = {"IAP", "Gameplay"};
	availableGamepasses = {};
})
