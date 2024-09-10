return {
    Name = "spectate";
	Aliases = {"spectate"};
	Description = "spectate character.";
	Group = "moderatorTrainee";
	Args = {
        {
			Type = "player";
			Name = "player";
			Description = "Player";
		},
    },
    ClientRun = function(context, player, stateType, scope)
        local execPlayer = context.Executor
        if player == execPlayer then return end
        local char = player.Character
        if not (char and char.Parent) then return end
        local charId = char:GetAttribute("uid")
        if not charId then return end
        execPlayer:SetAttribute("Spectate", charId)

        return "Done"
	end
}