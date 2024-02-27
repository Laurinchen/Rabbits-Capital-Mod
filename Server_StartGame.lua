require("Annotations");
require("Util");
require("SetOwnedCapital");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local PlayerGameData = Mod.PlayerGameData;

    for playerid, _ in pairs(game.Game.PlayingPlayers) do
        PlayerGameData[playerid] = {};
    end

    ---@type table
    local PrivateGameData = Mod.PrivateGameData;
    if not Mod.Settings.PlayersChooseCapitalLocation then
        ---@type table<PlayerID, table<integer, TerritoryStanding>>
        local playerterritories = {};
        for playerid, _ in pairs(game.Game.PlayingPlayers) do
            playerterritories[playerid] = {};
        end

        for _, stand in pairs(standing.Territories) do
            if not stand.IsNeutral then
                table.insert(playerterritories[stand.OwnerPlayerID], stand);
            end
        end

        ---@type table<PlayerID, TerritoryID>
        local PlayerCapitals = {};
        for playerid, territories in pairs(playerterritories) do
            ---@type TerritoryStanding
            local chosenterritory = territories[math.random(#territories)]

            ---@type table<EnumStructureType, integer>
            local structures = chosenterritory.Structures;

            if structures == nil then
                structures = {};
            end
            if structures[Mod.Settings.StructureType] == nil then
                structures[Mod.Settings.StructureType] = 1;
            end

            chosenterritory.Structures = structures;

            PlayerCapitals[playerid] = chosenterritory.ID;

            ---@type table

            PlayerGameData[playerid].CapitalLocation = chosenterritory.ID;
        end

        ---@type table
        PrivateGameData.PlayerCapitals = PlayerCapitals;
    else
        PrivateGameData.PlayerCapitals = {};
    end

    Mod.PlayerGameData = PlayerGameData;

    Mod.PrivateGameData = PrivateGameData;
    SetOwnedCapitals(game, standing);

    ---@type table<PlayerID, PlayerCards>
    local cards = standing.Cards;
    for playerid, _ in pairs(game.Game.PlayingPlayers) do
        if cards[playerid] == nil then
            cards[playerid] = WL.PlayerCards.Create(playerid);
        end
        ---@type ReinforcementCardInstance
        local card = WL.ReinforcementCardInstance.Create(Mod.Settings.CapitalBonus);

        ---@type table<CardInstanceID, CardInstance>
        local wholecards = cards[playerid].WholeCards;
        wholecards[card.ID] = card;
        cards[playerid].WholeCards = wholecards;
    end
    standing.Cards = cards;

    for playerid, _ in pairs(game.Game.PlayingPlayers) do
        for cardinstanceid, cardinstance in pairs(standing.Cards[playerid].WholeCards) do
            print(playerid, cardinstanceid, cardinstance.proxyType);
        end
    end
end
