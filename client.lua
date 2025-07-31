
local RainbowCore = exports["rainbow-core"]:initiate()

local PlayerStress = 0

local countInCombat = 0
local isArmed = false
local isAiming = false
local isInMeleeCombat = false
local isHogtied = false
local isHandcuffed = false

local isStill = true
local isWalking = false
local isSitting = false

local isImmuneToWeaponStress = false


function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


Citizen.CreateThread(function()
	while true do
		isImmuneToWeaponStress = RainbowCore.AbsolutelyHasJobInJoblistClient(Config.JobsImmuneToWeaponStress)
		if Config.PrintDebug then print("isImmuneToWeaponStress: ", isImmuneToWeaponStress) end
		Citizen.Wait(60 * 1000)
	end
end)


if Config.Debug then 
	RegisterCommand("setstress", function(source, args)
		TriggerEvent('vorp:UpdateStress', tonumber(args[1]))
	end)

	RegisterCommand("startstress", function(source, args)
		TriggerEvent('vorp:stress:StartStressThreads')
	end)
end


-------- STRESS --------
RegisterNetEvent('vorp:stress:StartStressThreads', function()

	if Config.PrintDebug then print('StartStressThreads') end
	
	Citizen.Wait(20000)
	
	StartStressThreads()
end)

function StartStressThreads() 

	-- Update all the statuses
	Citizen.CreateThread(function()
		while true do
			local ped = PlayerPedId()
		
			-- From serious to less serious (wrapped in if's for performance with invoking natives)
			countInCombat = Citizen.InvokeNative(0x5407B7288D0478B7, ped, 0) -- CountPedsInCombatWithTarget
			if not countInCombat then
				local isCurrentWeaponDangerous = isCurrentWeaponDangerous(ped)
				isAiming = Citizen.InvokeNative(0x698F456FB909E077) and isCurrentWeaponDangerous -- IsAimCamActive
				if not isAiming then
					isInMeleeCombat = Citizen.InvokeNative(0x4E209B2C1EAD5159, ped) -- IsPedInMeleeCombat
					if not isInMeleeCombat then
						isHogtied = (Citizen.InvokeNative(0x3AA24CCC0D451379, ped) ~= false) -- IsPedHogtied
						isHandcuffed = Citizen.InvokeNative(0x74E559B3BC910685, ped) -- IsPedCuffed
						isArmed = Citizen.InvokeNative(0xCB690F680A3EA971, ped, 4) and isCurrentWeaponDangerous -- IsPedArmed
					end
				end
			end

			if not isInGeneralDanger() then
				isStill = Citizen.InvokeNative(0xAC29253EEF8F0180, ped) -- IsPedStill
				if not isStill then
					isWalking = Citizen.InvokeNative(0xDE4C184B2B9B071A, ped) -- IsPedWalking
					isSitting = Citizen.InvokeNative(0x84D0BF2B21862059, ped) -- IsPedSitting
				end
			end
			
			Citizen.Wait(200)
		end
	end)
	
	--==================================================--
	--======== NEGATIVE STATES (ADDS STRESS)    ========--
	--==================================================--
	
	 -- Aiming, melee, hogtied, armed
	Citizen.CreateThread(function()
		while true do
		
			if countInCombat then
				if Config.PrintDebug then print("countInCombat: "..dump(countInCombat)) end
				TriggerEvent('vorp:AddStress', 20 * countInCombat)
				Citizen.Wait(10000)
			elseif isAiming then
				if Config.PrintDebug then print("isAiming") end
				TriggerEvent('vorp:AddStress', 4)
				Citizen.Wait(2000)
			elseif isInMeleeCombat then
				if Config.PrintDebug then print("isInMeleeCombat") end
				TriggerEvent('vorp:AddStress', 20)
				Citizen.Wait(10000)
			elseif (isHogtied ~= false) then
				if Config.PrintDebug then print("isHogtied") end
				TriggerEvent('vorp:AddStress', 2)
				Citizen.Wait(10000)
			elseif isHandcuffed then
				if Config.PrintDebug then print("isHandcuffed") end
				TriggerEvent('vorp:AddStress', 4)
				Citizen.Wait(10000)
			elseif isArmed and not isImmuneToWeaponStress then
				if Config.PrintDebug then print("isArmed") end
				TriggerEvent('vorp:AddStress', 0.4)
				Citizen.Wait(1000)
			else
				Citizen.Wait(100)
			end
			
			Citizen.Wait(10)
		end
	end)

	 -- While healt is below 100(half)
	-- Citizen.CreateThread(function()
		-- while true do
			-- local ped = PlayerPedId()
			-- local health = GetEntityHealth(ped)

			-- if health <= 50 then
				-- print("injured")
				-- TriggerEvent('vorp:AddStress', 100)
				-- -- exports['mythic_notify']:SendAlert("error", "METİN BURAYA // TEXT HERE") -- Örnek mythic notify // Example mythic notify
				-- Citizen.Wait(60000)
			-- else
				-- Citizen.Wait(5000)
			-- end
		-- end
	-- end)


	--==================================================--
	--======== POSITIVE STATES (REMOVES STRESS) ========--
	--==================================================--

	 -- Staying still or walking
	Citizen.CreateThread(function()
		while true do
		
			-- Abort if they're in danger
			if not isInGeneralDanger() then
			
				if isSitting then
					if Config.PrintDebug then print("isSitting") end
					TriggerEvent('vorp:RemoveStress', 20)
					Citizen.Wait(10000)
				elseif isWalking then
					if Config.PrintDebug then print("isWalking") end
					TriggerEvent('vorp:RemoveStress', 5)
					Citizen.Wait(10000)
				elseif isStill then
					if Config.PrintDebug then print("isStill") end
					TriggerEvent('vorp:RemoveStress', 10)
					Citizen.Wait(10000)
				end
			
			end
			
			Citizen.Wait(10 * 1000)
		end
	end)
	
	StartScreenEffectsThread()
end

function isInGeneralDanger()
	return (countInCombat or isAiming or isInMeleeCombat or (isHogtied ~= false) or isHandcuffed or isArmed)
end

function isCurrentWeaponDangerous(ped)
	local currentWeaponHash = Citizen.InvokeNative(0x8425C5F057012DAB, ped) -- GetPedCurrentHeldWeapon
	local currentWeaponTypeGroup = Citizen.InvokeNative(0xEDCA14CA5199FF25, currentWeaponHash) -- GetWeapontypeGroup
	if currentWeaponTypeGroup == `group_held` or 
		currentWeaponTypeGroup == `group_unarmed` or
		currentWeaponHash == `weapon_fishingrod` then
		return false
	else
		return true
	end
end

--==================================================--
--======== SCREEN EFFECTS                   ========--
--==================================================--

local hasStressSalve = false

-- Every 30 secs, check if they have a Stress Salve (accessibility)
CreateThread(function()
	while true do
		Citizen.Wait(30 * 1000) -- 30 secs
		updateHasStressSalve()
	end
end)

function updateHasStressSalve()
	if LocalPlayer.state["accessibility:hasStressSalve"] ~= nil and LocalPlayer.state["accessibility:hasStressSalve"] == true then
		hasStressSalve = true
	end
end

function StartScreenEffectsThread()
	Citizen.Wait(1 * 60 * 1000) -- 1 min
	CreateThread(function()
		while true do
		
			local ped = PlayerPedId()
			local sleep = GetEffectInterval(PlayerStress)
		
			TriggerEvent("vorpmetabolism:getValue", "Stress", function(stress)
				PlayerStress = stress
			end)
		
			 if PlayerStress >= 900 then
				if not hasStressSalve then
					local ShakeIntensity = GetShakeIntensity(PlayerStress)
					local FallRepeat = math.random(2, 4)
					local RagdollTimeout = (FallRepeat * 1750)
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
					
					if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
						local player = PlayerPedId()
						SetPedToRagdollWithFall(player, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
					end
					
					Wait(500)
					for i = 1, FallRepeat, 1 do
						Wait(750)
						DoScreenFadeOut(200)
						Wait(1000)
						DoScreenFadeIn(200)
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
					end
				end
				
				TriggerEvent("vorp:Tip", "You are extremely stressed out.", 10000)
			 elseif PlayerStress >= Config.MinimumStress then
				if Config.PrintDebug then print("greater than minimum stress") end
				
				if not hasStressSalve then
					local ShakeIntensity = GetShakeIntensity(PlayerStress)
					ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
				end
				TriggerEvent("vorp:Tip", "You are stressed out.", 6000)
			end
				
			Wait(sleep)
		end
	end)
end


function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for _, v in pairs(Config.Intensity['shake']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

function GetEffectInterval(stresslevel)
    local retval = 60000
    for _, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end

