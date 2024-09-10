return {
    Name = "GiveItem";
	Aliases = {"giveItem"};
	Description = "Give Item to target player. Super User Only.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "Target player.";
		},
        {
			Type = "string";
			Name = "itemName";
			Description = "Item Name";
		},
	}
}