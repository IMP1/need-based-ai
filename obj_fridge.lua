local Object = require 'cls_object'
local Action = require 'cls_action'

local Fridge = {
    _AUTHOR      = 'Huw Taylor',
    _NAME        = 'Simple Fridge',
    _VERSION     = '1.0',
    _DESCRIPTION = 'A simple fridge for getting food from.',
    _URL         = '',
    _LICENSE     = '',
}
setmetatable(Fridge, Object)
Fridge.__index = Fridge

function Fridge.new(x, y)
    local this = Object.new("fridge", x, y, x, y+1)
    setmetatable(this, Fridge)
    return this
end

function Fridge:getAdvertisements()
    return {
        {
            utility = {
                hunger = 100,
            },
            duration = 60 * 30,
            actions = {
                Action.new("preparing food", {
                    inertia  = 10,
                    duration = 60 * 10,
                    object = self,
                    position = {self.position[1], self.position[2] + 1}
                }),
                Action.new("cooking food", {
                    inertia  = 10,
                    duration = 60 * 15,
                    object = self,
                    position = {self.position[1], self.position[2] + 1}
                }),
                Action.new("eating food", {
                    inertia  = 10,
                    duration = 60 * 10,
                    update = function(action, dt, actor)
                        local need = actor.needs.hunger
                        need:change(-dt)
                        need:change(-100 / need.rate * dt / action.duration)
                    end,
                    object = self,
                    position = {self.position[1], self.position[2] + 1}
                }),
            }
        },
    }
end

function Fridge:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("line", x, y + 6, 32, 20)
end

return Fridge