return {
    Name = "GiveMoney";
	Aliases = {"giveMoeny"};
	Description = "Give Money to target player. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "number";
			Name = "quantity";
			Description = "Money quantity.";
		},
	}
}