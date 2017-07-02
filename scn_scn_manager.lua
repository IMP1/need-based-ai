local SceneManager = {}

local currentScene = nil
local sceneStack = {}

local function closeScene()
    if currentScene then
        currentScene:close()
    end
end

local function loadScene()
    if currentScene then
        currentScene:load()
    end
end

function SceneManager.scene()
    return currentScene
end

function SceneManager.setScene(newScene)
    closeScene()
    currentScene = newScene
    loadScene()
end

-- TODO: decide whether the other scenes in the stack should also be updated and stuff.
--       at the moment, only the current scene is updated, but the others are not 
--       disposed of.
function SceneManager.pushScene(newScene)
    table.insert(sceneStack, newScene)
    currentScene = newScene
    loadScene()
end

function SceneManager.popScene()
    closeScene()
    currentScene = table.remove(sceneStack)
end

return SceneManager