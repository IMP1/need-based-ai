local Need = {}
Need.__index = Need

function Need.new(name, options, start_value)
    local this = {}
    setmetatable(this, Need)
    this.name    = name
    this.value   = start_value or 0
    this.rate    = options.rate or 1 / 100
    this.formula = options.formula
    return this
end

function Need:increase(gdt)
    self:change(gdt * self.rate)
end

function Need:change(dv)
    self.value = math.max(0, self.value + dv)
    -- self.value = math.min(self.value, 100)
end

return Need