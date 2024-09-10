return {
    Name = "mute";
	Aliases = {"mute"};
	Description = "Mute player.";
	Group = "moderatorTrainee";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Player";
		},
        {
			Type = "number";
			Name = "duration (min)";
			Description = "Duration in minutes";
		},
	}
}