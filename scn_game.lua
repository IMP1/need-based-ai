---------------
-- Constants --
---------------
local GAME_TIMER_SPEEDS = { 1, 60, 600, 3600 }

-------------
-- Classes --
-------------
local SceneBase = require 'scn_base'
local Person    = require 'cls_person'

local SceneGame = {}
-- setmetatable(SceneGame, { __index = SceneBase} )
setmetatable(SceneGame, SceneBase )
SceneGame.__index = SceneGame

function SceneGame.new(address, port)
    local this = SceneBase.new("game")
    setmetatable(this, SceneGame)
    return this
end

function SceneGame:load()
    self.paused = false
    self.game_timer = 0
    self.game_timer_speed = 1
    self.people = {
        Person.new()
    }
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
        p:update(gdt)
    end
end

function SceneGame:draw()
    for _, p in pairs(self.people) do
        p:draw()
    end
    self.people[1]:drawInfo()
    self:drawTime()
end

function SceneGame:drawTime()
    local minutes = string.format("%02d", math.floor(self.game_timer / 60) % 60)
    local hours   = string.format("%02d", math.floor(self.game_timer / 60 / 60) % 60)
    love.graphics.print(hours .. ":" .. minutes, 0, 0)
    if self.paused then
        love.graphics.print("⏸", 64, 0)
    else
        love.graphics.print(string.rep("▶",self.game_timer_speed), 64, 0)
    end
end

return SceneGame