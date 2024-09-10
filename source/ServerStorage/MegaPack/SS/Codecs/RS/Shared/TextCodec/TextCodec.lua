local TextCodecs = script.Parent

-- return require(TextCodecs.TextCodecWaffle)

return {
    compress = function(text)
        return text
    end,
    decompress = function(text)
        return text
    end,
}