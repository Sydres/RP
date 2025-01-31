ESX = nil
local arrayWeight = Config.localWeight

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)


MySQL.ready(function()
	if Config.WeightSqlBased == false then
		return
	end

	arrayWeight = {}

	local items = MySQL.Sync.fetchAll('SELECT name, weight FROM items')

	for i=1, #items, 1 do
		arrayWeight[items[i].name] = items[i].weight
	end
end)

ESX.RegisterServerCallback('esx_vehicle_inventory:getItemWeights', function(source, cb)
	cb(arrayWeight)
end)

RegisterServerEvent('esx_truck_inventory:getOwnedVehicle')
AddEventHandler('esx_truck_inventory:getOwnedVehicle', function()
  local vehicles = {}
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  MySQL.Async.fetchAll(
      'SELECT * FROM owned_vehicles WHERE owner = @owner',
   		{
   			['@owner'] = xPlayer.identifier
   		},
    function(result)
      if result ~= nil and #result > 0 then
          for _,v in pairs(result) do
              local vehicle = json.decode(v.vehicle)
            --print(vehicle.plate)
              table.insert(vehicles, {plate = vehicle.plate})
          end
      end
    TriggerClientEvent('esx_truck_inventory:setOwnedVehicle', _source, vehicles)
    end)
end)



function getInventoryWeight(inventory)
  local weight = 0
  local itemWeight = 0

  if inventory ~= nil then
	  for i=1, #inventory, 1 do
	    if inventory[i] ~= nil then
	      itemWeight = Config.DefaultWeight
	      if arrayWeight[inventory[i].name] ~= nil then
	        itemWeight = arrayWeight[inventory[i].name]
	      end
	      weight = weight + (itemWeight * inventory[i].count)
	    end
	  end
  end
  return weight
end



RegisterServerEvent('esx_truck_inventory:getInventory')
AddEventHandler('esx_truck_inventory:getInventory', function(plate)
  local inventory_ = {}
  local _source = source
  local xPlayer  = ESX.GetPlayerFromId(_source)

--[[
  MySQL.Async.fetchAll(
    'SELECT * FROM `truck_inventory` WHERE `plate` = @plate',
    {
      ['@plate'] = plate
    },
    ]]--
--    function(inventory)
--[[
      if inventory ~= nil and #inventory > 0 then
        for i=1, #inventory, 1 do
          table.insert(inventory_, {
            label      = inventory[i].name,
            name      = inventory[i].item,
            count     = inventory[i].count
          })
        end
]]--
        local inventory = exports["esx_inventory"]:getInventory("car", plate, true)
        if inventory ~= nil then
            for k,v in pairs(inventory.items) do
                table.insert(inventory_, {
                    label = v.label,
                    name = v.name,
                    data = v,
                    count = v.amount,
                })
            end
        end

        --local weight = (getInventoryWeight(inventory_))
        local weight = inventory.weight
        TriggerClientEvent('esx_truck_inventory:getInventoryLoaded', xPlayer.source, inventory_,weight)

--    end
--    end)
end)


RegisterServerEvent('esx_truck_inventory:removeInventoryItem')
AddEventHandler('esx_truck_inventory:removeInventoryItem', function(plate, item, count)
    local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)

    item.amount = count

    if item.extra ~= nil then

      TriggerEvent('esx_inventory:removeItem',  "car", plate, item, function(res)
          if res == true then
              TriggerEvent('esx_inventory:addItem', "pocket", xPlayer.identifier, item, function(res) end)
          end
      end)
      return
    end
--[[
  local _source = source
  MySQL.Async.fetchAll(
    'UPDATE `truck_inventory` SET `count`= `count` - @qty WHERE `plate` = @plate AND `item`= @item',
    {
      ['@plate'] = plate,
      ['@qty'] = count,
      ['@item'] = item
    },
    function(result)
      local xPlayer  = ESX.GetPlayerFromId(_source)
      if xPlayer ~= nil then
        xPlayer.addInventoryItem(item, count)
      end
    end)
    ]]--
end)


RegisterServerEvent('esx_truck_inventory:addInventoryItem')
AddEventHandler('esx_truck_inventory:addInventoryItem', function(type, model, plate, item, count, name,ownedV)
  local _source = source
  local xPlayer  = ESX.GetPlayerFromId(_source)

  item.amount = count

  if item.extra ~= nil then

    TriggerEvent('esx_inventory:removeItem', "pocket", xPlayer.identifier, item, function(res)
        if res == true then
            TriggerEvent('esx_inventory:addItem', "car", plate, item, function(res) end)
        end
    end)
    return
  end
--[[
  MySQL.Async.fetchAll(
    'INSERT INTO truck_inventory (item,count,plate,name,owned) VALUES (@item,@qty,@plate,@name,@owned) ON DUPLICATE KEY UPDATE count=count+ @qty',
    {
      ['@plate'] = plate,
      ['@qty'] = count,
      ['@item'] = item,
      ['@name'] = name,
      ['@owned'] = ownedV,
    },
    function(result)
      local xPlayer  = ESX.GetPlayerFromId(_source)
      xPlayer.removeInventoryItem(item, count)
    end)
    ]]--
end)
