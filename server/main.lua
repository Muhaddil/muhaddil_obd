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

-- local function TranslateDates(servicing)
--     local translated = {
--         ["Bujías"] = string.format("%.2f%%", servicing.sparkPlugs or 0),
--         ["Pastillas de freno"] = string.format("%.2f%%", servicing.brakePads or 0),
--         ["Batería"] = string.format("%.2f%%", servicing.evBattery or 0),
--         ["Filtro de aire"] = string.format("%.2f%%", servicing.airFilter or 0),
--         ["Refrigerante"] = string.format("%.2f%%", servicing.evCoolant or 0),
--         ["Suspensión"] = string.format("%.2f%%", servicing.suspension or 0),
--         ["Embrague"] = string.format("%.2f%%", servicing.clutch or 0),
--         ["Neumáticos"] = string.format("%.2f%%", servicing.tyres or 0),
--         ["Motor"] = string.format("%.2f%%", servicing.evMotor or 0),
--         ["Aceite del motor"] = string.format("%.2f%%", servicing.engineOil or 0)
--     }
--     return translated
-- end

local function TranslateDates(servicing) -- Translate this to your needs
    return {
        motor = {
            ["Aceite del motor"] = string.format("%.2f%%", servicing.engineOil or 0),
            ["Bujías"] = string.format("%.2f%%", servicing.sparkPlugs or 0),
            ["Motor"] = string.format("%.2f%%", servicing.evMotor or 0),
            ["Refrigerante"] = string.format("%.2f%%", servicing.evCoolant or 0)
        },
        rendimiento = {
            ["Filtro de aire"] = string.format("%.2f%%", servicing.airFilter or 0),
            ["Suspensión"] = string.format("%.2f%%", servicing.suspension or 0),
            ["Embrague"] = string.format("%.2f%%", servicing.clutch or 0),
            ["Neumáticos"] = string.format("%.2f%%", servicing.tyres or 0),
            ["Pastillas de freno"] = string.format("%.2f%%", servicing.brakePads or 0),
        },
        diagnostico = {
            ["Batería"] = string.format("%.2f%%", servicing.evBattery or 0)
        }
    }
end

RegisterServerEvent("muhaddil_obd:getVehicleData")
AddEventHandler("muhaddil_obd:getVehicleData", function(plate, vehicle)
    local src = source

    MySQL.Async.fetchScalar("SELECT data FROM mechanic_vehicledata WHERE plate = @plate", {
        ['@plate'] = plate
    }, function(data)
        if data then
            local parsedData = json.decode(data)
            local servicing = parsedData.servicingData

            if not servicing then
                servicing = {
                    lastService = "No data",
                    nextService = "No data"
                }
            end

            local trServicing = TranslateDates(servicing)
            DebugPrint("Translated servicing data:", json.encode(trServicing))
            TriggerClientEvent("muhaddil_obd:openUI", src, trServicing, vehicle)
        else
            TriggerClientEvent("muhaddil_obd:SendNotification", src, "OBD", "No se encontraron datos del vehículo.", 5000,
            "error")
        end
    end)
end)

RegisterServerEvent("muhaddil_obd:closeUI")
AddEventHandler("muhaddil_obd:closeUI", function()
    DebugPrint("Close OBD UI event triggered for source:", source)
    -- No action needed here, just a placeholder for potential future logic
end)

function CreateUseableItem(name, cb)
    if Framework == "esx" then
        ESX.RegisterUsableItem(name, cb)
    elseif Framework == "qb" then
        QBCore.Functions.CreateUseableItem(name, cb)
    else
        print("Unsupported framework for CreateUseableItem")
    end
end

CreateUseableItem(Config.OBDItem, function(source, item)
    TriggerClientEvent('muhaddil_obd:toggleOBDTablet', source)
end)
