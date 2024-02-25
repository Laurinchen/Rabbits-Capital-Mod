require("Annotations");
require("MessageTypes");
require("CapitalTypes");

local InformClientOfSuccessfulTerritorySubmission;
local InformClientOfUnSuccessfulTerritorySubmission;
local SubmitAnswerByServer;
local OnTerritoryClick;
local UISelectTerritoryButtonInteracted;
local ListOwnedCapitals;

---@param rootParent RootParent
---@param TerritoryName string
InformClientOfSuccessfulTerritorySubmission = function(rootParent, TerritoryName)
    ---@type VerticalLayoutGroup
    local UIGroup = UI.CreateVerticalLayoutGroup(rootParent);

    ---@type Label
    local UISuccessfullySubmitted = UI.CreateLabel(UIGroup);

    UISuccessfullySubmitted.SetColor("#32cd32");
    UISuccessfullySubmitted.SetText("Territory " .. TerritoryName .. " successfully chosen!")
end


---@param game GameClientHook
---@param rootParent RootParent
---@param TerritoryName string
---@param close fun()
InformClientOfUnSuccessfulTerritorySubmission = function(rootParent, TerritoryName, game, close)
    ---@type VerticalLayoutGroup
    local UIGroup = UI.CreateVerticalLayoutGroup(rootParent);

    ---@type Label
    local UISuccessfullySubmitted = UI.CreateLabel(UIGroup);

    UISuccessfullySubmitted.SetColor("#ff0000");
    UISuccessfullySubmitted.SetText("Invalid Territory! You do not own " .. TerritoryName .. "!");

    ---@type Button
    local UISelectTerritoryButton = UI.CreateButton(UIGroup);
    UISelectTerritoryButton.SetText("Try again");
    UISelectTerritoryButton.SetOnClick(
        function()
            UISelectTerritoryButtonInteracted(game, close);
        end
    )
end

---@param game GameClientHook
---@param t table
---@param TerritoryDetails TerritoryDetails
SubmitAnswerByServer = function(game, t, TerritoryDetails)
    if t.success then
        game.CreateDialog(
            function(rootParent)
                InformClientOfSuccessfulTerritorySubmission(rootParent, TerritoryDetails.Name)
            end
        );
    else
        game.CreateDialog(
            function (rootParent, _, _, game, close)
                InformClientOfUnSuccessfulTerritorySubmission(rootParent, TerritoryDetails.Name, game, close)
            end
        );
    end
end

---@param game GameClientHook
---@param TerritoryDetails? TerritoryDetails
OnTerritoryClick = function(game, TerritoryDetails)
    if TerritoryDetails == nil then
        return;
    end
    game.HighlightTerritories({ TerritoryDetails.ID });
    game.SendGameCustomMessage("Submitting Territory...",
        { type = MessageType.submitCapital, TerritoryID = TerritoryDetails.ID },
        function(t)
            SubmitAnswerByServer(game, t, TerritoryDetails);
        end
    );
end


---@param game GameClientHook
---@param close fun()
UISelectTerritoryButtonInteracted = function(game, close)
    UI.InterceptNextTerritoryClick(
    ---@param TerritoryDetails? TerritoryDetails
        function(TerritoryDetails)
            OnTerritoryClick(game, TerritoryDetails);
        end
    );
    close();
end


---@param game GameClientHook
---@param UIGroup VerticalLayoutGroup
ListOwnedCapitals = function(game, UIGroup)
    ---@type {TerritoryID: TerritoryID, CapitalType: CapitalTypes}[]
    local capitals = Mod.PlayerGameData.ownedCapitals

    for _, capital in ipairs(capitals) do
        ---@type string
        local buttoncolor;

        if capital.CapitalType == CapitalTypes.own then
            buttoncolor = "#43C731";
        elseif capital.CapitalType == CapitalTypes.EnemyConquered then
            buttoncolor = "#FFC200";
        elseif capital.CapitalType == CapitalTypes.ownButConquered then
            buttoncolor = "#FF0000";
        else
            buttoncolor = "#36454F";
        end

        ---@type Button
        UIButton = UI.CreateButton(UIGroup);
        UIButton.SetColor(buttoncolor);
        UIButton.SetPreferredWidth(400);
        UIButton.SetText(game.Map.Territories[capital.TerritoryID].Name);
            UIButton.SetOnClick(function ()
                game.CreateLocatorCircle(game.Map.Territories[capital.TerritoryID].MiddlePointX, game.Map.Territories[capital.TerritoryID].MiddlePointY);
                game.HighlightTerritories({capital.TerritoryID});
            end
        )
    end
end

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    ---@type VerticalLayoutGroup
    local UIGroup = UI.CreateVerticalLayoutGroup(rootParent);

    ---@type Button
    local UISelectTerritoryButton = UI.CreateButton(UIGroup);

    UISelectTerritoryButton.SetText("Choose territory as capital location");
    if game.Game.TurnNumber ~= 1 or not Mod.Settings.PlayersChooseCapitalLocation then
        UISelectTerritoryButton.SetInteractable(false);
    else
        UISelectTerritoryButton.SetInteractable(true);
        ---@type Label
        local UIChosenTerritory = UI.CreateLabel(UIGroup);
        if Mod.PlayerGameData.CapitalLocation == nil then
            UIChosenTerritory.SetText("Chosen territory: None");
        else
            UIChosenTerritory.SetText("Chosen territory: " ..
                game.Map.Territories[Mod.PlayerGameData.CapitalLocation].Name);
        end
        UISelectTerritoryButton.SetOnClick(
            function()
                UISelectTerritoryButtonInteracted(game, close);
            end
        );
    end

    setMaxSize(425, 500);
    setScrollable(false, true);

    ---@type Label
    local UIYourCapitalsPretext = UI.CreateLabel(UIGroup);
    UIYourCapitalsPretext.SetText("Capitals owned by you");

    ---@type HorizontalLayoutGroup
    local UIYourCapitalsGroup = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UIYourCapitalsColor = UI.CreateLabel(UIYourCapitalsGroup);
    UIYourCapitalsColor.SetColor("#43C731");
    UIYourCapitalsColor.SetText("GREEN");
    
    ---@type Label
    local UIYourCapitalsText = UI.CreateLabel(UIYourCapitalsGroup);
    UIYourCapitalsText.SetText(" = your capital");

    ---@type HorizontalLayoutGroup
    local UIEnemyCapitalGroup = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UIEnemyCapitalColor = UI.CreateLabel(UIEnemyCapitalGroup);
    UIEnemyCapitalColor.SetColor("#FFC200");
    UIEnemyCapitalColor.SetText("YELLOW");

    ---@type Label
    local UIEnemyCapitalText = UI.CreateLabel(UIEnemyCapitalGroup);
    UIEnemyCapitalText.SetText(" = conquered enemy capitals");

    ---@type HorizontalLayoutGroup
    local UIConqueredCapitalGroup = UI.CreateHorizontalLayoutGroup(UIGroup);

    ---@type Label
    local UIConqueredCapitalColor = UI.CreateLabel(UIConqueredCapitalGroup);
    UIConqueredCapitalColor.SetColor("#FF0000");
    UIConqueredCapitalColor.SetText("RED");

    ---@type Label
    local UIConqueredCapitalText = UI.CreateLabel(UIConqueredCapitalGroup);
    UIConqueredCapitalText.SetText(" = your capital [conquered by another player]");

    ListOwnedCapitals(game, UIGroup);
end
