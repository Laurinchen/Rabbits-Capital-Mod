require("Annotations")

---@param Game GameServerHook
---@param Gamesettings GameSettings
function Server_Created(Game, Gamesettings)
    if Gamesettings.Cards[WL.CardID.Reinforcement] == nil then
        ---@type table<CardID, CardGame>
        local cards = Gamesettings.Cards;
        cards[WL.CardID.Reinforcement] = WL.CardGameReinforcement.Create(999999, 0, 0, 0, WL.ReinforcementCardMode.Fixed, 0, 1);
        Gamesettings.Cards = cards;
    end
end