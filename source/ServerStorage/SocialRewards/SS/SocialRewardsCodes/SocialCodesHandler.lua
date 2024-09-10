local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Date = Mod:find({"Date"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local ParentFolder = script.Parent
local SocialCodesCallbacks = require(ParentFolder.SocialCodesCallbacks)

local RemoteFunctions = ReplicatedStorage.Remotes.Functions
local SocialRewardsCodeRF = RemoteFunctions:WaitForChild("SocialRewardsCode")

local Data = Mod:find({"Data", "Data"})
local CODE_STATUS = Data.SocialCodes.CodeStatus
local CodesData = Data.SocialCodes.SocialCodes

local function isCodeNotReleasedYet(startDate, currentDate)
    return Date.isFirstDateAfterSecond(startDate, currentDate)
end

local function isCodeExpired(expirationDate, currentDate)
    return Date.isFirstDateAfterSecond(currentDate, expirationDate)
end

local S = Data.Strings.Strings
local function redeemCode(player, rawCode)
    if type(rawCode) ~= "string" then return CODE_STATUS.INVALID end
    local code = string.lower(rawCode)

    local id = CodesData.prettyNameToId[code]
    if not id then return CODE_STATUS.INVALID end

    local codeData = CodesData.idToData[id]

    local currentDate = os.date("!*t")
    if isCodeNotReleasedYet(codeData.startDate, currentDate) then return CODE_STATUS.INVALID end
    if isCodeExpired(codeData.expirationDate, currentDate) then return CODE_STATUS.EXPIRED end

    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return CODE_STATUS.INVALID end

    local SocialRewardsState = playerState:get("Stores", "SocialRewards")
    if SocialRewardsState.codes[id] then return CODE_STATUS.USED end
    if SocialRewardsState.codes[code] then return CODE_STATUS.USED end

    do
        local action = {
            name="addCode",
            code=id
        }
        playerState:set("Stores", "SocialRewards", action)
    end
    SocialCodesCallbacks[code](playerState)

    return CODE_STATUS.SUCCESS, codeData["message"]
end

SocialRewardsCodeRF.OnServerInvoke = redeemCode

local module = {}

return module
