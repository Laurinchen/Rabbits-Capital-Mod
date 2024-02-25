require("Annotations");
require("MessageTypes")
require("Util");
require("CapitalTypes");

---Server_GameCustomMessage
---@param game GameServerHook
---@param playerID PlayerID
---@param payload table
---@param setReturn fun(payload: table) # Sets the table that will be returned to the client when the custom message has been processed
function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if Mod.PrivateGameData.PlayerCapitals == nil then
        ---@type table
        local PrivateGameData = Mod.PrivateGameData;
        PrivateGameData.PlayerCapitals = {};
        Mod.PrivateGameData = PrivateGameData;
    end

    if Mod.PlayerGameData[playerID] == nil then
        ---@type table
        local PlayerGameData = Mod.PlayerGameData;
        PlayerGameData[playerID] = {};
        Mod.PlayerGameData = PlayerGameData;
    end

    if payload.type == MessageType.submitCapital then
        ---@type TerritoryID
        local TerritoryID = payload.TerritoryID

        if IsTerritoryOwnedByPlayer(playerID, TerritoryID, game.ServerGame.LatestTurnStanding.Territories) then
            ---@type table
            local PrivateGameData = Mod.PrivateGameData;
            PrivateGameData.PlayerCapitals[playerID] = TerritoryID;
            Mod.PrivateGameData = PrivateGameData;

            ---@type table
            local PlayerGameData = Mod.PlayerGameData;
            if PlayerGameData[playerID] == nil then
                PlayerGameData[playerID] = {};
            end

            PlayerGameData[playerID].CapitalLocation = TerritoryID;
            ---@type {TerritoryID: TerritoryID, CapitalType: CapitalTypes}[]
            capitals = {};
            capitals[1] = {TerritoryID=TerritoryID, CapitalType=CapitalTypes.own};
            PlayerGameData[playerID].ownedCapitals = capitals;

            Mod.PlayerGameData = PlayerGameData;

            setReturn({ success = true });
        else
            setReturn({ success = false });
        end
    end
end
