return {
    Name = "setFinishChapter";
	Aliases = {"setFinishChapter"};
	Description = "Set Finish Chapter. Super User Only.";
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
			Description = "Score.";
		},
	}
}