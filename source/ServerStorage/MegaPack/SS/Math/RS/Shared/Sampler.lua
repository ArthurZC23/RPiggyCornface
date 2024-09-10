local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local Sampler = {}
Sampler.__index = Sampler
Sampler.className = "Sampler"
Sampler.TAG_NAME = Sampler.className

function Sampler.new(kwargs)
    kwargs = kwargs or {}
    local self = {
        _maid = Maid.new(),
        randoms = {},
    }
    setmetatable(self, Sampler)

    return self
end

function Sampler:computeCumulativeDistribution(probArray)
    local cumDistributions = Functional.map(
        probArray,
        function (array, idx)
            local cum = Functional.reduce(
                probArray,
				function (a, b) return a+b end,
				{finish=idx})
            return cum
        end)
    return cumDistributions
end

function Sampler:validateProbArray(probArray)
    local sum = Functional.reduce(
        probArray,
        function (a, b) return a+b end)
    --print("SUM ", sum)
    return sum == 1
end

function Sampler:sampleFromKeyToOddsTable(odds)
    local keyArray, oddsArray = TableUtils.breakKeyValInSyncedArrays(odds)
    return keyArray[self:sampleDiscrete(oddsArray)]
end

function Sampler:sampleDiscrete(probArray, kwargs)
    --local isValid = self:validateProbArray(probArray)
    --if not isValid then warn("ProbArray has sum different from unity.") end

    kwargs = kwargs or {}
    local cumDistributions = self:computeCumulativeDistribution(probArray)
    self.randoms.sampleDiscrete = self.randoms.sampleDiscrete or kwargs.random or Random.new()
    local random = self.randoms.sampleDiscrete
    local uniformSample = random:NextNumber()
    for i, cum in ipairs(cumDistributions) do
        if uniformSample < cum then return i end
    end
    error("No sample was chosen")
end

function Sampler:Gaussian(mean, variance, kwargs)
    kwargs = kwargs or {}
    self.randoms.randomGauss1 = self.randoms.randomGauss1 or kwargs.random1 or Random.new()
    self.randoms.randomGauss2 = self.randoms.randomGauss2 or kwargs.random2 or Random.new()

    return math.sqrt(
        -2 * variance * math.log(self.randoms.randomGauss1:NextNumber())) *
        math.cos(2 * math.pi * self.randoms.randomGauss2:NextNumber()
    )
    + mean
end

function Sampler:UniformOverS2Sphere()
    local x
    local y
    local z
    local radius = 0
    local epi = 1e-2
    while radius < epi do
        x = self:Gaussian(0, 1)
        y = self:Gaussian(0, 1)
        z = self:Gaussian(0, 1)
        radius = math.sqrt(x ^ 2 + y ^ 2 + z ^ 2)
        task.wait(0.1)
    end
    return {x/radius, y/radius, z/radius}
end

function Sampler:UniformOverNSphere(n)
	--http://extremelearning.com.au/how-to-generate-uniformly-random-points-on-n-spheres-and-n-balls/
	local xs = {}
	for _=1,n do
		xs[#xs + 1] = self:Gaussian(0, 1)
	end
	local r = 0
	for _, x in ipairs(xs) do
		r = r + x^2
	end
	r = math.sqrt(r)
	for i, x in ipairs(xs) do
		xs[i] = xs[i] / r
	end

	return xs
end

function Sampler:testSampler(rarityArray, oddsArray)
    if RunService:IsStudio() then
        local testTable = {}
        local results = {}
        for i=1, 1e6 do
            local sampleIdx = self:sampleDiscrete(oddsArray)
            testTable[i] = sampleIdx
            results[rarityArray[sampleIdx]] = (results[rarityArray[sampleIdx]] or 0) + 1
        end
        for key, value in pairs(results) do
            print(key, ("%f %%"):format(100 * (value/#testTable)))
        end
    end
end

function Sampler:sampleTable(tbl, kwargs)
    assert(next(tbl), "Cannot sample empty table.")
    local size = TableUtils.len(tbl)
    kwargs = kwargs or {}
    -- if size == 0 then return end
    self.randoms.sampleTable = self.randoms.sampleTable or kwargs.random or Random.new()
    local random = self.randoms.sampleTable
    local stopIdx = random:NextInteger(1, size)
    local i = 0
    local sample = {
        key = nil,
        value = nil,
    }
    while stopIdx ~= i do
        i += 1
        sample.key, sample.value = next(tbl, sample.key)
    end
    return sample
end

function Sampler:sampleNoRepetition(arraySize, numSamples, kwargs)
    assert(arraySize >= numSamples, "arraySize must be > than numSamples.")
    kwargs = kwargs or {}
    self.randoms.sampleNoRepetition = self.randoms.sampleNoRepetition or kwargs.random or Random.new()
    local random = self.randoms.sampleNoRepetition
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
        if kwargs._returnType == "array" then
            table.insert(res, x[nextSampleIdx])
        else
            res[x[nextSampleIdx]] = true
        end
    end
    return res
end

function Sampler:sampleTableWithNoRepeats(tbl, numSamples, kwargs)
    assert(next(tbl), "Cannot sample empty table.")
    local size = TableUtils.len(tbl)
    self.randoms.sampleTableWithNoRepeats = self.randoms.sampleTableWithNoRepeats or kwargs.random or Random.new()
    local random = self.randoms.sampleTableWithNoRepeats
    kwargs.random = kwargs.random or random
    local idxs = self:sampleNoRepetition(size, numSamples, kwargs)
    local samples = {}

    local i = 0
    local previousKey
    while i < size do
        i += 1
        if idxs[i] then
            local sample = {}
            sample.key, sample.value = next(tbl, previousKey)
            table.insert(samples, sample)
        end
        previousKey = next(tbl, previousKey)
    end
    return samples
end

function Sampler:sampleTableKeysWithNoRepeats(tbl, numSamples, kwargs)
    kwargs = kwargs or {}
    self.randoms.sampleTableKeysWithNoRepeats = self.randoms.sampleTableKeysWithNoRepeats or kwargs.random or Random.new()
    local random = self.randoms.sampleTableKeysWithNoRepeats
    kwargs.random = kwargs.random or random
    local _samples = self:sampleTableWithNoRepeats(tbl, numSamples, kwargs)
    local samples = {}
    for i, data in ipairs(_samples) do
        samples[i] = data.key
    end
    self:shuffle(samples)
    return samples
end

function Sampler:sampleTableValsWithNoRepeats(tbl, numSamples, kwargs)
    kwargs = kwargs or {}
    self.randoms.sampleTableValsWithNoRepeats = self.randoms.sampleTableValsWithNoRepeats or kwargs.random or Random.new()
    local random = self.randoms.sampleTableValsWithNoRepeats
    kwargs.random = kwargs.random or random
    local _samples = self:sampleTableWithNoRepeats(tbl, numSamples, kwargs)
    local samples = {}
    for i, data in ipairs(_samples) do
        samples[i] = data.value
    end
    return samples
end

function Sampler:sampleArray(arr, kwargs)
    kwargs = kwargs or {}
    local size = #arr
    if size == 0 then return end

    self.randoms.sampleArray = self.randoms.sampleArray or kwargs.random or Random.new()
    local random = self.randoms.sampleArray
    local idx = random:NextInteger(1, #arr)
    return arr[random:NextInteger(1, #arr)], idx
end

function Sampler:shuffle(tbl, kwargs)
    kwargs = kwargs or {}
    self.randoms.shuffle = self.randoms.shuffle or kwargs.random or Random.new()
    local random = self.randoms.shuffle
    local size = kwargs.size or #tbl
    for i = #tbl, 2, -1 do
        local j = random:NextInteger(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function Sampler:getHugeSampleAndComputeOdds(idArray, oddsArray)
    if RunService:IsStudio() then
        local testTable = {}
        for i=1,1e6 do
            local sampleIdx = self:sampleDiscrete(oddsArray)
            testTable[i] = sampleIdx
        end
        local results = {}
        for i, idx in ipairs(testTable) do
            results[idArray[idx]] = (results[idArray[idx]] or 0) + 1
        end
        for key, value in pairs(results) do
            print(key, ("%f %%"):format(100 * (value/#testTable)))
        end
    end
end

function Sampler:Destroy()
    self._maid:Destroy()
end

return Sampler