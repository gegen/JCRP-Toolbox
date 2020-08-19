local maxPlayerDistance = 4 --Distance in GTA units

local display = false
local spawningObject = false

local closestPlayer

local controls = {
    SHIFT = 21,
    M = 244,
    ENTER = 176,
    ESC = 200,
    Backspace = 194,
    ArrowUp = 172,
    ArrowDown = 173
}

function displayMenu(toggle)
    display = toggle
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "display",
        toogle = toggle
    })
end

RegisterNUICallback("close", function(data, cb)
    displayMenu(false)
    spawningObject = false
    cb("ok")
end)

Citizen.CreateThread(function ()
    Citizen.Wait(300) -- Make sure nui has fully loaded
    while true do
	
        if --[[IsControlPressed(1, controls.SHIFT) and ]] IsControlJustReleased(0, controls.M) and IsInputDisabled(17) == 1 then
            displayMenu(not display)
        end

        if IsDisabledControlJustReleased(1, controls.ESC) then -- close everthing when esc is pressed
            displayMenu(false)
        end

        if display then
            DisableControlAction(0, controls.ENTER)
            DisableControlAction(0, controls.Backspace)
            DisableControlAction(0, controls.ESC)
            DisableControlAction(0, controls.ArrowUp)
            DisableControlAction(0, controls.ArrowDown)

            if IsEntityDead(PlayerPedId()) then -- Make sure player is alive and not in a vehicle
                displayMenu(false)
            end

            if IsDisabledControlJustReleased(1, controls.ENTER) then
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                SendNUIMessage({
                    type = "navigation",
                    value = "Enter"
                })
            end

            if IsDisabledControlJustReleased(1, controls.Backspace) then
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                SendNUIMessage({
                    type = "navigation",
                    value = "Back"
                })
            end

            if IsDisabledControlJustPressed(0, controls.ArrowUp) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                SendNUIMessage({
                    type = "navigation",
                    value = "Up"
                })
            elseif IsDisabledControlJustPressed(0, controls.ArrowDown) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET")
                SendNUIMessage({
                    type = "navigation",
                    value = "Down"
                })
            end

            local lPed = PlayerPedId()
            local lPedCoords = GetEntityCoords(lPed)
            local previousClosestPlayer = closestPlayer
            closestPlayer = nil
            local smallestDistance = maxPlayerDistance

            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if ped ~= lPed then
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), lPedCoords, true)
                    if smallestDistance > distance then
                        closestPlayer = player
                        smallestDistance = distance
                    end
                end
            end

            if closestPlayer ~= previousClosestPlayer then
                local id = GetPlayerServerId(closestPlayer)
                local name = GetPlayerName(closestPlayer)
                if closestPlayer == nil then
                    id = nil
                    name = nil
                end
                SendNUIMessage({
                    type = "closestPlayer",
                    id = id,
                    name = name
                })
            end
        end

        -- Following code is not being used!
        if spawningObject then
            -- Arrow Stuff below:

            form = setupScaleform("instructional_buttons")

            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)

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