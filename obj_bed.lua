local Object = require 'cls_object'
local Action = require 'cls_action'

local Bed = {
    _AUTHOR      = 'Huw Taylor',
    _NAME        = 'Simple Bed',
    _VERSION     = '1.0',
    _DESCRIPTION = 'A simple bed for restoring energy',
    _URL         = '',
    _LICENSE     = '',
}
setmetatable(Bed, Object)
Bed.__index = Bed

function Bed.new(x, y)
    local this = Object.new("bed", {
        position = {x, y},
    })
    this.categories = {"bed"}
    setmetatable(this, Bed)
    return this
end

function Bed:getAdvertisements(actor)
    return {
        {
            utility = {
                sleep = 100,
            },
            duration = 60 * 60 * 4,
            actions = {
                Action.new("sleeping", {
                    inertia  = 60,
                    duration = 60 * 60 * 4,
                    update = function(action, dt, actor)
                        local need = actor.needs.sleep
                        need:change(-dt)
                        need:change(-100 / need.rate * dt / action.duration)
                    end,
                    repeatable = true,
                    object = self
                }),
            },
        },
        {
            utility = {
                sleep = 30,
            },
            duration = 60 * 45,
            action = Action.new("napping", {
                inertia  = 60,
                duration = 60 * 45,
                update = function(action, dt, actor)
                    local need = actor.needs.sleep
                    need:change(-dt)
                    need:change(-30 / need.rate * dt / action.duration)
                end,
                object = self
            }),
        },
    }
end

function Bed:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("line", x - 12, y, 60, 32)
end

return Bed