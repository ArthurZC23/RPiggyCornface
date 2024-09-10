local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Promise = require(ComposedKey.getAsync(ReplicatedStorage, {"Promise", "Shared", "Promise"}))

local function _require(module)
    local timeout = 30
    if RunService:IsStudio() then
        timeout = 6
    end
    local trace = debug.traceback(("Module %s is not loaded after %s"):format(module:GetFullName(), timeout), 2)
    local p1 = Promise.delay(timeout):andThen(function()
        warn(trace)
    end)

    local ok, loadedModule = Promise.try(function()
        return require(module)
    end)
        :await()

    p1:cancel()
    if ok then
        return loadedModule
    else
        local err = tostring(loadedModule)
        error(err)
    end
end

local Shared = script:FindFirstAncestor("Shared")
local Sherlock = _require(Shared.Sherlock)
local DataUtils = _require(ComposedKey.getAsync(ReplicatedStorage, {"Data", "Shared", "DataUtils"}))

local MegaPackRs = ReplicatedStorage:WaitForChild("MegaPack")
local MegaPackSs
if RunService:IsServer() then
    MegaPackSs = ServerStorage:WaitForChild("MegaPack").SS
end

-- local GamePackRs = ReplicatedStorage:WaitForChild("GamePack")
local GamePackSs
if RunService:IsServer() then
    GamePackSs = ServerStorage:WaitForChild("GamePack").SS
end

local REvents = ReplicatedStorage.Remotes.Events
local RFunctions = ReplicatedStorage.Remotes.Functions

-- All of this need wait for child
local searchSpace = {}

searchSpace.Network = {
    PlayerNetwork = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Network", "PlayerNetwork"}))
    end,
}

searchSpace.CharEmotes = {
    Shared = {
        Utils = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Shared", "CharEmotesUtils"}))
        end,
    },
}

searchSpace.App = {
    Server = {
        Utils = function(kwargs)
            return _require(ComposedKey.getAsync(GamePackSs, {"App", "SS", "AppUtils"}))
        end
    }
}

searchSpace.Bugs = {
    GatherBugReport = function(kwargs)
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(MegaPackRs, {"Bugs", "Client", "GatherBugReportC"}))
        else
            return _require(ComposedKey.getAsync(MegaPackSs, {"Bugs", "SS", "GatherBugReportS"}))
        end
    end,
}

searchSpace.Assets = {
    Shared = {
        Utils = function(kwargs)
            return _require(ComposedKey.getAsync(MegaPackRs, {"Gaia", "Shared", "AssetsUtils"}))
        end,
    },
}

searchSpace.Bach = {
    Bach = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Bach", "Bach"}))
    end,
}

searchSpace.FastMode = {
    Shared = {
        FastMode = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Settings", "FastMode", "FastMode"}))
        end,
    }
}

searchSpace.Collisions = function(kwargs)
    local CollisionsRsFolder = ComposedKey.getAsync(ReplicatedStorage, {"Collisions"})
    CollisionsRsFolder:WaitForChild("AreCollisionsLoaded")
    return _require(ComposedKey.getAsync(CollisionsRsFolder, {"Shared", "Collisions"}))
end

searchSpace.Remotes = {
    FireFilteredClients = function(kwargs)
        return _require(ComposedKey.getAsync(ServerStorage, {"Remotes", "SS", "FireFilteredClients"}))
    end
}

searchSpace.Boosts = {
    SS = {
        Utils = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Boosts", "SS", "BoostsUtils"}))
        end
    }
}

searchSpace.Props = {
    Props = function(kwargs)
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Props", "Client", "PropsC", "PropsC"}))
        else
            return _require(ComposedKey.getAsync(ServerStorage, {"Props", "SS", "PropsS", "PropsS"}))
        end
    end,
    CharPropsDefault = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Props", "Shared", "PropsDefault", "CharPropsDefault"}))
    end
}

searchSpace.InstanceUtils = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"InstanceUtils", "Shared", "InstanceUtils"}))
    end,
    Props = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"InstanceUtils", "Shared", "InstanceProps"}))
    end
}

searchSpace.WaitFor = {
    WaitFor = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"WaitFor", "Shared", "WaitFor"}))
    end,
}

searchSpace.Id = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Id", "Shared", "IdUtils"}))
    end
}

searchSpace.Athena = {
    Athena = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Athena", "Shared", "Athena"}))
    end
}

searchSpace.MBay = {
    VfxFactory = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "VfxFactory"}))
    end,
    FxUtils = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "FxUtils"}))
    end,
    ParticleGroup = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "ParticleGroup"}))
    end,
    ParticleEmitter3D = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "ParticleEmitter3D"}))
    end,
    ParticleAcceleration = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "ParticleAcceleration", "ParticleAcceleration"}))
    end,
    TextureFlipbook = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"MBay", "Shared", "TextureFlipbook", "TextureFlipbook"}))
    end,
}

searchSpace.Fsm = {
    Fsm = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Fsm", "Shared", "Fsm"}))
    end,
    FsmSyncer = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Fsm", "Shared", "FsmSyncer"}))
    end,
    Logger = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Fsm", "Shared", "FsmLogger"}))
    end,
    StatesLoader = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Fsm", "Shared", "StatesLoader"}))
    end,
}

searchSpace.StateManager = {
    Actions = {
        Loader = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "Actions", "ActionsLoader"}))
        end,
        Signals = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "Actions", "ActionsSignals"}))
        end,
    }
}

searchSpace.Pathfinding = {
    Debug = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Pathfinding", "Shared", "Debug"}))
    end,
}

searchSpace.Causality = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Causality", "Shared", "CausalityUtils"}))
    end,
}

searchSpace.Vfx = {
    Thunder = {
        Bolt = function()
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"LightningBoltPart"}))
        end,
        Sparks = function()
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"LightningBoltPart", "LightningSparks"}))
        end,
        Explosion = function()
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"LightningBoltPart", "LightningExplosion"}))
        end,
    },
    Rock = {
        Crater = function()
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Vfx", "Rocks", "Rocks"}))
        end,
    },
}

searchSpace.HitDetection = {
    SpatialQuery = {
        SpatialQuery = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Baki", "Shared", "HitboxSpatialQuery", "HitboxSpatialQuery"}))
        end,
        HitboxProcessors = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Baki", "Shared", "HitboxSpatialQuery", "HitboxProcessors", "HitboxProcessors"}))
        end,
        HitboxFilters = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Baki", "Shared", "HitboxSpatialQuery", "HitboxFilters", "HitboxFilters"}))
        end,
    },
    Melee = function(kwargs)
        return _require(ReplicatedStorage.RaycastHitboxV4)
    end,
    Range = function()
        -- FastCast
    end,
}

searchSpace.Spring = {
    Spring = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Spring", "Shared", "Spring"}))
    end,
}

searchSpace.Ux = {
    Faders = function()
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Ux", "Faders", "Faders"}))
    end,
    ToggleButtons = function()
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Ux", "ToggleButtons"}))
    end,
}

searchSpace.Camera = {
    CameraShaker = {
        CameraShaker = function()
            return _require(ComposedKey.getAsync(MegaPackRs, {"Camera", "Client", "CameraShaker", "CameraShaker"}))
        end,
        Presets = function()
            return _require(ComposedKey.getAsync(MegaPackRs, {"Camera", "Client", "CameraShaker", "CameraShakePresets"}))
        end,
    },
    Utils = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"Camera", "Shared", "CameraUtils"}))
    end,
    RbxCameraModules = {
        CameraModule = function()
            assert(RunService:IsClient(), "Camera modules can only be called on client.")
            local localPlayer = Players.LocalPlayer
            return require(ComposedKey.getAsync(localPlayer, {"PlayerScripts", "PlayerModule"})).cameras
        end,
        Popper = function()
            assert(RunService:IsClient(), "Camera modules can only be called on client.")
            local localPlayer = Players.LocalPlayer
            return _require(ComposedKey.getAsync(localPlayer, {"PlayerScripts", "PlayerModule", "CameraModule", "ZoomController", "Popper"}))
        end,
        BaseCamera = function()
            assert(RunService:IsClient(), "Camera modules can only be called on client.")
            local localPlayer = Players.LocalPlayer
            return _require(ComposedKey.getAsync(localPlayer, {"PlayerScripts", "PlayerModule", "CameraModule", "BaseCamera"}))
        end,
        Utils = function()
            assert(RunService:IsClient(), "Camera modules can only be called on client.")
            local localPlayer = Players.LocalPlayer
            return _require(ComposedKey.getAsync(localPlayer, {"PlayerScripts", "PlayerModule", "CameraModule", "CameraUtils"}))
        end,
    }
}

searchSpace.Control = {
    RbxControlModules = {
        ControlModule = function()
            assert(RunService:IsClient(), "CameraModule can only be called on client.")
            local localPlayer = Players.LocalPlayer
            return require(ComposedKey.getAsync(localPlayer, {"PlayerScripts", "PlayerModule"})).controls
        end,
    }
}

searchSpace.Kubrick = {
    CameraMan = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"Kubrick", "Shared", "CameraMan"}))
    end,
}

searchSpace.Mosby = {
    Mosby = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Mosby", "Shared", "Mosby"}))
    end,
    CFrameUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Mosby", "Shared", "CFrameUtils"}))
    end,
    RaycastUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Mosby", "Shared", "RaycastUtils"}))
    end,
    SizeUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Mosby", "Shared", "SizeUtils"}))
    end,
}

searchSpace.Newton = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Newton", "Shared", "NewtonUtils"}))
    end,
}

searchSpace.Hamilton = {
    MultiplierMath = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Hamilton", "Shared", "Multipliers"}))
    end,
    Calculators = {
        Calculators = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Hamilton", "Shared", "Calculators", "Calculators"}))
        end,
        Money_1 = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Hamilton", "SS", "Calculators", "Money_1"}))
        end,
        Money_2 = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Hamilton", "SS", "Calculators", "Money_2"}))
        end,
    },
    Giver = {
        Giver = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Hamilton", "SS", "Giver", "Giver"}))
        end,
    },
    Conversions = {
        Conversions = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Hamilton", "SS", "Conversions", "Conversions"}))
        end,
        PetConversions = function(kwargs)
            return _require(ComposedKey.getAsync(ServerStorage, {"Hamilton", "SS", "Conversions", "PetConversions"}))
        end,
    },
    Exchanges = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Hamilton", "Shared", "Exchanges", "Exchanges"}))
    end,
}

searchSpace.Sherlocks = {
    Client = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Client", "ClientSherlock"}))
    end,
    Shared = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "SharedSherlock"}))
    end,
    Sherlock = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Sherlock"}))
    end,
}

searchSpace.UserInput = {
    CasUtils = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"UserInputUtils", "Client", "Cas"}))
    end,
    CasEffects = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"UserInputUtils", "Client", "CasEffects", "CasEffects"}))
    end,
}

searchSpace.Strings = {
    Utils = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"Strings", "Shared", "StringUtils"}))
    end,
}

searchSpace.DataStore = {
    Purge = function(kwargs)
        return _require(ComposedKey.getAsync(ServerStorage, {"DataStore", "SS", "Purge", "Purge"}))
    end,
}

Vehicles = {
    Car = {
        Chassis = function(kwargs)
            return require(ComposedKey.getAsync(ReplicatedStorage, {"Vehicles", "Shared", "Car", "Chassis"}))
        end
    },
}

searchSpace.DataStructures = {
    Array = {
        Circular = function(kwargs)
            return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "Array", "CircularArray"}))
        end,
    },
    JobScheduler = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "JobScheduler", "JobScheduler"}))
    end,
    Heap = {
        MinHeap = function(kwargs)
            return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "Heap", "MinHeap"}))
        end,
    },
    PriorityQueue = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "PriorityQueue", "PriorityQueue"}))
    end,
    Set = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "Set", "Set"}))
    end,
    Stack = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "Stack", "Stack"}))
    end,
    Queue = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DataStructures", "Shared", "Queue", "Queue"}))
    end,
}

searchSpace.Cronos = {
    Cronos = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Cronos", "Shared", "Cronos"}))
    end,
    BigBen = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Cronos", "Shared", "BigBen"}))
    end,
    Clock = function(kwargs)
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(MegaPackRs, {"Cronos", "Client", "ClientClock"}))
        else
            return _require(ComposedKey.getAsync(MegaPackSs, {"Cronos", "SS", "ServerClock"}))
        end
    end
}

searchSpace.BigTable = {
    BigTable = function(kwargs)
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(MegaPackRs, {"BigTable", "Shared", "BigTable"}))
        else
            return _require(ComposedKey.getAsync(MegaPackRs, {"BigTable", "Shared", "BigTable"}))
        end
    end,
}

searchSpace.Hooks = {
    CharTeleportInGame = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Hooks", "Client", "CharTeleportInGame"}))
    end,
}

searchSpace.Gui = {
    ViewUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses", "View", "ViewUtils"}))
    end,
    GuiClasses = function(kwargs)
        return ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses"})
    end,
    PageManager = {
        PageManager = function(kwargs)
            local GuiClasses = ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses"})
            return _require(ComposedKey.getAsync(GuiClasses, {"Functionality", "PageManager", "PageManager"}))
        end,
        PageManagerFactory = function(kwargs)
            local GuiClasses = ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses"})
            return _require(ComposedKey.getAsync(GuiClasses, {"Functionality", "PageManager", "PageManagerFactory"}))
        end,
    },
    ListLayout = function(kwargs)
        local GuiClasses = ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses"})
        return _require(ComposedKey.getAsync(GuiClasses, {"Layout", "ScrollingFrame", "ListLayout", "ListLayout"}))
    end,
    GridLayout = function(kwargs)
        local GuiClasses = ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses"})
        return _require(ComposedKey.getAsync(GuiClasses, {"Layout", "Grid", "Grid"}))
    end,
    TextUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Guis", "Shared", "TextUtils"}))
    end,
    Ux = {
        ShopTab = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Ux", "ShopTab"}))
        end,
        Highlight = function(kwargs)
            return _require(ComposedKey.getAsync(ReplicatedStorage, {"Ux", "Highlight"}))
        end,
    },
    Popup = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Guis", "Client", "GuiClasses", "Popup", "Popup"}))
    end,
}

searchSpace.ServerType = function(kwargs)
    if RunService:IsClient() then
        local GetServerTypeRF = RFunctions:WaitForChild("GetServerType")
        return GetServerTypeRF:InvokeServer()
    else
        return _require(ComposedKey.getAsync(MegaPackSs, {"ServerType", "SS", "ServerType"}))
    end
end

searchSpace.DescendantsUtils = {
    NetworkOwnership = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"DescendantsUtils", "Shared", "Common", "NetworkOwnership"}))
    end,
}

searchSpace.Debounce = {
    Debounce = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Debounce", "Shared", "Debounce"}))
    end,
    InstanceDebounce = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Debounce", "Shared", "InstanceDebounce"}))
    end,
    Local = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Debounce", "Client", "LocalDebounce"}))
    end
}

searchSpace.Data = {
    Data = function(kwargs)
        if RunService:IsClient() then
            if searchSpace.Data.cache then return searchSpace.Data.cache end

            local GetSharedDataRE = REvents:WaitForChild("GetSharedData")
            GetSharedDataRE.OnClientEvent:Connect(function(data)
                searchSpace.Data.cache = data
            end)

            local GetSharedDataRF = RFunctions:WaitForChild("GetSharedData")
            local data = GetSharedDataRF:InvokeServer()

            -- for _, metaData in ipairs(data.metatables) do
            --     local pathName = metaData[1]
            --     local dataModule = ComposedKey.get(data, pathName)
            --     DataUtils.setDataModuleMetatables(dataModule)
            -- end
            -- data.metatables = nil

            searchSpace.Data.cache = data
            return data
        else
            return _require(ComposedKey.getAsync(ServerStorage, {"Data", "SS", "DataS"}))
        end
    end,
    SharedData = function(kwargs)
        return _require(ComposedKey.getAsync(ServerStorage, {"Data", "SS", "SharedData"}))
    end,
    LocalData = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Data", "Client", "LocalData", "LocalData"}))
    end
}

searchSpace.Maid = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"Cleaner", "Shared", "Janitor", "Janitor"}))
end

searchSpace.PCallUtils = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"PCallUtils", "Shared", "PCallUtils"}))
end

searchSpace.FastSpawn = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"FastSpawn", "Shared", "FsPromise"}))
end

searchSpace.Error = {
    Error = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Error", "Shared", "Error"}))
    end,
}

searchSpace.ErrorReport = {
    ErrorReport = function()
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(MegaPackRs, {"ErrorReport", "Client", "ErrorReport"}))
        else
            return _require(ComposedKey.getAsync(MegaPackSs, {"ErrorReport", "SS", "ErrorReport"}))
        end
    end,
    Filters = function()
        return _require(ComposedKey.getAsync(MegaPackRs, {"ErrorReport", "Shared", "Filters", "Filters"}))
    end,
}
searchSpace.Gaia = {
    Client = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Gaia", "Client", "Gaia"}))
    end,
    Shared = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Gaia", "Shared", "Gaia"}))
    end,
    Server = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackSs, {"Gaia", "SS", "Gaia"}))
    end,
}

searchSpace.Table = {
    ComposedKey = function(kwargs)
        return _require(ReplicatedStorage.TableUtils.ComposedKey)
    end,
    Mts = function(kwargs)
        return _require(ReplicatedStorage.TableUtils.Metatables)
    end,
    Utils = function(kwargs)
        return _require(ReplicatedStorage.TableUtils.TableUtils)
    end,
}

searchSpace.Binder = {
    Binder = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Binder", "Shared", "Binder"}))
    end,
    Manager = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Binder", "Shared", "BindersManager"}))
    end,
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Binder", "Shared", "BinderUtils"}))
    end,
    Mover = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Binder", "Shared", "BindersMover"}))
    end,
}

searchSpace.Singleton = {
    Manager = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Singletons", "SingletonsManager"}))
    end,
}

searchSpace.Signal = {
    Event = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Signal", "Shared", "StravantGoodSignal", "StravantGoodSignal"}))
    end,
    Function = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Signal", "Shared", "BachSignal", "Function"}))
    end,
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Signal", "Shared", "Utils"}))
    end,
}

searchSpace.Codecs = {
    Actions = function(kwargs)
        if RunService:IsClient() then
            return _require(ComposedKey.getAsync(MegaPackRs, {"Codecs", "Client", "ActionsCodec", "ActionsCodec"}))
        else
            return _require(ComposedKey.getAsync(MegaPackSs, {"Codecs", "SS", "ActionsCodec", "ActionsCodec"}))
        end
    end,
    Text = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Codecs", "Shared", "TextCodec", "TextCodec"}))
    end,
}

searchSpace.PlayerUtils = {
    PlayerUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"PlayerUtils", "Shared", "PlayerUtils"}))
    end,
    RigLimbs = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"PlayerUtils", "Shared", "RigLimbs"}))
    end,
}

searchSpace.CharUtils = {
    CharUtils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"CharUtils", "Shared", "CharUtils"}))
    end,
}

searchSpace.Promise = {
    Promise = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Promise", "Shared", "Promise"}))
    end,
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Promise", "Shared", "PromiseUtils"}))
    end,
}

searchSpace.Functional = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"Functional", "Shared", "Functional"}))
end

searchSpace.Iterators = {
    Array = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Iterators", "Shared", "ArrayIterators"}))
    end,
    Table = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Iterators", "Shared", "TableIterators"}))
    end,
}

searchSpace.Sort = {
    Array = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Sort", "Shared", "SortArray"}))
    end,
    Keys = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Sort", "Shared", "SortKeys"}))
    end,
}

searchSpace.Date = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"Date", "Shared", "Date"}))
end

searchSpace.EzRef = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"EzRef", "Shared", "EzRefUtils"}))
    end,
}

searchSpace.Math = {
    Bezier = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "Bezier"}))
    end,
    Math = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "Math"}))
    end,
    Functionals = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "Functionals"}))
    end,
    Sampler = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "Sampler"}))
    end,
    GeometricSampler = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "GeometricSampler"}))
    end,
    Vectors = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Math", "Shared", "Vectors"}))
    end,
}

searchSpace.Function = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"FunctionUtils", "Shared", "FunctionUtils"}))
    end
}

searchSpace.Formatters = {
    NumberFormatter = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Formatters", "Shared", "NumberFormatter"}))
    end,
    TimeFormatter = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Formatters", "Shared", "TimeFormatter"}))
    end,
}

searchSpace.TweenUtils = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"TweenUtils", "Shared", "TweenUtils"}))
end

searchSpace.Tween = {
    Templates = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Tweens"}))
    end,
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"TweenUtils", "Shared", "TweenUtils"}))
    end,
    TweenGroup = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"TweenUtils", "Shared", "TweenGroup"}))
    end,
    TweenFactory = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"TweenUtils", "Shared", "TweenFactory"}))
    end,
}

searchSpace.Platforms = {
    Platforms = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Platforms", "Shared", "Platforms"}))
    end
}

searchSpace.Rodin = {
    LoadAnimations = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Rodin", "Shared", "LoadAnimations"}))
    end,
    RodinUtils = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Rodin", "Shared", "RodinUtils"}))
    end,
    AnimationsWeightCodesUtils = function(kwargs)
        return _require(ComposedKey.getAsync(ReplicatedStorage, {"Rodin", "Shared", "AnimationsWeightCodesUtils"}))
    end,
}

searchSpace.Tools = {
    Utils = function(kwargs)
        return _require(ComposedKey.getAsync(MegaPackRs, {"Tools", "Shared", "ToolsUtils"}))
    end,
}

searchSpace.Welder = function(kwargs)
    return _require(ComposedKey.getAsync(MegaPackRs, {"Welder", "Shared", "Welder"}))
end

searchSpace.PlayerPointsContainerSearch = function(kwargs)
    return _require(ComposedKey.getAsync(ServerStorage, {"Binders", "SS", "Binders", "PlayerPointsContainerSearch", "PlayerPointsContainerSearch"}))
end

return Sherlock.new(searchSpace)