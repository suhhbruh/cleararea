local QBCore = exports['qb-core']:GetCoreObject()
local zones = {}

--
Citizen.CreateThread(function()
    for groupName, zoneData in pairs(Config.Zones) do
        local zone = PolyZone:Create(zoneData.coords, {
            name = groupName,
            minZ = zoneData.minZ,
            maxZ = zoneData.maxZ,
            debugPoly = zoneData.debugPoly
        })
        zones[groupName] = {
            zone = zone,
            center = calculateZoneCenter(zoneData.coords),
            radius = calculateZoneRadius(zoneData.coords)
        }
    end
end)

Citizen.CreateThread(function()
    while true do
        for _, zoneData in pairs(zones) do
            ClearZoneOfEntities(zoneData.zone, zoneData.center, zoneData.radius)
        end
        Citizen.Wait(0)
    end
end)

--
function ClearZoneOfEntities(zone, center, radius)
    ClearAreaOfPeds(center.x, center.y, center.z, radius, false)
    ClearAreaOfVehicles(center.x, center.y, center.z, radius, false, false, false, false, false)
end

function calculateZoneCenter(coords)
    local sumX, sumY = 0, 0
    for _, coord in ipairs(coords) do
        sumX = sumX + coord.x
        sumY = sumY + coord.y
    end
    return vector3(sumX / #coords, sumY / #coords, 0)
end

function calculateZoneRadius(coords)
    local center = calculateZoneCenter(coords)
    local maxDistance = 0
    for _, coord in ipairs(coords) do
        local distance = #(vector2(coord.x, coord.y) - vector2(center.x, center.y))
        if distance > maxDistance then
            maxDistance = distance
        end
    end
    return maxDistance
end