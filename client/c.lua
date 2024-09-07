ESX = nil
PlayerData = {}
jailTime = 0
inzone = false
breakout = false
lockedup = false


function lockedup()
    while true do
        if lockedup then
            return true
        else
            return false
        end
    end
end
exports("lockedup", lockedup)



local check_out_blip = vector3(1783.69,2588.96,45.8)
local change_clothes = vector3(1780.575806, 2614.773682, 50.6)
local checkin_prisoner = vector3(1788.19,2598.19,45.8)
local medical_checkup = vector3(1780.85,2555.51,45.8)




function LoadAnim(animDict)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end

function LoadModel(model)
	RequestModel(model)

	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end
end
Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

end)

CreateThread(function()
    zones = {
        vector2(1848.99,2698.93),
        -- vector2(1844.35,2611.74),
        vector2(1818.53,2611.61),
        vector2(1819.11,2568.82),
        vector2(1817.0,2532.65),
        vector2(1823.62,2474.95),
        vector2(1762.31,2410.38),
        vector2(1659.26,2395.34),
        vector2(1541.69,2468.4),
        vector2(1535.8,2584.94),
        vector2(1569.3,2679.87),
        vector2(1648.82,2758.76),
        vector2(1773.09,2763.38),
    }
    startBoxZone = PolyZone:Create(zones, { name = 'prisonrange', debugPoly = false })
    startBoxZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        insideStartZone = isPointInside
    end, 100)

    local statement = "[CHARLIE AIRSPACE BREECH] PRISON COMPLEX - HELICOPTER"	
    local ped = PlayerPedId()
    local playercoords = GetEntityCoords(ped)
    local veh = GetVehiclePedIsUsing(ped)
    local class = GetVehicleClass(veh)
    local inveh = IsPedInVehicle(ped,veh,false)


    while true do
        Citizen.Wait(5000)
            if not insideStartZone then Wait(200) else Wait(10) end

            if insideStartZone then
                inzone = true
                local ped = PlayerPedId()
                local playercoords = GetEntityCoords(ped)
                local veh = GetVehiclePedIsUsing(ped)
                local class = GetVehicleClass(veh)
                local inveh = IsPedInVehicle(ped,veh,false)

                if class == 15 and inveh then
                    TriggerServerEvent('PoliceMDT:new-call', statement, { x = playercoords.x, y = playercoords.y })
                    Wait(25000)
                end
            else
                inzone = false
            end
    end
end)


RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(newData)
	PlayerData = newData
    ESX.PlayerData = newData

	Citizen.Wait(0)
	ESX.TriggerServerCallback("esx_prisonscript:gettime", function(inJail, newJailTime)
        if insideStartZone then
            -- print('already in block')
            TriggerEvent("eOPEN")
            lockedup = true
        else
            if inJail then
                PutInJail()
                lockedup = true
            end
        end

	end)

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-- Display time check marker
CreateThread(function()
	while true do
		local Sleep = 0
        local coords = GetEntityCoords(PlayerPedId())
        local drawtype = 27
        local Size  = { x = 1.0, y = 1.0, z = 1.0 }
        local Color = { r = 50, g = 200, b = 50 }

        if lockedup then
            if #(coords - check_out_blip) < 15.0 then
                    DrawMarker(drawtype, check_out_blip.x, check_out_blip.y, check_out_blip.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Size.x, Size.y, Size.z, Color.r, Color.g, Color.b, 100, false, true, 2, true, nil, nil, false)
                    Sleep = 0
            end
            if #(coords - medical_checkup) < 15.0 then
                    DrawMarker(drawtype, medical_checkup.x, medical_checkup.y, medical_checkup.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Size.x, Size.y, Size.z, Color.r, Color.g, Color.b, 100, false, true, 2, true, nil, nil, false)
                    Sleep = 0
            end
        end

        -- if #(coords - change_clothes) < 20.0 then
        --     DrawMarker(drawtype, change_clothes.x, change_clothes.y, change_clothes.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Size.x, Size.y, Size.z, Color.r, Color.g, Color.b, 100, false, true, 2, true, nil, nil, false)
        -- end
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
            if #(coords - checkin_prisoner) < 15.0 then
                DrawMarker(drawtype, checkin_prisoner.x, checkin_prisoner.y, checkin_prisoner.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Size.x, Size.y, Size.z, 255,0,0, 100, false, true, 2, true, nil, nil, false)
                Sleep = 0
            end
        end


	Wait(Sleep)
	end
end)



-- Enter / Exit marker events
CreateThread(function()
	while true do
		local Sleep = 500
			local coords = GetEntityCoords(PlayerPedId())
            local drawtype = 27
            local Size  = { x = 1.0, y = 1.0, z = 1.0 }
            local Color = { r = 50, g = 200, b = 50 }
			local isInMarker = false
			local currentZone = nil


            
            if lockedup then
                if(#(coords - check_out_blip) < 1.0) then
                    Sleep = 0
                    isInMarker  = true
                    currentZone = 'checktime'
                end
                if(#(coords - medical_checkup) < 1.0) then
                    Sleep = 0
                    isInMarker  = true
                    currentZone = 'medical'
                end
            end

            -- if(#(coords - change_clothes) < Size.x) then
            --     Sleep = 0
            --     isInMarker  = true
            --     currentZone = 'clothing'
            -- end
            if(#(coords - checkin_prisoner) < 1.0) then
                if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
                    Sleep = 0
                    isInMarker  = true
                    currentZone = 'prisoner_checkin'
                end
            end


			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_prisonscript:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_prisonscript:hasExitedMarker', LastZone)
			end
	Wait(Sleep)
	end
end)


AddEventHandler('esx_prisonscript:hasEnteredMarker', function(zone)
	if zone == 'checktime' then
		CurrentAction     = 'check_prison_time'
		CurrentActionMsg  = '[~r~E~w~] Check remaining time'
		CurrentActionData = {}
    elseif zone == 'clothing' then
		CurrentAction     = 'change_clothing'
		CurrentActionMsg  = '[~r~E~w~] Change Clothing'
		CurrentActionData = {}
    elseif zone == 'prisoner_checkin' then
		CurrentAction     = 'prisoner_checkin'
		CurrentActionMsg  = '[~r~E~w~] Check-In Prisoner'
		CurrentActionData = {}
    elseif zone == 'medical' then
		CurrentAction     = 'medical_checkin'
		CurrentActionMsg  = '[~r~E~w~] Medical Checkin'
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_prisonscript:hasExitedMarker', function(zone)
	if zone == 'checktime' then
    elseif zone == 'clothing' then
    elseif zone == 'prisoner_checkin' then
    elseif zone == 'medical_checkin' then
	end

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)


-- Key Controls
CreateThread(function()
	while true do
	local sleep = 500
		if CurrentAction then
			sleep = 0
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'check_prison_time' then
					-- OpenMechanicActionsMenu()
                    ESX.TriggerServerCallback("esx_prisonscript:gettime", function(inJail, timeleft)
                        if timeleft == 0 then
                            -- print('no longer need to be here')
                            UnJail()
                        elseif timeleft > 0 then
                            -- print('still got time')
                            -- ESX.ShowNotification("you still have "..timeleft.." months remaining.")
                            lib.notify({
                                title = 'Prison',
                                description = "you still have "..timeleft.." months remaining.",
                                position = 'top-right',
                                icon = 'clock',
                                iconColor = '#C53030'
                            })
                        end
                
                    end)
				elseif CurrentAction == 'change_clothing' then
					-- OpenMechanicActionsMenu()
                    ESX.TriggerServerCallback("esx_prisonscript:gettime", function(inJail, timeleft)
                        if timeleft == 0 then
                            -- print('no longer need to be here')
                            UnJail()
                        elseif timeleft > 0 then
                            -- print('still got time')
                            -- ESX.ShowNotification("you still have "..timeleft.." months remaining.")
                            lib.notify({
                                title = 'Prison',
                                description = "you still have "..timeleft.." months remaining.",
                                position = 'top-right',
                                icon = 'clock',
                                iconColor = '#C53030'
                            })
                        end
                
                    end)
				elseif CurrentAction == 'prisoner_checkin' then
					OpenJailMenu()
				elseif CurrentAction == 'medical_checkin' then
					MedicalCheckIn()
				end
				-- CurrentAction = nil
			 end
		 end
		Wait(sleep)
	end
end)






function MedicalCheckIn()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local health = GetEntityHealth(PlayerPedId())
    
    if(#(coords - medical_checkup) < 1.0) then
        ESX.ShowNotification("You're being treated, please do not move.")
            Wait(10000)
            coords = GetEntityCoords(player)
            if(#(coords - medical_checkup) < 1.0) then
                ESX.ShowNotification("You have been treated.")
                SetEntityHealth(player,200)
            else
                ESX.ShowNotification("you have moved, we cannot treat you.")
        end
    end
end




RegisterNetEvent('esx_prisonscript:PrisonClothesM')
AddEventHandler('esx_prisonscript:PrisonClothesM',function()
    local playerPed = PlayerPedId()
    local outfit = PrisonClothesMale(clothes)
    local pedComponents = outfit
    exports['fivem-appearance']:setPedComponents(playerPed, outfit.Components)
	exports['fivem-appearance']:setPedProps(playerPed, outfit.Props)
    TriggerEvent('fivem-appearance:setOutfit', pedComponents)
end)

RegisterNetEvent('esx_prisonscript:PrisonClothesF')
AddEventHandler('esx_prisonscript:PrisonClothesF',function()
    local playerPed = PlayerPedId()
    local outfit = PrisonClothesFemale(clothes)
    local pedComponents = outfit
    exports['fivem-appearance']:setPedComponents(playerPed, outfit.Components)
	exports['fivem-appearance']:setPedProps(playerPed, outfit.Props)
    TriggerEvent('fivem-appearance:setOutfit', pedComponents)
end)

RegisterNetEvent('esx_prisonscript:ReleaseClothesM')
AddEventHandler('esx_prisonscript:ReleaseClothesM',function()
    local playerPed = PlayerPedId()
    local outfit = ReleaseClothesMale(clothes)
    local pedComponents = outfit
    exports['fivem-appearance']:setPedComponents(playerPed, outfit.Components)
	exports['fivem-appearance']:setPedProps(playerPed, outfit.Props)
    TriggerEvent('fivem-appearance:setOutfit', pedComponents)
end)

RegisterNetEvent('esx_prisonscript:ReleaseClothesF')
AddEventHandler('esx_prisonscript:ReleaseClothesF',function()
    local playerPed = PlayerPedId()
    local outfit = ReleaseClothesFemale(clothes)
    local pedComponents = outfit
    exports['fivem-appearance']:setPedComponents(playerPed, outfit.Components)
	exports['fivem-appearance']:setPedProps(playerPed, outfit.Props)
    TriggerEvent('fivem-appearance:setOutfit', pedComponents)
end)




function PutInJail()
	local JailPosition = {
        ["x"] = 1786.03,
        ["y"] = 2568.4,
        ["z"] = 50.55,
        ["h"] = 4.22
    }
	SetEntityCoords(PlayerPedId(), JailPosition["x"], JailPosition["y"], JailPosition["z"] - 1)
	-- ESX.ShowNotification("Last time you went to sleep you were jailed, because of that you are now put back!")
    TriggerEvent("eOPEN")
    -- if PlayerData.sex == 'm' then
    --     TriggerEvent("esx_prisonscript:PrisonClothesM")
    -- else
    --     TriggerEvent("esx_prisonscript:PrisonClothesF")
    -- end
end




RegisterNetEvent("eOPEN")
AddEventHandler("eOPEN", function()
    local statement = "[BREAK OUT] PRISON COMPLEX - ESCAPEE"	
    local playercoords = GetEntityCoords(GetPlayerPed(-1))

    local amiinzone = inzone

    ESX.TriggerServerCallback("esx_prisonscript:gettime", function(inJail, LockupTime)
        if inJail then
            
            jailTime = LockupTime

            Citizen.CreateThread(function()
                while jailTime > 0 and insideStartZone do
                    jailTime = jailTime - 1
                    -- ESX.ShowNotification("You have " .. jailTime .. " minutes left in jail!")
                    TriggerServerEvent("esx_prisonscript:updateJailTime", jailTime)
                    if jailTime == 0 then
                        
                        -- REMOVED THIS UNJAIL OPTION AS THEY NEED TO GOTO BLIP TO GET OUT
                        -- start
                        -- UnJail()
                        -- end

                        TriggerServerEvent("esx_prisonscript:updateJailTime", 0)
                        
                    end
                        Citizen.Wait(60000)
                    end
                end
                
                while jailTime > 0 and not insideStartZone do
                    TriggerServerEvent("esx_prisonscript:updateJailTime", 0)
                    Citizen.Wait(5000)
                end

            end)
        end
	end)
end)

-- TriggerServerEvent('PoliceMDT:new-call', statement, { x = playercoords.x, y = playercoords.y })



function UnJail()
    lockedup = false
    DoScreenFadeOut(2000)
    local PlayerPed = PlayerPedId()
    -- GetPlayerServerId(closestPlayer)

	Citizen.Wait(3000)
	ESX.Game.Teleport(PlayerPedId(), {x = 1840.64, y = 2594.41, z = 45.95, heading = 178.54})
    TriggerServerEvent('esx_prisonscript:GiveBackItems')
    -- print(PlayerData.sex)
    if PlayerData.sex == 'f' then
        TriggerEvent("esx_prisonscript:ReleaseClothesF")
    elseif PlayerData.sex == "m" then
        TriggerEvent("esx_prisonscript:ReleaseClothesM")

    end

	-- TriggerServerEvent('esx_prisonscript:giveclothes',GetPlayerServerId(PlayerPed))
	Citizen.Wait(2000)
    DoScreenFadeIn(2000)
	-- TriggerServerEvent('esx_prisonscript:GiveBackItems')
	ESX.ShowNotification("You are released, stay calm outside! Good Luck!")
end

function TakePhoto()
    local PhotoPosition = {
        ["x"] = 402.91567993164,
        ["y"] = -996.75970458984,
        ["z"] = -99.000259399414,
        ["h"] = 186.22499084473
    }
    local JailPosition = {
        ["x"] = 1786.03,
        ["y"] = 2568.4,
        ["z"] = 50.55,
        ["h"] = 4.22
    }
	local coords = PhotoPosition
	TriggerEvent('ServicesCentre:TakeMugshot', vector4(coords["x"], coords["y"], coords["z"], coords["h"]), "criminal",false, function(filename)
		DoScreenFadeOut(250)
		local PlayerPed = PlayerPedId()
		local JailPosition = JailPosition
		SetEntityCoords(PlayerPed, JailPosition["x"], JailPosition["y"], JailPosition["z"])
		DeleteEntity(Police)
		SetModelAsNoLongerNeeded(-1320879687)
        
		Citizen.Wait(1000)
        
        
        
		PutInJail()
		
        Wait(3000)
        TriggerServerEvent("esx_prisonscript:updateJailPhoto", filename)
        DoScreenFadeIn(250)
    end)
end



function Cutscene()
    lockedup = true
    local PolicePosition = {
    ["x"] = 402.91702270508,
    ["y"] = -1000.6376953125,
    ["z"] = -99.004028320313,
    ["h"] = 356.88052368164
    }
    local PhotoPosition = {
        ["x"] = 402.91567993164,
        ["y"] = -996.75970458984,
        ["z"] = -99.000259399414,
        ["h"] = 186.22499084473
    }

	DoScreenFadeOut(100)

	Citizen.Wait(250)
    TriggerServerEvent('esx_prisonscript:RevokeItems')
	LoadModel(-1320879687)

	local PolicePosition = PolicePosition
	local Police = CreatePed(5, -1320879687, PolicePosition["x"], PolicePosition["y"], PolicePosition["z"], PolicePosition["h"], false)
	TaskStartScenarioInPlace(Police, "WORLD_HUMAN_PAPARAZZI", 0, false)

	local PlayerPosition = PhotoPosition
	local PlayerPed = PlayerPedId()
	SetEntityCoords(PlayerPed, PlayerPosition["x"], PlayerPosition["y"], PlayerPosition["z"] - 1)
	SetEntityHeading(PlayerPed, PlayerPosition["h"])
	Citizen.Wait(1000)
	TakePhoto()
	DoScreenFadeIn(100)
	Citizen.Wait(10000)

end




-- Jail Menu
function OpenJailMenu()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'jail_prison_menu',
		{
			title    = "Prison Menu",
			align    = 'center',
			elements = {
				{ label = "Jail Closest Person", value = "jail_closest_player" },
			}
		}, 
	function(data, menu)

		local action = data.current.value

		if action == "jail_closest_player" then

			menu.close()

			ESX.UI.Menu.Open(
          		'dialog', GetCurrentResourceName(), 'jail_choose_time_menu',
          		{
            		title = "Jail Time (minutes)"
          		},
          	function(data2, menu2)

            	local jailTime = tonumber(data2.value)

            	if jailTime == nil then
              		ESX.ShowNotification("The time needs to be in minutes!")
            	else
					if jailTime > 100 then jailTime = 100 end
              		menu2.close()

              		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

              		if closestPlayer == -1 or closestDistance > 3.0 then
                		ESX.ShowNotification("No players nearby!")
					else
						ESX.UI.Menu.Open(
							'dialog', GetCurrentResourceName(), 'jail_choose_reason_menu',
							{
							  title = "Jail Reason"
							},
						function(data3, menu3)
		  
						  	local reason = data3.value
		  
						  	if reason == nil then
								ESX.ShowNotification("You need to put something here!")
						  	else
								menu3.close()
		  
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		  
								if closestPlayer == -1 or closestDistance > 3.0 then
								  	ESX.ShowNotification("No players nearby!")
								else
                                    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 10.0, "jailcellsfx", 0.4)
                                    TriggerServerEvent("esx_prisonscript:jailPlayer", GetPlayerServerId(closestPlayer), jailTime, reason)
                                    Wait(5000)
									TriggerServerEvent('esx_policejob:removehandcuff', GetPlayerServerId(closestPlayer))
								end
		  
						  	end
		  
						end, function(data3, menu3)
							menu3.close()
						end)
              		end

				end

          	end, function(data2, menu2)
				menu2.close()
			end)
		end

	end, function(data, menu)
		menu.close()
	end)	
end


exports("OpenJailMenu", OpenJailMenu)



RegisterNetEvent("esx_prisonscript:jailPlayer")
AddEventHandler("esx_prisonscript:jailPlayer", function(newJailTime)
	jailTime = newJailTime
	Cutscene()
end)

























PrisonClothesMale = function(outfit)
    local random_number = math.random(1,3)
    if random_number == 1 then
        local data = {
            Components = {
                { drawable = 0, texture = 0, component_id = 3 },
                { drawable = 184, texture = 0, component_id = 4 },
                { drawable = 6, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 15, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 511, texture = 0, component_id = 11 },

            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    elseif random_number == 2 then
        local data = {
            Components = {
                { drawable = 0, texture = 0, component_id = 3 },
                { drawable = 184, texture = 1, component_id = 4 },
                { drawable = 6, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 15, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 511, texture = 1, component_id = 11 },

            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    elseif random_number == 3 then
        local data = {
            Components = {
                { drawable = 0, texture = 0, component_id = 3 },
                { drawable = 184, texture = 2, component_id = 4 },
                { drawable = 6, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 15, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 511, texture = 2, component_id = 11 },

            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    end
end
ReleaseClothesMale = function(outfit)
    local data = {
        Components = {
            { drawable = 0, texture = 0, component_id = 3 },
            { drawable = 6, texture = 0, component_id = 4 },
            { drawable = 6, texture = 0, component_id = 6 },
            { drawable = 0, texture = 0, component_id = 7 },
            { drawable = 15, texture = 0, component_id = 8 },
            { drawable = 0, texture = 0, component_id = 9 },
            { drawable = 0, texture = 0, component_id = 10 },
            { drawable = 16, texture = 0, component_id = 11 },
        },
        Props = {
            { drawable = -1, texture = 0, prop_id = 0 },
            { drawable = -1, texture = 0, prop_id = 1 },
            { drawable = -1, texture = 0, prop_id = 2 },
            { drawable = -1, texture = 0, prop_id = 6 },
            { drawable = -1, texture = 0, prop_id = 7 },

        }
    }
    return data
end
PrisonClothesFemale = function(outfit)
    local random_number = math.random(1,3)
    if random_number == 1 then
        local data = {
            Components = {
                { drawable = 14, texture = 0, component_id = 3 },
                { drawable = 193, texture = 0, component_id = 4 },
                { drawable = 117, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 9, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 561, texture = 0, component_id = 11 },
            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    elseif random_number == 2 then
        local data = {
            Components = {
                { drawable = 14, texture = 0, component_id = 3 },
                { drawable = 193, texture = 1, component_id = 4 },
                { drawable = 117, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 9, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 561, texture = 1, component_id = 11 },
            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    elseif random_number == 3 then
        local data = {
            Components = {
                { drawable = 14, texture = 0, component_id = 3 },
                { drawable = 193, texture = 2, component_id = 4 },
                { drawable = 117, texture = 0, component_id = 6 },
                { drawable = 0, texture = 0, component_id = 7 },
                { drawable = 9, texture = 0, component_id = 8 },
                { drawable = 0, texture = 0, component_id = 9 },
                { drawable = 0, texture = 0, component_id = 10 },
                { drawable = 561, texture = 2, component_id = 11 },
            },
            Props = {
                { drawable = -1, texture = 0, prop_id = 0 },
                { drawable = -1, texture = 0, prop_id = 1 },
                { drawable = -1, texture = 0, prop_id = 2 },
                { drawable = -1, texture = 0, prop_id = 6 },
                { drawable = -1, texture = 0, prop_id = 7 },
            }
        }
        return data
    end

end
ReleaseClothesFemale = function(outfit)
    local data = {
        Components = {
            { drawable = 14, texture = 0, component_id = 3 },
            { drawable = 137, texture = 3, component_id = 4 },
            { drawable = 117, texture = 0, component_id = 6 },
            { drawable = 0, texture = 0, component_id = 7 },
            { drawable = 9, texture = 0, component_id = 8 },
            { drawable = 0, texture = 0, component_id = 9 },
            { drawable = 0, texture = 0, component_id = 10 },
            { drawable = 73, texture = 2, component_id = 11 },
        },
        Props = {
            { drawable = -1, texture = 0, prop_id = 0 },
            { drawable = -1, texture = 0, prop_id = 1 },
            { drawable = -1, texture = 0, prop_id = 2 },
            { drawable = -1, texture = 0, prop_id = 6 },
            { drawable = -1, texture = 0, prop_id = 7 },
        }
    }
    return data
end