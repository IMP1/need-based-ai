local Action = {}
Action.__index = Action
function Action:__tostring()
    return self.name
end

function Action.new(name, options)
    local this = {}
    setmetatable(this, Action)
    this.name = name
    this.inertia       = options.inertia    or 0 -- time it takes to stop the action
    this.duration      = options.duration   or 0
    this.onupdate      = options.update     or nil
    this.object        = options.object     or nil
    this.position      = options.position   or nil
    this.repeatable    = options.repeatable
    if this.repeatable == nil then 
        this.repeatable = false 
    end
    this.interruptible = options.interruptible
    if this.interruptible == nil then 
        this.interruptible = true 
    end
    this.cancellable   = options.cancellable
    if this.cancellable == nil then
        this.cancellable = true
    end
    return this
end

function Action:start()
    self.started  = true
    self.timer    = 0
    self.finished = false
    self.paused   = false
end

function Action:update(gdt, actor)
    if not self.started then return end
    if self.finished then return end
    if self.paused then return end

    self.timer = self.timer + gdt
    if self.timer >= self.duration then
        self.finished = true
        gdt = self.duration - self.timer
    end

    if self.onupdate then
        self:onupdate(gdt, actor)
    end
end

function Action:progress()
    if not self.started then return 0 end
    if self.finished then return 1 end

    return self.timer / self.duration
end

function Action:interupt()
    if not self.interruptible then return end
    self.paused = true
end

function Action:resume()
    if not self.paused then return end
    self.paused = false
end

function Action:cancel()
    if not self.cancellable then return end
    self.finished = true
end

return Action