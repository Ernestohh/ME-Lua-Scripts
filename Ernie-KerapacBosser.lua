local version = "3.9"
local API = require("api")
API.SetDrawLogs(true)

local startScript = false
local currentTick = API.Get_tick()
local OBJECTS_table = API.ReadAllObjectsArray({-1}, {-1}, {})

local extraAbilities = {
    devotionAbility = {name = "Devotion", buffId = 21665, AB = API.GetABs_name("Devotion"), threshold = 50},
    debilitateAbility = {name = "Debilitate", debuffId = 14226, AB = API.GetABs_name("Debilitate"), threshold = 50},
    darknessAbility = {name = "Darkness", buffId = 30122, AB = API.GetABs_name("Darkness"), threshold = 0},
    invokeDeathAbility = {name = "Invoke Death", debuffId = 30100, AB = API.GetABs_name("Invoke Death"), threshold = 0}
}


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
    Sanctity = { name = "Sanctity", buffId = 30925, AB = API.GetABs_name("Sanctity"), type = prayerType.Prayers.name },
    None = {name = "None", buffId = nil, AB = nil, type = nil} 
}

local foodItems={"Lobster","Swordfish","Desert sole","Catfish","Monkfish","Beltfish","Ghostly sole","Cooked eeligator","Shark","Sea turtle","Great white shark","Cavefish","Manta ray","Rocktail","Tiger shark","Sailfish","Green blubber jellyfish","Blue blubber jellyfish","2/3 green blubber jellyfish","2/3 blue blubber jellyfish","1/3 green blubber jellyfish","1/3 blue blubber jellyfish","Potato with cheese","Tuna potato","Baron shark","Juju gumbo","Great maki","Great gunkan","Rocktail soup","Sailfish soup","Fury shark","Primal feast"}
local prayerRestoreItems={"Super restore (4)","Super restore (3)","Super restore (2)","Super restore (1)","Super restore flask (6)","Super restore flask (5)","Super restore flask (4)","Super restore flask (3)","Super restore flask (2)","Super restore flask (1)","Prayer potion (1)","Prayer potion (2)","Prayer potion (3)","Prayer potion (4)","Prayer flask (1)","Prayer flask (2)","Prayer flask (3)","Prayer flask (4)","Prayer flask (5)","Prayer flask (6)","Super prayer (1)","Super prayer (2)","Super prayer (3)","Super prayer (4)","Super prayer flask (1)","Super prayer flask (2)","Super prayer flask (3)","Super prayer flask (4)","Super prayer flask (5)","Super prayer flask (6)","Extreme prayer (1)","Extreme prayer (2)","Extreme prayer (3)","Extreme prayer (4)","Extreme prayer flask (1)","Extreme prayer flask (2)","Extreme prayer flask (3)","Extreme prayer flask (4)","Extreme prayer flask (5)","Extreme prayer flask (6)"}
local overloadItems={"Overload (4)","Overload (3)","Overload (2)","Overload (1)","Overload Flask (6)","Overload Flask (5)","Overload Flask (4)","Overload Flask (3)","Overload Flask (2)","Overload Flask (1)","Holy overload (6)","Holy overload (5)","Holy overload (4)","Holy overload (3)","Holy overload (2)","Holy overload (1)","Searing overload (6)","Searing overload (5)","Searing overload (4)","Searing overload (3)","Searing overload (2)","Searing overload (1)","Overload salve (6)","Overload salve (5)","Overload salve (4)","Overload salve (3)","Overload salve (2)","Overload salve (1)","Aggroverload (6)","Aggroverload (5)","Aggroverload (4)","Aggroverload (3)","Aggroverload (2)","Aggroverload (1)","Holy aggroverload (6)","Holy aggroverload (5)","Holy aggroverload (4)","Holy aggroverload (3)","Holy aggroverload (2)","Holy aggroverload (1)","Supreme overload salve (6)","Supreme overload salve (5)","Supreme overload salve (4)","Supreme overload salve (3)","Supreme overload salve (2)","Supreme overload salve (1)","Elder overload potion (6)","Elder overload potion (5)","Elder overload potion (4)","Elder overload potion (3)","Elder overload potion (2)","Elder overload potion (1)","Elder overload salve (6)","Elder overload salve (5)","Elder overload salve (4)","Elder overload salve (3)","Elder overload salve (2)","Elder overload salve (1)","Supreme overload potion (1)","Supreme overload potion (2)","Supreme overload potion (3)","Supreme overload potion (4)","Supreme overload potion (5)","Supreme overload potion (6)"}
local weaponPoisonItems={"Weapon poison (1)","Weapon poison (2)","Weapon poison (3)","Weapon poison (4)","Weapon poison+ (1)","Weapon poison+ (2)","Weapon poison+ (3)","Weapon poison+ (4)","Weapon poison++ (1)","Weapon poison++ (2)","Weapon poison++ (3)","Weapon poison++ (4)","Weapon poison+++ (1)","Weapon poison+++ (2)","Weapon poison+++ (3)","Weapon poison+++ (4)","Weapon poison flask (1)","Weapon poison flask (2)","Weapon poison flask (3)","Weapon poison flask (4)","Weapon poison flask (5)","Weapon poison flask (6)","Weapon poison+ flask (1)","Weapon poison+ flask (2)","Weapon poison+ flask (3)","Weapon poison+ flask (4)","Weapon poison+ flask (5)","Weapon poison+ flask (6)","Weapon poison++ flask (1)","Weapon poison++ flask (2)","Weapon poison++ flask (3)","Weapon poison++ flask (4)","Weapon poison++ flask (5)","Weapon poison++ flask (6)","Weapon poison+++ flask (1)","Weapon poison+++ flask (2)","Weapon poison+++ flask (3)","Weapon poison+++ flask (4)","Weapon poison+++ flask (5)","Weapon poison+++ flask (6)"}
local summoningPouches ={"Blood nihil pouch", "Ice nihil pouch", "Shadow nihil pouch", "Smoke nihil pouch", "Binding contract (ripper demon)", "Binding contract (kal'gerion demon)", "Binding contract (blood reaver)", "Binding contract (hellhound)"}

local sortedFoods = {}
for _, v in ipairs(foodItems) do
    table.insert(sortedFoods, v)
end
table.sort(sortedFoods)

local sortedRestore = {}
for _, v in ipairs(prayerRestoreItems) do
    table.insert(sortedRestore, v)
end
table.sort(sortedRestore)

local sortedOverload = {}
for _, v in ipairs(overloadItems) do
    table.insert(sortedOverload, v)
end
table.sort(sortedOverload)

local sortedWeaponPoison = {}
for _, v in ipairs(weaponPoisonItems) do
    table.insert(sortedWeaponPoison, v)
end
table.sort(sortedWeaponPoison)

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
    JUMP_ATTACK_LANDED = {name = "JUMP_ATTACK_LANDED", animations = {34195}},
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
local isPhasing = false
local isMovedToCenter = false
local hasOverload = false
local hasWeaponPoison = false
local hasDebilitate = false
local hasDevotion = false
local hasDarkness = false
local hasInvokeDeath = false
local playerPosition = nil
local startLocationOfArena = nil
local centerOfArenaPosition = nil
local selectedPrayerType = API.VB_FindPSettinOrder(3277, 0).state & 1
local selectedPassive = nil
local kerapacPhase = 1
local avoidLightningTicks = API.Get_tick()
local eatFoodTicks = API.Get_tick()
local drinkRestoreTicks = API.Get_tick()
local buffCheckCooldown = API.Get_tick()
local checkPlayerCooldown = API.Get_tick()
local hpThreshold= 70
local prayerThreshold = 30
local distanceThreshold = 5
local dodgeCooldown = 6
local foodCooldown = 3
local drinkCooldown = 3
local phaseTransitionThreshold = 50000
local lootPosition = 5
local dodgeDistance = -10 

local MARGIN = 100
local PADDING_Y = 6
local PADDING_X = 5
local LINE_HEIGHT = 12
local BOX_WIDTH = 280
local BOX_HEIGHT = 100
local BOX_START_Y = 200
local BOX_END_Y = BOX_START_Y + BOX_HEIGHT
local BOX_END_X = MARGIN + BOX_WIDTH + (2 * PADDING_X)
local BUTTON_WIDTH = 70
local BUTTON_HEIGHT = 25
local BUTTON_MARGIN = 8

local Background = API.CreateIG_answer()
Background.box_name = "GuiBackground"
Background.box_start = FFPOINT.new(MARGIN, BOX_START_Y, 0)
Background.box_size = FFPOINT.new(BOX_END_X, BOX_END_Y, 0)
Background.colour = ImColor.new(50, 48, 47)

local PassivesDropdown = API.CreateIG_answer()
PassivesDropdown.box_name = "Passives"
PassivesDropdown.box_start = FFPOINT.new(MARGIN + PADDING_X, BOX_START_Y + PADDING_Y, 0)
PassivesDropdown.stringsArr = {}

local StartButton = API.CreateIG_answer()
StartButton.box_name = "Start"
StartButton.box_start = FFPOINT.new(MARGIN + PADDING_X, BOX_START_Y + BOX_HEIGHT - BUTTON_HEIGHT - PADDING_Y, 0)
StartButton.box_size = FFPOINT.new(BUTTON_WIDTH, BUTTON_HEIGHT, 0)
StartButton.colour = ImColor.new(0, 255, 0)

local sortedKeys = {}
for key in pairs(passiveBuffs) do
    table.insert(sortedKeys, key)
end
table.sort(sortedKeys)

for _, key in ipairs(sortedKeys) do
    table.insert(PassivesDropdown.stringsArr, passiveBuffs[key].name)
end

local function log(message, level)
    level = level or "INFO"
    print(string.format("[%s] %s",level, message))
end

local function sleepTickRandom(sleepticks)
    API.Sleep_tick(sleepticks)
    API.RandomSleep2(1, 120, 0)
end

local function stopScript()
    log("Stopping script", "WARN")
    startScript = false
    API.Write_LoopyLoop(false)
end

local function getKerapacInformation()
    return API.FindNPCbyName("Kerapac, the bound", 30)
end

local function getKerapacAnimation()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo then
        return kerapacInfo.Anim
    end
    return nil
end

local function getKerapacPositionFFPOINT()
    local kerapacInfo = getKerapacInformation()
    if kerapacInfo then
        return FFPOINT.new(kerapacInfo.Tile_XYZ.x, kerapacInfo.Tile_XYZ.y, 0)
    end
    return nil
end

local function hasMarkOfDeath()
    return (API.VB_FindPSett(11303).state >> 7 & 0x1) == 1
end

local function hasDeathInvocation()
    return API.Buffbar_GetIDstatus(30100).id > 0
end

local function getBossStateFromAnimation(animation)
    if not animation then return nil end
    for state, data in pairs(bossStateEnum) do
        for _, animValue in ipairs(data.animations) do
            if animValue == animation then
                return state
            end
        end
    end
    return nil
end

local function whichFood()
    local food = ""
    local foundFood = false
    for i = 1, #sortedFoods do
        foundFood = Inventory:Contains(sortedFoods[i])
        if foundFood then
            food = sortedFoods[i]
            break
        end
    end
    return food
end

local function whichPrayerRestore()
    local prayerRestore = ""
    local foundPrayerRestore = false
    for i = 1, #sortedRestore do
        foundPrayerRestore = Inventory:Contains(sortedRestore[i])
        if foundPrayerRestore then
            prayerRestore = sortedRestore[i]
            break
        end
    end
    return prayerRestore
end

local function whichOverload()
    local overload = ""
    local foundOverload = false
    for i = 1, #sortedOverload do
        foundOverload = Inventory:Contains(sortedOverload[i])
        if foundOverload then
            overload = sortedOverload[i]
            break
        end
    end
    return overload
end

local function whichWeaponPoison()
    local weaponPoison = ""
    local foundWeaponPoison = false
    for i = 1, #sortedWeaponPoison do
        foundWeaponPoison = Inventory:Contains(sortedWeaponPoison[i])
        if foundWeaponPoison then
            weaponPoison = sortedWeaponPoison[i]
            break
        end
    end
    return weaponPoison
end

local function checkAvailableBuffs()
    local darknessOnBar = false
    local invokeDeathOnBar = false
    hasOverload = whichOverload() ~= ""
    hasWeaponPoison = whichWeaponPoison() ~= ""
    hasDebilitate = extraAbilities.debilitateAbility.AB.slot ~= 0
    hasDevotion = extraAbilities.devotionAbility.AB.slot ~= 0
    darknessOnBar = extraAbilities.darknessAbility.AB.slot ~= 0
    if darknessOnBar then
        hasDarkness = extraAbilities.darknessAbility.AB.enabled
    end
    invokeDeathOnBar = extraAbilities.invokeDeathAbility.AB.slot ~= 0
    if invokeDeathOnBar then
        hasInvokeDeath = extraAbilities.invokeDeathAbility.AB.enabled
    end
end

local function enableMagePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        log("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMage
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            log("Activate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
        end
    else
        log("No valid overhead prayer selected or data not found.")
    end
end

local function enableMeleePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        log("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMelee
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            log("Activate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
        end
    else
        log("No valid overhead prayer selected or data not found.")
    end
end

local function disableMagePray()
    local overheadTable = nil
    if selectedPrayerType == "Prayers" then
        overheadTable = overheadPrayersBuffs
    elseif selectedPrayerType == "Curses" then
        overheadTable = overheadCursesBuffs
    else
        log("Invalid prayer type selected.")
        return
    end
    local selectedOverheadData = overheadTable.PrayMage
    if selectedOverheadData then
        local buffId = selectedOverheadData.buffId
        local ability = selectedOverheadData.AB
        if API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            log("Deactivate " .. selectedOverheadData.name)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
        end
    else
        log("No valid overhead prayer selected or data not found.")
    end
end

local function enablePassivePrayer()
    if selectedPassive == passiveBuffs.None.name then
        return
    end
    local selectedPassiveData = passiveBuffs[selectedPassive]
    if selectedPassiveData then
        local buffId = selectedPassiveData.buffId
        local ability = selectedPassiveData.AB
        if not API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 and API.GetPrayPrecent() > 0 then
            log("Activate " .. selectedPassive)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        log("No valid passive prayer selected or data not found.")
    end
end

local function disablePassivePrayer()
    local selectedPassiveData = passiveBuffs[selectedPassive]
    if selectedPassiveData then
        local buffId = selectedPassiveData.buffId
        local ability = selectedPassiveData.AB
        if API.Buffbar_GetIDstatus(buffId).found and ability.id ~= 0 then
            log("Deactivate " .. selectedPassive)
            API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(2)
        end
    else
        log("No valid passive prayer selected or data not found.")
    end
end

local function useDarkness()
    if extraAbilities.darknessAbility.AB.id > 0 and
        extraAbilities.darknessAbility.AB.enabled and 
        not API.Buffbar_GetIDstatus(extraAbilities.darknessAbility.buffId).found then
        API.DoAction_Ability_check(extraAbilities.darknessAbility.name, 1, API.OFF_ACT_GeneralInterface_route, true, true, true)
        log("Concealing myself in the shadows")
        sleepTickRandom(2)
    end
end

local function useInvokeDeath()
    if  hasInvokeDeath and
        not hasMarkOfDeath() and
        not hasDeathInvocation() and 
        getKerapacInformation().Life > 15000 then
        API.DoAction_Ability_check(extraAbilities.invokeDeathAbility.name, 1, API.OFF_ACT_GeneralInterface_route, true, true, true)
        log("Die die die")
        sleepTickRandom(2)
    end
end

local function useDevotionAbility()
    if  hasDevotion and
        API.GetAdrenalineFromInterface() > extraAbilities.devotionAbility.threshold and 
        not API.Buffbar_GetIDstatus(extraAbilities.devotionAbility.buffId).found then
            if API.DoAction_Ability_check(extraAbilities.devotionAbility.name, 1, API.OFF_ACT_GeneralInterface_route, true, true, true) then
                log("Please protect me")
            end
        sleepTickRandom(2)
    end
end

local function useDebilitateAbility()
    if  hasDebilitate and
        API.GetAdrenalineFromInterface() > extraAbilities.debilitateAbility.threshold then
        local hasDebilitateDebuff = false
        for _,value in ipairs(API.ReadTargetInfo(true).Buff_stack) do
            if value == extraAbilities.debilitateAbility.debuffId then
                hasDebilitateDebuff = true
            end
        end
        if not hasDebilitateDebuff then
            if API.DoAction_Ability_check(extraAbilities.debilitateAbility.name, 1, API.OFF_ACT_GeneralInterface_route, true, true, true) then
                log("Kick in the nuts for more defense")
            end
            sleepTickRandom(2)
        end
    end
end

local function eatFood()
    if not Inventory:ContainsAny(foodItems) or 
    API.GetHPrecent() >= hpThreshold or 
    API.Get_tick() - eatFoodTicks <= foodCooldown then return end
    Inventory:Eat(whichFood())
    log("Eating some food")
    eatFoodTicks = API.Get_tick()
end

local function drinkPrayer()
    if not Inventory:ContainsAny(prayerRestoreItems) or 
    API.GetPrayPrecent() >= prayerThreshold or 
    API.Get_tick() - drinkRestoreTicks <= drinkCooldown then return end
    Inventory:Eat(whichPrayerRestore())
    log("Slurping on a prayer potion")
    drinkRestoreTicks = API.Get_tick()
end

local function drinkOverload()
    if not Inventory:ContainsAny(overloadItems) or 
    API.Buffbar_GetIDstatus(overloadBuff.ElderOverload.buffId).found or 
    API.Buffbar_GetIDstatus(overloadBuff.Overload.buffId).found or
    API.Buffbar_GetIDstatus(overloadBuff.SupremeOverload.buffId).found or
    API.Get_tick() - drinkRestoreTicks <= drinkCooldown then return end
    Inventory:Eat(whichOverload())
    log("Slurping an overload")
    drinkRestoreTicks = API.Get_tick()
end

local function drinkWeaponPoison()
    if not Inventory:ContainsAny(weaponPoisonItems) or 
    API.Buffbar_GetIDstatus(weaponPoisonBuff).found or
    API.Get_tick() - drinkRestoreTicks <= drinkCooldown then return end
    Inventory:DoAction(whichWeaponPoison(), 1, API.OFF_ACT_GeneralInterface_route)
    log("Slurping a weapon poison")
    drinkRestoreTicks = API.Get_tick()
end

local function warsTeleport()
    API.DoAction_Ability("War's Retreat", 1, API.OFF_ACT_GeneralInterface_route, false)
    sleepTickRandom(10)
end

local function checkStartLocation()
    if not (API.Dist_FLP(FFPOINT.new(3299, 10131, 0)) < 30) then
        log("Teleport to War's")
        warsTeleport()
    else
        log("Already in War's")
        isInWarsRetreat = true
        sleepTickRandom(2)
    end
end

local function attackKerapac()
    API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { getKerapacInformation().Id }, 50)
end

local function playerDied()
    if API.GetHPrecent() <= 0 then
        log("You died", "WARN")
        stopScript()
    end
end

local function prepareForBattle()
    log("Restoring prayer at Altar of War")
    API.DoAction_Object1(0x3d, API.OFF_ACT_GeneralObject_route0, { 114748 }, 50)
    API.WaitUntilMovingEnds(10, 4)
    log("Withdraw last quick preset")
    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, { 114750 }, 50)
    API.WaitUntilMovingEnds(10, 4)
    checkAvailableBuffs()
    sleepTickRandom(1)
    log(string.format("Do we have the following buffs: \nOverloads: %s\nWeaponPoison %s\nDebilitate %s\nDevotion %s\nDarkness %s\nInvoke Death %s",
        hasOverload, hasWeaponPoison, hasDebilitate, hasDevotion, hasDarkness, hasInvokeDeath))
    if not Inventory:ContainsAny(foodItems) then
        log("No food items in inventory", "WARN")
        stopScript()
    end
    isPrepared = true
end

local function goThroughPortal()
    log("Go through portal")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 121019 }, 50)
    API.WaitUntilMovingEnds(20, 4)
    sleepTickRandom(2)
    local colosseum = API.GetAllObjArray1({120046}, 30, {12})
    if #colosseum > 0 then
        isPortalUsed = true
        log("At Colosseum")
    end
end

local function goThroughGate()
    log("Click on Colosseum")
    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 120046 }, 50)
    sleepTickRandom(2)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 1591, 60, -1, API.OFF_ACT_GeneralInterface_route)
    sleepTickRandom(3)
    local gate = API.GetAllObjArray1({120047}, 30, {12})
    if #gate > 0 then
        isInArena = true
        log("In Colosseum")
    end
end

local function startEncounter()
    log("Start encounter")
    playerPosition = API.PlayerCoord()
    centerOfArenaPosition = FFPOINT.new(playerPosition.x -7, playerPosition.y, 0)
    startLocationOfArena = FFPOINT.new(API.PlayerCoord().x - 25, API.PlayerCoord().y, 0)
    log("Reset compass")
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1919, 2, -1, API.OFF_ACT_GeneralInterface_route)
    sleepTickRandom(1)
    log("Move to spot")
    API.DoAction_TileF(startLocationOfArena)
    API.WaitUntilMovingEnds(20, 4)
end

local function checkKerapacExists()
    if getKerapacInformation().Action == "Attack" then
        isInBattle = true
        isFightStarted = true
        attackKerapac()
        enableMagePray()
        log("Fight started")
    end
end

local function startPhaseTransition()
    kerapacPhase = kerapacPhase + 1
    LightningDodge.resetPhase(kerapacPhase)
    isPhasing = true
    log("Entering Phase " .. kerapacPhase)
end

local function endPhaseTransition()
    attackKerapac()
    isPhasing = false
    log("Resuming battle")
end

local function handlePhaseTransitions(bossLife)
    if bossLife <= phaseTransitionThreshold and kerapacPhase < 4 and not isPhasing then
        startPhaseTransition()
    elseif bossLife > phaseTransitionThreshold and isPhasing then
        endPhaseTransition()
    end
end

local function handleBossLoot()
    local guaranteedDrop = {51804, 51805}
    local lootPiles = API.GetAllObjArray1(guaranteedDrop, 20, {3})
    if #lootPiles > 0 then
        if not API.LootWindowOpen_2() then 
            log("Opening loot window")
            API.DoAction_G_Items1(0x2d, guaranteedDrop, 30)
            sleepTickRandom(3)
        end
        if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) and not isLooted then 
            local lootInterface = API.ScanForInterfaceTest2Get(true, { { 1622,4,-1,0 }, { 1622,6,-1,0 }, { 1622,1,-1,0 }, { 1622,11,-1,0 } })
            local lootInWindow = {}
            for _,value in ipairs(lootInterface) do
                if value.itemid1 ~= -1 then
                    table.insert(lootInWindow, value.itemid1)
                end
            end
            local inventorySlotsRemaining = Inventory:FreeSpaces() - #lootInWindow
            sleepTickRandom(2)
            if inventorySlotsRemaining < 0 then
                local slotsNeeded = -inventorySlotsRemaining
                log("Need to free " .. slotsNeeded .. " slots to collect all loot")
                for i = 1, slotsNeeded do
                    local foodItem = whichFood()
                    if foodItem ~= "" then
                        log("Eating " .. foodItem .. " to make room for loot (" .. slotsNeeded .. ")")
                        Inventory:Eat(foodItem)
                        sleepTickRandom(3)
                    else
                        log("No more food items to drop, can't collect all loot")
                        break
                    end
                end
            else
                log("Get loot")
                API.DoAction_LootAll_Button()
                isLooted = true
            end
        end
        sleepTickRandom(1)
    end
end
local function handleBossDeath()
    disableMagePray()
    disablePassivePrayer()
    isInBattle = false
    isTimeToLoot = true
    if playerPosition then
        local lootPosition = FFPOINT.new(playerPosition.x + lootPosition, playerPosition.y, 0)
        API.DoAction_TileF(lootPosition)
        log("Moving to loot")
        API.WaitUntilMovingEnds(20, 4)
    end
end

local function handleBossPhase()
    local kerapacInfo = getKerapacInformation()
    if not kerapacInfo then
        log("Kerapac information not available")
        return
    end
    if kerapacInfo.Life <= 0 then
        log("Preparing to loot")
        handleBossDeath()
        return
    end
    handlePhaseTransitions(kerapacInfo.Life)
end

local function handleBossReset()
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
    isPhasing = false
    isMovedToCenter = false
    hasOverload = false
    hasWeaponPoison = false
    hasDebilitate = false
    hasDevotion = false
    hasDarkness = false
    hasInvokeDeath = false
    kerapacPhase = 1
    log("Let's go again")
end

local function handleCombat(state)
    if (isFightStarted) then
        if state == bossStateEnum.TEAR_RIFT_ATTACK_COMMENCE.name and not isRiftDodged then
            API.DoAction_TileF(getKerapacPositionFFPOINT())
            isRiftDodged = true
            log("Moved player under Kerapac")
        end
        if state == bossStateEnum.TEAR_RIFT_ATTACK_MOVE.name and isRiftDodged then
            attackKerapac()
            isRiftDodged = false
            log("Attacking Kerapac")
        end
        if state == bossStateEnum.JUMP_ATTACK_COMMENCE.name and isJumpDodged then
            isJumpDodged = false
            attackKerapac()
            log("Preparing for jump attack")
            enableMeleePray()
        end
        if state == bossStateEnum.JUMP_ATTACK_IN_AIR.name and not isJumpDodged then
            isJumpDodged = true
            attackKerapac()
            sleepTickRandom(1)
            local surgeAB = API.GetABs_name("Surge")
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(1)
            attackKerapac()
            log("Dodge jump attack")
            enableMagePray()
        end
        if state == bossStateEnum.JUMP_ATTACK_LANDED.name and getKerapacInformation().Distance < 4 then
            API.DoAction_TileF(centerOfArenaPosition)
            sleepTickRandom(1)
            local surgeAB = API.GetABs_name("Surge")
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
            sleepTickRandom(1)
            attackKerapac()
        end
        if state == bossStateEnum.LIGHTNING_ATTACK.name then
            --IMPLEMENT
        end
    end
end


local function dodgeLightning2()
    local allLightningObjects = API.GetAllObjArray1({28071, 9216}, 60, {1})
    local inDanger = false
    local closestBolt = nil
    local minDistance = 30
    
    for i = 1, #allLightningObjects do
        if allLightningObjects[i].Distance < distanceThreshold then
            inDanger = true
            if allLightningObjects[i].Distance < minDistance then
                minDistance = allLightningObjects[i].Distance
                closestBolt = allLightningObjects[i]
            end
        end
    end

    if inDanger and API.Get_tick() - avoidLightningTicks > dodgeCooldown and closestBolt then
        local playerPosition = API.PlayerCoord()
        local dirX = playerPosition.x - closestBolt.Tile_XYZ.x
        local dirY = playerPosition.y - closestBolt.Tile_XYZ.y
        local length = math.sqrt(dirX*dirX + dirY*dirY)
        if length > 0 then
            dirX = dirX / length
            dirY = dirY / length
        else
            dirX = 1
            dirY = 0
        end
        
        local safeWPOINT = WPOINT.new(
            playerPosition.x + (dirX * dodgeDistance),
            playerPosition.y + (dirY * dodgeDistance),
            playerPosition.z
        )
        
        local safeFFPOINT = FFPOINT.new(safeWPOINT.x, safeWPOINT.y, 0)
        local surgeAB = API.GetABs_name("Surge")
        local BDiveAB = API.GetABs_name("Bladed Dive")
        local DiveAB = API.GetABs_name("Dive")
        
        if (BDiveAB.cooldown_timer > 0 or DiveAB.cooldown_timer > 0) then
            API.DoAction_TileF(safeFFPOINT)
            API.RandomSleep2(1, 120, 0)
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
        elseif not API.DoAction_Dive_Tile(safeWPOINT) then
            API.DoAction_BDive_Tile(safeWPOINT)
        end
        
        log("Dodged lightning at distance " .. minDistance)
        avoidLightningTicks = API.Get_tick()
    end
end

local function managePlayer()
    eatFood()
    drinkPrayer()
    enablePassivePrayer()
    playerDied()
end

local function manageBuffs()
    if API.Get_tick() - buffCheckCooldown <= 30 then return end

    if hasOverload then
        drinkOverload()
    end
    if hasWeaponPoison then
        drinkWeaponPoison()
    end
    if hasDebilitate then
        useDebilitateAbility()
    end
    if hasDevotion then
        useDevotionAbility()
    end
    if hasDarkness then
        useDarkness()
    end
    if hasInvokeDeath then
        useInvokeDeath()
    end
    buffCheckCooldown = API.Get_tick()
end

local function handleStateChange(currentAnimation)
    local newState = getBossStateFromAnimation(currentAnimation)
    if newState == nil then
        return
    end
    if newState ~= currentState then
        log("State changed to: " .. bossStateEnum[newState].name)
        currentState = newState
        handleCombat(newState)
    end
end

local function HandleStartButton()
    if not startScript then
        if StartButton.return_click then
            StartButton.return_click = false
            startScript = true
            selectedPassive = PassivesDropdown.stringsArr[tonumber(PassivesDropdown.int_value) + 1]
            if selectedPrayerType == 0 then
                selectedPrayerType = "Prayers"  
            elseif selectedPrayerType == 1 then
                selectedPrayerType = "Curses"  
            end
            log("Script started")
            log("Selected Prayer Type: " .. (selectedPrayerType or "None"))
            log("Selected Passive: " .. (selectedPassive or "None"))
        end
    end
end

local function HandleButtons()
    HandleStartButton()
end

local function DrawButtons()
    API.DrawSquareFilled(Background)
    API.DrawComboBox(PassivesDropdown, false)
    API.DrawBox(StartButton)
end

local function DrawGui()
    DrawButtons()
    HandleButtons()
end

log("Started Ernie's Kerapac Bosser " .. version)
API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    DrawGui()
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
            handleStateChange(getKerapacAnimation())
            handleBossPhase()
            dodgeLightning2()
            managePlayer()
            manageBuffs()
        elseif isTimeToLoot and not isLooted then
            handleBossLoot()
        elseif isLooted then
            handleBossReset()
        end
    end
end
log("Stopped Ernie's Kerapac Bosser " .. version)
