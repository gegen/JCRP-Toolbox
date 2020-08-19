local props = {
    spikes = 'P_ld_stinger_s',
    policeBarrier = 'prop_barrier_work05',
    roadBarrier = 'prop_mp_barrier_02b',
    roadBarrierArrow = 'prop_mp_arrow_barrier_01',
    cone = 'prop_roadcone01a',
    trafficBarrel = 'prop_barrier_wat_03a'
}

RegisterNUICallback('displayMsg', function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end)

RegisterNUICallback('executeCommand', function(cmd)
    ExecuteCommand(cmd)
end)

RegisterNUICallback('setSpikes', function(double)
    SetSpikesOnGround(double)
end)
RegisterNUICallback('removeSpikes', function()
    DeleteObjects(props.spikes, 4)
end)

RegisterNUICallback('spawnObject', function(obj)
    SpawnObject(props[obj])
end)

RegisterNUICallback('deleteCloseObjects', function()
    for _, prop in pairs(props) do
        DeleteObjects(prop)
    end
end)

RegisterCommand('sp', function()
    SetSpikesOnGround(false)
end, false)
RegisterCommand('sp2x', function()
    SetSpikesOnGround(true)
end, false)
RegisterCommand('spdelete', function()
    DeleteObjects(props.spikes, 4)
end, false)

TriggerEvent('chat:addSuggestions', {
    { name= '/sp', help= 'Set spikes infront of you.' },
    { name= '/sp2x', help= 'Set 2 lane spikes infront of you.' },
    { name= '/spdelete', help= 'Remove spikes close to you.' }
})

function SpawnObject(objectname)
    local Player = GetPlayerPed(-1)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.5))
    local heading = GetEntityHeading(Player)

    RequestModel(objectname)

    while not HasModelLoaded(objectname) do
	    Citizen.Wait(1)
    end

	local obj = CreateObject(GetHashKey(objectname), x, y, z, true, true, true)
	PlaceObjectOnGroundProperly(obj)
	SetEntityHeading(obj, heading+180)
	FreezeEntityPosition(obj, true)

    SetModelAsNoLongerNeeded(objectname)
end


function DeleteObjects(object, areaMultiplier)
    areaMultiplier = areaMultiplier or 1
    local obj = GetHashKey(object)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    while DoesObjectOfTypeExistAtCoords(x, y, z, 4.5 * areaMultiplier, obj, true) do
        iObj = GetClosestObjectOfType(x, y, z, 4.5 * areaMultiplier, obj, false, false, false)
        SetEntityAsMissionEntity(iObj, true, true)
        DeleteObject(iObj)
        Citizen.Wait(0)
    end
end

function SetSpikesOnGround(double)
	local Player = GetPlayerPed(-1)
	local heading = GetEntityHeading(Player)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.5, 0.5))

    spike = GetHashKey(props.spikes)

    RequestModel(spike)
    while not HasModelLoaded(spike) do
      Citizen.Wait(1)
    end

    local object = CreateObject(spike, x, y, z, true, true, true)
    PlaceObjectOnGroundProperly(object)
	SetEntityHeading(object, heading)
    FreezeEntityPosition(object, true)
    SetEntityCollision(object, false, false)

    SetObjectAsNoLongerNeeded(object)
    SetModelAsNoLongerNeeded(spike)

    if double then
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 6.5, 0.5))
        local object = CreateObject(spike, x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(object)
        SetEntityHeading(object, heading)
        FreezeEntityPosition(object, true)
        SetEntityCollision(object, false, false)
    
        SetObjectAsNoLongerNeeded(object)
        SetModelAsNoLongerNeeded(spike)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(ped, false)
        local vehCoord = GetEntityCoords(veh)
        if IsPedInAnyVehicle(ped, false) then
            if DoesObjectOfTypeExistAtCoords(vehCoord["x"], vehCoord["y"], vehCoord["z"], 0.9, GetHashKey(props.spikes), true) then
            SetVehicleTyreBurst(veh, 0, true, 1000.0)
            SetVehicleTyreBurst(veh, 1, true, 1000.0)
            SetVehicleTyreBurst(veh, 2, true, 1000.0)
            SetVehicleTyreBurst(veh, 3, true, 1000.0)
            SetVehicleTyreBurst(veh, 4, true, 1000.0)
            SetVehicleTyreBurst(veh, 5, true, 1000.0)
            SetVehicleTyreBurst(veh, 6, true, 1000.0)
            SetVehicleTyreBurst(veh, 7, true, 1000.0)
            RemoveSpike()
            end
        end
    end
end)

function RemoveSpike()
    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped, false)
    local vehCoord = GetEntityCoords(veh)
    if DoesObjectOfTypeExistAtCoords(vehCoord["x"], vehCoord["y"], vehCoord["z"], 0.9, GetHashKey(props.spikes), true) then
        spike = GetClosestObjectOfType(vehCoord["x"], vehCoord["y"], vehCoord["z"], 0.9, GetHashKey(props.spikes), false, false, false)
        SetEntityAsMissionEntity(spike, true, true)
        DeleteObject(spike)
    end
end