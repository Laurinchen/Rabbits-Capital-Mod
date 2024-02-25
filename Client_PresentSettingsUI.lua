require("Annotations");
require("PossibleStructureTypes");

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    ---@type VerticalLayoutGroup
    local UIGroup = UI.CreateVerticalLayoutGroup(rootParent);

    ---@type Label
    local UIInfoImportant = UI.CreateLabel(UIGroup);
    UIInfoImportant.SetColor("#CC0000");
    UIInfoImportant.SetText("IMPORTANT");

    ---@type Label
    local UIImportantInformation = UI.CreateLabel(UIGroup);
    UIImportantInformation.SetText(
        [[If your host didn't disable "Players choose their capital location", you have to set your capital in the first turn, otherwise a random location will be set.
To set your capital location, go to the mod menu of this mod and click on "Set capital location"!]]);

    ---@type Label
    local UIInfoImportantOver = UI.CreateLabel(UIGroup);
    UIInfoImportantOver.SetColor("#CC0000");
    UIInfoImportantOver.SetText("The important part is over.");

    ---@type Label
    local UIModInformation = UI.CreateLabel(UIGroup);
    UIModInformation.SetText(
        [[Welcome to Kaninchens Capital Mod. In this Mod, you own a capital. You must protect it at all cost, otherwise there might be bad consequences.
Depending on the host settings there might be bonuses for taking over other capitals. Refer to the settings below:]]);

    ---@type HorizontalLayoutGroup
    local UIGroupLoseOnGettingCapitalConquered = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UILoseOnGettingCapitalConqueredText = UI.CreateLabel(UIGroupLoseOnGettingCapitalConquered);
    UILoseOnGettingCapitalConqueredText.SetText("Player will automatically lose if they lose their capital: ");

    ---@type Label
    local UILoseOnGettingCapitalConqueredValue = UI.CreateLabel(UIGroupLoseOnGettingCapitalConquered);
    if Mod.Settings.LoseOnGettingCapitalConquered then
        UILoseOnGettingCapitalConqueredValue.SetColor("#FF0000");
        UILoseOnGettingCapitalConqueredValue.SetText("Yes");
    else
        UILoseOnGettingCapitalConqueredValue.SetColor("#32CD32");
        UILoseOnGettingCapitalConqueredValue.SetText("No");
    end

    ---@type HorizontalLayoutGroup
    local UIWinAutomaticallyIfOwningAllCapitals = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UIWinAutomaticallyIfOwningAllCapitalsText = UI.CreateLabel(UIWinAutomaticallyIfOwningAllCapitals);
    UIWinAutomaticallyIfOwningAllCapitalsText.SetText("Player/Team will win automatically if they own all capitals: ");

    ---@type Label
    local UIWinAutomaticallyIfOwningAllCapitalsValue = UI.CreateLabel(UIWinAutomaticallyIfOwningAllCapitals);
    if Mod.Settings.WinAutomaticallyIfOwningAllCapitals then
        UIWinAutomaticallyIfOwningAllCapitalsValue.SetColor("#32CD32");
        UIWinAutomaticallyIfOwningAllCapitalsValue.SetText("Yes");
    else
        UIWinAutomaticallyIfOwningAllCapitalsValue.SetColor("#FF0000");
        UIWinAutomaticallyIfOwningAllCapitalsValue.SetText("No");
    end;

    ---@type Label
    local UICapitalBonus = UI.CreateLabel(UIGroup);
    UICapitalBonus.SetText("Bonus for every capital owned (including own): " .. tostring(Mod.Settings.CapitalBonus));

    ---@type Label
    local UICapitalDefenceBonus = UI.CreateLabel(UIGroup);
    UICapitalDefenceBonus.SetText("How many extra armies are killed when attacking a capital: " ..
        tostring(Mod.Settings.CapitalDefenceBonus));

    ---@type HorizontalLayoutGroup
    local UIGroupPlayersChooseCapitalLocation = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UIPlayersChooseCapitalLocationText = UI.CreateLabel(UIGroupPlayersChooseCapitalLocation);
    UIPlayersChooseCapitalLocationText.SetText("Players are able to choose their own capital location: ");

    ---@type Label
    local UIPlayersChooseCapitalLocationValue = UI.CreateLabel(UIGroupPlayersChooseCapitalLocation);
    if Mod.Settings.PlayersChooseCapitalLocation then
        UIPlayersChooseCapitalLocationValue.SetColor("#32CD32");
        UIPlayersChooseCapitalLocationValue.SetText("Yes");
    else
        UIPlayersChooseCapitalLocationValue.SetColor("#FF0000");
        UIPlayersChooseCapitalLocationValue.SetText("No");
    end

    if not Mod.Settings.LoseOnGettingCapitalConquered then
        ---@type integer
        local LostCapitalPunishment = Mod.Settings.LostCapitalPunishment;

        ---@type Label
        local UILostCapitalPunishment = UI.CreateLabel(UIGroup);
        if Mod.Settings.LostCapitalPunishmentAsPercentage then
            UILostCapitalPunishment.SetText("If a player lost their capital, they will lose " ..
            tostring(LostCapitalPunishment) .. "% of their income (percentage)");
        else
            UILostCapitalPunishment.SetText("If a player lost their capital, they will lose " ..
            tostring(LostCapitalPunishment) .. " of their income (absolute)");
        end
    end

    ---@type Label
    local UIStructureType = UI.CreateLabel(UIGroup);
    UIStructureType.SetText("The capital is following structure: " .. StructureTypeNames[Mod.Settings.StructureType]);
end
