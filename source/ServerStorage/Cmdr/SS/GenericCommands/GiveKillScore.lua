return {
    Name = "giveKillScore";
	Aliases = {"giveKillScore"};
	Description = "Give Kill Score. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "number";
			Name = "value";
			Description = "Kill score.";
		},
	}
}