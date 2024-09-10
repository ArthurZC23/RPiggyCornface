local Data = script:FindFirstAncestor("Data")


-- One disadvantage of this method is that the I need to remember how to structure data while setting values.
-- One advantage is that I can import player values and replicate their state
local module = {}

module.studio = {
    ["Proto"] = {
    },
}

return module