local module = {}

function module.sampleNoRepetition(arraySize, numSamples)
    assert(arraySize >= numSamples, "arraySize must be > than numSamples.")
    local random = Random.new()
    local x = {}
    local res = {}
    for i = 1, arraySize do
        x[i] = i
    end
    for i = 1, numSamples do
        local nextSampleIdx = arraySize + 1 - i
        local r = random:NextInteger(1, nextSampleIdx)
        x[nextSampleIdx], x[r] = x[r], x[nextSampleIdx]
        --[nextSampleIdx] idx is reserved
        -- print("arraySize: ", arraySize)
        -- print("numSamples: ", numSamples)
        -- print("r: ", r)
        -- print("nextSampleIdx: ", nextSampleIdx)
        res[x[nextSampleIdx]] = true

    end
    return res
end

function module.indicator(boolExp)
    if boolExp == true then return 1 else return 0 end
end

function module.isInteger(x)
    return (x - math.floor(x)) == 0
end

function module.round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function module.sign(x)
    if x >= 0 then
        return 1
    else
        return -1
    end
end

do
    local random = Random.new()
    function module.randomSign()
        if random:NextNumber() > .5 then
            return 1
        else
            return -1
        end
    end
end

local function _factorial(n)
	if n == 0 then return 1 end
	return n * _factorial(n - 1)
end

module.factorial = setmetatable({}, {
	__call = function(tbl, n)
		if tbl[n] then return tbl[n] end
		tbl[n] = _factorial(n)
		return n
	end,
})

function module.roundOff(number, digits)
	local numberDigits = math.ceil(math.log(number, 10)) -- digits to the left of decimal point
	local expoent = digits - numberDigits
	local mantissa = number * (10 ^ expoent)
	
	local roundUp = mantissa + 0.5
	--if roundUp == math.ceil(mantissa) then -- carry 1
	--	local f = math.ceil(mantissa)
	--	local h = f - 2
	--	if (h % 2 ~= 0) then
	--		roundUp = roundUp - 1
	--	end
			
	--end
	
	local finalMantissa = math.floor(roundUp)
	return finalMantissa * (10 ^ (-expoent))
end

function module.roundOffNoCarry(number, digits)
	local numberDigits = math.ceil(math.log(number, 10)) -- digits to the left of decimal point
	local expoent = digits - numberDigits
	local mantissa = number * (10 ^ expoent)

	local finalMantissa = math.floor(mantissa)
	return finalMantissa * (10 ^ (-expoent))
end

do
	local random = Random.new()
	function module.flipCoinForSign(oddsForPositive)
		return random:NextNumber() < oddsForPositive and 1 or -1
	end
end

function module.taylorExpansion(m, fn, x0)
	local coefs = {}
	for i=0, m do
		coefs[i] = fn(i, x0) / module.factorial(i)
	end
	return function(x)
		local value = 0
		for i=0, m do value = value + coefs[i] * math.pow((x - x0), i) end
		return value
	end
end

function module.geometricProgressionSum(a1, r, n)
    return (a1 * (1 - r ^ n)) / (1 - r)
end

function module.createPoly(coefs)
    local degree = #coefs - 1
    return function(x)
        local res = 0
        for i, c in ipairs(coefs) do
            local d = i - 1
            res += c * (x ^ (degree - d))
        end
        return res
    end
end

function module.saturatedAffine(a, b, max, min)
    return function(x)
        local y = a * x + b
        if y >= max then
            return max
        elseif y <= min then
            return min end
        return y
    end
end

function module.lerp(p0, p1, t)
    return p0 + (p1- p0) * t
end

return module