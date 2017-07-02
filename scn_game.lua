-------------
-- Classes --
-------------
local SceneBase = require 'scn_base'

local SceneGame = {}
setmetatable(SceneGame, { __index = SceneBase} )
-- setmetatable(SceneGame, SceneBase )
SceneGame.__index = SceneGame

function SceneGame.new(address, port)
    local this = SceneBase.new("game")
    setmetatable(this, SceneGame)
    return this
end

return SceneGame