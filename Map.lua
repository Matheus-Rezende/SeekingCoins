Map = Class{}

function Map:init(world)
  self.world = world
  self.solids = {}
  self.spikes = {}
  self.gameMap = sti('maps/1.lua')
  self:createSolids()
  self:createSpikes()
end

function Map:update(dt)
  self.gameMap:update(dt)
end

function Map:draw()
  self.gameMap:drawLayer(self.gameMap.layers['Camada de Tiles 1'])
end

function Map:createSolids()
  local solid
  for _, obj in ipairs(self.gameMap.layers['Solidos'].objects) do
    solid = self.world:newRectangleCollider(obj.x, obj.y,
              obj.width, obj.height, {collision_class = 'Solidos'})
    solid:setType('static')
    table.insert(self.solids, solid)
  end

end

function Map:createSpikes()
  local spike
  for _, obj in ipairs(self.gameMap.layers['Espinhos'].objects) do
    spike = self.world:newRectangleCollider(obj.x, obj.y,
              obj.width, obj.height, {collision_class = 'Espinhos'})
    spike:setType('static')
    table.insert(self.spikes, spike)
  end

end
