local Need   = require 'cls_need'
local Action = require 'cls_action'

local Person = {}
Person.__index = Person

function Person.new(name)
    local this = {}
    setmetatable(this, Person)
    this.name = name
    this.needs = {
        sleep = Need.new("sleep", {
            formula = function(need_value)
                return -10 * ((need_value + 100) / 10) 
            end
        }),
        hunger = Need.new("hunger", {
            formula = function(need_value)
                return -10 * (((need_value + 100) / 10) ^ 2)
            end
        }),
        bladder = Need.new("bladder", {
            formula = function(need_value)
                return -1 * (((need_value + 100) / 10) ^ 2)
            end
        }),
        health = Need.new("health", {
            formula = function(need_value)
                return -10 * ((need_value / 10) ^ 2)
            end,
            rate = 0,
        }),
        fun = Need.new("fun", {
            formula = function(need_value)
                return -10 * ((need_value + 100) / 10)
            end
        }),
    }
    this.actions = {}
    this.last_action = nil
    this.current_action = nil
    this:queueAction(Action.new("idling", {
        duration = 60,
        repeatable = true
    }))
    this.position = { 120, 240 }
    return this
end

function Person:totalHappiness()
    local happiness = 0
    for _, n in pairs(self.needs) do
        happiness = happiness + n.formula(n.value)
    end
    return happiness
end

function Person:queueAction(action)
   table.insert(self.actions, action)
end

function Person:update(gdt)
    -- perform current action
    -- if no action, determine next action
        -- Examine objects around you, and find out what they advertise
        -- Score each advertisement based on your current needs
        -- pick the best advertisement, get its action sequence
        -- Push the action sequence on your queue
    -- if nothing to do, idle

    if self.current_action then
        self.current_action:update(gdt)
        if self.current_action.finished then
            self.last_action = self.current_action
            self.current_action = nil
        end
    elseif #self.actions > 0 then
        self.current_action = table.remove(self.actions, 1)
        self.current_action:start()
    else
        self:findBestAction()
    end

    -- need satisfaction
    -- update needs based on current state
    for _, need in pairs(self.needs) do
        need:increase(gdt)
    end

end

function Person:getAdvertisments()
    -- TODO: not have this hard-coded. Get these from the world.
    return {
        {
            object = "bed", -- TODO: make this reference to game object
            utility = {
                sleep = 100,
            },
            action = Action.new("sleeping", {
                inertia  = 60,
                duration = 60 * 60 * 4,
                update = function(action, dt)
                    local need = self.needs.sleep
                    need:change(-dt)
                    need:change(-100 / need.rate * dt / action.duration)
                end
            }),
        },
        {
            object = "fridge", -- TODO: make this reference to game object
            utility = {
                hunger = 100,
            },
            action = Action.new("eating", {
                inertia  = 10,
                duration = 60 * 15,
                update = function(action, dt)
                    local need = self.needs.hunger
                    need:change(-dt)
                    need:change(-100 / need.rate * dt / action.duration)
                end
            }),
        },
        {
            object = "toilet", -- TODO: make this reference to game object
            utility = {
                bladder = 100,
            },
            action = Action.new("toileting", {
                inertia  = 45,
                duration = 60 * 5,
                update = function(action, dt)
                    local need = self.needs.bladder
                    need:change(-dt)
                    need:change(-100 / need.rate * dt / action.duration)
                end
            }),
        },
        {
            object = "TV", -- TODO: make this reference to game object
            utility = {
                fun = 100,
            },
            action = Action.new("watching TV", {
                inertia  = 0,
                duration = 60 * 10,
                update = function(action, dt)
                    local need = self.needs.fun
                    need:change(-dt)
                    need:change(-10 / need.rate * dt / action.duration)
                end,
                repeatable = true,
            }),
        },
    }
end

function Person:findBestAction()
    local best_happiness_increase = 0.0001
    local best_action = nil
    for _, action in pairs(self:getAdvertisments()) do
        local happiness_increase = 0
        for need_name, satisfaction in pairs(action.utility) do
            local need = self.needs[need_name]
            local need_after_action = math.max(0, need.value - satisfaction)
            happiness_increase = happiness_increase + need.formula(need_after_action) - need.formula(need.value)
            print(need_name, need.formula(need_after_action) - need.formula(need.value))
        end
        if happiness_increase > best_happiness_increase then
            best_happiness_increase = happiness_increase
            best_action = action
        end
    end

    if best_action == nil then
        if self.last_action and self.last_action.repeatable then
            self:queueAction(self.last_action)
        else
            self:queueAction(Action.new("idling", {
                duration = 60
            }))
        end
        return
    end

    self:queueAction(best_action.action)
end

function Person:draw()
    local x, y = unpack(self.position)
    love.graphics.circle("fill", x, y, 16)
    if self.current_action then
        love.graphics.print(self.current_action.name, x - 16, y - 32)
        local r1 = -math.pi / 2
        local r2 = 2 * math.pi * self.current_action:progress() - math.pi / 2
        love.graphics.circle("line", x, y - 42, 6)
        love.graphics.arc("fill", x, y - 42, 6, r1, r2)
    end
end

function Person:drawInfo()
    local x = 316
    local y = 16
    for _, need in pairs(self.needs) do
        love.graphics.print(need.name, x, y)
        love.graphics.print(need.value, x + 64, y)
        love.graphics.print(need.formula(need.value), x + 256, y)
        y = y + 24
    end
    love.graphics.print("Total Happiness", x, y)
    love.graphics.print(self:totalHappiness(), x + 128, y)
end

return Person