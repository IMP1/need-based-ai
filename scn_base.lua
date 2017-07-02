local Scene = {}
Scene.__index = Scene
function Scene:__tostring()
    return "Scene " .. self._name
end

function Scene.new(name)
    local this = {}
    this._name = name
    return this
end

function Scene:load()
    
end

function Scene:keypressed(key, isRepeat)

end

function Scene:textinput(text)

end

function Scene:mousepressed(mx, my, key)

end

function Scene:mousereleased(mx, my, key)

end

function Scene:update(dt, mx, my)

end

function Scene:draw()

end

function Scene:close()

end

return Scene
