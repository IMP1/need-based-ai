---------------
-- Constants --
---------------
local GAME_TIMER_SPEEDS = { 1, 60, 600, 3600 }

-------------
-- Classes --
-------------
local SceneBase     = require 'scn_base'
local Action        = require 'cls_action'
local Person        = require 'cls_person'
local ObjectManager = require 'cls_object_manager'

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
        Person.new("Person #1", 7, 5)
    }
    self.objects = {
        ObjectManager.new("Huw Taylor/Simple Bed", 4, 4),
        ObjectManager.new("Huw Taylor/Toilet", 6, 8),
        ObjectManager.new("Huw Taylor/Simple Fridge", 9, 2),
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

function SceneGame:getAdvertisments()
    -- TODO: not have this hard-coded. Get these from the world.
    return {
        {
            object = "TV", -- TODO: make this reference to game object
            utility = {
                fun = 100,
            },
            action = Action.new("watching TV", {
                inertia  = 0,
                duration = 60 * 10,
                update = function(action, dt, actor)
                    local need = actor.needs.fun
                    need:change(-dt)
                    need:change(-10 / need.rate * dt / action.duration)
                end,
                repeatable = true,
            }),
        },
    }
end



function SceneGame:update(dt, mx, my)
    if self.paused then return end

    local gdt = dt * GAME_TIMER_SPEEDS[self.game_timer_speed]
    self.game_timer = self.game_timer + gdt

    local options = {}

    for _, o in pairs(self.objects) do
        o:update(gdt)
        for i, advert in pairs(o:getAdvertisements()) do
            table.insert(options, advert)
        end
    end

    for _, p in pairs(self.people) do
        p:update(gdt, options)
    end
end

function SceneGame:draw()
    love.graphics.setColor(128, 192, 255, 32)
    for i = 1, 32 do
        local x = i * 32
        love.graphics.line(x, 0, x, love.graphics.getHeight())
        love.graphics.line(0, x, love.graphics.getWidth(), x)
    end
    love.graphics.setColor(255, 255, 255)
    for _, o in pairs(self.objects) do
        o:draw()
    end
    for _, p in pairs(self.people) do
        p:draw()
    end
    self.people[1]:drawInfo()
    self:drawTime()
end

function SceneGame:drawTime()
    local minutes = string.format("%02d", math.floor(self.game_timer / 60) % 60)
    local hours   = string.format("%02d", math.floor(self.game_timer / 60 / 60) % 24)
    love.graphics.print(hours .. ":" .. minutes, 0, 0)
    if self.paused then
        love.graphics.print("⏸", 64, 0)
    else
        love.graphics.print(string.rep("▶",self.game_timer_speed), 64, 0)
    end
end

return SceneGame