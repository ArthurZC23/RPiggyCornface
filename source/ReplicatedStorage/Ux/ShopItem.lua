local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Math = Mod:find({"Math", "Math"})
local TableUtils = Mod:find({"Table", "Utils"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local tweenInfo = TweenInfo.new(
	0.15,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	true,
	0
)

local function _onLeft(imageBtn, productDescription, productData, kwargs)
    if productData.colors then
        imageBtn.ImageColor3 = productData.colors.default
    end
    return function()
        if kwargs.conn then
            kwargs.conn:Disconnect()
            kwargs.conn = nil
        end
        if productData.colors then
            imageBtn.ImageColor3 = productData.colors.default
        end
	end
end

local function _onHover(imageBtn, productDescription, productData, kwargs)
    return function()
        local tween = TweenService:Create(
            imageBtn.ProductImage,
            tweenInfo,
            {Rotation=Math.flipCoinForSign(0.5) * 15}
        )
        if productData.colors then
		    imageBtn.ImageColor3 = productData.colors.hover
        end

        if productDescription then
            TableUtils.setInstance(productDescription, productData.longDescription)
            local function update()
                productDescription.Text = imageBtn.ProductDescription.Value
            end
            kwargs.conn = imageBtn.ProductDescription.Changed:Connect(update)
            update()

		    productDescription.Visible = true
        end

        Bach:play("Hover", Bach.SoundTypes.SfxGui)
        tween:Play()
        tween.Completed:Wait()
	end
end

local function _onClick(imageBtn, productDescription, productData, kwargs)
    return function()
        Bach:play("Click", Bach.SoundTypes.SfxGui)
    end
end

local module = {}

-- kwargs allow for custom behavior
function module.addUx(btn, productDescription, productData, kwargs)
    kwargs = kwargs or {}
    -- if Platforms.getPlatform() == Platforms.Platforms.Console then
    --     btn.SelectionLost:Connect(Debounce.standard(_onLeft(btn, productDescription, productData, kwargs)))
    --     btn.SelectionGained:Connect(Debounce.standard(_onHover(btn, productDescription, productData, kwargs)))
    -- else
    --     btn.MouseLeave:Connect(Debounce.standard(_onLeft(btn, productDescription, productData, kwargs)))
    --     btn.MouseEnter:Connect(Debounce.standard(_onHover(btn, productDescription, productData, kwargs)))
    -- end
    btn.MouseLeave:Connect(Debounce.standard(_onLeft(btn, productDescription, productData, kwargs)))
    btn.MouseEnter:Connect(Debounce.standard(_onHover(btn, productDescription, productData, kwargs)))
    btn.Activated:Connect(Debounce.standard(_onClick(btn, productDescription, productData, kwargs)))
end

return module