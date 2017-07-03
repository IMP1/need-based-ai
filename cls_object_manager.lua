local Object = {}

local objects = {}

local function loadObject(filename)
    print("loaded object:", filename)
    local obj = love.filesystem.load(filename)()
    local name = obj._AUTHOR .. '/' .. obj._NAME
    objects[name] = obj
end

function Object.loadObjects(path, func)
    path = path or "."
    func = func or function(filename)
        local prefix = "obj_"
        return string.sub(filename,1,string.len(prefix)) == prefix
    end
    local objectFilenames = love.filesystem.getDirectoryItems(path)
    for _, filename in pairs(objectFilenames) do
        if func(filename) then
            loadObject(filename)
        end
    end
end

function Object.new(name, ...)
    if objects[name] then
        return objects[name].new(...)
    end
end

return Object