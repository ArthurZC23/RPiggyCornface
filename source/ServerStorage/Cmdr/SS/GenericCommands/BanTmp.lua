return {
    Name = "banTemporary";
	Aliases = {"banTmp"};
	Description = "Ban player for a period of time.";
	Group = "moderatorTrainee";
	Args = {
        {
			Type = "player";
			Name = "player";
			Description = "Player to be banned";
		},
        {
			Type = "number";
			Name = "duration";
			Description = "Ban duration in days";
		},
    }
}