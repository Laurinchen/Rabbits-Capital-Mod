require("Annotations");
require("Creators");
require("PossibleStructureTypes");

local function UILoseOnGettingCapitalConqueredInteracted()
    local value = UILoseOnGettingCapitalConquered.GetIsChecked();
    UILostCapitalPunishment.SetInteractable(not value);
    UILostCapitalPunishmentAsPercentage.SetInteractable(not value);
end

local function UILostCapitalPunishmentAsPercentageInteracted()
    local value = UILostCapitalPunishmentAsPercentage.GetIsChecked();
    if value then
        UILostCapitalPunishment.SetValue(20);
    else
        UILostCapitalPunishment.SetValue(25);
    end
end

local function UpdateUIStructureTypeInfo()
    UIStructureTypeInfo.SetText("Current structure selected: " .. StructureTypeNames[ChosenStructureType]);
end

function UIStructureTypeInteracted()
    ---@type {text: string, selected: fun()}[]
    local options = {};

    for _, structure in ipairs(ValidStructureTypes) do
        table.insert(options, { text = StructureTypeNames[structure], selected = function()
            ChosenStructureType = structure;
            UpdateUIStructureTypeInfo();
            end
        });
    end

    UI.PromptFromList("Select a structure type", options);
end

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    --Default initialising the variables

    ---@type boolean
    local InitialLoseOnGettingCapitalConquered = Mod.Settings.LoseOnGettingCapitalConquered or false;

    ---@type boolean
    local InitialWinAutomaticallyIfOwningAllCapitals = Mod.Settings.WinAutomaticallyIfOwningAllCapitals
    if InitialWinAutomaticallyIfOwningAllCapitals == nil then
        InitialWinAutomaticallyIfOwningAllCapitals = false;
    end

    ---@type integer
    local InitialCapitalBonus = Mod.Settings.CapitalBonus or 10;

    ---@type integer
    local InitialCapitalDefenceBonus = Mod.Settings.CapitalDefenceBonus or 10;

    ---@type boolean
    local InitialPlayersChooseCapitalLocation = Mod.Settings.PlayersChooseCapitalLocation;
    if InitialPlayersChooseCapitalLocation == nil then
        InitialPlayersChooseCapitalLocation = true;
    end

    ---@type integer
    local InitialLostCapitalPunishment = Mod.Settings.LostCapitalPunishment or 25;

    ---@type boolean
    local InitialLostCapitalPunishmentAsPercentage = Mod.Settings.LostCapitalPunishmentAsPercentage or false;

    ---@type string
    ChosenStructureType = Mod.Settings.StructureType or WL.StructureType.MercenaryCamp;

    --Creating the UI Elements


    ---@type HorizontalLayoutGroup
    local UIGroup = UI.CreateVerticalLayoutGroup(rootParent);

    ---@type Label
    local UIMainInfo = UI.CreateLabel(UIGroup);

    ---@type Label
    local UICreatorsInfo = UI.CreateLabel(UIGroup);

    ---@type CheckBox
    UILoseOnGettingCapitalConquered = UI.CreateCheckBox(UIGroup);

    ---@type CheckBox
    UIWinAutomaticallyIfOwningAllCapitals = UI.CreateCheckBox(UIGroup);

    ---@type Label
    local UIInfoCapitalBonus = UI.CreateLabel(UIGroup);

    ---@type NumberInputField
    UICapitalBonus = UI.CreateNumberInputField(UIGroup)

    ---@type Label
    local UIInfoCapitalDefenceBonus = UI.CreateLabel(UIGroup);

    ---@type NumberInputField
    UICapitalDefenceBonus = UI.CreateNumberInputField(UIGroup);

    ---@type CheckBox
    UIPlayersChooseCapitalLocation = UI.CreateCheckBox(UIGroup);

    ---@type Label
    local UIInfoLostCapitalPunishment = UI.CreateLabel(UIGroup);

    ---@type NumberInputField
    UILostCapitalPunishment = UI.CreateNumberInputField(UIGroup);

    ---@type CheckBox
    UILostCapitalPunishmentAsPercentage = UI.CreateCheckBox(UIGroup);

    ---@type Label
    local UIInfoStructureType = UI.CreateLabel(UIGroup);

    ---@type Button
    UIStructureType = UI.CreateButton(UIGroup);

    ---@type Label
    UIStructureTypeInfo = UI.CreateLabel(UIGroup);

    --Add content to UI elements

    --UIMainInfo
    UIMainInfo.SetText(
        [[Welcome to Kaninchens Capital Mod. Every player get their own Capital and you can decide here if they immediately lose if their capital gets conquered
or if they just get an punishment, what kind of punishment, bonuses for holding 1 or more capitals and more!
Enjoy.]]);

    --UICreatorsInfo
    ---@type string
    local creators = "By\n";
    for _, name in pairs(Creators) do
        creators = creators .. "    ·" .. name .. "\n";
    end
    creators = creators .. "\n\n";
    UICreatorsInfo.SetText(creators);

    --UILoseOnGettingCapitalConquered
    UILoseOnGettingCapitalConquered.SetText("Should a player immediately lose if they lose their capital?");
    UILoseOnGettingCapitalConquered.SetIsChecked(InitialLoseOnGettingCapitalConquered);
    UILoseOnGettingCapitalConquered.SetOnValueChanged(UILoseOnGettingCapitalConqueredInteracted);

    --UIWinAutomaticallyIfOwningAllCapitals
    UIWinAutomaticallyIfOwningAllCapitals.SetText("Should a player owning all capitals automatically win?");
    UIWinAutomaticallyIfOwningAllCapitals.SetIsChecked(InitialWinAutomaticallyIfOwningAllCapitals);
    
    --UIInfoCapitalBonus
    UIInfoCapitalBonus.SetText("How much extra income a player should get for every capital they own");

    --UICapitalBonus
    UICapitalBonus.SetWholeNumbers(true);
    UICapitalBonus.SetSliderMinValue(0);
    UICapitalBonus.SetSliderMaxValue(100);
    UICapitalBonus.SetValue(InitialCapitalBonus);

    --UIInfoCapitalDefenceBonus
    UIInfoCapitalDefenceBonus.SetText("How many extra attacking armies should be killed when a capital is attacked?");

    --UICapitalDefenceBonus
    UICapitalDefenceBonus.SetWholeNumbers(true);
    UICapitalDefenceBonus.SetSliderMinValue(0);
    UICapitalDefenceBonus.SetSliderMaxValue(100);
    UICapitalDefenceBonus.SetValue(InitialCapitalDefenceBonus);

    --UIPlayersChooseCapitalLocation
    UIPlayersChooseCapitalLocation.SetText("Should players be able to choose their own capital?");
    UIPlayersChooseCapitalLocation.SetIsChecked(InitialPlayersChooseCapitalLocation);

    --UIInfoLostCapitalPunishment
    UIInfoLostCapitalPunishment.SetText(
    "If players shouldn't immediately lose on capital loss, how much should their income be reduced?");

    --UILostCapitalPunishment
    UILostCapitalPunishment.SetWholeNumbers(true);
    UILostCapitalPunishment.SetSliderMinValue(0);
    UILostCapitalPunishment.SetSliderMaxValue(100);
    UILostCapitalPunishment.SetValue(InitialLostCapitalPunishment);

    --UILostCapitalPunishmentAsPercentage
    UILostCapitalPunishmentAsPercentage.SetText(
    "Should the above option reduce the players income by a percentage instead of an absolute number?");
    UILostCapitalPunishmentAsPercentage.SetIsChecked(InitialLostCapitalPunishmentAsPercentage);
    UILostCapitalPunishmentAsPercentage.SetOnValueChanged(UILostCapitalPunishmentAsPercentageInteracted);



    --UIInfoStructureType
    UIInfoStructureType.SetText(
    "[advanced] To prevent incompatibility problems with other mods, what structure type should the Capital be?");

    --UIStructureType
    UIStructureType.SetText("Choose structure type");
    UIStructureType.SetOnClick(UIStructureTypeInteracted);

    --Other
    UILoseOnGettingCapitalConqueredInteracted();
    UpdateUIStructureTypeInfo();


end
