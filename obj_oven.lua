local Object = require 'cls_object'
local Action = require 'cls_action'

local Oven = {
    _AUTHOR      = 'Huw Taylor',
    _NAME        = 'Oven',
    _VERSION     = '1.0',
    _DESCRIPTION = 'An oven and hobs for cooking meals.',
    _URL         = '',
    _LICENSE     = '',
}
setmetatable(Oven, Object)
Oven.__index = Oven

function Oven.new(x, y)
    local this = Object.new("oven", {
        position = {x, y},
        usage_positions = {
            {x, y+1},
        }
    })
    this.categories = {"cooker"}
    setmetatable(this, Oven)
    return this
end

function Oven:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("line", x, y+2, 32, 28)
end

return Oven