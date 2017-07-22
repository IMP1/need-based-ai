local Object = require 'cls_object'
local Action = require 'cls_action'

local Table = {
    _AUTHOR      = 'Huw Taylor',
    _NAME        = 'Table',
    _VERSION     = '1.0',
    _DESCRIPTION = 'A table for eating or sitting at.',
    _URL         = '',
    _LICENSE     = '',
}
setmetatable(Table, Object)
Table.__index = Table

function Table.new(x, y)
    local this = Object.new("table", {
        position = {x, y},
        usage_positions = {
            {x, y-1},
            {x-1, y},
        }
    })
    this.categories = {"counter", "table"}
    setmetatable(this, Table)
    return this
end

function Table:usagePosition(purpose)
    if purpose == "counter" then
        return self.usage_positions[1]
    elseif purpose == "table" then
        return self.usage_positions[2]
    else
        return self.usage_positions[1]
    end
end

function Table:getAdvertisements(actor)
    return {
        {
            utility = {
                fun = 50,
            },
            actions = {
                Action.new("sitting", {
                    inertia  = 45,
                    duration = 60 * 5,
                    update = function(action, gdt, actor)
                        local need = actor.needs.fun
                        need:change(-gdt)
                        need:change(-50 * gdt / action.duration)
                    end,
                    object = self,
                    position = self:usagePosition("table")
                }),
            }
        },
    }
end

function Table:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("line", x-4, y-4, 40, 40)
end

return Table