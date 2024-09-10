return {
    Name = "banForever";
	Aliases = {"ban4ever"};
	Description = "Ban player forever.";
	Group = "moderator";
	Args = {
        {
			Type = "player";
			Name = "player";
			Description = "Player to be banned";
		},
    }
}