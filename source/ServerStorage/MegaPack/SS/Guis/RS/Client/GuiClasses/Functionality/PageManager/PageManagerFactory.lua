local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Functional = Mod:find({"Functional"})

local PageManagerFactory = {}
PageManagerFactory.__index = PageManagerFactory
PageManagerFactory.className = "PageManagerFactory"
PageManagerFactory.TAG_NAME = PageManagerFactory.className

function PageManagerFactory.new()
    local self = {}
    setmetatable(self, PageManagerFactory)

    return self
end

function PageManagerFactory:setCurrentPagePageManager(currentPage, pageManagerName)
    local pages = Functional.filter(
        currentPage:GetChildren(),
        function(v)
            return v:IsA("Frame") or v:IsA("ScrollingFrame")
        end
    )
    local pageManager = ClientSherlock:find({"PageManager", pageManagerName})
    for _, page in ipairs(pages) do
        pageManager:addGui(page)
    end
    return pageManager
end

function PageManagerFactory:Destroy()
    self._maid:Destroy()
end

return PageManagerFactory