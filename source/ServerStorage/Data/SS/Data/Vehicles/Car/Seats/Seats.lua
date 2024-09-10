local module = {}

module.idToData = {}

module.seatTypes = {
    ["1"] = "DriverSeat",
    ["2"] = "PassengerSeat",
}

module.idToData["0"] = {
    ["1"] = {
        seatTypeId = "1",
        instName="DriverSeatFL",
    },
    ["2"] = {
        seatTypeId = "2",
        instName="PassengerSeatFR",
        -- Could have extra args. Like permissions for who can open the glass in the car.
    },
    ["3"] = {
        seatTypeId = "2",
        instName="PassengerSeatRL",
    },
    ["4"] = {
        seatTypeId = "2",
        instName="PassengerSeatRR",
    },
}

module.instNameToData = {}

for mId, seatsData in pairs(module.idToData) do
    module.instNameToData[mId] = {}
    for seatId, data in pairs(seatsData) do
        data.seatId = seatId
        module.instNameToData[mId][data.instName] = data
    end
end

return module