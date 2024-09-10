return {
    Name = "GiveKey";
	Aliases = {"giveKey"};
	Description = "Give Key to target player. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "string";
			Name = "keyName";
			Description = "Key Name";
		},
	}
}