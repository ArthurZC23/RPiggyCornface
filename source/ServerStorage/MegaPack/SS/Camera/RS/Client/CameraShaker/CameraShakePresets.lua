-- Camera Shake Presets
-- Stephen Leitnick
-- February 26, 2018

local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {

	-- A high-magnitude, short, yet smooth shake.
	-- Should happen once.
	Bump = {
        params = {2.5, 4, 0.1, 0.75},
        influence = {
            position = {0.15, 0.15, 0.15},
            rotation = {1, 1, 1},
        },
    },

	-- An intense and rough shake.
	-- Should happen once.
	Explosion = {
        params = {5, 10, 0, 1.5},
        influence = {
            position = {0.25, 0.25, 0.25},
            rotation = {4, 1, 1},
        },
    },

	-- A continuous, rough shake
	-- Sustained.
	Earthquake = {
        params = {0.6, 3.5, 2, 10},
        influence = {
            position = {0.25, 0.25, 0.25},
            rotation = {1, 1, 4},
        },
    },

    -- Creating pressure
	Channel1 = {
        params = {0.3, 8, 0.3, 1},
        influence = {
            position = {3, 3, 0},
            rotation = {0, 0, 10},
        },
    },

    PowerfulAttack = {
        params = {1, 8, 0.2, 3},
        influence = {
            position = {5, 5, 0},
            rotation = {0, 0, 15},
        },
    },

	-- A bizarre shake with a very high magnitude and low roughness.
	-- Sustained.
	BadTrip = {
        params = {10, 0.15, 5, 10},
        influence = {
            position = {0, 0, 0.15},
            rotation = {2, 1, 4},
        },
    },

	-- A subtle, slow shake.
	-- Sustained.
	HandheldCamera = {
        params = {1, 0.25, 5, 10},
        influence = {
            position = {0, 0, 0},
            rotation = {1, 0.5, 0.5},
        },
    },

	-- A very rough, yet low magnitude shake.
	-- Sustained.
	Vibration = {
        params = {0.4, 20, 2, 2},
        influence = {
            position = {0, 0.15, 0},
            rotation = {1.25, 0, 4},
        },
    },

	-- A slightly rough, medium magnitude shake.
	-- Sustained.
	RoughDriving = {
        params = {1, 2, 1, 1},
        influence = {
            position = {0, 0, 0},
            rotation = {1, 1, 1},
        },
    },
}

return setmetatable({
    _presets = CameraShakePresets
    },
    {
	__index = function(t, preset)
		local data = CameraShakePresets[preset]
        assert(data, ("Preset %s was not found"):format(preset))
        local c = CameraShakeInstance.new(unpack(data.params))
        c.PositionInfluence = Vector3.new(unpack(data.influence.position))
		c.RotationInfluence = Vector3.new(unpack(data.influence.rotation))
        return c
	end,
})