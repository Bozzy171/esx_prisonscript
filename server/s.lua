ESX = exports["es_extended"]:getSharedObject()
function GetRPName(playerId, data)
	local Identifier = ESX.GetPlayerFromId(playerId).identifier

	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		data(result[1].firstname, result[1].lastname)

	end)
end

ESX.RegisterServerCallback("esx_prisonscript:gettime", function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier


	MySQL.Async.fetchAll("SELECT jail FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		local JailTime = tonumber(result[1].jail)

		if JailTime > 0 then

			cb(true, JailTime)
		else
			cb(false, 0)
		end

	end)
end)


RegisterServerEvent("esx_prisonscript:updateJailTime")
AddEventHandler("esx_prisonscript:updateJailTime", function(JailTime)
	local src = source

	EditJailTime(src, JailTime)
end)

function EditJailTime(source, jailTime)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier

	MySQL.Async.execute(
       "UPDATE users SET jail = @jailTime WHERE identifier = @identifier",
        {
			['@identifier'] = Identifier,
			['@jailTime'] = tonumber(jailTime)
		}
	)
end
RegisterServerEvent("esx_prisonscript:updateJailPhoto")
AddEventHandler("esx_prisonscript:updateJailPhoto", function(filename)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.Async.fetchAll(
			"SELECT * FROM `mdt_police_jails` WHERE `identifier` = @identifier ORDER BY id DESC LIMIT 1;",
			{
				['@identifier'] = xPlayer.identifier,
			}, function(result)
				if result[1].id then
					MySQL.Async.execute(
						"UPDATE `mdt_police_jails` SET `photo` = @photo WHERE `id` = @id",
						{
							['@photo'] = filename,
							['@id'] = result[1].id,
						}
					)
				end
			end
		)
end)

RegisterCommand("d_jail", function(src, args, raw)

	local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(args[1])

		local jailPlayer = args[1]
		local jailTime = tonumber(args[2])
		local jailReason = args[3]

		JailPlayer(jailPlayer, jailTime)

end)

RegisterServerEvent("esx_prisonscript:jailPlayer")
AddEventHandler("esx_prisonscript:jailPlayer", function(targetSrc, jailTime, jailReason)
	local src = source
	local targetSrc = tonumber(targetSrc)

	local xPlayer = ESX.GetPlayerFromId(src)
	local xPlayer_target = ESX.GetPlayerFromId(targetSrc)

	JailPlayer(targetSrc, jailTime)

	MySQL.Async.execute(
			"INSERT INTO `mdt_police_jails` (identifier, name, officer_identifier, officer_name, length, reason) VALUES (@identifier, @name, @officer_identifier, @officer_name, @length, @reason)",
			{
				['@identifier'] = xPlayer_target.identifier,
				['@name'] = xPlayer_target.name,
				['@officer_identifier'] = xPlayer.identifier,
				['@officer_name'] = xPlayer.name,
				['@length'] = jailTime,
				['@reason'] = jailReason
			}
		)
	
	GetRPName(targetSrc, function(Firstname, Lastname)
	if xPlayer["job"]["name"] == "police" or xPlayer["job"]["name"] == "AFP" then
	end
	end)
end)

function JailPlayer(jailPlayer, jailTime)
	local xPlayer = ESX.GetPlayerFromId(jailPlayer)
	TriggerClientEvent("esx_prisonscript:jailPlayer", jailPlayer, jailTime)

	MySQL.Async.fetchAll("SELECT sex FROM users WHERE identifier = @identifier", { ["@identifier"] = xPlayer.identifier }, function(result)
		for i = 1, #result, 1 do
			trips = {}
			for i=1, #result, 1 do
				if result[i].sex == 'f' then
					TriggerClientEvent("esx_prisonscript:PrisonClothesF", jailPlayer)
				elseif result[i].sex == 'm' then
					TriggerClientEvent("esx_prisonscript:PrisonClothesM", jailPlayer)
				end
			end
		end
		
	end)
	Citizen.Wait(5000)
	EditJailTime(jailPlayer, jailTime)
	Citizen.Wait(2000)
	-- TriggerClientEvent("eOPEN",jailPlayer)
end

RegisterNetEvent("esx_prisonscript:giveclothes")
AddEventHandler("esx_prisonscript:giveclothes",function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll("SELECT sex FROM users WHERE identifier = @identifier", { ["@identifier"] = xPlayer.identifier }, function(result)
		for i = 1, #result, 1 do
			trips = {}
			for i=1, #result, 1 do
				if result[i].sex == 'f' then
					TriggerClientEvent("esx_prisonscript:ReleaseClothesF", jailPlayer)
				elseif result[i].sex == 'm' then
					TriggerClientEvent("esx_prisonscript:ReleaseClothesM", jailPlayer)
				end
			end
		end
	end)
end)



RegisterServerEvent('esx_prisonscript:RevokeItems')
AddEventHandler('esx_prisonscript:RevokeItems',function()
	exports.ox_inventory:ConfiscateInventory(source)
end)
RegisterServerEvent('esx_prisonscript:GiveBackItems')
AddEventHandler('esx_prisonscript:GiveBackItems',function()
	exports.ox_inventory:ReturnInventory(source)
end)