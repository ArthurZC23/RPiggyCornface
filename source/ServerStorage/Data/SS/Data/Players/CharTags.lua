local module = {}

module.asyncTags = {
    PlayerCharacter = true,
    CharStateManagers = true,
    CharState = true,
    CharReplicator = true,
    --------------
}


module.tags = {
    "PlayerCharacter",
    "CharStateManagers",
    "CharState",
    "CharReplicator",
    ----------------
    -- "CharBoundingBox",
    "CharParts",
    "CharHades",
    "CharRegion",
    "CharCamera",
    "CharVelocity",
    "CharAE",
    "CharPhysics",
    "CharTeleportInGame",
    "CharAttachments",
    "Causality",
    "CharProps",
    "CharGuis",
    "CharLeaderstats",
    "CharRefs",
    -- "CharRagdoll",
    "CharRegionProps",
    -- ------------------
    "CharTeamGuis",
    {tag = "CharCrawl", teams = {MatchHuman = true, Lobby = true, Engine = true}},
    "CharAnimations",
    -- "CharAnimationMarkers",
    -- "CharSoundtrack",
    -- {tag = "CharTeamHuman", teams = {human = true}},
    {tag = "CharCoreAnimationsR15", teams = {MatchHuman = true, Lobby = true, Engine = true}},
    -- "CharDamage",
    -- {tag = "CharMapPuzzle", teams = {human = true}},
    -- -- {tag = "CharCloseToMonsterVfx", teams = {human = true}},
    -- -- {tag = "CharHide", teams = {human = true}},
    -- {tag = "CharAppearance", teams = {human = true}},
    -- {tag = "CharTrails", teams = {human = true}},
    -- {tag = "CharChatM", teams = {human = true}},
    -- {tag = "CharItems", teams = {human = true}},
    -- {tag = "CharSpeedHuman", teams = {human = true}},

}

return module