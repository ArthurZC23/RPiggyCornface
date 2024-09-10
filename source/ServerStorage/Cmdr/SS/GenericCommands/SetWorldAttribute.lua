return {
    Name = "setWorldAttribute";
	Aliases = {"swAttr"};
	Description = "Set World Attribute.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "string";
			Name = "attributeName";
			Description = "Attribute Name";
		},
        {
			Type = "any";
			Name = "attributeValue";
			Description = "Attribute Value";
		},
	}
}