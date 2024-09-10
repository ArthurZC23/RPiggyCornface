local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local Animate = {}
Animate.__index = Animate
Animate.TAG_NAME = "Animate"

function Animate.new(char)
	local self = {
        char = char,
        _maid = Maid.new(),
        isRunning = true,
        random = Random.new(),
    }
    setmetatable(self, Animate)

    if not self:getFields() then return end

	self._maid:Add(function()
		self.isRunning = false
		local AnimationTracks = self.humanoid:GetPlayingAnimationTracks()
		for _, track in pairs (AnimationTracks) do
			track:Stop()
		end
	end)
    task.spawn(function()
		self:animate(char)
    end)

	return self
end

function Animate:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end
            self.humanoid = self.charParts.humanoid
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop") end)
local userNoUpdateOnLoop = userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue

local animateScriptEmoteHookFlagExists, animateScriptEmoteHookFlagEnabled = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScriptEmoteHook")
end)
local FFlagAnimateScriptEmoteHook = animateScriptEmoteHookFlagExists and animateScriptEmoteHookFlagEnabled

function Animate:animate(char)
	self.char = char
	self.pose = "Standing"

	local AnimationSpeedDampeningObject = self.char:GetAttribute("ScaleDampeningPercent")
	local HumanoidHipHeight = self.humanoid.HipHeight

	self.currentAnim = ""
	self.currentAnimInstance = nil
	self.currentAnimTrack = nil
	self.currentAnimKeyframeHandler = nil
	self.currentAnimSpeed = 1.0

	self.runAnimTrack = nil
	self.runAnimKeyframeHandler = nil

	local PreloadedAnims = {}

	self.animTable = {}
	self.animNames = {}

	local function configureAnimNames()
		for _, animFolder in ipairs(self.char.Animations:GetChildren()) do
			self.animNames[animFolder.Name] = {}
			for i, animation in ipairs(animFolder:GetChildren()) do
				local weight = animation:FindFirstChild("Weight")
				if weight then
					weight = weight.Value
				else
					weight = 10
				end
				self.animNames[animFolder.Name][i] = {id=animation.AnimationId, weight=weight}
			end
		end
	end
	configureAnimNames()

	-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
	local emoteNames = { wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

	local function configureAnimationSet(name, fileList)
		if (self.animTable[name] ~= nil) then
			for _, connection in pairs(self.animTable[name].connections) do
				connection:disconnect()
			end
		end
		self.animTable[name] = {}
		self.animTable[name].count = 0
		self.animTable[name].totalWeight = 0	
		self.animTable[name].connections = {}

		local allowCustomAnimations = true

		local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
		if not success then
			allowCustomAnimations = true
		end

		-- check for config values
		local config = script:FindFirstChild(name)
		if (allowCustomAnimations and config ~= nil) then
			table.insert(self.animTable[name].connections, config.ChildAdded:Connect(function(child) configureAnimationSet(name, fileList) end))
			table.insert(self.animTable[name].connections, config.ChildRemoved:Connect(function(child) configureAnimationSet(name, fileList) end))
			
			local idx = 0
			for _, childPart in pairs(config:GetChildren()) do
				if (childPart:IsA("Animation")) then
					local newWeight = 1
					local weightObject = childPart:FindFirstChild("Weight")
					if (weightObject ~= nil) then
						newWeight = weightObject.Value
					end
					self.animTable[name].count = self.animTable[name].count + 1
					idx = self.animTable[name].count
					self.animTable[name][idx] = {}
					self.animTable[name][idx].anim = childPart
					self.animTable[name][idx].weight = newWeight
					self.animTable[name].totalWeight = self.animTable[name].totalWeight + self.animTable[name][idx].weight
					table.insert(self.animTable[name].connections, childPart.Changed:Connect(function(property) configureAnimationSet(name, fileList) end))
					table.insert(self.animTable[name].connections, childPart.ChildAdded:Connect(function(property) configureAnimationSet(name, fileList) end))
					table.insert(self.animTable[name].connections, childPart.ChildRemoved:Connect(function(property) configureAnimationSet(name, fileList) end))
				end
			end
		end
		
		-- fallback to defaults
		if (self.animTable[name].count <= 0) then
			for idx, anim in pairs(fileList) do
				self.animTable[name][idx] = {}
				self.animTable[name][idx].anim = Instance.new("Animation")
				self.animTable[name][idx].anim.Name = name
				self.animTable[name][idx].anim.AnimationId = anim.id
				self.animTable[name][idx].weight = anim.weight
				self.animTable[name].count = self.animTable[name].count + 1
				self.animTable[name].totalWeight = self.animTable[name].totalWeight + anim.weight
			end
		end
		
		-- preload anims
		for i, animType in pairs(self.animTable) do
			for idx = 1, animType.count, 1 do
				if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
                    if self.humanoid.Parent then -- Edge case. Keep track
                        self.humanoid:LoadAnimation(animType[idx].anim)
                        PreloadedAnims[animType[idx].anim.AnimationId] = true
                    end
				end
			end
		end
	end

	------------------------------------------------------------------------------------------------------------

	-- Setup animation objects
	local function scriptChildModified(child)
		local fileList = self.animNames[child.Name]
		if (fileList ~= nil) then
			configureAnimationSet(child.Name, fileList)
		end
	end

	script.ChildAdded:Connect(scriptChildModified)
	script.ChildRemoved:Connect(scriptChildModified)


	for name, fileList in pairs(self.animNames) do 
		configureAnimationSet(name, fileList)
	end	

	-- ANIMATION

	-- declarations

	local jumpAnimTime = 0
	local jumpAnimDuration = 0.31

	local fallTransitionTime = 0.2

	local currentlyPlayingEmote = false

	-- functions

	local function stopAllAnimations()
		local oldAnim = self.currentAnim

		-- return to idle if finishing an emote
		if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
			oldAnim = "idle"
		end
		
		if FFlagAnimateScriptEmoteHook and currentlyPlayingEmote then
			oldAnim = "idle"
			currentlyPlayingEmote = false
		end

		self.currentAnim = ""
		self.currentAnimInstance = nil
		if (self.currentAnimKeyframeHandler ~= nil) then
			self.currentAnimKeyframeHandler:disconnect()
		end

		if (self.currentAnimTrack ~= nil) then
			self.currentAnimTrack:Stop()
			self.currentAnimTrack:Destroy()
			self.currentAnimTrack = nil
		end

		-- clean up walk if there is one
		if (self.runAnimKeyframeHandler ~= nil) then
			self.runAnimKeyframeHandler:disconnect()
		end

		if (self.runAnimTrack ~= nil) then
			self.runAnimTrack:Stop()
			self.runAnimTrack:Destroy()
			self.runAnimTrack = nil
		end

		return oldAnim
	end

	local function getHeightScale()
		if self.humanoid then
			if not self.humanoid.AutomaticScalingEnabled then
				return 1
			end

			local scale = self.humanoid.HipHeight / HumanoidHipHeight
			if AnimationSpeedDampeningObject == nil then
				AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
			end
			if AnimationSpeedDampeningObject ~= nil then
				scale = 1 + (self.humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampeningObject.Value / HumanoidHipHeight
			end
			return scale
		end
		return 1
	end

	local smallButNotZero = 0.0001
	local function setRunSpeed(speed)
		local speedScaled = speed * 1.25
		local heightScale = getHeightScale()
		local runSpeed = speedScaled / heightScale

		if runSpeed ~= self.currentAnimSpeed then
			if runSpeed < 0.33 then
				self.currentAnimTrack:AdjustWeight(1.0)		
				self.runAnimTrack:AdjustWeight(smallButNotZero)
			elseif runSpeed < 0.66 then
				local weight = ((runSpeed - 0.33) / 0.33)
				self.currentAnimTrack:AdjustWeight(1.0 - weight + smallButNotZero)
				self.runAnimTrack:AdjustWeight(weight + smallButNotZero)
			else
				self.currentAnimTrack:AdjustWeight(smallButNotZero)
				self.runAnimTrack:AdjustWeight(1.0)
			end
			self.currentAnimSpeed = runSpeed
			self.runAnimTrack:AdjustSpeed(runSpeed)
			self.currentAnimTrack:AdjustSpeed(runSpeed)
		end
	end

	local function setAnimationSpeed(speed)
		if self.currentAnim == "walk" then
				setRunSpeed(speed)
		else
			if speed ~= self.currentAnimSpeed then
				self.currentAnimSpeed = speed
				self.currentAnimTrack:AdjustSpeed(self.currentAnimSpeed)
			end
		end
	end

	local function rollAnimation(animName)
        -- Edge case. Keep track
        local animation = self.animTable[animName]
        if not animation then return 1 end

		local roll = self.random:NextInteger(1, self.animTable[animName].totalWeight)
		local origRoll = roll
		local idx = 1
		while (roll > self.animTable[animName][idx].weight) do
			roll = roll - self.animTable[animName][idx].weight
			idx = idx + 1
		end
		return idx
	end

	local function switchToAnim(anim, animName, transitionTime, humanoid)
		-- switch animation
		if not humanoid.Parent then return end
		if (anim ~= self.currentAnimInstance) then
			
			if (self.currentAnimTrack ~= nil) then
				self.currentAnimTrack:Stop(transitionTime)
				self.currentAnimTrack:Destroy()
			end

			if (self.runAnimTrack ~= nil) then
				self.runAnimTrack:Stop(transitionTime)
				self.runAnimTrack:Destroy()
				if userNoUpdateOnLoop == true then
					self.runAnimTrack = nil
				end
			end

			self.currentAnimSpeed = 1.0
		
			-- load it to the humanoid; get AnimationTrack
			self.currentAnimTrack = humanoid:LoadAnimation(anim)
			self.currentAnimTrack.Priority = Enum.AnimationPriority.Core
			
			-- play the animation
			self.currentAnimTrack:Play(transitionTime)
			self.currentAnim = animName
			self.currentAnimInstance = anim

			-- set up keyframe name triggers
			if (self.currentAnimKeyframeHandler ~= nil) then
				self.currentAnimKeyframeHandler:disconnect()
			end
			self.currentAnimKeyframeHandler =
				self.currentAnimTrack.KeyframeReached:Connect(function(frameName)
					self:keyFrameReachedFunc(frameName)
				end)
			
			-- check to see if we need to blend a walk/run animation
			if animName == "walk" then
				local runAnimName = "run"
				local runIdx = rollAnimation(runAnimName)

				self.runAnimTrack = humanoid:LoadAnimation(self.animTable[runAnimName][runIdx].anim)
				self.runAnimTrack.Priority = Enum.AnimationPriority.Core
				self.runAnimTrack:Play(transitionTime)		
				
				if (self.runAnimKeyframeHandler ~= nil) then
					self.runAnimKeyframeHandler:disconnect()
				end
				self.runAnimKeyframeHandler =
					self.runAnimTrack.KeyframeReached:Connect(function(frameName)
						self:keyFrameReachedFunc(frameName)
					end)
			end
		end
	end

	local function playAnimation(animName, transitionTime, humanoid)
		local idx = rollAnimation(animName)
		local anim = self.animTable[animName][idx].anim

		switchToAnim(anim, animName, transitionTime, humanoid)
		currentlyPlayingEmote = false
	end

	function Animate:keyFrameReachedFunc(frameName)
		if self.char.Parent ~= nil and self.isRunning then return end
		if (frameName == "End") then
			if self.currentAnim == "walk" then
				if userNoUpdateOnLoop == true then
					if self.runAnimTrack.Looped ~= true then
						self.runAnimTrack.TimePosition = 0.0
					end
					if self.currentAnimTrack.Looped ~= true then
						self.currentAnimTrack.TimePosition = 0.0
					end
				else
					self.runAnimTrack.TimePosition = 0.0
					self.currentAnimTrack.TimePosition = 0.0
				end
			else
				local repeatAnim = self.currentAnim
				
				local animSpeed = self.currentAnimSpeed
				playAnimation(repeatAnim, 0.15, self.humanoid)
				setAnimationSpeed(animSpeed)
			end
		end
	end



	-------------------------------------------------------------------------------------------
	-- STATE CHANGE HANDLERS

	local function onRunning(speed)
		if speed > 0.75 then
			local scale = 16.0
			playAnimation("walk", 0.2, self.humanoid)
			setAnimationSpeed(speed / scale)
			self.pose = "Running"
		else
			if emoteNames[self.currentAnim] == nil and not currentlyPlayingEmote then
				playAnimation("idle", 0.2, self.humanoid)
				self.pose = "Standing"
			end
		end
	end

	local function onDied()
		self.pose = "Dead"
	end

	local function onJumping()
		playAnimation("jump", 0.1, self.humanoid)
		jumpAnimTime = jumpAnimDuration
		self.pose = "Jumping"
	end

	local function onClimbing(speed)
		local scale = 5.0
		playAnimation("climb", 0.1, self.humanoid)
		setAnimationSpeed(speed / scale)
		self.pose = "Climbing"
	end

	local function onGettingUp()
		self.pose = "GettingUp"
	end

	local function onFreeFall()
		if (jumpAnimTime <= 0) then
			playAnimation("fall", fallTransitionTime, self.humanoid)
		end
		self.pose = "FreeFall"
	end

	local function onFallingDown()
		self.pose = "FallingDown"
	end

	local function onSeated()
		self.pose = "Seated"
	end

	local function onPlatformStanding()
		self.pose = "PlatformStanding"
	end

	-------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------

	local function onSwimming(speed)
		if speed > 1.00 then
			local scale = 10.0
			playAnimation("swim", 0.4, self.humanoid)
			setAnimationSpeed(speed / scale)
			self.pose = "Swimming"
		else
			playAnimation("swimidle", 0.4, self.humanoid)
			self.pose = "Standing"
		end
	end

	local lastTick = 0

	local function stepAnimate(currentTime)
		local amplitude = 1
		local frequency = 1
		local deltaTime = currentTime - lastTick
		lastTick = currentTime

		local climbFudge = 0
		local setAngles = false

		if (jumpAnimTime > 0) then
			jumpAnimTime = jumpAnimTime - deltaTime
		end

		if (self.pose == "FreeFall" and jumpAnimTime <= 0) then
			playAnimation("fall", fallTransitionTime, self.humanoid)
		elseif (self.pose == "Seated") then
			playAnimation("sit", 0.5, self.humanoid)
			return
		elseif (self.pose == "Running") then
			playAnimation("walk", 0.2, self.humanoid)
		elseif (self.pose == "Dead" or self.pose == "GettingUp" or self.pose == "FallingDown" or self.pose == "Seated" or self.pose == "PlatformStanding") then
			stopAllAnimations()
			amplitude = 0.1
			frequency = 1
			setAngles = true
		end
	end

	-- connect events
	self.humanoid.Died:connect(onDied)
	self.humanoid.Running:connect(onRunning)
	self.humanoid.Jumping:connect(onJumping)
	self.humanoid.Climbing:connect(onClimbing)
	self.humanoid.GettingUp:connect(onGettingUp)
	self.humanoid.FreeFalling:connect(onFreeFall)
	self.humanoid.FallingDown:connect(onFallingDown)
	self.humanoid.Seated:connect(onSeated)
	self.humanoid.PlatformStanding:connect(onPlatformStanding)
	self.humanoid.Swimming:connect(onSwimming)

	-- initialize to idle
	playAnimation("idle", 0.1, self.humanoid)
	self.pose = "Standing"

	-- loop to handle timed state transitions and tool animations
	-- WARNING: This will not detect if player dummy has fallen off the map
	while self.char.Parent ~= nil and self.isRunning do
		local _, currentGameTime = wait(0.1)
		stepAnimate(currentGameTime)
	end
end

function Animate:Destroy()
	self._maid:Destroy()
end

return Animate