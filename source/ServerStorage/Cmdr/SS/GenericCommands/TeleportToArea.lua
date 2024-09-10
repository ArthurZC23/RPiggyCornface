return {
    Name = "teleportToArea";
	Aliases = {"teleportToArea"};
	Description = "Teleport To Specific Area.";
	Group = "DefaultAdmin";
	Args = {
        {
			Type = "mapAreas";
			Name = "MapArea";
			Description = "Area to teleport";
		},
        {
			Type = "string";
			Name = "spawnId";
			Description = "Spawn Id";
		},
    }
}