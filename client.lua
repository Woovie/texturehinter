local w, h = guiGetScreenSize()
local fontHeight = dxGetFontHeight()

local scanning = false
local hitData = {
  currentTarget = nil,
  modelName = "",
  textures = {},
  hitpoint = {},
  position = {},
  groundZ = 0.0,
  detailsText = ""
}

function clientRender()
  if (scanning) then
    local sx, sy, sz = getWorldFromScreenPosition(w/2, h/2, 20) -- 5 units away
    local camx, camy, camz, camrx, camry, camrz, uh, uhh = getCameraMatrix()
    local hit, hitx, hity, hitz, elementHit, hitnormx, hitnormy, hitnormz, mat, lighting, piece, worldModelID, worldModelX, worldModelY, worldModelZ, worldModelRX, worldModelRY, worldModelRZ, worldLODModelID = processLineOfSight(camx, camy, camz, sx, sy, sz, true, false, false, false, false, true, true, true, nil, true, false)
    if (worldModelID) then -- We hit something
      hitData.currentTarget = worldModelID
      hitData.modelName = engineGetModelNameFromID(worldModelID)
      hitData.position = {
        x = worldModelX,
        y = worldModelY,
        z = worldModelZ
      }
      local textures = engineGetModelTextures(worldModelID)
      local t = { }
      for textureName, texture in pairs(textures) do
        t[#t+1] = textureName
      end
      -- hitData.textureNames = t
      hitData.hitpoint = {
        x = hitx,
        y = hity,
        z = hitz
      }
      hitData.groundZ = getGroundPosition(hitData.position.x, hitData.position.y, hitData.position.z)
      hitData.detailsText = "Name: " .. hitData.modelName .. "\nModel ID: " .. hitData.currentTarget .. "\nTextures:\n  - " .. table.concat(t, "\n  - ")
      scanning = false
      outputChatBox("Hit " .. hitData.modelName)
    end
  end
  if (hitData.currentTarget) then
    local camx, camy, camz, camrx, camry, camrz, uh, uhh = getCameraMatrix()
    local psx, psy, psz = getElementPosition(localPlayer)
    -- dxDrawLine3D(camx, camy, camz - 0.5, hitData.hitpoint.x, hitData.hitpoint.y, hitData.hitpoint.z, 0xFF0000FF, 2)
    dxDrawLine3D(psx, psy, psz, hitData.position.x, hitData.position.y, hitData.position.z, 0xFFFF00FF, 2)
    local drawx, drawy = getScreenFromWorldPosition(hitData.position.x, hitData.position.y, hitData.groundZ)
    if (drawx) then
      dxDrawText(hitData.modelName, drawx, drawy, drawx, drawy, 0xFFFF00FF, 3, 3)
    end
    dxDrawText(hitData.detailsText, 20 - 1, 200 - 1, 200 - 1, 600 - 1, 0xFF000000, 1.5, 1.5)
    dxDrawText(hitData.detailsText, 20 + 1, 200 - 1, 200 + 1, 600 - 1, 0xFF000000, 1.5, 1.5)
    dxDrawText(hitData.detailsText, 20 - 1, 200 + 1, 200 - 1, 600 + 1, 0xFF000000, 1.5, 1.5)
    dxDrawText(hitData.detailsText, 20 + 1, 200 + 1, 200 + 1, 600 + 1, 0xFF000000, 1.5, 1.5)
    dxDrawText(hitData.detailsText, 20, 200, 200, 600, 0xFFFFFFFF, 1.5, 1.5)
  end
end

function enableScanning()
  scanning = true
  outputChatBox("Scanning enabled")
end

function toggleScanningKeybind(button, pressOrRelease)
  if (button == "lalt") then
    scanning = pressOrRelease
  end
end

addCommandHandler("scanning", enableScanning)
addEventHandler("onClientRender", root, clientRender)
addEventHandler("onClientKey", root, toggleScanningKeybind)