local SceneManager = require 'scn_scn_manager'

local Pathfinder = require 'jumper.pathfinder' -- For pathfinding
local Need   = require 'cls_need'
local Action = require 'cls_action'

local Person = {}
setmetatable(Person, Object)
Person.__index = Person

function Person.new(name, x, y)
    local this = {}
    setmetatable(this, Person)
    this.name = name
    this.needs = {
        sleep = Need.new("sleep", {
            formula = function(need_value)
                return -1 * math.max(0, (need_value - 100)) / 10
            end
        }),
        hunger = Need.new("hunger", {
            formula = function(need_value)
                return -1 * (need_value^ 2) / 10
            end
        }),
        bladder = Need.new("bladder", {
            formula = function(need_value)
                return -1 * (need_value ^ 2) / 100
            end
        }),
        health = Need.new("health", {
            formula = function(need_value)
                return -1 * (need_value ^ 2) / 10
            end,
            rate = 0,
        }),
        fun = Need.new("fun", {
            formula = function(need_value)
                return -10 * math.max(0, (need_value - 100)) / 10
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
    this.position = { x or 0, y or 0 }
    this.move_path = nil
    return this
end

function Person:totalHappiness()
    local happiness = 0
    for _, n in pairs(self.needs) do
        happiness = happiness + 0, n.formula(n.value)
    end
    return happiness
end

function Person:queueAction(action)
   table.insert(self.actions, action)
end

function Person:update(gdt, map, nearby_objects)
    -- perform current action
    -- if no action, determine next action
        -- Examine objects around you, and find out what they advertise
        -- Score each advertisement based on your current needs
        -- pick the best advertisement, get its action sequence
        -- Push the action sequence on your queue
    -- if nothing to do, idle
    if self.move_path then
        print(self.name)
        print("path length", #self.move_path._nodes)
        self:moveAlongPath(gdt)
        -- moooove
    elseif self.current_action then
        if self.current_action.object and not self.current_action.object:isAt(unpack(self.position)) then
            local myFinder = Pathfinder(map.grid, 'ASTAR', map.walkable) 

            -- Define start and goal locations coordinates
            local startx, starty = unpack(self.position)
            local end_position = self.current_action.position or self.current_action.object.position
            local endx, endy = unpack(end_position)

            -- Calculates the path, and its length
            self.move_path = myFinder:getPath(startx, starty, endx, endy)
            table.remove(self.move_path._nodes, 1)
            if self.move_path then
                for i, n in pairs(self.move_path._nodes) do
                    print(i, n, n:getX(), n:getY())
                end
            end
            print("path length", #self.move_path._nodes)
        else
            self.current_action:update(gdt, self)
            if self.current_action.finished then
                self.last_action = self.current_action
                self.current_action = nil
            end
        end
    elseif #self.actions > 0 then
        self.current_action = table.remove(self.actions, 1)
        self.current_action:start()
    else
        self:findBestAction(nearby_objects)
    end

    -- need satisfaction
    -- update needs based on current state
    for _, need in pairs(self.needs) do
        need:increase(gdt)
    end

end

function Person:moveAlongPath(gdt)
    if not self.move_path then return end
    local x, y = unpack(self.position)
    if self.move_path then
        for i, n in pairs(self.move_path._nodes) do
            print(i, n, n:getX(), n:getY())
        end
    end
    local current_target = self.move_path._nodes[1]
    print("current_target", current_target)
    print("move path", self.move_path)
    print("move path nodes", self.move_path._nodes)
    print("move path node #1", self.move_path._nodes[1])
    local x1, y1 = current_target:getX(), current_target:getY()

    local dx = (x1 - x) / math.abs(x1 - x)
    local dy = (y1 - y) / math.abs(y1 - y)
    local move_speed = 0.1

    local newX = x + dx * gdt * move_speed
    local newY = y + dy * gdt * move_speed

    local oldDist = math.abs(x1 - x) + math.abs(y1 - y)
    local newDist = math.abs(x1 - newX) + math.abs(y1 - newY)
    if newDist < oldDist then
        self.position[1] = newX
        self.position[2] = newY
        if newDist < 0.00001 then
            print(newDist)
            self.position = {x1, y1}
            table.remove(self.move_path._nodes, 1)
            if #self.move_path._nodes == 0 then
                self.move_path = nil
            end
        end
    else
        self.position = {x1, y1}
        table.remove(self.move_path._nodes, 1)
        if #self.move_path._nodes == 0 then
            self.move_path = nil
        end
    end
end

function Person:findBestAction(nearby_objects)
    local advertisements = {}
    for _, object in pairs(nearby_objects) do
        for _, advert in pairs(object:getAdvertisements(self, nearby_objects)) do
            table.insert(advertisements, advert)
        end
    end

    local best_happiness_increase = 0.0001
    local best_action = nil
    for _, action in pairs(advertisements) do
        local happiness_increase = 0
        for need_name, satisfaction in pairs(action.utility) do
            local need = self.needs[need_name]
            local need_after_action = math.max(0, need.value - satisfaction)
            happiness_increase = happiness_increase + need.formula(need_after_action) - need.formula(need.value)
        end
        if happiness_increase > best_happiness_increase then
            best_happiness_increase = happiness_increase
            best_action = action
        end
    end

    if best_action then
        for _, action in ipairs(best_action.actions) do
            self:queueAction(action)
        end
    elseif self.last_action and self.last_action.repeatable then
        self:queueAction(self.last_action)
    else
        self:queueAction(Action.new("idling", {
            duration = 60
        }))
    end
end

function Person:findNearestObject(objects, object_type, default)
    local shortest_distance = math.huge
    local nearest_object = nil

    for _, object in pairs(objects) do
        if object:isType(object_type) then
            local distance = math.abs(object.position[1] - self.position[1]) + 
                             math.abs(object.position[2] - self.position[2])
            if distance < shortest_distance then
                shortest_distance = distance
                nearest_object = object
            end
        end
    end

    if nearest_object then 
        return nearest_object
    elseif default then
        return default
    else
        return nil
    end
end

function Person:draw()
    local i, j = unpack(self.position)
    local x, y = (i-0.5) * 32, (j-0.5) * 32
    love.graphics.circle("fill", x, y, 16)
    if self.move_path and self.move_path._nodes[1] then
        local node1 = self.move_path._nodes[1]
        local x1, y1 = node1:getX() - 0.5, node1:getY() - 0.5
        love.graphics.line(x, y, x1 * 32, y1 * 32)
        for i = 1, #self.move_path._nodes - 1 do
            local node1 = self.move_path._nodes[i]
            local x1, y1 = node1:getX() - 0.5, node1:getY() - 0.5
            local node2 = self.move_path._nodes[i+1]
            local x2, y2 = node2:getX() - 0.5, node2:getY() - 0.5
            love.graphics.line(x1 * 32, y1 * 32, x2 * 32, y2 * 32)
        end
    end
end

function Person:drawActionQueue()
    local x = love.graphics.getWidth() - 16
    local y = 16
    if self.current_action then
        local text = self.current_action.name
        local w = love.graphics.getFont():getWidth(text)
        love.graphics.rectangle("line", x - w, y, w + 4, 20)
        love.graphics.print(text, x - w + 2, y + 2)
        local r1 = -math.pi / 2
        local r2 = 2 * math.pi * self.current_action:progress() - math.pi / 2
        love.graphics.circle("line", x - w - 12, y + 10, 6)
        love.graphics.arc(   "fill", x - w - 12, y + 10, 6, r1, r2)
        y = y + 24
    end
    for _, action in pairs(self.actions) do
        local text = action.name
        local w = love.graphics.getFont():getWidth(text)
        love.graphics.rectangle("line", x - w, y, w + 4, 20)
        love.graphics.print(text, x - w + 2, y + 2)
        y = y + 24
    end
end

function Person:drawInfo()
    local x = 360
    local y = 448
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