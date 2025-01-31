local randomVehicles = {
    {model = "ADDER", label = "Adder", price = 2300},
    {model = "SANDKING", label = "Sandking", price = 800},
    {model = "LANDSTAL", label = "Landstalker", price = 1000},
    {model = "SUPERDIAMOND", label = "Superdiamond", price = 1600},
    {model = "SABREGT", label = "Sabre GT", price = 900},
    {model = "PANTO", label = "Panto", price = 500}
    -- Add more vehicles you want.
}

local chopShopLocations = {
    {x = 1204.86, y = -3117.26, z = 5.54}
    -- Add More if you want :D
}

local timer = false
local selectRandomVehicle = nil
Citizen.CreateThread(function()
	if Config.ShowBlips then
		for _, item in pairs(chopShopLocations) do
			item.blip = AddBlipForCoord(item.x, item.y, item.z)
			SetBlipSprite(item.blip, 380)
			SetBlipColour(item.blip, 1)
			SetBlipScale(item.blip, 0.8)
			SetBlipAsShortRange(item.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Разборка авто")
			EndTextCommandSetBlipName(item.blip)
		end
	end
    while true do
        Citizen.Wait(1)
        for a = 1, #chopShopLocations do
            local ped = GetPlayerPed(PlayerId())
            local pedPos = GetEntityCoords(ped, false)
            local distance = Vdist(pedPos.x, pedPos.y, pedPos.z, chopShopLocations[a].x, chopShopLocations[a].y, chopShopLocations[a].z)
            local vehicle = IsPedInAnyVehicle(ped, false)
            if distance <= 30.0 then
                    DrawMarker(1, chopShopLocations[a].x, chopShopLocations[a].y, chopShopLocations[a].z - 1, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 0.5001, 1555, 0, 0,165, 0, 0, 0,0)
                if distance <= 2.0 then
                    if not timer then
                        drawText('Нажмите ~r~E~s~ чтобы взять задание ',0,1,0.5,0.8,0.6,255,255,255,255)
                        if IsControlJustPressed(1, 86) then
                            selectRandomVehicle = randomVehicles[math.random(1, #randomVehicles)]
                            Countdown = GetGameTimer() + 600 * 1000
                            timer = true
                            TriggerEvent('chatMessage', 'Разборка', {255, 123, 0}, "^4Найдите - "..selectRandomVehicle.label.."")
                        end
                    elseif timer and vehicle ~= false then
                        drawText('Нажмите ~r~E~s~ чтобы сдать автомобиль',0,1,0.5,0.8,0.6,255,255,255,255)
                        local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(PlayerId()))))
                        if IsControlJustPressed(1, 86) then
                            if currentVeh == selectRandomVehicle.model then
                                TriggerServerEvent("Darkzy:PayDeManPlz", selectRandomVehicle.price)
                                selectRandomVehicle = nil
                                timer = false
                                local vehicleIn = GetVehiclePedIsUsing(ped)
                                deleteCar(vehicleIn)
                            else
                                TriggerEvent("ISRP_Notification:Error", "Разборка", "Это не тот автомобиль", 5000, false, "leftCenter")
                            end
                        end
                    elseif timer then
                        local secsRemaining = math.ceil((Countdown - GetGameTimer()) / 1000)
                        secsRemaining = secsRemaining - 1
                        if secsRemaining > 0 then
                            drawText('Подождите ~r~'..secsRemaining..'~w~ пока нет заданий',0,1,0.5,0.8,0.6,255,255,255,255)
                        else
                            timer = false
                            print(timer)
                        end
                    end
                end
            end
        end
    end
end)

function deleteCar( vehicle )
	Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( vehicle ) )
end

function drawText(text,font,centre,x,y,scale,r,g,b,a)
    SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
    DrawText(x , y)
end
