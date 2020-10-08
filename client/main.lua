local lastSkin, playerLoaded, cam, isCameraActive
local zoomOffset, camOffset, heading, skinLoaded = true, 0.0, 0.0, 90.0, false


function CreateSkinCam()
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    local playerPed = PlayerPedId()

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)

    isCameraActive = true
    SetCamRot(cam, 0.0, 0.0, 270.0, true)
    SetEntityHeading(playerPed, 0.0)
end

function DeleteSkinCam()
    isCameraActive = false
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 500, true, true)
    cam = nil
end

function loadCamera(camOffset, zoomOffset)
    CreateSkinCam()

    DisableControlAction(2, 30, true)
    DisableControlAction(2, 31, true)
    DisableControlAction(2, 32, true)
    DisableControlAction(2, 33, true)
    DisableControlAction(2, 34, true)
    DisableControlAction(2, 35, true)
    DisableControlAction(0, 25, true) -- Input Aim
    DisableControlAction(0, 24, true) -- Input Attack

    local angle = 90
    
    if isCameraActive then
        if angle > 360 then
            angle = angle - 360
        elseif angle < 0 then
            angle = angle + 360
        end

        heading = angle + 0.0
    end

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

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    print(coords.z + camOffset)

    SetCamCoord(cam, pos.x, pos.y, coords.z + camOffset)
    PointCamAtCoord(cam, posToLook.x, posToLook.y, coords.z + camOffset)

end

RegisterNetEvent('esx_skin_hud:OpenNui')
AddEventHandler('esx_skin_hud:OpenNui', function()

    SetNuiFocus(false,false)
    DeleteSkinCam()

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

            if data.max ~= 0 then
                table.insert(elements, data)
            end
        end

        zoomOffset = _components[1].zoomOffset
        camOffset = _components[1].camOffset

        loadCamera(zoomOffset, camOffset)
        SetNuiFocus(true, true)
        SendNUIMessage({ showSkinHud = true, components = elements})
    end)
end)


RegisterNUICallback('esx_skin_hud:ChangeOption', function(data, cb)
    TriggerEvent('skinchanger:change', data.data.name, data.data.value)
    cb('OK')
end)


RegisterNUICallback('esx_skin_hud:ChangeCameraOffSet', function(data, cb)
    loadCamera(data.data.camOffset, data.data.zoomOffset)
    cb('OK')
end)


RegisterNUICallback('esx_skin_hud:SavePersonSkin', function(data, cb)
    DeleteSkinCam()
    SetNuiFocus(false, false)
    
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('esx_skin:save', skin)

        cb({ success = true, showSkinHud = false, components = ''})
    end)
end)

