return {
    Name = "changeTeam";
	Aliases = {"changeTeam"};
	Description = "ChangeTeam. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "string";
			Name = "team";
			Description = "Team.";
		},
	}
}