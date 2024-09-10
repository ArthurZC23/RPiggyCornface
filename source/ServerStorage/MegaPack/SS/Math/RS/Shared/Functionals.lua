local module = {}

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

function module.logBaseN(n, value)
    return math.log(value)/math.log(n)
end

function module.affine(a, b)
	return function(x)
		 return a * x + b
	end
end

function module.lowerLimit(f, limit)
	return function(x)
		 return math.max(f(x), limit)
	end
end

function module.affineBasedOnTwoPoints(p1, p2)
    local x1, y1 = unpack(p1)
    local x2, y2 = unpack(p2)
    local a = (y2 - y1) / (x2 - x1)
    local b = (y1 * x2 - y2 * x1) / (x2 - x1)
    return module.affine(a, b)
end

return module