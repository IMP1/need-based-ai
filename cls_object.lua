local Object = {}
Object.__index = Object

function Object.new(name, options)
    local this = {}
    this.name = name
    this.position = options.position or {0, 0}
    this.usage_positions = options.usage_positions or { {this.position[1], this.position[2]} }
    this.categories = {}
    return this
end

function Object:usagePosition(purpose)
    return self.usage_positions[1]
end

function Object:isAt(x, y)
    for _, pos in pairs(self.usage_positions) do
        if pos[1] == x and pos[2] == y then return true end
    end
    return false
    -- return self.usage_position[1] == x and self.usage_position[2] == y
end

function Object:isType(object_type)
    for _, category in pairs(self.categories) do
        if category == object_type then return true end
    end
    return false
end

function Object:update(gdt)
end

function Object:getAdvertisements(actor, other_objects)
    return {}
end

function Object:draw()
    local i, j = unpack(self.position)
    local x, y = (i-1) * 32, (j-1) * 32
    love.graphics.rectangle("fill", x, y, 32, 32)
end

return Object