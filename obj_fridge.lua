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
    local this = Object.new("fridge", {
        position        = {x, y},
        usage_positions = {
            {x, y+1},
        }
    })
    table.insert(this.categories, "fridge")
    setmetatable(this, Fridge)
    return this
end

function Fridge:getAdvertisements(actor, other_objects)
    local adverts = {}

    local counter      = actor:findNearestObject(other_objects, "counter")
    local cooker       = actor:findNearestObject(other_objects, "cooker")
    local dining_table = actor:findNearestObject(other_objects, "table")

    if counter and cooker then
        local food_actions = {
            Action.new("getting ingredients", {
                inertia  = 10,
                duration = 45,
                object = self,
                position = self:usagePosition("fridge")
            }),
            Action.new("preparing food", {
                inertia  = 10,
                duration = 60 * 10,
                object = counter,
                position = counter:usagePosition("counter")
            }),
            Action.new("cooking food", {
                inertia  = 10,
                duration = 60 * 15,
                object = cooker,
                position = cooker:usagePosition("cooker")
            }),
        }
        if dining_table then
            table.insert(food_actions, Action.new("eating food", {
                inertia  = 10,
                duration = 60 * 10,
                update = function(action, dt, actor)
                    local need = actor.needs.hunger
                    need:change(-dt)
                    need:change(-100 / need.rate * dt / action.duration)
                end,
                object = dining_table,
                position = dining_table:usagePosition("table")
            }))
        else
            table.insert(food_actions, Action.new("eating food", {
                inertia  = 10,
                duration = 60 * 10,
                update = function(action, dt, actor)
                    local hunger_need = actor.needs.hunger
                    hunger_need:change(-dt)
                    hunger_need:change(-100 / hunger_need.rate * dt / action.duration)
                    local toilet_need = actor.needs.bladder
                    toilet_need:change(30 / toilet_need.rate * dt / action.duration)
                end,
                object = nil
            }))
        end
        table.insert(adverts, {
            utility = {
                hunger = 100,
            },
            duration = 60 * 30,
            actions = food_actions
        })
    end

    return adverts
end

function Fridge:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("line", x, y + 6, 32, 20)
end

return Fridge