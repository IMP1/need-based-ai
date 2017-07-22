---------------
-- Constants --
---------------
local GAME_TIMER_SPEEDS = { 1, 60, 600, 3600 }

-------------
-- Classes --
-------------
local Grid          = require 'jumper.grid' -- For pathfinding
local SceneBase     = require 'scn_base'
local Action        = require 'cls_action'
local Fighter       = require 'cls_fighter'
local ObjectManager = require 'cls_object_manager'

local SceneGame = {}
-- setmetatable(SceneGame, { __index = SceneBase} )
setmetatable(SceneGame, SceneBase )
SceneGame.__index = SceneGame

function SceneGame.new()
    local this = SceneBase.new("arena")
    setmetatable(this, SceneGame)
    return this
end

function SceneGame:load()
    self.paused = false
    self.game_timer = 0
    self.game_timer_speed = 1
    self.people = {
        Fighter.new("Person #1", 3, 6),
        Fighter.new("Person #2", 12, 6)
    }
    self.map = {
        map = {
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,1,0,0,0,0,0,0,1,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,1,0,0,0,0,0,0,1,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        },
        walkable = 0,
    }
    self.map.grid = Grid(self.map.map)
end

function SceneGame:keypressed(key, isRepeat)
    if key == "up" and self.game_timer_speed < #GAME_TIMER_SPEEDS then
        self.game_timer_speed = self.game_timer_speed + 1
    end
    if key == "down" and self.game_timer_speed > 1 then
        self.game_timer_speed = self.game_timer_speed - 1
    end
    if key == "space" then
        self.paused = not self.paused
    end
    if key == "escape" and self.people[1].current_action then
        self.people[1].current_action:cancel()
    end
end

function SceneGame:update(dt, mx, my)
    if self.paused then return end

    local gdt = dt * GAME_TIMER_SPEEDS[self.game_timer_speed]
    self.game_timer = self.game_timer + gdt

    for _, p in pairs(self.people) do
        p:update(gdt, self.map, self.people)
    end
end

function SceneGame:draw()
    love.graphics.setColor(128, 192, 255, 32)
    for j, row in pairs(self.map.map) do
        for i, tile in pairs(row) do
            local mode = "line"
            local colour = {128, 192, 255, 32}
            if tile == 1 then
                mode = "fill"
            end
            love.graphics.setColor(unpack(colour))
            love.graphics.rectangle(mode, (i-1) * 32, (j-1) * 32, 32, 32)
        end
    end
    love.graphics.setColor(255, 255, 255)
    for _, p in pairs(self.people) do
        p:draw()
        p:drawActionQueue()
        p:drawInfo()
    end
end

return SceneGame