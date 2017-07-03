-- http://gameai.com/wiki/index.php?title=The_Sims
-- http://www.zubek.net/robert/publications/Needs-based-AI-draft.pdf
-- https://www.reddit.com/r/gamedev/comments/2dzp8l/decisionmaking_ai_in_the_sims/

-------------
-- Classes --
-------------
local SceneManager  = require 'scn_scn_manager'
local SceneGame     = require 'scn_game'
local ObjectManager = require 'cls_object_manager'

function love.load()
    ObjectManager.loadObjects()
    local scene = SceneGame.new()
    SceneManager.setScene(scene)
end

function love.keypressed(key, isRepeat)
    SceneManager.scene():keypressed(key, isRepeat)
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