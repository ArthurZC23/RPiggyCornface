return {
    Name = "banRemote";
	Aliases = {"banRemote"};
	Description = "Ban player that is not in this server.";
	Group = "DefaultAdmin";
	Args = {
        {
			Type = "string";
			Name = "userId";
			Description = "UserId (string).";
		},
        {
			Type = "string";
			Name = "reason";
			Description = "Reason for ban.";
		},
        {
			Type = "number";
			Name = "banTimeInDays";
			Description = "Ban time in days.";
		},
    }
}