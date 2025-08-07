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

RegisterNetEvent("muhaddil_obd:SendNotification")
AddEventHandler("muhaddil_obd:SendNotification", function(msgtitle, msg, time, type)
    SendNotification(msgtitle, msg, time, type)
end)

RegisterNetEvent("muhaddil_obd:toggleOBDTablet")
AddEventHandler("muhaddil_obd:toggleOBDTablet", function()
    toggleOBDTablet()
end)

function toggleOBDTablet()
    if IsNuiFocused() then
        DebugPrint("NUI is focused, hiding UI")
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "hideUI" })
    else
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        DebugPrint("Getting closest vehicle from player coordinates:", coords)

        -- local vehicle, distance = ESX.Game.GetClosestVehicle(coords)
        local vehicle = lib.getClosestVehicle(coords, Config.ScanDistance, true)
        if vehicle then
            local plate = GetVehicleNumberPlateText(vehicle)
            plate = plate:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
            DebugPrint("Vehicle found. Plate:", plate)
            TriggerServerEvent("muhaddil_obd:getVehicleData", plate, vehicle)
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

    DebugPrint("Vehicle data - Engine Temp:", engineTemp)
    DebugPrint("Vehicle data - RPM:", currentRpm)
    DebugPrint("Vehicle data - Fuel Level:", fuelLevel)
    DebugPrint("Vehicle data - Body Health:", bodyHealth)

    vehicleData.diagnostico["Temperatura del refrigerante"] = string.format("%.2f", engineTemp)
    vehicleData.diagnostico.RPM = string.format("%.2f", currentRpm)
    vehicleData.diagnostico["Nivel de combustible"] = string.format("%.2f%%", fuelLevel)
    vehicleData.diagnostico["Estado de la carrocería"] = string.format("%.2f%%", bodyHealth / 10)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showUI",
        vehicle = vehicleData
    })

    DebugPrint("UI displayed with vehicle diagnostics")
end)

RegisterNUICallback("closeUI", function(data, cb)
    DebugPrint("UI closed via NUI callback")
    TriggerServerEvent("muhaddil_obd:closeUI")
    SetNuiFocus(false, false)
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
