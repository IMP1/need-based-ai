local Object = {}
Object.__index = Object

function Object.new(name, x, y, usageX, usageY)
    local this = {}
    this.name = name
    this.position = {x or 0, y or 0}
    this.usage_position = { usageX or this.position[1], usageY or this.position[2] }
    return this
end

function Object:isAt(x, y)
    return self.usage_position[1] == x and self.usage_position[2] == y
end

function Object:update(gdt)
end

function Object:getAdvertisements()
    return {}
end

function Object:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("fill", x, y, 32, 32)
end

return Object