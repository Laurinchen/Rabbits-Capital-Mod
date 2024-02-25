require("Annotations");
require("Util");
require("SetOwnedCapital");

---Server_AdvanceTurn_Start hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Start(game, addNewOrder)
    PrivateGameData = Mod.PrivateGameData;
    if PrivateGameData.PlayerCapitals == nil then
        PrivateGameData.PlayerCapitals = {};
    end

    ---@type GameStanding
    local standing = game.ServerGame.LatestTurnStanding;

    if Mod.Settings.PlayersChooseCapitalLocation and game.Game.TurnNumber == 1 then
        ---@type table<PlayerID, TerritoryStanding[]>
        local playerterritories = {};

        for playerid, _ in pairs(game.Game.PlayingPlayers) do
            playerterritories[playerid] = {};
        end

        for _, stand in pairs(standing.Territories) do
            if not stand.IsNeutral then
                ---@type PlayerID
                local playerid = stand.OwnerPlayerID;
                if InKeys(PrivateGameData.PlayerCapitals, stand.OwnerPlayerID) then
                    table.insert(
                        playerterritories[playerid], standing.Territories[PrivateGameData.PlayerCapitals[playerid]]);
                    goto continue
                end
                table.insert(playerterritories[playerid], stand);
            end
            ::continue::
        end

        ---@type table<PlayerID, TerritoryID>
        local PlayerCapitals = {}
        ---@type table
        local PlayerGameData = Mod.PlayerGameData;

        for playerid, territories in pairs(playerterritories) do
            ---@type TerritoryStanding
            local chosenterritory = territories[math.random(#territories)]

            ---@type table<EnumStructureType, integer>
            local structures = chosenterritory.Structures;

            PlayerCapitals[playerid] = chosenterritory.ID;


            if PlayerGameData[playerid] == nil then
                PlayerGameData[playerid] = {};
            end

            PlayerGameData[playerid].CapitalLocation = chosenterritory.ID;

            if structures == nil or structures[Mod.Settings.StructureType] == nil then
                ---@type table<EnumStructureType, integer>
                local temp = {};
                temp[Mod.Settings.StructureType] = 1;

                ---@type TerritoryModification
                local terrmod = WL.TerritoryModification.Create(chosenterritory.ID);
                terrmod.AddStructuresOpt = temp;

                ---@type GameOrderEvent
                local order = WL.GameOrderEvent.Create(playerid, "Establishing Capital", {}, { terrmod }, {}, {});
                addNewOrder(order);
            end
        end
        Mod.PlayerGameData = PlayerGameData
        PrivateGameData.PlayerCapitals = PlayerCapitals;
        Mod.PrivateGameData = PrivateGameData;
    end
end

---Server_AdvanceTurn_Order
---@param game GameServerHook
---@param order GameOrder
---@param orderResult GameOrderResult
---@param skipThisOrder fun(modOrderControl: EnumModOrderControl) # Allows you to skip the current order
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
    ---@cast order GameOrderAttackTransfer
    ---@cast orderResult GameOrderAttackTransferResult
    if order.proxyType == "GameOrderAttackTransfer" and orderResult.IsAttack and not orderResult.IsNullified and InValues(Mod.PrivateGameData.PlayerCapitals, order.To) then
        ---@type TerritoryStanding
        local territory = game.ServerGame.LatestTurnStanding.Territories[order.To];

        ---@type GamePlayer
        local FromPlayer = game.Game.PlayingPlayers[order.PlayerID];
        ---@type GamePlayer
        local ToPlayer = game.Game.PlayingPlayers[territory.OwnerPlayerID];

        if Mod.PrivateGameData.PlayerCapitals[ToPlayer.ID] == territory.ID and FromPlayer.Team ~= -1 and ToPlayer.Team ~= -1 and ToPlayer.Team == FromPlayer.Team then
            addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Cannot attack capital from teammate", {}, {}, {}, {}));
            skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
        else
            ---@type Armies
            orderResult.AttackingArmiesKilled = orderResult.AttackingArmiesKilled.Add(WL.Armies.Create(
                Mod.Settings.CapitalDefenceBonus, {}));
        end
    end
    ---@cast order GameOrderPlayCardGift
    if order.proxyType == "GameOrderPlayCardGift" and Mod.PrivateGameData.PlayerCapitals[order.PlayerID] == order.TerritoryID then
        addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, "Cannot gift away your own capital", {}, {}, {}, {}));
        skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage)
    end
end

---Server_AdvanceTurn_End hook
---@param game GameServerHook
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders
function Server_AdvanceTurn_End(game, addNewOrder)
    if Mod.Settings.WinAutomaticallyIfOwningAllCapitals then
        ---@type PlayerID[]
        local winners = {};
        ---@type table<PlayerID, boolean>
        local allPlayersOwningCapitals = {};
        ---@type table<TeamID, PlayerID[]>;
        local allTeamsOwningCapitals = {};
        ---@type integer
        local allPlayersOwningCapitalsSize = 0
        ---@type integer
        local allTeamsOwningCapitalsSize = 0;


        for _, territoryID in pairs(Mod.PrivateGameData.PlayerCapitals) do
            ---@type PlayerID
            local playerid = game.ServerGame.LatestTurnStanding.Territories[territoryID].OwnerPlayerID;

            if playerid ~= WL.PlayerID.Neutral then
                if allPlayersOwningCapitals[playerid] == nil then
                    allPlayersOwningCapitals[playerid] = true;
                    allPlayersOwningCapitalsSize = allPlayersOwningCapitalsSize + 1;
                end
                ---@local TeamID
                local teamid = game.Game.PlayingPlayers[playerid].Team;

                if teamid ~= -1 then
                    if allTeamsOwningCapitals[teamid] == nil then
                        allTeamsOwningCapitals[teamid] = {};
                        allTeamsOwningCapitalsSize = allTeamsOwningCapitalsSize + 1;
                    end
                    table.insert(allTeamsOwningCapitals[teamid], playerid);
                end
            end
        end

        if allPlayersOwningCapitalsSize == 1 then
            ---@type PlayerID
            for playerid, _ in pairs(allPlayersOwningCapitals) do
                table.insert(winners, playerid)
            end
        elseif allTeamsOwningCapitalsSize == 1 then
            for _, winningteam in pairs(allTeamsOwningCapitals) do
                winners = winningteam;
            end
        end
        print(allPlayersOwningCapitals)

        if #winners ~= 0 then
            ---@type TerritoryModification[]
            local terrmods = {};
            for territoryID, standing in pairs(game.ServerGame.LatestTurnStanding.Territories) do
                if standing.OwnerPlayerID ~= WL.PlayerID.Neutral and standing.OwnerPlayerID ~= winner then
                    ---@type TerritoryModification
                    local terrmod = WL.TerritoryModification.Create(territoryID);

                    --FIX THAT
                    terrmod.SetOwnerOpt = winners[math.random(#winners)];

                    table.insert(terrmods, terrmod);
                end
            end
            addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, "All capitals are owned by 1 player/team. Congratulations!", winners,
                terrmods, {}, {}));
            return;
        end
    end




    ---@type table<PlayerID, {bonus: integer, punish: boolean}>
    local bonusesAndPunishment = {}

    for territoryid, standing in pairs(game.ServerGame.LatestTurnStanding.Territories) do
        ---@type PlayerID
        local StandingOwner = standing.OwnerPlayerID;

        ---@type PlayerID?
        local capitalOwner = GetKeyByValue(Mod.PrivateGameData.PlayerCapitals, territoryid);
        if capitalOwner ~= nil then
            if Mod.Settings.CapitalBonus ~= 0 then
                if bonusesAndPunishment[StandingOwner] == nil then
                    bonusesAndPunishment[StandingOwner] = { bonus = Mod.Settings.CapitalBonus, punish = false };
                else
                    bonusesAndPunishment[StandingOwner].bonus = bonusesAndPunishment[StandingOwner].bonus +
                        Mod.Settings.CapitalBonus;
                end
            end
            if StandingOwner ~= capitalOwner and InKeys(game.Game.PlayingPlayers, capitalOwner) then
                if Mod.Settings.LoseOnGettingCapitalConquered then
                    ---@type TerritoryModification[]
                    local terrmods = {}
                    for territoryid2, standing2 in pairs(game.ServerGame.LatestTurnStanding.Territories) do
                        if standing2.OwnerPlayerID == capitalOwner then
                            ---@type TerritoryModification
                            local terrmod = WL.TerritoryModification.Create(territoryid2);
                            terrmod.SetOwnerOpt = WL.PlayerID.Neutral;
                            table.insert(terrmods, terrmod);
                        end
                    end
                    addNewOrder(WL.GameOrderEvent.Create(capitalOwner, "Eliminating for losing capital", {}, terrmods, {},
                        {}));
                else
                    if bonusesAndPunishment[capitalOwner] == nil then
                        bonusesAndPunishment[capitalOwner] = { bonus = 0 }
                    end
                    bonusesAndPunishment[capitalOwner].punish = true;
                end
            end
        end
    end
    for playerid, data in pairs(bonusesAndPunishment) do
        ---@type IncomeMod[]
        local incomemods = {};
        ---@type IncomeMod
        table.insert(incomemods, WL.IncomeMod.Create(playerid, data.bonus, "Owning capitals"));

        if data.punish then
            ---@type integer
            local punishment = 0;

            ---@type string
            local percentageOrEmpty = "";

            if Mod.Settings.LostCapitalPunishmentAsPercentage then
                punishment = math.floor((game.Game.Players[playerid].Income(0, game.ServerGame.LatestTurnStanding, false, true).Total + data.bonus) /
                    100 * Mod.Settings.LostCapitalPunishment + 0.5);
                percentageOrEmpty = " (-" .. tostring(Mod.Settings.LostCapitalPunishment) .. "%)"
            else
                punishment = Mod.Settings.LostCapitalPunishment;
            end
            table.insert(incomemods,
                WL.IncomeMod.Create(playerid, -punishment,
                    "Having their own capital conquered by another player" .. percentageOrEmpty));
        end

        ---@type GameOrderEvent
        addNewOrder(WL.GameOrderEvent.Create(playerid, "Paying out bonuses for owning capitals", {}, {}, {},
            incomemods));
    end
    SetOwnedCapitals(game, game.ServerGame.LatestTurnStanding);
end
