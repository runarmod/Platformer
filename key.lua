keyImages = {}
keyImages.keyYellow = love.graphics.newImage("assets/Items/keyYellow.png")
keyImages.keyBlue = love.graphics.newImage("assets/Items/keyBlue.png")
keyImages.keyGreen = love.graphics.newImage("assets/Items/keyGreen.png")
keyImages.keyRed = love.graphics.newImage("assets/Items/keyRed.png")


Key = {}
Key.__index = Key
ActiveKeys = {}

function Key.new(key, x, y)
    local instance = setmetatable({}, Key)
    instance.x = x
    instance.y = y
    instance.name = key
    instance.img = keyImages[key]

    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveKeys, instance)
end

function Key:remove()
    for i, instance in ipairs(ActiveKeys) do
        if instance == self then
            Player:addKey(instance.name)
            self.physics.body:destroy()
            table.remove(ActiveKeys, i)
        end
    end
end

function Key:update(dt)
    self:checkRemove()
end

function Key:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Key:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Key.addAllKeysAndRemovePrevious()
    ActiveKeys = {}

    for i, KeyData in ipairs(Map.layers.keys.objects) do
        Key.new(KeyData.name, KeyData.x, KeyData.y)
    end
end

function Key.updateAll(dt)
    for i, instance in ipairs(ActiveKeys) do
        instance:update(dt)
    end
end

function Key.drawAll()
    for i, instance in ipairs(ActiveKeys) do
        instance:draw()
    end
end

function Key.beginContact(firstBody, secondBody, collision)
    for i, instance in ipairs(ActiveKeys) do
        -- if one of the bodies are the a Key
        if firstBody == instance.physics.fixture or secondBody == instance.physics.fixture then
            -- and the other body is the player
            if firstBody == Player.physics.fixture or secondBody == Player.physics.fixture then
                -- remove the Key
                instance.toBeRemoved = true
                return true
            end
        end
    end
end