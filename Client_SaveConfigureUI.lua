require("Annotations");
require("Client_PresentConfigureUI");

---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
    Mod.Settings.LoseOnGettingCapitalConquered = UILoseOnGettingCapitalConquered.GetIsChecked();

    Mod.Settings.WinAutomaticallyIfOwningAllCapitals = UIWinAutomaticallyIfOwningAllCapitals.GetIsChecked();

    ---@type integer
    local CapitalBonus = UICapitalBonus.GetValue();
    if CapitalBonus < 0 then
        alert("Capital Bonus must be at least 0");
    end
    Mod.Settings.CapitalBonus = CapitalBonus;

    ---@type integer
    local CapitalDefenceBonus = UICapitalDefenceBonus.GetValue();
    if CapitalDefenceBonus < 0 then
        alert("Capital Defence Bonus must be at least 0");
    end
    Mod.Settings.CapitalDefenceBonus = CapitalDefenceBonus;

    Mod.Settings.PlayersChooseCapitalLocation = UIPlayersChooseCapitalLocation.GetIsChecked();

    ---@type boolean
    local LostCapitalPunishmentAsPercentage = UILostCapitalPunishmentAsPercentage.GetIsChecked();

    Mod.Settings.LostCapitalPunishmentAsPercentage = LostCapitalPunishmentAsPercentage;

    ---@type integer
    local LostCapitalPunishment = UILostCapitalPunishment.GetValue();
    if LostCapitalPunishment < 0 then
        alert("Lost Capital Punishment must be at least 0");
    elseif LostCapitalPunishmentAsPercentage and LostCapitalPunishment > 100 then
        alert("Percentage of Lost Capital Punishment must be at most 100");
    end
    Mod.Settings.LostCapitalPunishment = LostCapitalPunishment;

    Mod.Settings.StructureType = ChosenStructureType;
end