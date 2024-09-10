local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local JohnShoutSE = SharedSherlock:find({"Bindable", "async"}, {root=ServerStorage, signal="JohnShout"})

local CHANNEL_NAME = "All"
local HOST_COLOR = Color3.fromRGB(255,215,0)

if not ChatService:GetChannel(CHANNEL_NAME) then
    local channelName
	while not channelName == CHANNEL_NAME do
		channelName = ChatService.ChannelAdded:Wait()
	end
end

local HostSpeaker = ChatService:AddSpeaker("John")
HostSpeaker:JoinChannel(CHANNEL_NAME)

local HostTag = {TagText = "Shampoo Sim Host", TagColor = HOST_COLOR}
HostSpeaker:SetExtraData("NameColor", HOST_COLOR)
HostSpeaker:SetExtraData("ChatColor", HOST_COLOR)
HostSpeaker:SetExtraData("TextSize", 22)
HostSpeaker:SetExtraData("Tags", {HostTag})

local function shout(message)
	HostSpeaker:SayMessage(message, "All")
end

JohnShoutSE:Connect(shout)

local module = {}

return module