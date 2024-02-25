require("CapitalTypes");

---@param game GameServerHook
---@param standing GameStanding
function SetOwnedCapitals(game, standing)
    ---@type table
    local PlayerGameData = Mod.PlayerGameData;

    for playerID, _ in pairs(game.Game.PlayingPlayers) do
        ---@type {TerritoryID: TerritoryID, CapitalType: CapitalTypes}[]
        local result = {}

        ---@type TerritoryID?
        local CapitalOwnedByPlayer = PlayerGameData[playerID].CapitalLocation;

        for _, territoryid in pairs(Mod.PrivateGameData.PlayerCapitals) do
            if standing.Territories[territoryid].OwnerPlayerID == playerID then
                if CapitalOwnedByPlayer == territoryid then
                    table.insert(result, { TerritoryID = territoryid, CapitalType = CapitalTypes.own });
                else
                    table.insert(result, { TerritoryID = territoryid, CapitalType = CapitalTypes.EnemyConquered });
                end
            elseif CapitalOwnedByPlayer == territoryid then
                table.insert(result, { TerritoryID = territoryid, CapitalType = CapitalTypes.ownButConquered });
            end
        end
        PlayerGameData[playerID].ownedCapitals = result;
    end

    Mod.PlayerGameData = PlayerGameData;
end