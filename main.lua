-- http://gameai.com/wiki/index.php?title=The_Sims
-- http://www.zubek.net/robert/publications/Needs-based-AI-draft.pdf
-- https://www.reddit.com/r/gamedev/comments/2dzp8l/decisionmaking_ai_in_the_sims/

-------------
-- Classes --
-------------
local SceneManager  = require 'scn_scn_manager'
local SceneHouse    = require 'scn_house'
local SceneArena    = require 'scn_arena'
local ObjectManager = require 'cls_object_manager'

function love.load()
    ObjectManager.loadObjects()
    local scene = SceneHouse.new()
    SceneManager.setScene(scene)
end

function love.keypressed(key, isRepeat)
    SceneManager.scene():keypressed(key, isRepeat)
    if key == "f1" and SceneManager:scene().name ~= "house" then
        local scene = SceneHouse.new()
        SceneManager.setScene(scene)
    end
    if key == "f2" and SceneManager:scene().name ~= "arena" then
        local scene = SceneArena.new()
        SceneManager.setScene(scene)
    end
end

function love.textinput(text)
    SceneManager.scene():keytyped(text)
end

function love.mousepressed(mx, my, key)
    SceneManager.scene():mousepressed(mx, my, key)
end

function love.mousereleased(mx, my, key)
    SceneManager.scene():mousereleased(mx, my, key)
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    SceneManager.scene():update(dt, mx, my)
end

function love.draw()
    SceneManager.scene():draw()
end