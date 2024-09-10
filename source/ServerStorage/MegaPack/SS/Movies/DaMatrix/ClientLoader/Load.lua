local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Promise = Mod:find({"Promise", "Promise"})

local Remotes = ReplicatedStorage.Remotes
local PlayMovieRE = Remotes.Events:WaitForChild("PlayMovie")
local MovieStoppedRE = Remotes.Events:WaitForChild("MovieStopped")

local Bindables = ReplicatedStorage.Bindables
local PlayMovieBE = Bindables.Events:WaitForChild("PlayMovie")
local MovieStoppedBE = Bindables.Events:WaitForChild("MovieStopped")

local RootFolder = script:FindFirstAncestor("Movies")
local Movies = require(RootFolder:WaitForChild("Client"):WaitForChild("Movies"))

local function jobHandler(job)
    local func, args = job.func, job.args

    local movieName = args[1]
    Promise.defer(function (resolve)
        func(unpack(args))
        resolve()
    end)
        :catch(function (err)
            warn(tostring(err))
            MovieStoppedBE:Fire(movieName, {status="Finished"})
            MovieStoppedRE:FireServer(movieName, {status="Finished"})
        end)

    MovieStoppedBE.Event:Wait()
end
local jobScheduler = JobScheduler.new(jobHandler)

local function playMovie(movieName, ...)
    local module = Movies[movieName]
    local job = {func = module.play, args={movieName, ...}}
    jobScheduler:pushJob(job)
end

PlayMovieRE.OnClientEvent:Connect(playMovie)
PlayMovieBE.Event:Connect(playMovie)

return {}