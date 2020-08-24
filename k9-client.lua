local K9Config = {
    OpenDoorsOnSearch = true
}

local textureIds = {
    ["police"] = 0,
    ["sheriff"] = 1,
    ["rescue"] = 2,
    ["state"] = 3,
    ["security"] = 7
}

local spawned_ped = nil
local following = false
local attacking = false
local searching = false
local auth = false
local blip = nil
local animations = {
    ['Normal'] = {
        sit = {
            dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a",
            anim = "idle_b"
        },
        laydown = {
            dict = "creatures@rottweiler@amb@sleep_in_kennel@",
            anim = "sleep_in_kennel"
        },
    }
}

--[[ NUI Callbacks ]]--

RegisterNUICallback("toggleK9", function(texture, cb)
    TriggerEvent("K9:ToggleK9", texture)
    cb("ok")
end)

RegisterNUICallback("vehicletoggle", function(data, cb)
    TriggerEvent("K9:ToggleVehicle")
    cb("ok")
end)

RegisterNUICallback("searchvehicle", function(data, cb)
    TriggerEvent("K9:SearchVehicle")
    cb("ok")
end)
RegisterNUICallback("searchplayer", function(data, cb)
    --TriggerEvent("K9:SearchVehicle")
    ExecuteCommand('do K9 starts sniffing player. (^1Respond: Does it smell anything?^0)')
    cb("ok")
end)

RegisterNUICallback("k9follow", function(data, cb)
    TriggerEvent("K9:ToggleFollow")
    cb("ok")
end)

RegisterNUICallback("sit", function(data, cb)
    if DoesEntityExist(spawned_ped) then
        following = false
        PlayAnimation(animations['Normal'].sit.dict, animations['Normal'].sit.anim)
    else
        Notification(tostring("~r~K9 has despawned."))
    end
    cb("ok")
end)

RegisterNUICallback("laydown", function(data, cb)
    if DoesEntityExist(spawned_ped) then
        following = false
        PlayAnimation(animations['Normal'].laydown.dict, animations['Normal'].laydown.anim)
    else
        Notification(tostring("~r~K9 has despawned."))
    end
    cb("ok")
end)

    -- Error for Identifier Whitelist
    --RegisterNetEvent("K9:IdentifierRestricted")
    AddEventHandler("K9:IdentifierRestricted", function()
        Notification(tostring("~r~You do not match any identifiers in the whitelist."))
    end)

    -- Spawns and Deletes K9
    --RegisterNetEvent("K9:ToggleK9")
    AddEventHandler("K9:ToggleK9", function(texture)
        if IsPedInAnyVehicle(GetLocalPed(), false) then
            Notification(tostring("~r~You need to exit your vehicle."))
            return
        end
        if not DoesEntityExist(spawned_ped) then
            SendNUIMessage({
                type = "navigation",
                value = "Back"
            })
            local ped = GetHashKey('a_c_shepherd')
            RequestModel(ped)
            while not HasModelLoaded(ped) do
                Citizen.Wait(1)
                RequestModel(ped)
            end
            local plyCoords = GetOffsetFromEntityInWorldCoords(GetLocalPed(), 0.0, 2.0, 0.0)
            local dog = CreatePed(28, ped, plyCoords.x, plyCoords.y, plyCoords.z, GetEntityHeading(GetLocalPed()), 0, 1)
            spawned_ped = dog
            SetPedComponentVariation(spawned_ped, 8, 0, textureIds[texture])
            SetBlockingOfNonTemporaryEvents(spawned_ped, true)
            SetPedFleeAttributes(spawned_ped, 0, 0)
            SetPedRelationshipGroupHash(spawned_ped, GetHashKey("k9"))
            blip = AddBlipForEntity(spawned_ped)
            SetBlipAsFriendly(blip, true)
            SetBlipSprite(blip, 442)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(tostring("K9"))
            EndTextCommandSetBlipName(blip)
            NetworkRegisterEntityAsNetworked(spawned_ped)
            while not NetworkGetEntityIsNetworked(spawned_ped) do
                NetworkRegisterEntityAsNetworked(spawned_ped)
                Citizen.Wait(1)
            end
            attacking = false
            following = false
            searching = false       
        else
            local has_control = false
            RequestNetworkControl(function(cb)
                has_control = cb
            end)
            if has_control then
                SetEntityAsMissionEntity(spawned_ped, true, true)
                DeleteEntity(spawned_ped)
                spawned_ped = nil
                if attacking then
                    SetPedRelationshipGroupDefaultHash(target_ped, GetHashKey("CIVMALE"))
                    target_ped = nil
                    attacking = false
                end
                following = false
                searching = false
            end
        end
    end)

    -- Toggles K9 to Follow / Heel
    --RegisterNetEvent("K9:ToggleFollow")
    AddEventHandler("K9:ToggleFollow", function()
        if DoesEntityExist(spawned_ped) then
            if not following then
                local has_control = false
                RequestNetworkControl(function(cb)
                    has_control = cb
                end)
                if has_control then
                    TaskFollowToOffsetOfEntity(spawned_ped, GetLocalPed(), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
                    SetPedKeepTask(spawned_ped, true)
                    following = true
                    attacking = false
                    Notification(tostring("K9 will now follow you."))
                end
            else
                local has_control = false
                RequestNetworkControl(function(cb)
                    has_control = cb
                end)
                if has_control then
                    SetPedKeepTask(spawned_ped, false)
                    ClearPedTasks(spawned_ped)
                    following = false
                    attacking = false
                    Notification(tostring("K9 will nolonger follow you."))
                end
            end
        elseif spawned_ped ~= nil then
            Notification(tostring("~r~K9 has despawned."))
        end
    end)

    -- Toggles K9 In and Out of Vehicles
    --RegisterNetEvent("K9:ToggleVehicle")
    AddEventHandler("K9:ToggleVehicle", function()
        if DoesEntityExist(spawned_ped) then
            if not searching then
                if IsPedInAnyVehicle(spawned_ped, false) then
                    TaskLeaveVehicle(spawned_ped, GetVehiclePedIsIn(spawned_ped, false), 256)
                    Notification(tostring("K9 is exsiting your vehicle."))
                else
                    if not IsPedInAnyVehicle(GetLocalPed(), false) then
                        local plyCoords = GetEntityCoords(GetLocalPed(), false)
                        local vehicle = GetVehicleAheadOfPlayer()
                        if vehicle ~= 0 then
                            local door = GetClosestVehicleDoor(vehicle)
                            if door ~= false then
                                TaskEnterVehicle(spawned_ped, vehicle, -1, door, 2.0, 1, 0)
                                Notification(tostring("K9 is entering vehicle."))
                            else
                                Notification(tostring("~r~Vehicle has no rear door."))                            
                            end
                        else
                            Notification(tostring("~r~No nearby vehicle."))
                        end
                    else
                        local vehicle = GetVehiclePedIsIn(GetLocalPed(), false)
                        if vehicle ~= 1 then
                            if GetNumberOfVehicleDoors(vehicle) > 4 then
                                local door = 1
                                TaskEnterVehicle(spawned_ped, vehicle, -1, door, 2.0, 1, 0)
                                Notification(tostring("K9 is entering your vehicle."))
                            else
                                Notification(tostring("~r~Vehicle has no rear door.")) 
                            end
                        else
                            Notification(tostring("~r~Unable to get players vehicle."))
                        end
                    end
                end
            else
                Notification(tostring("~r~K9 is currently searching..."))
            end
        else
            Notification(tostring("~r~K9 has despawned."))
        end
    end)

    -- Triggers K9 to Attack
    --RegisterNetEvent("K9:ToggleAttack")
    AddEventHandler("K9:ToggleAttack", function(target)
        if searching then
            Notification(tostring("~r~K9 is currently searching..."))
            return
        end
        if not attacking then
            if IsPedAPlayer(target) then
                local has_control = false
                RequestNetworkControl(function(cb)
                    has_control = cb
                end)
                if has_control then
                    local player = GetPlayerFromServerId(GetPlayerId(target))
                    SetCanAttackFriendly(spawned_ped, true, true)
                    TaskPutPedDirectlyIntoMelee(spawned_ped, target, 0.0, -1.0, 0.0, 0)
                    Notification(tostring("K9 is attacking player."))
                end
            else
                local has_control = false
                RequestNetworkControl(function(cb)
                    has_control = cb
                end)
                if has_control then
                    SetCanAttackFriendly(spawned_ped, true, true)
                    TaskPutPedDirectlyIntoMelee(spawned_ped, target, 0.0, -1.0, 0.0, 0)
                    Notification(tostring("K9 is attacking NPC."))
                end
            end
            attacking = true
            following = false
        else
            Notification(tostring("~r~K9 is already attacking..."))
        end
    end)

    -- Triggers K9 to Search Vehicle
    --RegisterNetEvent("K9:SearchVehicle")
    AddEventHandler("K9:SearchVehicle", function()
        if searching then
            Notification(tostring("~r~K9 is already searching..."))
            return
        end
        local vehicle = GetVehicleAheadOfPlayer()
        if vehicle ~= 0 then
            following = false
            searching = true

            Notification(tostring("K9 has began searching..."))
            ExecuteCommand('do K9 starts sniffing vehicle. (^1Respond: Does it smell anything?^0)')
            
            if K9Config.OpenDoorsOnSearch then
                for i=0, 7 do
                    if i ~= 4 then
                        SetVehicleDoorOpen(vehicle, i, 0, 0)
                    end
                end
            end

            -- Back Right
            local offsetOne = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, -2.0, 0.0)
            TaskGoToCoordAnyMeans(spawned_ped, offsetOne.x, offsetOne.y, offsetOne.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Right
            local offsetTwo = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, 2.0, 0.0)
            TaskGoToCoordAnyMeans(spawned_ped, offsetTwo.x, offsetTwo.y, offsetTwo.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Left
            local offsetThree = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, 2.0, 0.0)
            TaskGoToCoordAnyMeans(spawned_ped, offsetThree.x, offsetThree.y, offsetThree.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            -- Front Right
            local offsetFour = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, -2.0, 0.0)
            TaskGoToCoordAnyMeans(spawned_ped, offsetFour.x, offsetFour.y, offsetFour.z, 5.0, 0, 0, 1, 10.0)

            Citizen.Wait(7000)

            if K9Config.OpenDoorsOnSearch then
                SetVehicleDoorsShut(vehicle, 0)
            end

            Notification(tostring("K9 has finished searching."))
            searching = false
        else
            Notification(tostring("~r~No vehicle found."))
        end
    end)

--]]

--[[ Threads ]]
    -- Controls Menu
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            -- Trigger Attack
            if IsControlJustPressed(1, 73) and IsPlayerFreeAiming(PlayerId()) then
                local bool, target = GetEntityPlayerIsFreeAimingAt(PlayerId())

                if bool then
                    if IsEntityAPed(target) then
                        TriggerEvent("K9:ToggleAttack", target)
                    end
                end
            end

            -- Trigger Follow
            if IsControlJustPressed(1, 73) and not IsPlayerFreeAiming(PlayerId()) then
                TriggerEvent("K9:ToggleFollow")
            end

            -- Deletes K9 when you die
            if DoesEntityExist(spawned_ped) and IsEntityDead(GetLocalPed()) then
                TriggerEvent("K9:ToggleK9")
            end
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            SendNUIMessage({
                type = "k9Data",
                data = {
                    following = following,
                    summoned = spawned_ped ~= nil,
                    auth = auth,
                }
            })

            if spawned_ped ~= nil then
                if attacking and not GetIsTaskActive(spawned_ped, 128) then
                    attacking = false
                end
                if not DoesEntityExist(spawned_ped) then
                    spawned_ped = nil
                    Notification(tostring("~r~Your K9 has despawned."))
                    SetBlipDisplay(blip, 0)
                    blip = nil
                elseif IsEntityDead(spawned_ped) then
                    spawned_ped = nil
                    Notification(tostring("~r~Your K9 has died."))
                    SetBlipDisplay(blip, 0)
                    blip = nil
                end
            end
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            TriggerServerEvent('k9:GetPerms')
        end
    end)

    RegisterNetEvent("k9:GetPerms:callback")
    AddEventHandler("k9:GetPerms:callback", function(_auth)
        auth = _auth
    end)
    

--]]

--[[ EXTRA FUNCTIONS ]]--

-- Gets Local Ped
function GetLocalPed()
    return GetPlayerPed(PlayerId())
end

-- Gets Control Of Ped
function RequestNetworkControl(callback)
    local netId = NetworkGetNetworkIdFromEntity(spawned_ped)
    local timer = 0
    NetworkRequestControlOfNetworkId(netId)
    while not NetworkHasControlOfNetworkId(netId) do
        Citizen.Wait(1)
        NetworkRequestControlOfNetworkId(netId)
        timer = timer + 1
        if timer == 5000 then
            Citizen.Trace("Control failed")
            callback(false)
            break
        end
    end
    callback(true)
end

-- Gets Players
function GetPlayers()
    local players = {}
    for i = 0, 32 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

-- Get Searching item
function ChooseItem(items)
    local number = math.random(1, 100)

    if number > 70 and number < 95 then -- 70 | 95
        local randomItem = math.random(1, #items)
        return items[randomItem]
    else
        return false
    end
end

-- Set K9 Animation (Sit / Laydown)
function PlayAnimation(dict, anim)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(spawned_ped, dict, anim, 8.0, -8.0, -1, 2, 0.0, 0, 0, 0)
end

-- Gets Player ID
function GetPlayerId(target_ped)
    local players = GetPlayers()
    for a = 1, #players do
        local ped = GetPlayerPed(players[a])
        local server_id = GetPlayerServerId(players[a])
        if target_ped == ped then
            return server_id
        end
    end
    return 0
end

-- Checks Ped Restriction
function CheckPedRestriction(ped, PedList)
	for i = 1, #PedList do
		if GetHashKey(PedList[i]) == GetEntityModel(ped) then
			return true
		end
	end
	return false
end

-- Checks Vehicle Restriction
function CheckVehicleRestriction(vehicle, VehicleList)
	for i = 1, #VehicleList do
		if GetHashKey(VehicleList[i]) == GetEntityModel(vehicle) then
			return true
		end
	end
	return false
end

-- Gets Vehicle Ahead Of Player
function GetVehicleAheadOfPlayer()
    local lPed = GetLocalPed()
    local lPedCoords = GetEntityCoords(lPed, alive)
    local lPedOffset = GetOffsetFromEntityInWorldCoords(lPed, 0.0, 3.0, 0.0)
    local rayHandle = StartShapeTestCapsule(lPedCoords.x, lPedCoords.y, lPedCoords.z, lPedOffset.x, lPedOffset.y, lPedOffset.z, 1.2, 10, lPed, 7)
    local returnValue, hit, endcoords, surface, vehicle = GetShapeTestResult(rayHandle)

    if hit then
        return vehicle
    else
        return false
    end
end

-- Gets Closest Door To Player
function GetClosestVehicleDoor(vehicle)
    local plyCoords = GetEntityCoords(GetLocalPed(), false)
	local backleft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_r"))
	local backright = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_r"))
	local bldistance = GetDistanceBetweenCoords(backleft['x'], backleft['y'], backleft['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)
    local brdistance = GetDistanceBetweenCoords(backright['x'], backright['y'], backright['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)

    local found_door = false

    if (bldistance < brdistance) then
        found_door = 1
    elseif(brdistance < bldistance) then
        found_door = 2
    end

    return found_door
end

-- Displays Notification
function Notification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0, 1)
end
--]]
