-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
-- local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
-- local Promise = Mod:find({"Promise", "Promise"})

-- -- returning Promise defer makes so the next chained andThen to not be called.

-- local p1 = Promise.try(function()
--     print("z1")
--     Promise.try(function()
--         print("z2")
--     end)

--     Promise.defer(function()
--         print("z5")
--     end)

--     -- return Promise.defer(function()
--     --     print("z5")
--     -- end)
--     -- return Promise.delay(1)
-- end)
-- :andThen(function()
--     print("z3")
--     Promise.try(function()
--         print("z4")
--     end)
--     Promise.defer(function()
--         print("z6")
--     end)
-- end)