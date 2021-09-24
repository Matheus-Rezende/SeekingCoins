WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576
WIDTH = 640
HEIGHT = 360
font = love.graphics.newFont('LeagueSpartan-Bold.otf', 40)
push = require 'lib/push'
wf = require 'lib/windfield'
Class = require 'lib/class'
sti = require 'lib/sti'
Camera = require 'lib/camera'
anim8 = require 'lib/anim8'

score = 0
alpha = 25

require 'Player'
require 'Map'
require 'Enemy'

state = 'start'
music_state = true

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  push:setupScreen(WIDTH, HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)

  world = wf.newWorld(0, 800, false)
  world:setQueryDebugDrawing(true)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Enemy')
  -- plat = world:newRectangleCollider(5, 300, 640, 60, {collision_class = 'Solidos'})
  -- plat:setType('static')
  player = Player(world)
  map = Map(world)

  enemies = {}
  for _, obj in ipairs(map.gameMap.layers['Inimigos'].objects) do
    table.insert(enemies, Enemy(world, obj.x, obj.y))
  end

  cam = Camera()

  coins = {}
  spritesheet = love.graphics.newImage('maps/tiles_packed.png')

  g = anim8.newGrid(18, 18, spritesheet: getWidth(),
            spritesheet: getHeight())

  animation = anim8.newAnimation(g('12-13', 8), 0.2)

  key = {}
  key.sprite = anim8.newAnimation(g('8 - 8', 2), 0.1)

  key.x = map.gameMap.layers['Chave'].objects[1].x
  key.y = map.gameMap.layers['Chave'].objects[1].y
  key.visible = true

  chest = {}
  chest.sprite = anim8.newAnimation(g('9 - 9', 2), 0.1)

  chest.x = map.gameMap.layers['Bau'].objects[1].x
  chest.y = map.gameMap.layers['Bau'].objects[1].y
  chest.visible = true

  flag = {}

  flag.x = map.gameMap.layers['Bandeira'].objects[1].x
  flag.y = map.gameMap.layers['Bandeira'].objects[1].y

  delimiters = {}

  for _, obj in ipairs(map.gameMap.layers['Delimitador'].objects) do
    delimiter = {
              x = obj.x,
              y = obj.y
    }
    table.insert(delimiters, delimiter)
  end

  sound = {}
  sound.theme = love.audio.newSource("Yoshi Island.mp3", 'static')
  sound.jump = love.audio.newSource("Jump.wav", 'static')
  sound.coin = love.audio.newSource("Coin.wav", 'static')
  sound.chest = love.audio.newSource("Chest.wav", 'static')
  sound.key = love.audio.newSource("Key.wav", 'static')
  sound.finish = love.audio.newSource("Finish.wav", 'static')
  sound.hit = love.audio.newSource("Hit.wav", 'static')
  --sound.point = love.audio.newSource("point.wav", 'static')
  --sound.hit_wall = love.audio.newSource("blip.wav", 'static')

end

function love.update(dt)
  world:update(dt)
  player:update(dt)
  for _, e in ipairs(enemies) do
    e:update(dt)
  end
  map:update(dt)

  animation:update(dt)

  local cont = 1
  for _, c in ipairs(coins) do
    if collides(c, player, 15) then
        table.remove(coins, cont)
        score = score + 1
        sound.coin:play()
    end
      cont = cont + 1
  end

  if collides(key, player, 15) and key.visible then
      key.visible = false
      sound.key:play()
  end

  if collides(flag, player, 15) then
      sound.finish:play()
      state = 'finish'
  end

  if state ~= 'play' then
    coins = {}
    for _, obj in ipairs(map.gameMap.layers['Moedas'].objects) do
      coin = {
                x = obj.x,
                y = obj.y,
                w = 18,
                h = 18
      }
      table.insert(coins, coin)
    end
    key.visible = true
    chest.visible = true
  end

  if collides(chest, player, 15) and key.visible == false then
      chest.visible = false
      key.visible = nil
      score = score + 5
      sound.chest:play()
      -- alpha = alpha - (dt * (255 / 3))
	    -- if alpha < 0 then alpha = 0 end
      --
      -- love.graphics.setColor(255,255,255,alpha)
      -- love.graphics.draw("Você destrancou o baú e recebeu 5 moedas", 100, 100)
  end
end

function love.draw()

  if not sound.theme:isPlaying() and music_state then
    love.audio.play(sound.theme)
    love.audio.setVolume(0.06)
    music_state = true
  end

  if state == 'start' then
    love.graphics.setFont(font)
    love.graphics.setColor(255, 0, 0)
    love.graphics.printf('SeekingCoins', 0, WINDOW_HEIGHT/2-100, WINDOW_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('Pressione ENTER \n para jogar', 0, WINDOW_HEIGHT/2+50, WINDOW_WIDTH, 'center')
  end
  if state == 'play' then
    love.graphics.clear(135/255, 206/255, 235/255)
    push:start()
    cam:attach()
    map:draw()
    for _, e in ipairs(enemies) do
      e:draw(dt)
    end
    if key.visible then
      key.sprite:draw(spritesheet, key.x, key.y, 0, 1, 1, 9, 9)
    end
    if chest.visible then
      chest.sprite:draw(spritesheet, chest.x, chest.y+9, 0, 1, 1, 9, 9)
    end
    player:draw()
    for _, c in ipairs(coins) do
      animation:draw(spritesheet, c.x, c.y, 0, 1, 1, 9, 9)
    end
    --world:draw()
    cam:lookAt(player.x+200, HEIGHT-75)
    cam:detach()
    push:finish()
    love.graphics.print(score.."/13 ")
    animation:draw(spritesheet, 110, -7.5, 0, 3, 3)
    if key.visible == false then
      key.sprite:draw(spritesheet, 450, -7.5, 0, 3, 3)
    end
  end
  if state == 'gameOver' then
    love.graphics.setFont(font)
    love.graphics.setColor(255, 0, 0)
    love.graphics.printf('Você morreu!', 0, WINDOW_HEIGHT/2-50, WINDOW_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('Pressione ESPAÇO para tentar novamente', 0, WINDOW_HEIGHT/2+100, WINDOW_WIDTH, 'center')
  end
  if state == 'finish' then
    love.graphics.setFont(font)
    love.graphics.setColor(255, 0, 0)
    love.graphics.printf('Você conseguiu chegar até o final\nParabéns', 0, WINDOW_HEIGHT/2-150, WINDOW_WIDTH, 'center')

    -- if chest.visible then
    --   love.graphics.printf('Você não pegou o baú do tesouro!', 0, WINDOW_HEIGHT/2, WINDOW_WIDTH, 'center')
    -- end
    love.graphics.printf('Moedas coletadas: '..score.. '/13', 0, WINDOW_HEIGHT/2+50, WINDOW_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf('Pressione ESPAÇO jogar novamente', 0, WINDOW_HEIGHT/2+100, WINDOW_WIDTH, 'center')
  end
end

function collides(a, b, c)
  if math.sqrt((a.y - b.y)^2 + (a.x - b.x)^2) <= c then
    return true
  end
  return false
end

function love.keypressed(key)
  if key == 'return' and state == 'start' then
    state = 'play'
  end

  if key == 'w' and state == 'play' then
    player:jump()
    if player.grounded then
      sound.jump:play()
    end
  end

  if key == 'space' and (state == 'gameOver' or state == 'finish') then
    player.body:setX(10)
    player.body:setY(300)
    player.isdead = false
    score = 0
    state = 'play'
  end
end
