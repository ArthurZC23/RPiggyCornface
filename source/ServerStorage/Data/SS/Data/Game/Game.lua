local module = {
    name = "ScaryMazeCornface",
    prettyName = "Ecape Cornface",
    maxPlayers = 15,
    rigType = "R15",
    developer = {
        isGroup = true,
        name = "Only Scary Games",
        id = "34149564",
    },
    version = "1.3.2",
    serverTypePlaceId = {
        ["TEST"] = 18429305768,
        ["PRODUCTION"] = 18429285861,
    },
    placeIds = {
        [18429305768] = "TEST",
        [18429285861] = "PRODUCTION",
    },
    updatePlaceIds = {
        [0] = "",
    },
    sessionLocking = {
        timeoutDelta = 60, --Is enough to make exploits wortheless most of the time. At the same time it doesn't disrupt normal players ux.
    },
	otherGames = {
        ["Puppy Game"] = {
            view = true,
            viewName = "Puppy Game",
            LayoutOrder = 15,
            ["PRODUCTION"] = {
                placeId = 14140521313,
            },
            ["TEST"] = {
                placeId = 14140521313,
            }
		},
        ["BackroomsDancingPug"] = {
            view = true,
            viewName = "Dancing Pug Meme",
            LayoutOrder = 15,
            ["PRODUCTION"] = {
                placeId = 18619783618,
            },
            ["TEST"] = {
                placeId = 18619783618,
            }
		},
        -- +1 and cat story
        ["CircusDog"] = {
			view = false,
			viewName = "Amazing Dog Meme Backrooms",
			LayoutOrder = -450,
			["PRODUCTION"] = {
				placeId = 17010405348,
			},
			["TEST"] = {
				placeId = 17010405348,
			}
		},
        ["SadPObby"] = {
			view = false,
			viewName = "Obby But You're Sad P",
			LayoutOrder = -400,
			["PRODUCTION"] = {
				placeId = 16818562486,
			},
			["TEST"] = {
				placeId = 16818562486,
			}
		},
        ["Speed+1"] = {
			view = false,
			viewName = "+1 Fast Every Second",
			LayoutOrder = -200,
			["PRODUCTION"] = {
				placeId = 16929518191,
			},
			["TEST"] = {
				placeId = 16929518191,
			}
		},
		["ToiletBattles"] = {
			view = false,
			viewName = "Toilet Battles",
			LayoutOrder = -100,
			["PRODUCTION"] = {
				placeId = 16742872699,
			},
			["TEST"] = {
				placeId = 16742872699,
			}
		},
        ["Toothless Dancing Meme Backrooms"] = {
			view = false,
			viewName = "Toothless Dancing Meme Backrooms",
            LayoutOrder = 10,
			["PRODUCTION"] = {
				placeId = 16137607911,
			},
			["TEST"] = {
				placeId = 16137607911,
			}
		},
        ["Shampoo Simulator"] = {
             view = false,
            viewName = "Shampoo Simulator",
            LayoutOrder = 40,
            ["PRODUCTION"] = {
                placeId = 6440133276,
            },
            ["TEST"] = {
                placeId = 6467532414,
            }
        },
        ["HairSalonSimulator"] = {
            view = false,
            viewName = "Hair Salon Simulator",
            LayoutOrder = -300,
            ["PRODUCTION"] = {
                placeId = 5275666932,
            },
            ["TEST"] = {
                placeId = 7626492382,
            }
        },
        ["Glady"] = {
            view = false,
            viewName = "Glady",
            LayoutOrder = 70,
            ["PRODUCTION"] = {
                placeId = 5245142176,
            },
            ["TEST"] = {
                placeId = 5245142176,
            }
        },
        ["CrunchySquirrels"] = {
            view = false,
            viewName = "Squirrel Tycoon",
            LayoutOrder = 30,
            ["PRODUCTION"] = {
                placeId = 8463491001,
            },
            ["TEST"] = {
                placeId = 8463469871,
            }
        },
        ["VioletObby"] = {
            view = false,
            viewName = "Violet Obby!",
            LayoutOrder = 100,
            ["PRODUCTION"] = {
                placeId = 13969153920,
            },
            ["TEST"] = {
                placeId = 13969153920,
            }
        },
        ["DogObby"] = {
            view = false,
            viewName = "🐶 Obby but u're a dog",
            LayoutOrder = 20,
            ["PRODUCTION"] = {
                placeId = 15463023876,
            },
            ["TEST"] = {
                placeId = 15463023876,
            }
        },
        ["ValentineDogObby"] = {
            view = false,
            viewName = "Valentine Obby but u're a dog",
            LayoutOrder = -1,
            ["PRODUCTION"] = {
                placeId = 16276597411,
            },
            ["TEST"] = {
                placeId = 16276597411,
            }
        },
        ["Speed+1Bike"] = {
            view = true,
            viewName = "+1 Speed Every Second But You’re On a Bike",
            LayoutOrder = 15,
            ["PRODUCTION"] = {
                placeId = 15153224838,
            },
            ["TEST"] = {
                placeId = 15219681920,
            }
        },
        ["Speed+1Skate"] = {
            view = false,
            viewName = "+1 Speed Every Second Skate",
            LayoutOrder = 15,
            ["PRODUCTION"] = {
                placeId = 18135507876,
            },
            ["TEST"] = {
                placeId = 18135507876,
            }
        },
        ["SlayerArena"] = {
            thumbnail = "rbxassetid://18138263130",
            view = false,
            viewName = "Demon Slayer Arena",
            LayoutOrder = 15,
            ["PRODUCTION"] = {
                placeId = 10044344099,
            },
            ["TEST"] = {
                placeId = 10044344099,
            }
        },
    },
}

module.placeTypeToId = {}
for id, placeType in pairs(module.placeIds) do
    module.placeTypeToId[placeType] = id
end

if not module.developer.name then
    warn("Add developer name")
end

if not module.developer.id then
    warn("Add developer id")
end

if not next(module.placeIds) then
    warn("Add test and production places")
end

return module