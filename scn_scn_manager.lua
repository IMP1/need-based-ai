local SceneManager = {}

local current_scene = nil
local scene_stack = {}

local function closeScene()
    if current_scene then
        current_scene:close()
    end
end

local function loadScene()
    if current_scene then
        current_scene:load()
    end
end

function SceneManager.scene()
    return current_scene
end

function SceneManager.setScene(new_scene)
    closeScene()
    current_scene = new_scene
    loadScene()
end

function SceneManager.pushScene(new_scene)
    table.insert(scene_stack, current_scene)
    current_scene = new_scene
    loadScene()
end

function SceneManager.popScene()
    closeScene()
    current_scene = table.remove(scene_stack)
end

------------------------------------------------
-- Methods to pass along to relevant scene(s) --
------------------------------------------------
function SceneManager.keypressed(key, is_repeat)
    if current_scene and current_scene.keypressed then 
        current_scene:keypressed(key, is_repeat)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundKeypressed then
            scene:backgroundKeypressed()
        end
    end
end

function SceneManager.textinput(text)
    if current_scene and current_scene.keytyped then
        current_scene:keytyped(text)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundTextinput then
            scene:backgroundTextinput()
        end
    end
end

function SceneManager.mousepressed(mx, my, key)
    if current_scene and current_scene.mousepressed then
        current_scene:mousepressed(mx, my, key)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundMousepressed then
            scene:backgroundMousepressed()
        end
    end
end

function SceneManager.mousereleased(mx, my, key)
    if current_scene and current_scene.mousereleased then
        current_scene:mousereleased(mx, my, key)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundMousereleased then
            scene:backgroundMousereleased()
        end
    end
end

function SceneManager.update(dt)
    local mx, my = love.mouse.getPosition()
    if current_scene and current_scene.update then
        current_scene:update(dt, mx, my)
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundUpdate then
            scene:backgroundUpdate()
        end
    end
end

function SceneManager.draw()
    if current_scene and current_scene.draw then
        current_scene:draw()
    end
    for _, scene in pairs(scene_stack) do
        if scene and scene.backgroundDraw then
            scene:backgroundDraw()
        end
    end
end

return SceneManager