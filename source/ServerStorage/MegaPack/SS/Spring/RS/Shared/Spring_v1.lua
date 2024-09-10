local Spring = {}
Spring.__index = Spring
Spring.className = "Spring"

function Spring.new(kwargs)
    kwargs = kwargs or {}
    local p0 = kwargs.p0 or 0
    local v0 = kwargs.v0 or 0
    local target0 = kwargs.target0 or 0
    local damper = kwargs.damper or 1
    local speed = kwargs.speed or 1
    local clock = kwargs.clock or os.clock

    local self = {
        clock = clock,
		_time = clock(),
		_position = p0,
		_velocity = v0,
		_target = target0,
		_damper = damper,
		_speed = speed,
	}

	setmetatable(self, Spring)

    return self
end

function Spring:Impulse(velocity)
	self.Velocity = self.Velocity + velocity
end

function Spring:TimeSkip(delta)
	local now = os.clock()
	local position, velocity = self:_positionVelocity(now+delta)
	self._position = position
	self._velocity = velocity
	self._time = now
end

function Spring:setTarget(target)
    local now = os.clock()
    local position, velocity = self:_positionVelocity(now)
    self._position = position
    self._velocity = velocity
    self._target = target
end

-- local meta = {}

-- meta._indexMethods = setmetatable(
--     {
--         Position = function(self)
--             local position, _ = self:_positionVelocity(os.clock())
--             return position
--         end,
--         Value = function(self)
--             return meta._indexMethods.Position(self)
--         end,
--         p = function(self)
--             return meta._indexMethods.Position(self)
--         end,
--         Velocity = function(self)
--             local _, velocity = self:_positionVelocity(os.clock())
--             return velocity
--         end,
--         v = function(self)
--             return meta._indexMethods.Velocity(self)
--         end,
--         Target = function(self)
--             return self._target
--         end,
--         Damper = function(self)
--             return self._damper
--         end,
--         d = function(self)
--             return meta._indexMethods.Damper(self)
--         end,
--         Speed = function(self)
--             return self._speed
--         end,
--         s = function(self)
--             return meta._indexMethods.Speed(self)
--         end,
--     },
--     {
--         __index = function(table, index)
--             if Spring[index] then
--                 return Spring[index]
--             end
--             error(("%q is not a valid member of Spring"):format(tostring(index)), 2)
--         end
--     }
-- )

-- function Spring:__index(index)
--     print("b")
--     return meta._indexMethods[index](self)
-- end

-- meta.__newindexMethods = setmetatable(
--     {
--         Position = function(self, value, now)
--             local _, velocity = self:_positionVelocity(now)
--             self._position = value
--             self._velocity = velocity
--         end,
--         Value = function(self, value, now)
--             meta.__newindexMethods.Position(self, value, now)
--         end,
--         p = function(self, value, now)
--             meta.__newindexMethods.Position(self, value, now)
--         end,
--         Velocity = function(self, value, now)
--             local position, _ = self:_positionVelocity(now)
--             self._position = position
--             self._velocity = value
--         end,
--         v = function(self, value, now)
--             meta.__newindexMethods.Velocity(self, value, now)
--         end,
--         Target = function(self, value, now)
--             print("c")
--             print(self, value, now)
--             local position, velocity = self:_positionVelocity(now)
--             self._position = position
--             self._velocity = velocity
--             self._target = value
--         end,
--         Damper = function(self, value, now)
--             local position, velocity = self:_positionVelocity(now)
--             self._position = position
--             self._velocity = velocity
--             self._damper = math.clamp(value, 0, 1)
--         end,
--         d = function(self, value, now)
--             meta.__newindexMethods.Damper(self, value, now)
--         end,
--         Speed = function(self, value, now)
--             local position, velocity = self:_positionVelocity(now)
--             self._position = position
--             self._velocity = velocity
--             self._speed = value < 0 and 0 or value
--         end,
--         s = function(self, value, now)
--             meta.__newindexMethods.Speed(self, value, now)
--         end,
--     },
--     {
--         __index = function(table, index)
--             if Spring[index] then
--                 return Spring[index]
--             end
--             error(("%q is not a valid member of Spring"):format(tostring(index)), 2)
--         end
--     }
-- )

-- function Spring:__newindex(index, value)
-- 	local now = os.clock()
--     meta.__newindexMethods[index](self, value, now)

-- 	self._time = now
-- end

function Spring:_positionVelocity(now)
	local p0 = self._position
	local v0 = self._velocity
	local p1 = self._target
	local d = self._damper
	local s = self._speed

    print(s)
    print(now)
    print(self._time)
	local t = s * (now - self._time)
	local d2 = d * d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d*t)/h
		co, si = ep*math.cos(h*t), ep*math.sin(h*t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d*t)/h
		co, si = ep, ep*t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h)*t)/(2*h)
		local v = math.exp((-d - h)*t)/(2*h)
		co, si = u + v, u - v
	end

	local a0 = h*co + d*si
	local a1 = 1 - (h*co + d*si)
	local a2 = si/s

	local b0 = -s*si
	local b1 = s*si
	local b2 = h*co - d*si

	return
		a0*p0 + a1*p1 + a2*v0,
		b0*p0 + b1*p1 + b2*v0
end

return Spring