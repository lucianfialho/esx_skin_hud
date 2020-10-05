RegisterNetEvent('esx_skin_hud:OpenNui')
AddEventHandler('esx_skin_hud:OpenNui', function()
    SetNuiFocus(false,false)
    TriggerEvent('skinchanger:getSkin', function(skin)
        lastSkin = skin
    end)

    TriggerEvent('skinchanger:getData', function(components, maxVals)
        local elements    = {}
        local _components = {}
        
        for i=1, #components, 1 do
            _components[i] = components[i]
        end
        
        for i=1, #_components, 1 do
            local value       = _components[i].value
            local componentId = _components[i].componentId

            if componentId == 0 then
                value = GetPedPropIndex(playerPed, _components[i].componentId)
            end

            local data = {
                label     = _components[i].label,
                name      = _components[i].name,
                value     = value,
                min       = _components[i].min,
                textureof = _components[i].textureof,
                zoomOffset= _components[i].zoomOffset,
                camOffset = _components[i].camOffset,
            }

            for k,v in pairs(maxVals) do
                if k == _components[i].name then
                    data.max = v
                    break
                end
            end
            table.insert(elements, data)
        end

        CreateSkinCam()
        zoomOffset = _components[1].zoomOffset
        camOffset = _components[1].camOffset

        local playerPed = PlayerPedId()
        local coords    = GetEntityCoords(playerPed)

        local angle = heading * math.pi / 180.0
        local theta = {
            x = math.cos(angle),
            y = math.sin(angle)
        }

        local pos = {
            x = coords.x + (zoomOffset * theta.x),
            y = coords.y + (zoomOffset * theta.y)
        }
        local angle = 90
        local angleToLook = heading - 140.0
        if angleToLook > 360 then
            angleToLook = angleToLook - 360
        elseif angleToLook < 0 then
            angleToLook = angleToLook + 360
        end

        angleToLook = angleToLook * math.pi / 180.0
        local thetaToLook = {
            x = math.cos(angleToLook),
            y = math.sin(angleToLook)
        }

        local posToLook = {
            x = coords.x + (zoomOffset * thetaToLook.x),
            y = coords.y + (zoomOffset * thetaToLook.y)
        }

        SetCamCoord(cam, pos.x, pos.y, coords.z + camOffset)
        PointCamAtCoord(cam, posToLook.x, posToLook.y, coords.z + camOffset)

        SetNuiFocus(true, true)
        SendNUIMessage({ showSkinHud = true, components = elements})
    end)
end)