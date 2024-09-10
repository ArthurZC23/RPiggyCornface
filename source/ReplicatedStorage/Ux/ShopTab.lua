local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local RootF = script:FindFirstAncestor("Ux")
local Utils = RootF.Utils
local Dilatation = require(Utils.Dilatation)

local function _onClick(imageBtn, data, kwargs)
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

function module.onLeft(tab, imageBtn, data, tabSize, kwargs)
    imageBtn.ImageColor3 = data.colors.default
    local conn
    return function()
        imageBtn.ImageColor3 = data.colors.default
        local ActiveV = tab:FindFirstChild("Active")
        if ActiveV and not conn then
            conn = ActiveV.AncestryChanged:Connect(function(_, parent)
                conn:Disconnect()
                conn = nil
                Dilatation.shrink(tab, tabSize)
            end)
        else
            Dilatation.shrink(tab, tabSize)
        end
	end
end

function module.onHover(tab, imageBtn, data, tabSize, kwargs)
    return function()
        imageBtn.ImageColor3 = data.colors.hover
        Dilatation.expand(tab, tabSize, kwargs.dilatation)
    end
end

-- kwargs allow for custom behavior
function module.addUx(tab, btn, productData, kwargs)
    local tabSize = tab.Size
    -- if Platforms.getPlatform() == Platforms.Platforms.Console then
    --     btn.SelectionLost:Connect(module.onLeft(tab, btn, productData, tabSize, kwargs))
    --     btn.SelectionGained:Connect(module.onHover(tab, btn, productData, tabSize, kwargs))
    -- else
    --     btn.MouseLeave:Connect(module.onLeft(tab, btn, productData, tabSize, kwargs))
    --     btn.MouseEnter:Connect(module.onHover(tab, btn, productData, tabSize, kwargs))
    -- end
    btn.MouseLeave:Connect(module.onLeft(tab, btn, productData, tabSize, kwargs))
    btn.MouseEnter:Connect(module.onHover(tab, btn, productData, tabSize, kwargs))
    btn.Activated:Connect(_onClick(btn, productData, kwargs))
end

return module