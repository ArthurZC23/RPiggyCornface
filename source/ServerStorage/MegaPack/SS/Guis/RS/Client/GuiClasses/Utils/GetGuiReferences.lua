local module = {}

function module.getReferences(references)
	local tbl = {}
    for key, ref in pairs(references) do
        if not ref.Value then ref.Changed:Wait() end
		tbl[key] = ref.Value
    end
    return tbl
end

return module