local module = {}

module.asyncTags = {
    PlayerStateManagers = true,
    PlayerGameState = true,
    PlayerState = true,
    PlayerDefaults = true,
    PlayerBindToClose = true,
    PlayerReplicator = true,
    PlayerBinder = true,
    PlayerTeam = true, -- Player team is required for some logics
    --------------
}

module.tags = {
    "PlayerStateManagers",
    "PlayerGameState",
    "PlayerState",
    "PlayerDefaults",
    "PlayerBindToClose",
    "PlayerReplicator",
    "PlayerBinder",
    "PlayerTeam",
    ----------------
    "PlayerCharacterSpawner",
    -- "StartScreen",
    "PlayerHades",
    "PlayerGamePasses",
    "PlayerScores",
    "PlayerSinglePurchase",
    "PlayerBadges",
    "PlayerTime",
    "PlayerAutoSave",
    "PlayerLeaderboards",
    "PlayerLeaderstats",
    "PlayerDevPurchaseFinisher",
    "PlayerSounds",
    "PlayerPurchaseHistory",
    "PlayerMembership",
    "PlayerGroup",
    "PlayerFps",
    "PlayerChat",
    "PlayerServer",
    "PeriodicMoneyGiver",
    "PlayerRandoms",
    "PlayerRobuxStats",
    "PlayerFriends",
    "PlayerPacioli",
    "PlayerTeleporters",
    "PlayerGuis",
    "PlayerShop",
    "PlayerPlatform",
    "PlayerBugReport",
    "PlayerTeleporter",
    "PlayerAds",
    "PlayerPolicyService",
    -- "PlayerMobileController",
    "CustomStateOnStudio",
    ---------------------
    -- "PlayerFinishGame",
    -- "PlayerTeamGuis",
    -- "PlayerBoosts",
    -- "PlayerMonsterSkins",
    -- "PlayerBecomeMonster",
    -- "PlayerMoney_1",
    -- "PlayerMoney_1Spawner",
    -- "PlayerChest",
    -- "PlayerSpinWheel",
}

return module