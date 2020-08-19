local maxPlayerDistance = 4 --Distance in GTA units

local display = false
local menu = false

local controls = {
    SHIFT = 21,
    M = 244,
    ENTER = 176,
    ESC = 200,
    ArrowUp = 172,
    ArrowDown = 173
}

local closestPlayer

function displayMenu(toggle, id, name)
    menu = toggle
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "display",
        toogle = toggle,
        id = id,
        name = name
    })
end

RegisterNUICallback("executeCommand", function(cmd)
    print(cmd)
    ExecuteCommand(cmd)
end)

RegisterNUICallback("action", function(data)
    TriggerServerEvent('jcrp-toolbox:SendQueueItem', data)
end)

RegisterNUICallback("SendResponse", function(data)
    TriggerServerEvent('jcrp-toolbox:SendResponse', data)
end)

RegisterNUICallback("close", function()
    menu = false
    display = false
end)

RegisterNetEvent('jcrp-toolbox:AddQueueItem')
AddEventHandler('jcrp-toolbox:AddQueueItem', function(action, source)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "addQueueItem",
        source = source,
        name = GetPlayerName(GetPlayerFromServerId(source)),
        action = action
    })
end)

Citizen.CreateThread(function ()    
    SetNuiFocus(false, false)
    while true do

        if IsControlPressed(1, controls.SHIFT) and IsControlJustReleased(1, controls.M) then
            display = not display
            displayMenu(false)
        end

        if IsDisabledControlJustReleased(1, controls.ESC) then -- close everthing when esc is pressed
            display = false
            displayMenu(false)
        end

        if IsEntityDead(PlayerPedId()) or IsPedInAnyVehicle(PlayerPedId(), false) then -- Make sure player is alive and not in a vehicle
            display = false
            displayMenu(false)
        end

        if menu then
            DisableControlAction(0, controls.ArrowUp)
            DisableControlAction(0, controls.ArrowDown)

            if IsDisabledControlJustReleased(1, controls.ENTER) then
                SendNUIMessage({
                    type = "navigation",
                    value = "Enter"
                })
            end

            if IsDisabledControlJustPressed(0, controls.ArrowUp) then
                SendNUIMessage({
                    type = "navigation",
                    value = "Up"
                })
            elseif IsDisabledControlJustPressed(0, controls.ArrowDown) then
                SendNUIMessage({
                    type = "navigation",
                    value = "Down"
                })
            end
        end

        if display then
            DisableControlAction(0, controls.ENTER)
            DisableControlAction(0, controls.ESC)


            -- Arrow Stuff below:

            form = setupScaleform("instructional_buttons")

            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
            
            if not menu then
                local lPed = PlayerPedId()
                local lPedCoords = GetEntityCoords(lPed)
                closestPlayer = nil
                local smallestDistance = maxPlayerDistance

                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped ~= "lPed" then
                        local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), lPedCoords, true)
                        if smallestDistance > distance then
                            closestPlayer = player
                            smallestDistance = distance
                        end
                    end
                end
            end

            if closestPlayer == nil then
                BeginTextCommandPrint("String")
                AddTextComponentSubstringPlayerName("No nearby players.")
                EndTextCommandPrint(0, true)
            else
                if IsDisabledControlJustReleased(1, controls.ENTER) and not menu then
                    displayMenu(true, GetPlayerServerId(closestPlayer), GetPlayerName(closestPlayer))
                end

                local ped = GetPlayerPed(closestPlayer);

                local boneId = GetEntityBoneIndexByName(ped, "IK_Head")
                if boneId ~= -1 then
                    coords = GetWorldPositionOfEntityBone(ped, boneId)
                    zOffset = 0.6;
                else
                    coords = GetEntityCoords(ped)
                    zOffset = 1.2;
                end
                DrawMarker(
                    0, -- type (0 is arrow)
                    coords["x"], coords["y"], coords["z"] + zOffset,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.2, 0.2, 0.15, -- scale
                    0, 148, 207, 150, -- rgba
                    true, -- bobupAndDown
                    true
                )
            end
        end

        Citizen.Wait(0)
    end
end)


function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    if not menu and closestPlayer ~= nil then
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(1)
        Button(GetControlInstructionalButton(2, controls.ENTER, true))
        ButtonMessage("Select Player")
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, controls.ESC, true))
    ButtonMessage("Close")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end