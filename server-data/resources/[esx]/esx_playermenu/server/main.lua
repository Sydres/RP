ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function updateAdmin(xPlayer)
	TriggerEvent('es:canGroupTarget', xPlayer.getGroup(), "admin", function(canTarget)
		TriggerClientEvent('esx_playermenu:setAdmin', xPlayer.source, canTarget)
	end)
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	updateAdmin(xPlayer)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			local xPlayers = ESX.GetPlayers()

			for i=1, #xPlayers, 1 do
				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
				if xPlayer ~= nil then
					updateAdmin(xPlayer)
				end
			end
		end)
	end
end)


ESX.RegisterServerCallback('esx_playermenu:adminGetPlayers', function(source, cb)
    xPlayer = ESX.GetPlayerFromId(source)
    if not exports["essentialmode"]:canGroupTarget(xPlayer.getGroup(), "admin") then
        return
    end

    local xPlayers = ESX.GetPlayers()
    local arr = {}
    for i=1, #xPlayers, 1 do
        local pl = ESX.GetPlayerFromId(xPlayers[i])
	local identity = pl.getSessionVar("identity")
	local job = "unemployed"
	if pl.job ~= nil then
		job = pl.job.name
	end

        table.insert(arr, {
            ["id"] = pl.source,
            ["name"] = pl.name,
            ["job"] = job,
            ["identity"] = identity,
            ["identifier"] = pl.identifier,
	    ["money"] = pl.getMoney(),
            ["bank"] = pl.getBank(),
            ["black_money"] = pl.getAccount('black_money').money,
            ["phone_number"] = exports["gcphone"]:getNumberPhone(pl.identifier),
        })
    end

    cb(arr)
end)

ESX.RegisterServerCallback('esx_playermenu:adminGetSocietyAccount', function(source, cb, societyName)
	TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
		cb({
			["money"] = account.money,
		})
	end)
end)

ESX.RegisterServerCallback('esx_playermenu:adminMoney', function(source, cb, identifier, moneytype, act, val)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not exports["essentialmode"]:canGroupTarget(xPlayer.getGroup(), "admin") then
        return
    end
    xTarget = ESX.GetPlayerFromIdentifier(identifier)
    TriggerEvent('admin_commands:setmoney', xPlayer.source, xTarget.source, moneytype, act, val)
    cb()
end)
