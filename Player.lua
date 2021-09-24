Player = Class{}
anim8 = require 'lib/anim8'

function Player:init(world)
  self.w = 20
  self.h = 20
  self.x = 10
  self.y = 10
  self.speed = 100
  self.spritesheet = love.graphics.newImage('Adventurer Sprite Sheet v1.1.png')
  self.w = self.spritesheet: getWidth() / 13
  self.h = self.spritesheet: getHeight() / 16
  self.cw = self.w - 15
  self.ch = self.h - 15
  g = anim8.newGrid(self.w, self.h, self.spritesheet: getWidth(),
            self.spritesheet: getHeight())
  self.animations = {}
  self.animations.idle = anim8.newAnimation(g ('1-13', 1), 0.1)
  self.animations.run = anim8.newAnimation(g('1-8', 2), 0.1)
  self.animations.jump = anim8.newAnimation(g('3-5', 6), 0.5)
  self.curAnimation = self.animations.idle
  self.body = world:newRectangleCollider(self.x, self.y, self.cw, self.ch)
  self.body:setFixedRotation(true)

  self.grounded = false
  --self.spike = false

  self.direction = 1
  self.isdead = false
end

function Player:update(dt)
  -- if self.isdead then
  --   return
  -- end

  self.x, self.y = self.body:getPosition()
  if love.keyboard.isDown('a') then
    self.x = self.x - self.speed * dt
    self.direction = -1
    self.curAnimation = self.animations.run
  elseif love.keyboard.isDown('d') then
    self.x = self.x + self.speed * dt
    self.direction = 1
    self.curAnimation = self.animations.run
  else
    self.curAnimation = self.animations.idle
  end
  if self.grounded == false then
      self.curAnimation = self.animations.jump
  end
  self.body:setX(self.x)
  colliders = world:queryRectangleArea(self.x - self.cw/2,
                self.y + self.ch/2, self.cw, 4, {'Solidos'})
  colliders_spike = world:queryRectangleArea(self.x - self.cw/2,
                self.y - self.ch/2-1, self.cw-5, self.h/2+7, {'Espinhos'})
  -- colliders_spike = world:queryRectangleArea(self.x - self.cw/2,
  --               self.y + self.ch/2, self.cw, 4, {'Espinhos'})

  if #colliders_spike > 0 then
    -- self.spike = true
    self.isdead = true
  -- else
  --   self.spike = false
  end

  if #colliders > 0 then
    self.grounded = true
  else
    self.grounded = false
  end

  -- if self.body:enter('Enemy') then
  --   self.isdead = true
  --   --sound.hit:play()
  -- end

  if self.isdead then
    key.visible = true
    state = 'gameOver'
  end
  self.curAnimation:update(dt)
end

function Player:draw()
  -- if self.isdead then
  --   return
  -- end
  self.curAnimation:draw(self.spritesheet,
                    self.body:getX(),
                    self.body:getY(),
                    0, self.direction, 1, self.w/2, self.h/2+5)
end

function Player:jump()
  if self.grounded then
    self.body:applyLinearImpulse(0, -400)
  end
end
