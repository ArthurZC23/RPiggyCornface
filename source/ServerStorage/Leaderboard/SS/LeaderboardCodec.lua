local module = {}

function module.encode(scoreData)
    --print("Raw score data: ", scoreData)
    local compressedScore
    local stringScore = tostring(scoreData)
    local numDigits = stringScore:len()
    if numDigits <= 3 then
        compressedScore = scoreData
    else
        local digits = stringScore:sub(1, 3)
        local compressedString = ("%s%s"):format(numDigits, digits)
        compressedScore = tonumber(compressedString)
        --print("Compressed Score Sending: ", compressedScore)
    end
    return compressedScore
end

function module.decode(compressedScore)
    --print("Receiving compressed score: ", compressedScore)
    local compressedString = tostring(compressedScore)
    local numDigitsCompressed = compressedString:len()
    local score
    if numDigitsCompressed <= 3 then
        score = compressedScore
    else
        local idx = numDigitsCompressed - 3
        local numDigits = tonumber(compressedString:sub(1, idx))
        local digitsStr = compressedString:sub(idx + 1)
        local digits = tonumber(digitsStr)
        score = digits * 10 ^ (numDigits - digitsStr:len())
    end
    --print("True score: ", score)
    return score
end

return module