return function (context, attributeName, attributeValue)
    workspace:SetAttribute(attributeName, attributeValue)
    print(attributeName, attributeValue)
	return
end