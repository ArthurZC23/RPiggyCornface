-- _Data is only used in a binder

local module = {}

module.idData = {
    ["1"] = {
        obbyStates = {
            ["1"] = {
                duration = 4,
                _state = {
                    ["1"] = true,
                },
            },
            ["2"] = {
                duration = 1,
                _state = {
                    ["1"] = false,
                },
            },
        },
    },
    ["2"] = {
        obbyStates = {
            ["1"] = {
                duration = 4,
                _state = {
                    ["1"] = true,
                    ["2"] = true,
                },
            },
            ["2"] = {
                duration = 1,
                _state = {
                    ["1"] = false,
                    ["2"] = true,
                },
            },
            ["3"] = {
                duration = 1,
                _state = {
                    ["1"] = false,
                    ["2"] = false,
                },
            },
            ["4"] = {
                duration = 1,
                _state = {
                    ["1"] = true,
                    ["2"] = false,
                },
            },
        },
    },
    ["3"] = {
        obbyStates = {
            ["1"] = {
                duration = 4,
                _state = {
                    ["1"] = true,
                    ["2"] = true,
                    ["3"] = true,
                },
            },
            ["2"] = {
                duration = 2,
                _state = {
                    ["1"] = false,
                    ["2"] = true,
                    ["3"] = true,
                },
            },
            ["3"] = {
                duration = 1,
                _state = {
                    ["1"] = false,
                    ["2"] = false,
                    ["3"] = true,
                },
            },
            ["4"] = {
                duration = 1,
                _state = {
                    ["1"] = false,
                    ["2"] = false,
                    ["3"] = false,
                },
            },
            ["5"] = {
                duration = 1,
                _state = {
                    ["1"] = true,
                    ["2"] = false,
                    ["3"] = false,
                },
            },
            ["6"] = {
                duration = 1,
                _state = {
                    ["1"] = true,
                    ["2"] = true,
                    ["3"] = false,
                },
            },
        },
    },
}

return module