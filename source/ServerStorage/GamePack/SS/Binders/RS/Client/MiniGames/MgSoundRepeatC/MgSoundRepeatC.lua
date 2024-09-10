local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Functional = Mod:find({"Functional"})
local Bach = Mod:find({"Bach", "Bach"})

local camera = workspace.CurrentCamera

local function setAttributes()
    script:SetAttribute("noteDuration", 1)
    script:SetAttribute("playingNoteDb", 0.1)
end
setAttributes()

local MgSoundRepeatC = {}
MgSoundRepeatC.__index = MgSoundRepeatC
MgSoundRepeatC.className = "MgSoundRepeat"
MgSoundRepeatC.TAG_NAME = MgSoundRepeatC.className

function MgSoundRepeatC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
        isRunning = false,
    }
    setmetatable(self, MgSoundRepeatC)

    if not self:getFields() then return end
    self:createSignals()
    self:handleButtonTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})
local melody = {1, 4, 3, 4, 2}

function MgSoundRepeatC:setMgStart()
    local maid = Maid.new()

    maid:Add2(function()
        self.isRunning = false
        camera.CameraType = Enum.CameraType.Custom
        self.ButtonText.Text = "Start"
        self.ButtonPart.Color = Color3.fromRGB(0, 255, 0)
        for _, Wire in ipairs(self.Wires:GetChildren()) do
            Wire.Material = Enum.Material.SmoothPlastic
            Wire.Color = Color3.fromRGB(17, 17, 17)
        end
    end)

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = self.CameraWp:GetPivot()

    self.isRunning = true
    self.ButtonText.Text = "Running"
    self.ButtonPart.Color = Color3.fromRGB(151, 0, 0)
    for _, Wire in ipairs(self.Wires:GetChildren()) do
        Wire.Material = Enum.Material.Neon
        Wire.Color = Color3.fromRGB(165, 165, 0)
    end

    return maid
end

function MgSoundRepeatC:releaseReward()
    self.MView1:Destroy()
    for i, desc in ipairs(self.MView2:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.CanCollide = true
        desc.Transparency = 0
    end

    self.MapToken:PivotTo(self.MapToken:GetPivot() - 160 * Vector3.yAxis)
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")
local DisableGuisSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="DisableGuis"})

function MgSoundRepeatC:setGui()
    local maid = Maid.new()

    self.gui = maid:Add2(ReplicatedStorage.Assets.Guis.MgSoundRepeat:Clone())
    maid:Add(function()
        DisableGuisSE:Fire("Enable")
    end)
    self.instruction = self.gui.Root.Frame.TextLabel
    DisableGuisSE:Fire("Disable", "exceptions", {
        ["Fade"] = true,
        ["StartScreen"] = true,
        ["LoadingScreen"] = true,
    })
    self.gui.Parent = PlayerGui


    return maid
end

function MgSoundRepeatC:handleButtonTouch()
    self._maid:Add2(self.ButtonToucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
        function(player, char, hrp)
            if self.isRunning or self.lockedGame then
                return
            end
            if not (char and char.Parent) then return end
            local charProps = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharProps", inst = char})
            if not charProps then return end
            local charParts = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharParts", inst = char})
            if not charParts then return end

            local prop = charProps.props[charParts.humanoid]
            if not prop then return end
            local cause = "Mg"
            prop:set("WalkSpeed", cause, 0)

            local maid = self._maid:Add2(Maid.new(), "Start")
            maid:Add2(function()
                prop:removeCause("WalkSpeed", cause)
            end)
            local cf0 = char:GetPivot()
            char:PivotTo(cf0 - 4 * cf0.LookVector)

            local p1 = Promise.fromEvent(char.Destroying)
            local p2 = Promise.fromEvent(self.playedWrongMelodySE)
            local p3 = Promise.try(function()
                maid:Add2(self:setMgStart())
                maid:Add2(self:setGui())

                local lastNoteIdx = 2
                while lastNoteIdx <= #melody do
                    local ok, err = maid:Add2(
                        maid:Add2(Promise.each({
                            {"playMelody", {lastNoteIdx}},
                            {"waitPlayerInput", {lastNoteIdx}},
                        },
                        function(tbl)
                            local method, args = tbl[1], tbl[2]
                            local res = self[method](self, unpack(args))
                            if res.maid then
                                maid:Add2(res.maid)
                            end
                            return res._return
                        end)))
                    :await()
                    if not ok then warn("[MgSoundRepeatC:startGame]\n", tostring(err)) end
                    lastNoteIdx += 1
                    task.wait()
                end
                self:releaseReward()
                self.lockedGame = true
            end)

            maid:Add2(Promise.any({p1, p2, p3})
                :timeout(3 * 60)
                :catchAndPrint()
                :finally(function()
                    self._maid:Remove("Start")
                end)
            )
        end,
        0.1
    )))
end

function MgSoundRepeatC:playNote(noteIdx)
    local res = {}
    local maid = self._maid:Add2(Maid.new(), "playNote")

    local noteData = self.allNoteData[noteIdx]
    local sfx = noteData.sfx
    local GlowParts = noteData.GlowParts
    maid:Add2(function()
        sfx:Stop()
        for _, part in ipairs(GlowParts) do
            part.Material = Enum.Material.Plastic
        end
    end)
    for _, part in ipairs(GlowParts) do
        part.Material = Enum.Material.Neon
    end
    sfx:Play()
    maid:Add2(Promise.any({Promise.fromEvent(sfx.Stopped), Promise.fromEvent(sfx.Ended)})
    :andThen(function()
        self._maid:Remove("playNote")
    end))

    -- maid:Add2(Promise.delay(script:GetAttribute("noteDuration"))
    -- :andThen(function()
    --     self._maid:Remove("playNote")
    -- end))

    res.sfx = sfx
    return res
end

function MgSoundRepeatC:playMelody(lastNoteIdx)
    self.instruction.Text = "Listen..."
    local res = {}
    local melodySlice = TableUtils.slice(melody, nil, lastNoteIdx)
    res._return = Promise.each(melodySlice, function(noteIdx, idx)
        local _res = self:playNote(noteIdx, idx)
        return Promise.fromEvent(_res.sfx.Ended)
    end)
    return res
end


function MgSoundRepeatC:waitPlayerInput(subMelodySize)
    self.instruction.Text = "Play!"
    local maid = self._maid:Add2(Maid.new(), "waitPlayerInput")

    local res = {
        maid = maid,
    }

    local playerMelody = {}
    local playerMelodySize = 0

    maid:Add2(function()
        for _, noteData in pairs(self.allNoteData) do
            noteData.ClickDetector.MaxActivationDistance = 0
        end
    end)

    local playingNoteDb = false
    for idx, noteData in pairs(self.allNoteData) do
        noteData.ClickDetector.MaxActivationDistance = 128
        maid:Add2(noteData.ClickDetector.MouseClick:Connect(function()
            if playingNoteDb then return end
            playingNoteDb = true
            Promise.delay(script:GetAttribute("playingNoteDb")):andThen(function()
                playingNoteDb = false
            end)
            if subMelodySize == playerMelodySize then return end

            local resPlayNote = self:playNote(idx)
            Promise.any({Promise.fromEvent(resPlayNote.sfx.Stopped), Promise.fromEvent(resPlayNote.sfx.Ended)})
            :finally(function()
                table.insert(playerMelody, idx)
                playerMelodySize += 1
                local correctMelody = TableUtils.slice(melody, 1, playerMelodySize)
                local isPlayerMelodyRight = TableUtils.deepCompare(correctMelody, playerMelody)
                if isPlayerMelodyRight then
                    if subMelodySize == playerMelodySize then
                        self.finishedMelodySE:Fire()
                    end
                else
                    Bach:play("Denied", Bach.SoundTypes.SfxGui)
                    self.playedWrongMelodySE:Fire()
                end
            end)
        end))
    end

    res._return = Promise.fromEvent(self.finishedMelodySE)
    :finally(function()
        self._maid:Remove("waitPlayerInput")
    end)
    return res
end

function MgSoundRepeatC:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.RootModel, {
        events = {"playedWrongMelody", "finishedMelody"},
    }))
end


local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MgSoundRepeatC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.ButtonPart = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="ButtonPart"})
            if not self.ButtonPart then return end

            self.ButtonText = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="ButtonText"})
            if not self.ButtonText then return end

            self.ButtonToucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="ButtonToucher"})
            if not self.ButtonToucher then return end

            self.Wires = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Wires"})
            if not self.Wires then return end
            self.Wires = ComposedKey.getFirstDescendant(self.Wires, {"Model"})
            if not self.Wires then return end

            self.Notes = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Notes"})
            if not self.Notes then return end
            self.Notes = ComposedKey.getFirstDescendant(self.Notes, {"Model"})
            if not self.Notes then return end

            self.CameraWp = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="CameraWp"})
            if not self.CameraWp then return end

            self.Lock = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Lock"})
            if not self.Lock then return end

            self.MView1 = ComposedKey.getFirstDescendant(self.Lock, {"MView1"})
            if not self.MView1 then return end

            self.MView2 = ComposedKey.getFirstDescendant(self.Lock, {"MView2"})
            if not self.MView2 then return end

            local MapTokens = SharedSherlock:find({"EzRef", "GetSync"}, {inst=workspace.Map.Chapters["1"], refName="MapTokens"})
            if not MapTokens then return end
            self.MapToken = ComposedKey.getFirstDescendant(MapTokens, {"Model", "MapToken6"})

            self.allNoteData = {}
            for _, Note in ipairs(self.Notes:GetChildren()) do
                local noteIdx = Note:GetAttribute("noteIdx")
                if not noteIdx then return end
                local GlowParts = Functional.filter(Note:GetChildren(), function(child)
                    return child:GetAttribute("canGlow")
                end)

                self.allNoteData[noteIdx] = {
                    ClickDetector = Note.ClickDetector,
                    GlowParts = GlowParts,
                    sfx = Note.Sfx,
                }

            end


            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function MgSoundRepeatC:Destroy()
    self._maid:Destroy()
end

return MgSoundRepeatC