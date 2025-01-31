
ESX = nil
lockStatus = {}

function IsCar(vehicle)
    local vc = GetVehicleClass(vehicle)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20) or (vc == 8) -- 8 = bike
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_locksystem:sendLockStatuses')
AddEventHandler('esx_locksystem:sendLockStatuses', function(locks)
	lockStatus = locks
end)

RegisterNetEvent('esx_locksystem:sendLockStatus')
AddEventHandler('esx_locksystem:sendLockStatus', function(plate, status)
	lockStatus[plate] = status
end)

function carLock(vehicle, plate)
	local lockStatus = GetVehicleDoorLockStatus(vehicle)

        if lockStatus <= 2 then
            SetVehicleDoorsLocked(vehicle, 4)
            SetVehicleDoorsLockedForAllPlayers(vehicle, 1)
            TriggerEvent('esx:showNotification', "Транспорт закрыт")
            TriggerServerEvent('esx_locksystem:setLock', plate, true)
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "lock", 0.2)
        else
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            TriggerEvent('esx:showNotification', "Транспорт открыт")
            TriggerServerEvent('esx_locksystem:setLock', plate, false)
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "unlock", 0.2)
        end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)

        -- If the defined key is pressed
        if IsControlJustPressed(1, 303) then
		local ped = PlayerPedId()
		local pos = GetEntityCoords(PlayerPedId())
		local vehicle = 0

                if IsPedInAnyVehicle(ped, true) then
                -- by sitting inside
                    vehicle = GetVehiclePedIsIn(ped, false)
                else
                -- by targeting the vehicle
    	            vehicle = GetTargetedVehicle(pos, ped)
                end

		if vehicle == nil or vehicle < 1 then
			local vehs = ESX.Game.GetVehiclesInArea(pos, 1.1)
			if #vehs > 0 then
				vehicle = vehs[1]
			end
		end

		if vehicle ~= nil and vehicle > 0 and IsCar(vehicle) then
			local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
                        local vc = GetVehicleClass(vehicle)

			ESX.TriggerServerCallback('esx_locksystem:haveKeys', function(res)
				if res == true then
                                        if vc ~= 8 then
						local dict = "anim@mp_player_intmenu@key_fob@"
						RequestAnimDict(dict)
						while not HasAnimDictLoaded(dict) do
						    Citizen.Wait(100)
						end
						TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
					end
					carLock(vehicle, plate)
				else
			            TriggerEvent('esx:showNotification', "У вас нет ключей от этой машины")
				end
			end, plate)
		end
	end
    end
end)

---- Prevents the player from breaking the window if the vehicle is locked
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local ped = GetPlayerPed(-1)
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId(ped))) then
                local veh = GetVehiclePedIsTryingToEnter(PlayerPedId(ped))
                local lock = GetVehicleDoorLockStatus(veh)
                local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

		if lockStatus[plate] ~= nil then
			if lock == 4 and lockStatus[plate] == false then
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleDoorsLockedForAllPlayers(vehicle, false)
			elseif lock ~= 4 and lockStatus[plate] == true then
				SetVehicleDoorsLocked(vehicle, 4)
				SetVehicleDoorsLockedForAllPlayers(vehicle, 1)
			end
		end

	        if lock == 4 then
                    ClearPedTasks(ped)
	        end
        end
	end
end)

---- Get a vehicle in direction
-- @param array coordFrom
-- @param array coordTo
-- @return int
function GetVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

---- Get the vehicle in front of the player
-- @param array pCoords
-- @param int ply
-- @return int
function GetTargetedVehicle(pCoords, ply)
    for i = 1, 200 do
        coordB = GetOffsetFromEntityInWorldCoords(ply, 0.0, (6.281)/i, 0.0)
        targetedVehicle = GetVehicleInDirection(pCoords, coordB)
        if(targetedVehicle ~= nil and targetedVehicle ~= 0)then
            return targetedVehicle
        end
    end
    return
end

RegisterNetEvent('InteractSound_CL:PlayWithinDistance')
AddEventHandler('InteractSound_CL:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = #(lCoords - eCoords)--Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if distIs <= maxDistance then
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = soundVolume
        })
    end
end)
