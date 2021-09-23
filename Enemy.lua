Enemy = Class{}
anim8 = require 'lib/anim8'

function Enemy:init(world, x, y)
  self.x = x
  self.y = y
  self.speed = 50
  self.spritesheet = love.graphics.newImage('enemy.png')
  self.direction = -1
  self.w = 26
  self.h = 25
  self.body = world:newRectangleCollider(self.x, self.y, self.w, self.h,
              {collision_class = 'Enemy'})

  g = anim8.newGrid(self.w, self.h, self.spritesheet: getWidth(),
            self.spritesheet: getHeight())

  self.animation = anim8.newAnimation(g('1-3', 1), 0.2)
end

function Enemy:update(dt)
  self.animation: update(dt)

  self.x = self.x + self.speed * dt
  self.body:setX(self.x)

  for _, d in ipairs(delimiters) do
    if collides(self, d, 15) then
      self.speed = self.speed * - 1
      self.direction = self.direction * - 1
    end
  end
end

function Enemy:draw()
  self.animation:draw(self.spritesheet,
                    self.body:getX(),
                    self.body:getY(),
                    0, self.direction, 1, self.w/2, self.h/2)
end
