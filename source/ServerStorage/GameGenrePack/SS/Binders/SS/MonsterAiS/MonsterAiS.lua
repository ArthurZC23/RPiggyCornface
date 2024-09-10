local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local function setAttributes()
    script:SetAttribute("StuckTimeTolerance", 0.5)
    script:SetAttribute("StuckDistanceTreshold", 1e-2)
    script:SetAttribute("maxDistance", 0.5)
    script:SetAttribute("getTargetMaxDistance", 80)
    script:SetAttribute("maxCantNavigateToTargetCounter", 10)
    script:SetAttribute("timeSinceLastTargetAcquisition", 5)
    script:SetAttribute("killRange", 5.5)
    script:SetAttribute("debug_displayPath", false)
    script:SetAttribute("debug_displayPathLifetime", 20)
    script:SetAttribute("debug_visioRay", false)
    script:SetAttribute("debug_visioRayLifetime", 0.5)
    script:SetAttribute("MaxPatrolStepMemory", 10)
    script:SetAttribute("ShowDirectWalkTarget", false)
    if not RunService:IsStudio() then
        script:SetAttribute("debug_displayPath", false)
        script:SetAttribute("debug_visioRay", false)
        script:SetAttribute("ShowDirectWalkTarget", false)
    end
end
setAttributes()

local MonsterAiS = {}
MonsterAiS.__index = MonsterAiS
MonsterAiS.className = "MonsterAi"
MonsterAiS.TAG_NAME = MonsterAiS.className

function MonsterAiS.new(Npc)
    local self = {
        _maid = Maid.new(),
        Npc = Npc,
        Attacking = false,
        FollowingPlayer = false,
        Navigating = false,
        PatrolPoint = nil,
        Target = nil,
        TimeSinceTarget = 0,
        TimeOnSamePlace = 0,
        cantNavigateToTargetCounter = 0,
        lostTarget = false,
        LastStuck = time(),
        randoms = {
            patrolWp = Random.new()
        },
        t0 = nil,
        t1 = nil,
    }
    setmetatable(self, MonsterAiS)

    if not self:getFields() then return end
    self:setRaycastParams()
    self:setPhysics()
    self._maid:Add2(Promise.delay(3):andThen(function()
        task.spawn(function()
            self.t0 = os.clock()
            while self.Npc and self.Npc.Parent and CollectionService:HasTag(self.Npc, MonsterAiS.TAG_NAME) do
                self:patrol()
                self.t1 = os.clock()
                if self.t1 - self.t0 < 1/60 then
                    task.wait()
                end
                self.t0 = self.t1
                -- if RunService:IsStudio() then
                --     -- task.wait(1)
                -- end
            end
        end)
    end))

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BigBen = Mod:find({"Cronos", "BigBen"})
function MonsterAiS:patrol()
	local target = self:getTarget()
	-- print("patrol")

    -- print("cantNavigateToTargetCounter: ",  self.cantNavigateToTargetCounter)
    if self.Target and self.Target.Parent == nil then
        -- -- print("Target removed from workspace")
        self.Target = nil
    end
	if target then
		-- print("Target DirectWalk")
        self._maid:Remove("FollowingPlayerWithoutSeeing")
        self.cantNavigateToTargetCounter = 0
		self.Target = target
		self.TimeSinceTarget = 0
		self.FollowingPlayer = true
		self.Navigating = false
		self:DirectWalk(self.Target.Position, {_type = "target"})
	elseif
        self.Target
        and self.TimeSinceTarget < script:GetAttribute("timeSinceLastTargetAcquisition")
        and self.lostTarget ~= true
        and self.cantNavigateToTargetCounter < script:GetAttribute("maxCantNavigateToTargetCounter")
    then
		-- print("Target NavigateTo", self.Target, self.TimeSinceTarget, script:GetAttribute("timeSinceLastTargetAcquisition"), self.lostTarget)
        self.FollowingPlayer = true
        self:NavigateTo(self.Target.Position)

        if not self.FollowingPlayerWithoutSeeingMaid then
            self.FollowingPlayerWithoutSeeingMaid = true
            local maid = self._maid:Add2(Maid.new(), "FollowingPlayerWithoutSeeing")
            maid:Add(BigBen.every(1, "Heartbeat", "frame", true):Connect(function(_, timeStep)
                self.TimeSinceTarget += timeStep
                if self.Navigating then
                    self.cantNavigateToTargetCounter = 0
                else
                    self.cantNavigateToTargetCounter += 1
                end

            end))
            maid:Add(function()
                self.FollowingPlayerWithoutSeeingMaid = false
                -- self.TimeSinceTarget = 0
            end)
        end

	else
		-- print("Finding waypoint", self.Target, self.TimeSinceTarget, self.TimeSinceTarget < script:GetAttribute("timeSinceLastTargetAcquisition"))
        self._maid:Remove("FollowingPlayerWithoutSeeing")
        self.lostTarget = false
		self.FollowingPlayer = false
        self.Target = nil
        self.TimeSinceTarget = 0
        self.cantNavigateToTargetCounter = 0
		-- Walk to random location
		local waypoints = self.PatrolWaypoints:GetChildren()
		if not waypoints or (not next(waypoints)) then return end -- Exit if map has been destroyed and no waypoints
        if self.PatrolPoint then
            local removeIdx = table.find(waypoints, self.PatrolPoint)
            table.remove(waypoints, removeIdx)
        end
        if not next(waypoints) then return end
		local wpIdx = self.randoms.patrolWp:NextInteger(1, #waypoints)
        self.PatrolPoint = waypoints[wpIdx]

        if self:CanSee(waypoints[wpIdx]) then
            -- print("Waypoint DirectWalk")
            self:DirectWalk(waypoints[wpIdx].Position, {_type = "directNavigation"})
        else
            -- [BUG] this is getting called twice in quick succession
            -- print("Waypoint NavigateTo")
            self:NavigateTo(waypoints[wpIdx].Position)
        end
	end
end

function MonsterAiS:FindPath(destination)
	local PathfindingService = game:GetService("PathfindingService")

    local pathParams = {
		["AgentHeight"] = 9,
		["AgentRadius"] = 5,
		["AgentCanJump"] = true
	}

	local path = PathfindingService:CreatePath(pathParams)
	path:ComputeAsync(self.charParts.hrp.Position, destination)

	if path.Status == Enum.PathStatus.Success then
		return path:GetWaypoints()
	else
		--warn(path.Status)
		return false
	end
end

function MonsterAiS:NavigateTo(destination)
	local path = self:FindPath(destination)
	-- print("Navigate to...", path)
	if path then
        if script:GetAttribute("debug_displayPath") then
            self:DisplayPath(path)
        end
		self.Navigating = true
		local prevWaypoint, distance = nil, nil
		for index, waypoint in pairs(path) do
			-- If tracking target for too long and lost them
			if self.FollowingPlayer and not self.Target then
				-- print("Lost Target")
				break
			-- If patrolling and target spotted
			elseif not self.FollowingPlayer and self.Target then
				-- print("Found Target while patrolling")
				break
			-- If target changes or has moved substantially since path creation
			elseif self.Target and (self.Target.Position - destination).Magnitude > 10 then
				-- print("Target moved")
				break
			end

			if index > 1 then
				distance = (prevWaypoint.Position - waypoint.Position).Magnitude
				if distance > 1 then
					self:DirectWalk(waypoint.Position, {_type = "navigation"})
				end
			end
			prevWaypoint = waypoint
		end
	else
		self.Navigating = false
	end
end

function MonsterAiS:DisplayPath(waypoints)
	local color = BrickColor.Random()
	for index, waypoint in pairs(waypoints) do
		local part = GaiaShared.clone(ReplicatedStorage.Assets.Parts.DebugIdx, {
            Name = ("DisplayPath_%s"):format(tostring(index)),
            Size = Vector3.new(1, 1, 1),
            Transparency = 0.5,
            Position = waypoint.Position,
            BrickColor = color,
            Parent = workspace.Studio.Tmp
        })
        part.SurfaceGui.TextLabel.Text = tostring(index)
		Debris:AddItem(part, script:GetAttribute("debug_displayPathLifetime"))
	end
end

function MonsterAiS:CanSee(target, doPlayerSearch)
    local p0 = self.charParts.hrp.Position
    local p1 = target.Position
    -- print("?CanSee target: ", target:GetFullName())
    local delta = p1 - p0
    local Ray
    if script:GetAttribute("debug_visioRay") then
        local distance = (p1 - p0).Magnitude
        Ray = GaiaShared.create("Part", {
            Name = "Ray",
            Size = Vector3.new(0.1, 0.1, distance),
            CFrame = CFrame.new(p0, p1) * CFrame.new(0, 0, -distance / 2),
            Anchored = true,
            CanCollide = false,
            Color = Color3.fromRGB(127, 127, 127),
            BottomSurface = Enum.SurfaceType.Smooth,
            TopSurface = Enum.SurfaceType.Smooth,
            Transparency = 0.5,
        })
        Ray.Parent = workspace.Debug

        Debris:AddItem(Ray, script:GetAttribute("debug_visioRayLifetime"))
    end
    local raycast = workspace:Raycast(p0, delta, self.raycastParams)

    if not (raycast and raycast.Instance) then return false end
    if
        raycast.Instance == target
        or (doPlayerSearch and raycast.Instance:IsDescendantOf(target.Parent))
    then
        if Ray then Ray.Color = Color3.new(0, 1, 0) end
        return true
    end

    if Ray then Ray.Color = Color3.new(1, 0, 0) end
	return false
end

function MonsterAiS:getTarget()
	local targets = CollectionService:GetTagged("PlayerCharacter")
	local maxDistance = script:GetAttribute("getTargetMaxDistance")
	local nearestTarget
	for _, char in ipairs(targets) do
        local charParts = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharParts", inst = char})
        if not charParts then continue end

        local charState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharState", inst = char})
        if not charState then continue end

        local player = Players:GetPlayerFromCharacter(char)
        if not player then continue end

        local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
        if not playerState then continue end

        local boostState = playerState:get(S.Stores, "Boosts")
        if boostState.st[Data.Boosts.Boosts.nameData[S.GhostBoost].id]  ~= nil then continue end

        local target = charParts.hrp
        local distance = (self.charParts.hrp.Position - target.Position).Magnitude
        if charParts.humanoid.Health <= 0 then continue end
        if distance > maxDistance then continue end

        if char:HasTag("Monster") then continue end

        local hideState = charState:get(S.Session, "Hide")
        if hideState.on then
            if self.Target == target then
                self.lostTarget = true
                self.Target = false
            end
            continue
        end

        if not self:CanSee(target, true) then continue end
        nearestTarget = target
        maxDistance = distance
	end

    -- print("getTarget: ", nearestTarget)
	return nearestTarget
end

function MonsterAiS:GetUnstuck(target)
	local lastStuck = time() - self.LastStuck
	-- Try to prevent any feedback loops, we shouldn't be getting caught multiple times a second
	if lastStuck > script:GetAttribute("StuckTimeTolerance") then
		-- -- print(lastStuck)
		self.LastStuck = time()
		self:DirectWalk(target - (8 * self.charParts.hrp.CFrame.LookVector), {_type = "unstucking"})
		self.charParts.humanoid.Jump = true
		-- -- print("Unstuck")
	end
end

function MonsterAiS:DirectWalk(targetPoint, kwargs)
	local targetReached = false

    if script:GetAttribute("ShowDirectWalkTarget") then
        self.DirectWalkDebugIdx = self.DirectWalkDebugIdx or 0
        self.DirectWalkDebugIdx += 1
        local debugPart = self._maid:Add2(GaiaShared.clone(ReplicatedStorage.Assets.Parts.DebugIdx, {
            Name = ("DirectWalkDebug_%s"):format(self.DirectWalkDebugIdx),
            Size = Vector3.new(1, 1, 1),
            Transparency = 0.5,
            Position = targetPoint,
            Parent = workspace.Studio.Tmp
        }))
        debugPart.SurfaceGui.TextLabel.Text = tostring(self.DirectWalkDebugIdx)
        if kwargs._type == "target" then
            debugPart.Color = Color3.fromRGB(255, 0, 0)
        elseif kwargs._type == "navigation" then
            debugPart.Color = Color3.fromRGB(0, 255, 0)
        elseif kwargs._type == "unstucking" then
            debugPart.Color = Color3.fromRGB(0, 0, 255)
        elseif kwargs._type == "directNavigation" then
            debugPart.Color = Color3.fromRGB(0, 0, 255)
        end
    end

	local connection
	connection = self.charParts.humanoid.MoveToFinished:Connect(function()
		targetReached = true
		return
	end)

	repeat
        local humanoid = self.charParts.humanoid
		if humanoid.WalkSpeed > 0 then
			local startTime = time()
			local startPosition = self.charParts.hrp.Position
			humanoid:MoveTo(targetPoint)

			-- Forgive me
			RunService.Heartbeat:Wait()

			-- Check if trapped
			local studsMoved = (self.charParts.hrp.Position - startPosition).Magnitude
            -- Needs a bigger step to make this comparison
            -- -- print("TimeOnSamePlace: ", self.TimeOnSamePlace)
			if studsMoved < script:GetAttribute("StuckDistanceTreshold") then
                local timeTaken = time() - startTime
                self.TimeOnSamePlace += timeTaken
                if self.TimeOnSamePlace > 2 then
                    self.TimeOnSamePlace = 0
                    -- print("Stuck (moved", studsMoved, ")")
                    self:GetUnstuck(targetPoint)
                    break
                end
            else
                self.TimeOnSamePlace = 0
			end

			-- Are there any targets?
			local newTarget = self:getTarget()

			-- New target found or regain sight of the previous target
			if newTarget then
                -- print("New target")
				self.Target = newTarget
				-- local distance = (self.charParts.hrp.Position - self.Target.Position).Magnitude
				-- print("Target distance: ", distance)
				-- if distance < script:GetAttribute("killRange") and not self.Killing then
				-- 	self:Attack(self.Target.Parent)
				-- print("Attack finished")
				-- end
				task.wait(0.1)
				break
			-- Nobody in sight, track previous target for max x seconds
			elseif self.Target and not newTarget then
				-- print("Last seen", self.Target.Name, self.TimeSinceTarget)
				if self.TimeSinceTarget >= script:GetAttribute("timeSinceLastTargetAcquisition") then
					self.Target = nil
				else
					if not self.Navigating or not self.Target then
						-- Exit any previous MoveTo commands if we have a target we should be tracking
						-- print("Quit Navigating")
						break
					end
				end
			end
		else
			-- print("Waiting")
			RunService.Heartbeat:Wait()
		end
	until targetReached

	if connection then
		connection:Disconnect()
		connection = nil
	end
end

function MonsterAiS:setRaycastParams()
    self.raycastParams = RaycastParams.new()
    self.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    self.raycastParams.FilterDescendantsInstances = {self.Npc, workspace.Debug, workspace.Regions}
end

function MonsterAiS:setPhysics()
    self._maid:Add(Promise.try(function()
        while true do
            if self.charParts.hrp.Anchored == false then
                self.charParts.hrp:SetNetworkOwner(nil)
            end
            task.wait(5)
        end
    end))
end

function MonsterAiS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.PatrolWaypoints = SharedSherlock:find({"EzRef", "GetSync"}, {inst=workspace.Map.Chapters["1"], refName="PatrolWaypoints"})
            if not self.PatrolWaypoints then return end

            self.PatrolWaypoints = self.PatrolWaypoints:FindFirstChild("Model")
            if not self.PatrolWaypoints then return end

            local bindersData = {
                {"Npc", self.Npc},
                {"CharParts", self.Npc},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.Npc.Parent
        end,
        cooldown=nil
    })
end

function MonsterAiS:Destroy()
    self._maid:Destroy()
end

return MonsterAiS