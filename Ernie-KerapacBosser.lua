local version = "2.0"
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
local superRestoreItems = { "Super restore (4)", "Super restore (3)", "Super restore (2)", "Super restore (1)", "Super restore flask (6)", "Super restore flask (5)", "Super restore flask (4)", "Super restore flask (3)", "Super restore flask (2)", "Super restore flask (1)" }
local overloadItems = {
"Overload (4)", "Overload (3)", "Overload (2)", "Overload (1)",
"Overload Flask (6)", "Overload Flask (5)", "Overload Flask (4)", "Overload Flask (3)", "Overload Flask (2)", "Overload Flask (1)",
"Holy overload (6)", "Holy overload (5)", "Holy overload (4)", "Holy overload (3)", "Holy overload (2)", "Holy overload (1)", 
"Searing overload (6)", "Searing overload (5)", "Searing overload (4)", "Searing overload (3)", "Searing overload (2)", "Searing overload (1)",
"Overload salve (6)", "Overload salve (5)", "Overload salve (4)", "Overload salve (3)", "Overload salve (2)", "Overload salve (1)",     
"Aggroverload (6)", "Aggroverload (5)", "Aggroverload (4)", "Aggroverload (3)", "Aggroverload (2)", "Aggroverload (1)",
"Holy aggroverload (6)", "Holy aggroverload (5)", "Holy aggroverload (4)", "Holy aggroverload (3)", "Holy aggroverload (2)", "Holy aggroverload (1)",
"Supreme overload salve (6)", "Supreme overload salve (5)", "Supreme overload salve (4)", "Supreme overload salve (3)", "Supreme overload salve (2)", "Supreme overload salve (1)",
"Elder overload potion (6)", "Elder overload potion (5)", "Elder overload potion (4)", "Elder overload potion (3)", "Elder overload potion (2)", "Elder overload potion (1)",
"Elder overload salve (6)", "Elder overload salve (5)", "Elder overload salve (4)", "Elder overload salve (3)", "Elder overload salve (2)", "Elder overload salve (1)"
}
local weaponPoisonItems = {}
local overloadBuff = {
    Overload = {
        buffId = 26093
    },
    ElderOverload = {
        buffId = 49039
    },
    SupremeOverload = {
        buffId = 33210
    }
}
local weaponPoisonBuff = 30095

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
local isPortalUsed = false
local playerPosition = nil
local centerOfArenaPosition = nil
local selectedPrayerType = nil
local selectedPassive = nil
local avoidLightningTicks = API.Get_tick()

local MARGIN = 100
local PADDING_Y = 6
local PADDING_X = 5
local LINE_HEIGHT = 12
local BOX_WIDTH = 280
local BOX_HEIGHT = 100
local BOX_START_Y = 200
local BOX_END_Y = BOX_START_Y + BOX_HEIGHT
local BOX_END_X = MARGIN + BOX_WIDTH + (2 * PADDING_X)

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

-- Calculate direction vector from one point to another
function CalculateDirectionVector(fromPoint, toPoint)
    return WPOINT.new(
        toPoint.x - fromPoint.x,
        toPoint.y - fromPoint.y,
        toPoint.z - fromPoint.z
    )
end

-- Calculate magnitude of a vector
function CalculateMagnitude(vector)
    return math.sqrt(
        vector.x * vector.x + 
        vector.y * vector.y + 
        vector.z * vector.z
    )
end

-- Normalize a vector (returns nil if magnitude is zero)
function NormalizeVector(vector)
    local magnitude = CalculateMagnitude(vector)
    
    -- Prevent division by zero
    if magnitude > 0 then
        return WPOINT.new(
            vector.x / magnitude,
            vector.y / magnitude,
            vector.z / magnitude
        )
    else
        return nil -- or you could return a zero vector depending on your needs
    end
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
    if API.GetHPrecent() < 70 and Inventory:ContainsAny(foodItems) and eatFoodAB ~= nil then
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
            sleepTickRandom(4)
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
        if state == bossStateEnum.LIGHTNING_ATTACK.name then
            API.DoAction_TileF(centerOfArenaPosition)
            print("Moved to center")
            sleepTickRandom(4)
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
    local guaranteedDrop = {51804, 51805}
    local lootPiles = API.GetAllObjArray1(guaranteedDrop, 20, {3})
    if #lootPiles > 0 then
        if not API.LootWindowOpen_2() then 
            print("Opening loot window")
            API.DoAction_G_Items1(0x2d, guaranteedDrop, 30)
            sleepTickRandom(1)
        end
        if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then 
            print("Looting")
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
    isPortalUsed = false
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
    isPrepared = true
end

function goThroughPortal()
    print("Go through portal")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 121019 }, 50)
    API.WaitUntilMovingEnds(20, 4)
    sleepTickRandom(2)
    local colosseum = API.GetAllObjArray1({120046}, 30, {12})
    if #colosseum > 0 then
        isPortalUsed = true
        print("At Colosseum")
    end
end

function goThroughGate()
    print("Click on Colosseum")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 120046 }, 50)
    sleepTickRandom(2)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 1591, 60, -1, API.OFF_ACT_GeneralInterface_route)
    sleepTickRandom(3)
    local gate = API.GetAllObjArray1({120047}, 30, {12})
    if #gate > 0 then
        isInArena = true
        print("In Colosseum")
    end
end

function startEncounter()
    print("Start encounter")
    playerPosition = API.PlayerCoord()
    centerOfArenaPosition = FFPOINT.new(playerPosition.x -7, playerPosition.y, 0)
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

function RoundVectorToInts(vector)
    return WPOINT.new(
        math.floor(vector.x + 0.5),
        math.floor(vector.y + 0.5),
        math.floor(vector.z + 0.5)
    )
end

function dodgeLightning()
    local findObjects = API.GetAllObjArray1({28071, 9216}, 60, {1})
    local boltsNearPlayer = {}
    for i = 1, #findObjects do
        if findObjects[i].Distance < 6 then
            table.insert(boltsNearPlayer, findObjects[i])
        end
    end
    if API.Get_tick() - avoidLightningTicks > 8 and #boltsNearPlayer > 0 then 
        local directionOfBolt = CalculateDirectionVector(boltsNearPlayer[1].Tile_XYZ, centerOfArenaPosition)
        local normalizedFFPOINT = NormalizeVector(directionOfBolt)
        local roundedFFPOINT = RoundVectorToInts(normalizedFFPOINT)
        local surgeAB = API.GetABs_name("Surge")
        local BDiveAB = API.GetABs_name("Bladed Dive")
        local DiveAB = API.GetABs_name("Dive")
        print("x: " .. roundedFFPOINT.x .. "y: " .. roundedFFPOINT.y)
        if (BDiveAB.cooldown_timer > 0 or DiveAB.cooldown_timer > 0) then
            API.DoAction_TileF(FFPOINT.new(boltsNearPlayer[1].Tile_XYZ.x + (roundedFFPOINT.x * -10), boltsNearPlayer[1].Tile_XYZ.y + (roundedFFPOINT.y * -10), 0))
            API.RandomSleep2(1, 120, 0)
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
        elseif not API.DoAction_Dive_Tile(WPOINT.new(boltsNearPlayer[1].Tile_XYZ.x + (roundedFFPOINT.x * -10), boltsNearPlayer[1].Tile_XYZ.y + (roundedFFPOINT.y * -10), 0)) then
            API.DoAction_BDive_Tile(WPOINT.new(boltsNearPlayer[1].Tile_XYZ.x + (roundedFFPOINT.x * -10), boltsNearPlayer[1].Tile_XYZ.y + (roundedFFPOINT.y * -10), 0))
        end  
        print("Dodged lightning")
        avoidLightningTicks = API.Get_tick()
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
            if isPrepared and not isPortalUsed then
               goThroughPortal() 
            end
            if isPortalUsed and not isInArena then
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
            dodgeLightning()
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
