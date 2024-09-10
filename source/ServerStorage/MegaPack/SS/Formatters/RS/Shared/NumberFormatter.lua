local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Math = Mod:find({"Math", "Math"})

local module = {}

local suffixes = {
    "",
    "K",
    "M",
    "B",
    "T",
    "Qa",
    "Qi",
    "Si",
    "Sp",
    "Oc",
    "No",
    "De",
	"DeUn",
	"DeDuo",
	"DeTre",
	"DeQt",
	"DeQn",
	"DeSd",
	"DeSp",
	"DeOc",
	"DeNv",
	"Vg", -- 63
	"VgUn",
    "VgDuo",
	"VgTre",
	"VgQt",
	"VgQn",
	"VgSd",
	"VgSp",
	"VgOc",
	"VgNv",	-- 90
}

-- Double has upper limit ~ 2^1024 = 2^(4 * 256)

local mt = {
	__index = function(_, _)
		return "HUGE"
	end
}

setmetatable(suffixes, mt)

local function decimalPart(number)
    return number - math.floor(number)
end

function module.numberToEngV1(number)
    local numberStr = tostring(number)
    local numDigits = string.len(numberStr)
    local exp = math.floor(numDigits/3)
    local arrayIdx = exp + 1
    local suffix = suffixes[arrayIdx]
    local coef = number / (10 ^(3 * exp))
    local coefStr
    if decimalPart(coef) > 0 then
        coefStr = string.format("%.1f", coef)
    else
        coefStr = string.format("%.0f", coef)
    end
    return coefStr..suffix
end

function module.numberToEngV2(number)
	if number < 1e3 then return tostring(number) end
	if number == math.huge then return tostring(number) end
	local decimalExp = math.log10(number) --2
	local suffixIdx = math.floor(decimalExp / 3) -- 0
	local suffix = suffixes[suffixIdx + 1] -- ""
	print(number)
	print(10 ^(3 * suffixIdx))
	print(number / (10 ^(3 * suffixIdx)))
	local coef = number / (10 ^(3 * suffixIdx))
	print(coef)
	local integerPart = coef - decimalPart(coef)
	local numDigits = string.len(tostring(integerPart))
	local coefStr
	
	if numDigits == 3 then
		coefStr = string.format("%3.0f", coef)
	elseif numDigits == 2 then
		coefStr = string.format("%2.1f", coef)
	elseif numDigits == 1 then
		coefStr = string.format("%1.2f", coef)
	end
	return coefStr..suffix
end

-- Hard to debug, because Roblox real time inspecto round the number for display.
-- Need to print to see the real value.
function module.numberToEng(number)
	if number < 1e3 then return tostring(number) end
	if number == math.huge then return tostring(number) end

	local orderOfMagnitude = math.floor(math.log(number, 10))
	local div = orderOfMagnitude / 3
	local u = math.floor(div)
	local s = 3 * u
	local r = orderOfMagnitude - s
	
	local z = number / (10 ^ s)
	z = Math.roundOffNoCarry(z, 3)
	local numDigits = r + 1
	
	local coefStr = ""
	if numDigits == 3 then
		coefStr = string.format("%3.0f", z)
	elseif numDigits == 2 then
		coefStr = string.format("%2.1f", z)
	elseif numDigits == 1 then
		coefStr = string.format("%1.2f", z)
	end
	
	return coefStr..suffixes[u + 1]
end

return module