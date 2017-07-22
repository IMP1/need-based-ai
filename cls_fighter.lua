local SceneManager = require 'scn_scn_manager'
local Pathfinder   = require 'jumper.pathfinder' -- For pathfinding
local Need         = require 'cls_need'
local Action       = require 'cls_action'
local Person       = require 'cls_person'

local Fighter = {}
setmetatable(Fighter, Person)
Fighter.__index = Fighter

function Fighter.new(name, x, y)
    local this = Person.new(name, x, y)
    setmetatable(this, Fighter)
    this.name = name
    this.needs = {
        bloodlust = Need.new("bloodlust", {
            formula = function(need_value)
                return -1 * math.max(0, (need_value)) / 10
            end,
            rate = 0
        }, 100),
        health = Need.new("health", {
            formula = function(need_value)
                return -1 * (need_value ^ 2) / 10
            end,
            rate = 0,
        }),
    }
    return this
end

function Fighter:isAt(x, y)
    return math.abs(self.position[1] - x) + math.abs(self.position[2] - y) == 1
end

function Fighter:getAdvertisements(actor, other_objects)
    local adverts = {}

    table.insert(adverts, {
        utility = {
            bloodlust = 100,
        },
        duration = 60 * 30,
        actions = {
            Action.new("attacking", {
                inertia  = 5,
                duration = 45,
                update = function(action, dt, actor)
                    local need = actor.needs.bloodlust
                    need:change(-dt * need.rate)
                    need:change(-50 * dt / action.duration)
                end,
                object = self,
                position = { unpack(self.position) },
            }),
        }
    })

    return adverts
end

return Fighter