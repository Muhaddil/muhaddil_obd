if Config.FrameWork == "auto" then
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = "esx"
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = "qb"
    end
elseif Config.FrameWork == "esx" and GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = "esx"
elseif Config.FrameWork == "qb" and GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = "qb"
else
    print('===NO SUPPORTED FRAMEWORK FOUND===')
end

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

local tabletProp = nil
local tabletAnimDict = Config.tabletAnimDict
local tabletAnimName = Config.tabletAnimName
local tabletModel = Config.tabletModel
local uiOpen = false
local lastVehicle = nil
local lastPlate = nil
local lastIsElectric = false

if Config.DebugMode then
    RegisterCommand("obd", function()
        toggleOBDTablet()
    end)
end

if Config.EnableKeyOpen then
    RegisterKeyMapping('obd', 'Open OBD tablet', 'keyboard', Config.OpenKey)
end

function SendNotification(msgtitle, msg, time, type)
    if not Config.ShowNotifications then
        return
    end

    if Config.UseOXNotifications then
        lib.notify({
            title = msgtitle,
            description = msg,
            duration = time or 5000,
            showDuration = true,
            type = type,
        })
    else
        if Framework == 'qb' then
            QBCore.Functions.Notify(msg, type, time)
        elseif Framework == 'esx' then
            TriggerEvent('esx:showNotification', msg, type, time)
        end
    end
end

local function StartTabletAnimation()
    local playerPed = PlayerPedId()

    RequestModel(tabletModel)
    while not HasModelLoaded(tabletModel) do
        Wait(0)
    end

    RequestAnimDict(tabletAnimDict)
    while not HasAnimDictLoaded(tabletAnimDict) do
        Wait(0)
    end

    tabletProp = CreateObject(GetHashKey(tabletModel), 0, 0, 0, true, true, false)
    AttachEntityToEntity(tabletProp, playerPed, GetPedBoneIndex(playerPed, 28422),
        0.0, -0.03, 0.0, 20.0, -90.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(playerPed, tabletAnimDict, tabletAnimName, 3.0, -1, -1, 49, 0, false, false, false)
end

local function StopTabletAnimation()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)

    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end
end

RegisterNetEvent("muhaddil_obd:SendNotification")
AddEventHandler("muhaddil_obd:SendNotification", function(msgtitle, msg, time, type)
    SendNotification(msgtitle, msg, time, type)
end)

RegisterNetEvent("muhaddil_obd:toggleOBDTablet")
AddEventHandler("muhaddil_obd:toggleOBDTablet", function()
    toggleOBDTablet()
end)

local function IsElectricVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    local spawnName = string.lower(GetDisplayNameFromVehicleModel(model))
    for _, evModel in ipairs(Config.ElectricVehicles) do
        if spawnName == string.lower(evModel) then
            return true
        end
    end
    return false
end

function toggleOBDTablet()
    if IsNuiFocused() then
        DebugPrint("NUI is focused, hiding UI")
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "hideUI" })

        if Config.UseAnimations then
            StopTabletAnimation()
        end

        uiOpen = false
    else
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        local vehicle = nil

        if Config.InCarUseOnly and not IsPedInAnyVehicle(playerPed, false) then
            SendNotification("OBD", "Debes estar dentro de un vehículo para usar la OBD.", 5000, "error")
            return
        end

        if Config.InCarUseOnly then
            vehicle = GetVehiclePedIsIn(playerPed, false)
        else
            vehicle = lib.getClosestVehicle(coords, Config.ScanDistance, true)
        end

        if vehicle then
            local plate = GetVehicleNumberPlateText(vehicle)
            plate = plate:gsub("^%s*(.-)%s*$", "%1")

            local isElectric = IsElectricVehicle(vehicle)

            DebugPrint("Vehicle found. Plate:", plate, "Electric:", isElectric)

            lastVehicle = vehicle
            lastPlate = plate
            lastIsElectric = isElectric
            uiOpen = true
            TriggerServerEvent("muhaddil_obd:getVehicleData", plate, vehicle, isElectric)

            Citizen.CreateThread(function()
                while uiOpen do
                    Citizen.Wait(Config.UpdateInterval * 1000)
                    if uiOpen and lastPlate and lastVehicle then
                        TriggerServerEvent("muhaddil_obd:getVehicleData", lastPlate, lastVehicle, lastIsElectric)
                    end
                end
            end)
        else
            DebugPrint("No vehicle found nearby")
            SendNotification("OBD", "No hay vehículos cerca.", 5000, "error")
        end
    end
end

RegisterNetEvent("muhaddil_obd:openUI")
AddEventHandler("muhaddil_obd:openUI", function(vehicleData, vehicle)
    DebugPrint("Event received: muhaddil_obd:openUI")

    local engineTemp = GetVehicleEngineTemperature(vehicle)
    local rawRpm = GetVehicleCurrentRpm(vehicle)
    local maxRpm = 8000
    local currentRpm = rawRpm * maxRpm
    local fuelLevel = GetVehicleFuelLevel(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)

    vehicleData.diagnostico["Temperatura del refrigerante"] = string.format("%.2f", engineTemp)
    vehicleData.diagnostico.RPM = string.format("%.2f", currentRpm)
    vehicleData.diagnostico["Nivel de combustible"] = string.format("%.2f%%", fuelLevel)
    vehicleData.diagnostico["Estado de la carrocería"] = string.format("%.2f%%", bodyHealth / 10)

    if not IsNuiFocused() then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "showUI",
            vehicle = vehicleData,
            showParticles = Config.EnableBackgrondParticles,
        })
        if Config.UseAnimations then
            StartTabletAnimation()
        end
        DebugPrint("UI displayed with vehicle diagnostics")
    else
        SendNUIMessage({
            action = "updateData",
            vehicle = vehicleData
        })
        DebugPrint("UI updated with new vehicle diagnostics")
    end
end)

RegisterNUICallback("closeUI", function(data, cb)
    DebugPrint("UI closed via NUI callback")

    if Config.UseAnimations then
        StopTabletAnimation()
    end

    TriggerServerEvent("muhaddil_obd:closeUI")
    SetNuiFocus(false, false)
    uiOpen = false
    cb({})
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if IsNuiFocused() and IsControlJustReleased(0, 322) then
--             SetNuiFocus(false, false)
--             SendNUIMessage({ action = "hideUI" })
--         end
--     end
-- end)
