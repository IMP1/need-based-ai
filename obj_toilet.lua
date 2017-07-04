local Object = require 'cls_object'
local Action = require 'cls_action'

local Toilet = {
    _AUTHOR      = 'Huw Taylor',
    _NAME        = 'Toilet',
    _VERSION     = '1.0',
    _DESCRIPTION = 'A toilet for relieving the digestive system',
    _URL         = '',
    _LICENSE     = '',
}
setmetatable(Toilet, Object)
Toilet.__index = Toilet

function Toilet.new(x, y)
    local this = Object.new("toilet", {
        position = {x, y},
    })
    table.insert(this.categories, "toilet")
    setmetatable(this, Toilet)
    return this
end

function Toilet:getAdvertisements(actor)
    return {
        {
            utility = {
                bladder = 100,
            },
            actions = {
                Action.new("toileting", {
                    inertia  = 45,
                    duration = 60 * 5,
                    update = function(action, gdt, actor)
                        local need = actor.needs.bladder
                        need:change(-gdt)
                        need:change(-100 / need.rate * gdt / action.duration)
                    end,
                    object = self
                }),
            }
        },
    }
end

function Toilet:draw()
    local i, j = unpack(self.position)
    local x, y = (i-0.5) * 32, (j-0.5) * 32
    love.graphics.circle("line", x, y, 12)
end

return Toilet