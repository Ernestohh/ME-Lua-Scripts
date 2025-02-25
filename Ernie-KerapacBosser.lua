local version = "1"
local API = require("api")
API.SetDrawLogs(true)

local startScript = false
local currentTick = API.Get_tick()
local OBJECTS_table = API.ReadAllObjectsArray({-1}, {-1}, {})

local eatFoodAB = API.GetABs_name("Eat Food")
local drinkRestoreAB = API.GetABs_name("Super restore potion")

local prayerType = {
    Curses = { name = "Curses" },
    Prayers = { name = "Prayers" }
}

local overheadPrayersBuffs = {
    PrayMage = { name = "Protect from Magic", buffId = 25959, AB = API.GetABs_name("Protect from Magic") },
    PrayMelee = { name = "Protect from Melee", buffId = 25961, AB = API.GetABs_name("Protect from Melee") }
}

local overheadCursesBuffs = {
    PrayMage = { name = "Deflect Magic", buffId = 26041, AB = API.GetABs_name("Deflect Magic") },
    PrayMelee = { name = "Deflect Melee", buffId = 26040, AB = API.GetABs_name("Deflect Melee") }
}

local passiveBuffs = {
    Ruination = { name = "Ruination", buffId = 30769, AB = API.GetABs_name("Ruination"), type = prayerType.Curses.name },
    Sorrow = { name = "Sorrow", buffId = 30771, AB = API.GetABs_name("Sorrow"), type = prayerType.Curses.name },
    Turmoil = { name = "Turmoil", buffId = 26019, AB = API.GetABs_name("Turmoil"), type = prayerType.Curses.name },
    Malevolence = { name = "Malevolence", buffId = 29262, AB = API.GetABs_name("Malevolence"), type = prayerType.Curses.name },
    Anguish = { name = "Anguish", buffId = 26020, AB = API.GetABs_name("Anguish"), type = prayerType.Curses.name },
    Desolation = { name = "Desolation", buffId = 29263, AB = API.GetABs_name("Desolation"), type = prayerType.Curses.name },
    Torment = { name = "Torment", buffId = 26021, AB = API.GetABs_name("Torment"), type = prayerType.Curses.name },
    Affliction = { name = "Affliction", buffId = 29264, AB = API.GetABs_name("Affliction"), type = prayerType.Curses.name },
    Piety = { name = "Piety", buffId = 25973, AB = API.GetABs_name("Piety"), type = prayerType.Prayers.name },
    Rigour = { name = "Rigour", buffId = 25982, AB = API.GetABs_name("Rigour"), type = prayerType.Prayers.name },
    Augury = { name = "Augury", buffId = 25974, AB = API.GetABs_name("Augury"), type = prayerType.Prayers.name },
    Sanctity = { name = "Sanctity", buffId = 30925, AB = API.GetABs_name("Sanctity"), type = prayerType.Prayers.name }
}

local foodItems = { "Sailfish", "Rocktail", "Sailfish soup", "Desert sole", "Ghostly sole", "Beltfish", "Catfish" }
local superRestoreItems = { "Super restore potion (4)", "Super restore potion (3)", "Super restore potion (2)", "Super restore potion (1)", "Super restore flask (6)", "Super restore flask (5)", "Super restore flask (4)", "Super restore flask (3)", "Super restore flask (2)", "Super restore flask (1)" }

local bossStateEnum = {
    BASIC_ATTACK = { name = "BASIC_ATTACK", animations = { 34192 } },
    TEAR_RIFT_ATTACK_COMMENCE = { name = "TEAR_RIFT_ATTACK_COMMENCE", animations = { 34198 } },
    TEAR_RIFT_ATTACK_MOVE = { name = "TEAR_RIFT_ATTACK_MOVE", animations = { 34199 } },
    JUMP_ATTACK_COMMENCE = { name = "JUMP_ATTACK_COMMENCE", animations = { 34193 } },
    JUMP_ATTACK_IN_AIR = { name = "JUMP_ATTACK_IN_AIR", animations = { 34194 } },
    LIGHTNING_ATTACK = { name = "LIGHTNING_ATTACK", animations = { 34197 } }
}

local currentState = nil
local isRiftDodged = false
local isFightStarted = false
local isJumpDodged = true
local isInWarsRetreat = false
local isInBattle = false
local isTimeToLoot = false
local isPrepared = false
local isInArena = false
local isLooted = false
local playerPosition = nil
local selectedPrayerType = nil
local selectedPassive = nil

local MARGIN = 10
local PADDING_Y = 6
local PADDING_X = 5
local LINE_HEIGHT = 12
local BOX_WIDTH = 280
local BOX_HEIGHT = 100
local BOX_START_Y = 50
local BOX_END_Y = BOX_START_Y + BOX_HEIGHT
local BOX_END_X = MARGIN + BOX_WIDTH + (2 * PADDING_X)
local guiVisible = true

local GUI = {
    Background = API.CreateIG_answer(),
    PassivesDropdown = API.CreateIG_answer(),
    StartButton = API.CreateIG_answer()
}

GUI.Background.box_name = "GuiBackground"
GUI.Background.box_start = FFPOINT.new(MARGIN, BOX_START_Y, 0)
GUI.Background.box_size = FFPOINT.new(BOX_END_X, BOX_END_Y, 0)
GUI.Background.colour = ImColor.new(50, 48, 47)

GUI.PassivesDropdown.box_name = "Passives"
GUI.PassivesDropdown.box_start = FFPOINT.new(MARGIN + PADDING_X, BOX_START_Y + PADDING_Y, 0)
GUI.PassivesDropdown.stringsArr = {}

local sortedKeys = {}
for key in pairs(passiveBuffs) do
    table.insert(sortedKeys, key)
end
table.sort(sortedKeys)

for _, key in ipairs(sortedKeys) do
    table.insert(GUI.PassivesDropdown.stringsArr, passiveBuffs[key].name)
end

local BUTTON_WIDTH = 70
local BUTTON_HEIGHT = 25
local BUTTON_MARGIN = 8

GUI.StartButton.box_name = "Start"
GUI.StartButton.box_start = FFPOINT.new(MARGIN + PADDING_X, BOX_START_Y + BOX_HEIGHT - BUTTON_HEIGHT - PADDING_Y, 0)
GUI.StartButton.box_size = FFPOINT.new(BUTTON_WIDTH, BUTTON_HEIGHT, 0)
GUI.StartButton.colour = ImColor.new(0, 255, 0)
 
function GUI.HandleStartButton()
    if not startScript then
        if GUI.StartButton.return_click then
            GUI.StartButton.return_click = false
            startScript = true
            selectedPassive = GUI.PassivesDropdown.stringsArr[tonumber(GUI.PassivesDropdown.int_value) + 1]
            local prayerTypeFromSelectedPassive = passiveBuffs[selectedPassive]
            selectedPrayerType = prayerTypeFromSelectedPassive.type
            print("Script started")
            print("Selected Prayer Type: " .. (selectedPrayerType or "None"))
            print("Selected Passive: " .. (selectedPassive or "None"))
        end
    end
end

function GUI:HandleButtons()
    GUI.HandleStartButton()
end

function GUI.DrawButtons()
    API.DrawSquareFilled(GUI.Background)
    API.DrawComboBox(GUI.PassivesDropdown, false)
    API.DrawBox(GUI.StartButton)
end

function GUI:DrawGui()
    GUI:DrawButtons()
    GUI:HandleButtons()
end

function sleepTickRandom(sleepticks)
    API.Sleep_tick(sleepticks)
    API.RandomSleep2(1, 120, 0)
end

function stopScript()
    startScript = false
    API.Write_LoopyLoop(false)
end

function eatFood()
    if API.GetHPrecent() < 60 and Inventory:ContainsAny(foodItems) and eatFoodAB ~= nil then
        print("Yum yum")
        API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
        sleepTickRandom(1)
    end
end

function drinkRestore()
    if API.GetPrayPrecent() < 30 and Inventory:ContainsAny(superRestoreItems) and drinkRestoreAB ~= nil then
        print("Slurp")
        API.DoAction_Ability_Direct(drinkRestoreAB, 1, API.OFF_ACT_GeneralInterface_route)
        sleepTickRandom(1)
    end
end

function enablePassivePrayer()
    local selectedPassiveData = passiveBuffs[selectedPassive]
    if selectedPassiveData then
        local buffId = selectedPassiveData.buffId
        local ability = selectedPassiveData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 and API.GetPrayPrecent() > 0 then
            print("Activate " .. selectedPassive)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        print("No valid passive prayer selected or data not found.")
    end
end

function enableMagePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        print("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMage
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            print("Activate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        print("No valid overhead prayer selected or data not found.")
    end
end

function enableMeleePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        print("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMelee
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            print("Activate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        print("No valid overhead prayer selected or data not found.")
    end
end

function disableMagePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        print("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMage
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            print("Deactivate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        print("No valid overhead prayer selected or data not found.")
    end
end

function disablePassivePrayer()
    local selectedPassiveData = passiveBuffs[selectedPassive]
    if selectedPassiveData then
        local buffId = selectedPassiveData.buffId
        local ability = selectedPassiveData.AB
        if API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            print("Deactivate " .. selectedPassive)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        print("No valid passive prayer selected or data not found.")
    end
end

function getKerapacInformation()
    return API.FindNPCbyName("Kerapac, the bound", 30)
end

function getKerapacAnimation()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo then
        return kerapacInfo.Anim
    end
    return nil
end

function getKerapacPositionFFPOINT()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo then
        return FFPOINT.new(kerapacInfo.Tile_XYZ.x, kerapacInfo.Tile_XYZ.y, 0)
    end
    return nil
end

function getKerapacLife()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo then
        return kerapacInfo.Life
    end
    return nil
end

function getBossStateFromAnimation(animation)
    for state, data in pairs(bossStateEnum) do
        for _, animValue in ipairs(data.animations) do
            if animValue == animation then
                return state
            end
        end
    end
    return nil
end

function handleStateChange(currentAnimation)
    local newState = getBossStateFromAnimation(currentAnimation)
    if newState == nil then
        return
    end
    if newState ~= currentState then
        print("State changed to: " .. bossStateEnum[newState].name)
        currentState = newState
        handleCombat(newState)
    end
end

function handleCombat(state)
    if (isFightStarted) then
        if state == bossStateEnum.TEAR_RIFT_ATTACK_COMMENCE.name and not isRiftDodged then
            API.DoAction_TileF(getKerapacPositionFFPOINT())
            isRiftDodged = true
            print("Moved player under Kerapac")
        end
        if state == bossStateEnum.TEAR_RIFT_ATTACK_MOVE.name and isRiftDodged then
            API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
            isRiftDodged = false
            print("Attacking Kerapac")
        end
        if state == bossStateEnum.JUMP_ATTACK_COMMENCE.name and isJumpDodged then
            isJumpDodged = false
            API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
            enableMeleePray()
            print("Preparing for jump attack")
        end
        if state == bossStateEnum.JUMP_ATTACK_IN_AIR.name and not isJumpDodged then
            isJumpDodged = true
            API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
            sleepTickRandom(1)
            local surgeAB = API.GetABs_name("Surge")
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(1)
            API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
            print("Dodge jump attack")
            sleepTickRandom(2)
            enableMagePray()
        end
    end
end

function handleBossDeath()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo.Life <= 0 then
        print("Kerapac is dead")
        disableMagePray()
        disablePassivePrayer()
        isInBattle = false
        isTimeToLoot = true
        API.DoAction_TileF(FFPOINT.new(playerPosition.x + 6, playerPosition.y, 0))
        API.WaitUntilMovingEnds(20, 4)
        sleepTickRandom(2)
    end
end

function handleBossLoot()
    local lootPiles = API.GetAllObjArray1({51804}, 20, {3})
    if #lootPiles > 0 then
        if not API.LootWindowOpen_2() then 
            API.KeyboardPress("/", 0, 50)
            sleepTickRandom(1)
        end
        if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then 
            print("looting")
            sleepTickRandom(3)
            API.DoAction_LootAll_Button()
            isLooted = true
        end
        sleepTickRandom(1)
    end
end

function handleBossReset()
    isFightStarted = false
    isRiftDodged = false
    isJumpDodged = true
    isInBattle = false
    isTimeToLoot = false
    isInWarsRetreat = false
    isPrepared = false
    isInArena = false
    isLooted = false
end

function checkStartLocation()
    if not (API.Dist_FLP(FFPOINT.new(3299, 10131, 0)) < 30) then
        print("Teleport to War's")
        warsTeleport()
    else
        print("Already in War's")
        isInWarsRetreat = true
        sleepTickRandom(2)
    end
end

function warsTeleport()
    API.DoAction_Ability("War's Retreat", 1, API.OFF_ACT_GeneralInterface_route, false)
    sleepTickRandom(10)
end

function prepareForBattle()
    print("Restoring prayer at Altar of War")
    API.DoAction_Object1(0x3d, API.OFF_ACT_GeneralObject_route0, { 114748 }, 50)
    API.WaitUntilMovingEnds(10, 4)
    print("Withdraw last quick preset")
    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { 114750 }, 50)
    API.WaitUntilMovingEnds(10, 4)
    if not Inventory:ContainsAny(foodItems) then
        print("No food items in inventory")
        stopScript()
    end
    if not Inventory:ContainsAny(superRestoreItems) then
        print("No super restores in inventory")
        stopScript()
    end
    print("Go through portal")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 121019 }, 50)
    API.WaitUntilMovingEnds(20, 4)
    if API.FindObject_string({ "Colosseum gateway" }) then
        isPrepared = true
        print("At Colosseum")
    end
end

function goThroughGate()
    print("Click on Colosseum")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 120046 }, 50)
    sleepTickRandom(2)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 1591, 60, -1, API.OFF_ACT_GeneralInterface_route)
    sleepTickRandom(3)
    if API.FindObject_string({ "Gate" }) then
        isInArena = true
        print("In Colosseum")
    end
end

function startEncounter()
    print("Start encounter")
    playerPosition = API.PlayerCoord()
    print("Reset compass")
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1919, 2, -1, API.OFF_ACT_GeneralInterface_route)
    sleepTickRandom(1)
    print("Move to spot")
    API.DoAction_TileF(FFPOINT.new(API.PlayerCoord().x - 25, API.PlayerCoord().y, 0))
    API.WaitUntilMovingEnds(20, 4)
end

function playerDied()
    if API.GetHPrecent() <= 0 then
        print("You died")
        stopScript()
    end
end

function checkKerapacExists()
    if getKerapacInformation().Action == "Attack" then
        isInBattle = true
        isFightStarted = true
        API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
        enableMagePray()
        print("Fight started")
    end
end

API.logWarn("Started Ernie's Kerapac Bosser " .. version)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    GUI:DrawGui()
    if startScript then
        if not isInBattle and not isTimeToLoot then
            if not isInWarsRetreat then
                checkStartLocation()
            end
            if isInWarsRetreat and not isPrepared then
                prepareForBattle()
            end
            if isPrepared and not isInArena then
                goThroughGate() 
            end
            if isInArena then
                startEncounter()
                checkKerapacExists()
            end
        elseif isInBattle then
            enablePassivePrayer()
            eatFood()
            drinkRestore()
            playerDied()
            handleStateChange(getKerapacAnimation())
            handleBossDeath()
        elseif isTimeToLoot and not isLooted then
            handleBossLoot()
        elseif isLooted then
            handleBossReset()
        end
    end
end
API.logWarn("Stopped Ernie's Kerapac Bosser " .. version)