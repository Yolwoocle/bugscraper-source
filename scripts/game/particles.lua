require "scripts.util"
local Class = require "scripts.meta.class"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"
local utf8 = require "utf8"
local shaders = require "data.shaders"

local Particle = Class:inherit()

function Particle:init(x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
end

function Particle:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
	params = params or {}
	self.x, self.y = x, y
	self.vx, self.vy = vx or 0, vy or 0
	self.friction_x = params.friction_x or 1
	self.friction_y = params.friction_y or 1

	self.s = s or 1.0-- size or radius
	self.original_s = self.s
	self.vs = vs or 20 
	
	self.r = r or 0
	self.vr = vr or 0

	self.gravity = g or 0
	self.is_solid = is_solid or false
	self.bounces = 2
	self.bounce_force = 100

	self.max_life = life or 5
	self.life = self.max_life

	self.clamp_to_cabin_rect = param(params.clamp_to_cabin_rect, true)

	self.ignore_frameskip = param(params.ignore_frameskip, false)
	self.is_removed = false
end

function Particle:update_particle(dt)
	self.vx = self.vx * self.friction_x
	self.vy = self.vy * self.friction_y

	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
	self.s = self.s - self.vs*dt
	self.r = self.r + self.vr*dt

	self.vy = self.vy + self.gravity
	self.life = self.life - dt

	if self.is_solid then
		local items, len = Collision.world:queryPoint(self.x, self.y, function(item) 
			return (item.collision_info and item.collision_info.type == COLLISION_TYPE_SOLID) or item.is_player
		end) 
		if len > 0 and self.vy > 0 then
			self.bounces = self.bounces - 1
			self.vy = -self.bounce_force - random_neighbor(40)
		end

		if game and game.level and game.level.cabin_inner_rect then
			if self.x < game.level.cabin_inner_rect.ax then
				self.vx = math.max(math.abs(self.vx), 20)
			elseif game.level.cabin_inner_rect.bx < self.x then
				self.vx = -math.max(math.abs(self.vx), 20)
			elseif self.y < game.level.cabin_inner_rect.ay then
				self.vy = self.bounce_force - random_neighbor(40)
			end

			if self.clamp_to_cabin_rect then
				self.x = clamp(self.x, game.level.cabin_inner_rect.ax, game.level.cabin_inner_rect.bx)
				self.y = clamp(self.y, game.level.cabin_inner_rect.ay, game.level.cabin_inner_rect.by)
			end
		end

	end

	if self.s <= 0 or self.life <= 0 then
		self:remove()
	end
end

function Particle:update(dt)
	self:update_particle(dt)
end
function Particle:draw()
end
function Particle:remove()
	self.is_removed = true
	self:on_removed()
end
function Particle:on_removed()
end

-----------

local CircleParticle = Particle:inherit()


function CircleParticle:init(x,y,s,palette, vx,vy,vs, life, g, fill_mode, params)
	params = params or {}
	self:init_particle(x,y,s,0, vx,vy,vs,0, life, g)

	self.palette = palette or COL_WHITE
	if self.palette.type == "gradient" then
		self.col = self.palette[1]

	elseif self.palette[1] and type(self.palette[1]) == "table" then
		self.col = random_sample(self.palette)

	elseif not self.palette.type then
		self.col = palette

	end
	self.fill_mode = fill_mode or "fill"
	self.type = "circle"

	self.spawn_delay = param(params.spawn_delay, 0)
	self.spawn_timer = 0
	if self.spawn_delay > 0 then
		self.spawn_timer = self.spawn_delay
	end
end
function CircleParticle:update(dt)
	self.spawn_timer = math.max(0, self.spawn_timer - dt)
	if self.spawn_timer > 0 then
		return
	end

	self:update_particle(dt)
	
	if self.palette.type == "gradient" then
		self.col = self.palette[math.floor(#self.palette * (1 - self.s/self.original_s)) + 1]
	end
end
function CircleParticle:draw()
	if self.spawn_timer > 0 then
		return
	end
	circle_color(self.col, self.fill_mode, self.x, self.y, self.s)
end
------------------------------------------------------------

local ImageParticle = Particle:inherit()

function ImageParticle:init(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
	self:init_image_particle(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
end
function ImageParticle:init_image_particle(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
	params = params or {}
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid, params)
	self.spr = spr

	self.is_animated = (type(spr) == "table")
	if self.is_animated then
		-- TODO implement spritesheet system for particle animation
		self.spr_table = spr
		self.spr = spr[1]
	end
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.color = params.color
	self.alpha = params.alpha or 1
	self.alpha_speed = params.alpha_speed or 0

	self.flip_x = param(params.flip_x, false) and -1 or 1
	self.flip_y = param(params.flip_y, false) and -1 or 1

	self.is_solid = is_solid

	self.follow_actor = params.follow_actor
end
function ImageParticle:update(dt)
	self:update_particle(dt)

	self.alpha = clamp(self.alpha - self.alpha_speed*dt, 0, 1)

	if self.is_animated then
		local frame_i = clamp(math.ceil(#self.spr_table * (1 - self.life/self.max_life)), 1, #self.spr_table)
		self.spr = self.spr_table[frame_i]
	end

	if self.follow_actor then
		self.x = self.follow_actor.mid_x
		self.y = self.follow_actor.mid_y
	end
end
function ImageParticle:draw()
	if self.color then
		shaders.draw_in_color:send("fillColor", self.color)
		love.graphics.setShader(shaders.draw_in_color)
	end

	exec_color({1, 1, 1, (self.color or {})[4] or 1}, function()
		love.graphics.draw(self.spr, self.x, self.y, self.r, self.flip_x*self.s, self.flip_y*self.s, self.spr_ox, self.spr_oy)
	end)
	
	if self.color then
		love.graphics.setShader()
	end
end

------------------------------------------------------------

local RiseAndLingerParticle = Particle:inherit()

function RiseAndLingerParticle:init(x,y, spawn_delay, stay_time)
	RiseAndLingerParticle.super.init(self, x,y,s,r, vx,vy,vs,vr, life, g, is_solid)

	self.spawn_y = y

	self.vy = -5
	self.vy2 = 0
	self.spawn_delay = spawn_delay or 0.0
	self.stay_timer = stay_time or 0.1

	self.start_rise_y = nil

	self.min_oy = -50
end

function RiseAndLingerParticle:update(dt)
	if self.spawn_delay > 0 then
		self.spawn_delay = self.spawn_delay - dt
		return
	end

	self.vy = self.vy * 0.9
	self.y = self.y + self.vy
	
	if abs(self.vy) <= 0.005 then
		self.stay_timer = math.max(0, self.stay_timer-dt)

		if not self.start_rise_y then
			self.start_rise_y = self.y
		end 

		if self.stay_timer <= 0 then
			self.vy2 = self.vy2 - dt*2
			self.y = self.y + self.vy2
		end		
	end

	if self.y <= self.spawn_y + self.min_oy then
		self:remove()
	end
end

------------------------------------------------------------


local TextParticle = RiseAndLingerParticle:inherit()

function TextParticle:init(x,y,str,spawn_delay, col, stay_time, text_scale, outline_color, params)
	params = params or {}
	TextParticle.super.init(self, x,y, spawn_delay, stay_time)
	self.str = str
	self.text_scale = text_scale or 1
	self.font = param(params.font, nil)

	self.col_in = col
	self.col_out = outline_color
end
function TextParticle:update(dt)
	TextParticle.super.update(self, dt)
end

function TextParticle:draw()
	if self.spawn_delay > 0 then
		return
	end

	local col = COL_WHITE
	if self.col_in then col = self.col_in end
	if self.font then
		Text:push_font(self.font)
	end
	print_outline(col, self.col_out or COL_BLACK_BLUE, self.str, self.x, self.y, nil, nil, self.text_scale)
	if self.font then
		Text:pop_font()
	end
end

------------------------------------------------------------


local RisingImageParticle = RiseAndLingerParticle:inherit()

function RisingImageParticle:init(x, y, image, scale, spawn_delay, stay_time, params)
	params = params or {}
	RisingImageParticle.super.init(self, x,y, spawn_delay, stay_time)

	self.rising_squish_x = param(params.rising_squish_x, false)
	self.rising_squish_y = param(params.rising_squish_y, false)
	self.image = image
	self.scale = scale or 1
	self.rot = 0.0
end
function RisingImageParticle:update(dt)
	RisingImageParticle.super.update(self, dt)
end

function RisingImageParticle:draw()
	if self.spawn_delay > 0 then
		return
	end

	local squish_x = 1
	local squish_y = 1
	if self.start_rise_y then
		local min_y = self.spawn_y + self.min_oy
		local dist = self.y - min_y
		local total = self.start_rise_y - min_y
		squish_x = dist / total
	end
	draw_centered(self.image, self.x, self.y, self.rot, self.scale * squish_x, self.scale * squish_y)
end

------------------------------------------------------------

local CollectedUpgradeParticle = RisingImageParticle:inherit()

function CollectedUpgradeParticle:init(x, y, image, color, scale, spawn_delay, stay_time)
	CollectedUpgradeParticle.super.init(self, x,y, image, scale, spawn_delay, stay_time)

	self.color = color or COL_WHITE
	self.rot = 0.0
end

function CollectedUpgradeParticle:update(dt)
	CollectedUpgradeParticle.super.update(self, dt)
end

function CollectedUpgradeParticle:draw()
	if self.spawn_delay > 0 then
		return
	end
	
	draw_centered(self.image, self.x, self.y, 0, self.scale, self.scale)
end

function CollectedUpgradeParticle:on_removed()
	-- function ParticleSystem:smoke(x, y, number, col, spw_rad, size, sizevar, layer, fill_mode, params)
	Particles:smoke(self.x, self.y, 30, nil, 16)
end



------------------------------------------------------------

local StompedEnemyParticle = Particle:inherit()

function StompedEnemyParticle:init(x,y,spr)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     2, 0, false)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h

	self.sx = 1
	self.sy = 1
	self.squash = 1
	self.squash_target = 2
end
function StompedEnemyParticle:update(dt)
	self:update_particle(dt)
	self.squash = lerp(self.squash, self.squash_target, 0.2)

	self.sx = self.squash
	self.sy = (1/self.squash) * 0.5

	if abs(self.squash_target - self.squash) <= 0.01 then
		self:remove()
		-- number, col, spw_rad, size, sizevar, layer, fill_mode, params
		Particles:smoke(self.x, self.y, 24, nil, 10)
	end
end
function StompedEnemyParticle:draw()
	-- local oy = self.spr_h*.5 - self.spr_h*.5*self.sy
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local DeadPlayerParticle = Particle:inherit()

function DeadPlayerParticle:init(x,y,spr, colors, dir_x)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     10, 0, false)
	self.spr = spr
	
	self.dir_x = dir_x
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2

	self.oy = 0

	self.sx = 1
	self.sy = 1

	self.r = 0

	self.cols = colors

	Particles:splash(self.x, self.y - self.oy, 40, self.cols)
end
function DeadPlayerParticle:update(dt)
	self:update_particle(dt)

	local goal_r = 5*sign(self.dir_x)*pi2
	self.r = lerp(self.r, goal_r, 0.06)
	self.oy = lerp(self.oy, 40, 0.05)

	if abs(self.r - goal_r) < 0.1 then
		game:screenshake(10)
		Input:vibrate_all(0.3, 0.5)
		
		Audio:play("explosion", nil, nil, {x=self.x, y=self.y})
		Particles:splash(self.x, self.y - self.oy, 40, {COL_LIGHT_YELLOW, COL_ORANGE, COL_LIGHT_RED, COL_WHITE})
		Particles:star_splash(self.x, self.y-self.oy)
		self:remove()
	end
end
function DeadPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y - self.oy, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local EjectedPlayerParticle = Particle:inherit()

function EjectedPlayerParticle:init(spr, x, y, vx, vy)
	--                (x,y,s,r, vx,vy,vs,vr,                    life, g, is_solid)
	self:init_particle(x,y,1,0, vx,vy,0, sign(vx) * random_range(10, 20),   3,    15)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.is_solid = false
end
function EjectedPlayerParticle:update(dt)
	self:update_particle(dt)
	Particles:dust(self.x, self.y, COL_WHITE, nil, nil, nil)
end
function EjectedPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local SmashedPlayerParticle = Particle:inherit()

function SmashedPlayerParticle:init(spr, x, y, vx, vy)
	--                (x,y,s,r, vx,vy,vs,vr,                    life, g, is_solid)
	self:init_particle(x,y,1,0, 0,0,0,0,   3,    0)
	self.future_vx = vx
	self.future_vy = vy
	self.future_vr = random_range(10, 20)

	self.ox = 0
	self.oy = 0

	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.freeze_duration = 1.0

	self.is_solid = false
end
function SmashedPlayerParticle:update(dt)
	self:update_particle(dt)

	self.freeze_duration = max(0.0, self.freeze_duration - dt)
	if self.freeze_duration > 0 then
		self.ox = random_polar(2)
		self.oy = random_polar(2)

	else
		self.vx = self.future_vx
		self.vy = self.future_vy
		self.vr = self.future_vr
	-- else
		-- self.ox = random_neighbor(3)
		-- self.oy = random_neighbor(3)
	end

	if self.y <= -8 then
		local a = atan2(self.vy, self.vx)
		game:screenshake(15)
		Particles:smash_flash(self.x, -80, a, COL_LIGHT_BLUE)
		Particles:smash_flash(self.x, -80, a, color(0xf6757a))
		Particles:smash_flash(self.x, -80, a, COL_WHITE)
		self:remove()
	end

	-- (x, y, col, size, rnd_pos, sizevar, params)
	Particles:dust(self.x, self.y, COL_WHITE, nil, nil, nil)
end
function SmashedPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x + self.ox, self.y + self.oy, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local SmashFlashParticle = Particle:inherit()

function SmashFlashParticle:init(x, y, r, col)
	--                (x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self:init_particle(x,y,1,r, 0,0,0,0,     1,    0)
	self.spr = images.smash_flash
	self.col = col

	self.ox = 0
	self.oy = 0

	self.sx = 1
	self.sy = 1
	self.flip_y = false
	self.flash_size = 1.0

	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w
	self.spr_oy = 0
	
	self.is_solid = false

	self.points = {}
end
function SmashFlashParticle:update(dt)
	self:update_particle(dt)
	
	self.ox = random_neighbor(10)
	self.oy = random_neighbor(10)

	self.flash_size = (self.life / self.max_life)
	self.sy = random_range(0.8, 1.2) * self.flash_size
	-- self.sx = 0.5 * self.flash_size
	-- if random_sample{0, 1} == 1 then
	-- 	self.flip_y = not self.flip_y
	-- end
end
function SmashFlashParticle:draw()
	exec_color(self.col, function()
		local fy = 1-- ternary(self.flip_y, -1, 1)
		love.graphics.draw(self.spr, self.x + self.ox, self.y + self.oy, self.r, self.sx, fy*self.sy, self.spr_ox, self.spr_oy)
	end)
end

------------------------------------------------------------

local FallingGridParticle = Particle:inherit()

function FallingGridParticle:init(img_side, img_top, x,y, params)
	params = params or {}
	self:init_particle(x,y,s,r, vx,vy,0,vr, params.lifespan or 2.5, g, false)
	-- self.spr_side = Sprite:new(img_side, SPRITE_ANCHOR_LEFT_BOTTOM)
	-- self.spr_top =  Sprite:new(img_top,  SPRITE_ANCHOR_LEFT_BOTTOM)
	self.img_side = img_side
	self.img_top =  img_top
	-- self.spr_top:set_scale(nil, 0)

	self.orig_y = y

	-- self.spr_w = self.spr:getWidth()
	-- self.spr_h = self.spr:getWidth()
	-- self.spr_ox = self.spr_w / 2
	-- self.spr_oy = self.spr_h / 2
	
	self.t = 0 
	self.rot_3d = math.pi/2
	self.rot_3d_vel = 0 
	self.rot_3d_acc = params.rot_3d_acc or -6
	self.rot_3d_bounce = 0.5
	self.bounce_vel_threshold = params.bounce_vel_threshold or 1

	self:update(0)
end

function FallingGridParticle:update(dt)
	self:update_particle(dt)

	self.t = self.t + dt*4
	if self.rot_3d > 0 then
		self.rot_3d_vel = self.rot_3d_vel + self.rot_3d_acc*dt 
	end
	self.rot_3d = math.max(0, self.rot_3d + self.rot_3d_vel*dt)
	
	if self.rot_3d <= 0 and math.abs(self.rot_3d_vel) >= self.bounce_vel_threshold then
		self.rot_3d_vel = math.abs(self.rot_3d_vel) * self.rot_3d_bounce

		local w = self.img_side:getWidth()
		for ix = 0, w, 4 do
			Particles:dust(self.x + ix, self.y + self.img_top:getHeight())
		end
	end

	self.y = self.orig_y - math.sin(self.rot_3d) * self.img_side:getHeight()
end

function FallingGridParticle:draw()
	local h_side = self.img_side:getHeight()
	local h_top =  self.img_top:getHeight()
	local scale_side = math.sin(self.rot_3d)
	local scale_top = math.cos(self.rot_3d)

	local oy = scale_top * h_top

	love.graphics.draw(self.img_side, self.x, self.y + oy, 0, 1, scale_side)
	love.graphics.draw(self.img_top,  self.x, self.y,      0, 1, scale_top)
	-- love.graphics.line(self.x-32, self.orig_y, self.x+32, self.orig_y)
end

------------------------------------------------------------

local OpenedDoorParticle = Particle:inherit()

function OpenedDoorParticle:init(img, x,y, params)
	params = params or {}
	self:init_particle(x,y,s,r, vx,vy,0,vr, 5.0, g, false)
	self.img = img
	
	self.t = 0 
	self.rot_3d = math.pi/2
	self.rot_3d_vel = 0 
	self.rot_3d_acc = -40

	self.linger_time = param(params.linger_time, 1.0)
	self.phase = "open"

	Audio:play("sfx_cutscene_door_open", 1.0, 1.0, {x = self.x, y = self.y})
end

function OpenedDoorParticle:update(dt)
	self:update_particle(dt)

	self.t = self.t + dt*4

	self.rot_3d_vel = self.rot_3d_vel + self.rot_3d_acc*dt
	self.rot_3d = clamp(self.rot_3d + self.rot_3d_vel*dt, 0, pi/2)

	if self.phase == "open" then
		if self.rot_3d <= 0 then
			self.phase = "linger" 
		end
		
	elseif self.phase == "linger" then
		self.linger_time = self.linger_time - dt
		if self.linger_time < 0 then
			self.phase = "close" 
			self.rot_3d_acc = 40
			self.rot_3d_vel = 0 
		end
		
	elseif self.phase == "close" then
		if self.rot_3d >= pi/2 - 0.0001 then
			Audio:play("sfx_cutscene_door_slam", 1.0, 1.0, {x = self.x, y = self.y})
			self.phase = "disabled" 
		end

	elseif self.phase == "disabled" then
		
	end
end

function OpenedDoorParticle:draw()
	local scale_side = math.cos(self.rot_3d)
	love.graphics.draw(self.img, self.x, self.y, 0, scale_side, 1)
end

------------------------------------------------------------

local SparkParticle = Particle:inherit()

function SparkParticle:init(x,y, life, g, is_solid, params)
	params = params or {}
	local vx = params.vx or (random_neighbor(150)) 
	local vy = params.vy or (-70 + random_neighbor(15))
	local life = life or 1
	local g = g or (10 + random_neighbor(3))
	self:init_particle(x,y,__s,__r, vx,vy,0,1, life, g, is_solid)

	self.is_solid = false --param(is_solid, true)
	self.color = random_sample(params.colors or {COL_WHITE, COL_WHITE, COL_WHITE, COL_LIGHT_YELLOW, COL_YELLOW_ORANGE})
end
function SparkParticle:update(dt)
	self:update_particle(dt)

end
function SparkParticle:draw()
	local mult = 0.05
	line_color(self.color, self.x, self.y, self.x + self.vx*mult, self.y + self.vy*mult)
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

local ParticleSystem = Class:inherit()

function ParticleSystem:init(x,y)
	self.layers = {}
	self.layer_count = PARTICLE_LAYER_COUNT
	
	self.layer_stack = {PARTICLE_LAYER_NORMAL}
	self.current_layer = self.layer_stack[#self.layer_stack]
	for i = 1, self.layer_count do
		self.layers[i] = {}
	end
end

function ParticleSystem:update(dt) 
	for _, layer in pairs(self.layers) do
		for i, p in pairs(layer) do
			if game.frames_to_skip <= 0 or p.ignore_frameskip then
				p:update(dt)

				if p.is_removed then
					-- OPTI: maybe performance can improved by doing layer[i] = nil instead as it won't 
					-- shift all items in the table  
					table.remove(layer, i)
				end
			end
		end
	end
end

function ParticleSystem:push_layer(layer)
	table.insert(self.layer_stack, layer)
	self.current_layer = self.layer_stack[#self.layer_stack]
end

function ParticleSystem:pop_layer()
	local layer = table.remove(self.layer_stack, #self.layer_stack)
	self.current_layer = self.layer_stack[#self.layer_stack] or PARTICLE_LAYER_NORMAL
	return layer
end

function ParticleSystem:get_number_of_particles()
	local n = 0
	for _, layer in pairs(self.layers) do
		n = n + #layer
	end
	return n
end

function ParticleSystem:draw_layer(layer_id)
	layer_id = param(layer_id, PARTICLE_LAYER_NORMAL)
	for i,p in pairs(self.layers[layer_id]) do
		p:draw()
	end
end

function ParticleSystem:add_particle(ptc)
	local layer_id = self.current_layer
	assert(self.layers[layer_id] ~= nil, "layer doesn't exist")
	table.insert(self.layers[layer_id], ptc)
end

function ParticleSystem:clear(layer_id)
	if layer_id == nil then
		for i=1, self.layer_count do
			self.layers[i] = {}
		end
	else
		self.layers[layer_id] = {}
	end
end

function ParticleSystem:explosion(x, y, radius, args)
	args = args or {}

	local function explosion_layer(col, rad, quantity, min_spawn_delay, max_spawn_delay)
		self:smoke_big(x, y, col, rad, quantity, {
			vx = 0, 
			vx_variation = 20, 
			vy = -50, 
			vy_variation = 10,
			min_spawn_delay = min_spawn_delay or 0,
			max_spawn_delay = max_spawn_delay or 0.2,
		})
	end

	local gradient = {
		type = "gradient",
		COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
	}
	if args.color_gradient then
		gradient = copy_table_shallow(args.color_gradient)
		gradient.type = "gradient"
	end
	explosion_layer({type = "gradient", COL_DARK_GRAY},  radius, (radius*radius/16), 0.2, 0.4)
	explosion_layer({type = "gradient", COL_BLACK_BLUE}, radius, (radius*radius/16), 0.2, 0.4)

	explosion_layer(gradient, radius,     200)

	-- x, y, number, spr, spw_rad, life, vs, g, params
	Particles:image(x, y, 5, images.bullet_casing, 4, nil, nil, nil, {
		vx1 = -150,
		vx2 = 150,

		vy1 = 80,
		vy2 = -200,
	})

	Particles:image(x , y, 5, images.white_dust, 4, nil, nil, nil, {
		vx1 = -150,
		vx2 = 150,

		vy1 = 80,
		vy2 = -200,
	})
	
	Particles:static_image(images.explosion_flash, x, y)
	-- x, y, number, col, spw_rad, size, sizevar, layer, fill_mode, params
end

function ParticleSystem:smoke_big(x, y, col, spawn_rad, quantity, params)
	params = params or {}
	self:smoke(x, y, quantity or 15, col or COL_WHITE, spawn_rad or 16, params.size or 8, 4, params)
end

function ParticleSystem:smoke(x, y, number, col, spw_rad, size, sizevar, params)
	params = params or {}

	number = param(number, 10)
	spw_rad = param(spw_rad, 8)
	size = param(size, 4)
	sizevar = param(sizevar, 2)
	local fill_mode = param(params.fill_mode, nil)
	local min_spawn_delay = param(params.min_spawn_delay, 0)
	local max_spawn_delay = param(params.max_spawn_delay, 0)

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local col = col or {v,v,v,1}

		local vx = param(params.vx, 0) + random_neighbor(param(params.vx_variation, 0))
		local vy = param(params.vy, 0) + random_neighbor(param(params.vy_variation, 0))
		
		-- x,y,s,col, vx,vy,vs, life, g, fill_mode
		local particle = CircleParticle:new(x+dx, y+dy, size+dsize, col, vx, vy, _vs, _vr, _life, fill_mode, {
			spawn_delay = random_range(min_spawn_delay, max_spawn_delay),
		})
		self:add_particle(particle)
	end
end

function ParticleSystem:dust(x, y, col, size, rnd_pos, sizevar, params)
	params = params or {}

	rnd_pos = param(rnd_pos, 3)
	size = param(size, 4)
	sizevar = param(sizevar, 2)

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local v = random_range(0.6, 1)
	local col = col or {v,v,v,1}

	local vx = random_range(params.vx1 or 0, params.vx2 or 0)
	local vy = random_range(params.vy1 or 0, params.vy2 or 0)
	-- x,y,s,palette, vx,vy,vs, life, g, fill_mode, params
	self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, vx, vy, _vr, _life))
end


function ParticleSystem:fire(x, y, size, sizevar, velvar, vely)
	rnd_pos = rnd_pos or 3
	size = size or 4
	sizevar = sizevar or 2

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local col_fire = {1, random_range(0, 1),0.2,1}
	local v = random_range(0.6, 1)
	local col_smoke = {v,v,v,1}
	local col = random_sample{col_fire, col_smoke}

	velvar = velvar or 5
	vely = vely or -2
	local vy = random_range(vely - velvar, vely)
	local particle = CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, vy, _vr, _life)
	self:add_particle(particle)
end


function ParticleSystem:splash(x, y, number, col, spw_rad, size, sizevar)
	number = number or 10
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local c = col or {v,v,v,1}
		if type(col) == "table" then
			c = random_sample(col)
		end

		local vx = random_neighbor(50)
		local vy = random_range(-200, 0)
		local vy = random_neighbor(50)
		local vs = random_range(6,12)

		self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, c, vx, vy, vs, _life, 0))
	end
end


function ParticleSystem:glow_dust(x, y, size, sizevar)
	size = size or 4
	sizevar = sizevar or 2

	local ang = love.math.random() * pi2
	local spd = random_neighbor(50)
	local vx = cos(ang) * spd
	local vy = sin(ang) * spd
	local vs = random_range(6,12)
	local dsize = random_neighbor(sizevar)

	self:add_particle(CircleParticle:new(x, y, size+dsize, COL_WHITE, vx, vy, vs, _life, 0))
end


function ParticleSystem:flash(x, y, radius, radius_rand)
	-- x,y,r,col, vx,vy,vr, life
	local r = (radius or 8) + random_neighbor(radius_rand or 2)
	-- self:add_particle(x, y, r, COL_LIGHT_YELLOW, 0, 0, 220, _life)
	self:add_particle(CircleParticle:new(x, y, r, COL_WHITE, 0, 0, 220, _life))
end

-- FIXME giant scotch, fix for later
function ParticleSystem:image(x, y, number, spr, spw_rad, life, vs, g, params)
	params = params or {}
	number = number or 10
	spw_rad = spw_rad or 8
	life = life or 1
	-- size = size or 4
	-- sizevar = sizevar or 2

	for i=1,number do
		local particle_params = {}

		local ang = love.math.random() * pi2
		local distance = love.math.random() * spw_rad
		local dx, dy = cos(ang)*distance, sin(ang)*distance
		-- local dsize = random_neighbor(sizevar)

		local rot = random_neighbor(pi)
		local vx = random_neighbor(100)
		local vy = -random_range(40, 80)
		local vs = (vs or random_range(1, 0.5)) * random_range(1, 0.8)
		local vr = random_neighbor(1)
		local life = life + random_neighbor(params.life_rand or 0.5)
		local g = (g or 1) * 3
		local is_solid = true
		local is_animated = false
		local scale = params.scale or 1

		if params.vx1 ~= nil and params.vx2 ~= nil then
			vx = random_range(params.vx1, params.vx2)
		end
		if params.vy1 ~= nil and params.vy2 ~= nil then
			vy = random_range(params.vy1, params.vy2)
		end
		if params.vr1 ~= nil and params.vr2 ~= nil then
			vr = random_range(params.vr1, params.vr2)
		end
		if params.rot ~= nil then
			rot = params.rot
		end
		if params.is_solid ~= nil then
			is_solid = params.is_solid
		end
		if params.is_animated ~= nil then
			is_animated = params.is_animated
		end
		if params.life ~= nil then
			life = params.life
		end
		if params.scale ~= nil then
			scale = params.scale
		end
		if params.friction_x ~= nil then
			particle_params.friction_x = params.friction_x
		end
		if params.friction_y ~= nil then
			particle_params.friction_y = params.friction_y
		end
		if params.max_vel then
			local nvx, nvy = normalize_vect(vx, vy)
			local norm = math.min(dist(vx, vy), params.max_vel)
			vx, vy = nvx * norm, nvy * norm
		end 
		if params.color then
			particle_params.color = params.color
		end
		if params.color ~= nil then
			particle_params.clamp_to_cabin_rect = params.clamp_to_cabin_rect
		end
		
		local sprite = spr
		if (not is_animated) and type(spr) == "table" then
			sprite = random_sample(spr)
		end

		if params.ignore_frameskip ~= nil then
			particle_params.ignore_frameskip = params.ignore_frameskip
		end
		
		particle_params.flip_x = params.flip_x
		particle_params.flip_y = params.flip_y
		
		particle_params.follow_actor = params.follow_actor

		--spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid
		self:add_particle(ImageParticle:new(sprite, x+dx, y+dy, scale, rot, vx,vy,vs,vr, life, g, is_solid, particle_params))
	end
end

-- FIXME: scotch scotch scotch ugly ugly ugly ugly!!!
function ParticleSystem:static_image(img, x, y, rot, life, scale, params)
	params = params or {}
	local final_params = {
		is_solid = false,
		rot = rot,
		vx1 = params.vx1 or 0,
		vx2 = params.vx2 or 0,
		vy1 = params.vy1 or 0,
		vy2 = params.vy2 or 0,
		vr1 = 0,
		vr2 = 0,
		life = life or 0.12,
		life_rand = params.life_rand,
		is_animated = true,
		scale = scale,
		follow_actor = follow_actor,
	}
	for k, v in pairs(params or {}) do
		final_params[k] = v 
	end
	self:image(x, y, 1, img, 0, nil, 0, 0, final_params)
end

-- scottttcccchhhh
function ParticleSystem:floating_image(img, x, y, amount, rot, life, scale, vel, friction, params)
	params = params or {}
	Particles:image(x, y, amount, img, 0, nil, 0, 0, {
		is_solid = false,
		rot = rot,
		vx1 = -vel,
		vx2 = vel,
		vy1 = -vel,
		vy2 = vel,
		max_vel = vel,
		vr1 = 0,
		vr2 = 0,
		life = life or 0.12,
		life_rand = params.life_rand,
		is_animated = true,
		scale = scale,
		friction_x = friction,
		friction_y = friction,

		ignore_frameskip = param(params.ignore_frameskip, false)
	})
end

-- FIXME: scotch
function ParticleSystem:bullet_vanish(x, y, rot)
	self:static_image({
		images.bullet_vanish_1,
		images.bullet_vanish_2,
		images.bullet_vanish_3,
	}, x, y, rot)
end

-- FIXME: scotch
function ParticleSystem:sweat(x, y, flip_x)
	-- x, y, rot, life, scale, params
	self:static_image({
		images.sweat_1,
		images.sweat_2,
		images.sweat_3,
		images.sweat_4,
	}, x, y, 0, 0.2, nil, {
		flip_x = flip_x
	})
end

-- FIXME: scotch
function ParticleSystem:star_splash(x, y)
	self:static_image({
		images.star_splash_1,
		images.star_splash_2,
		images.star_splash_2,
		images.star_splash_3,
		images.star_splash_4,
	}, x, y, 0, 0.15, 1)
end

-- FIXME: scotch
function ParticleSystem:star_splash_small(x, y)
	self:static_image({
		images.star_splash_small_1,
		images.star_splash_small_2,
		images.star_splash_small_3,
	}, x, y, 0, 0.15)
end

-- FIXME: scotch
function ParticleSystem:jump_dust_kick(x, y, rot)
	self:static_image({
		images.jump_dust_kick_1,
		images.jump_dust_kick_2,
		images.jump_dust_kick_3,
		images.jump_dust_kick_4,
		images.jump_dust_kick_5,
	}, x, y, rot, 0.12)
end

-- FIXME: scotch
function ParticleSystem:bubble_fizz_cloud(x, y, radius, amount)
	for i=1, amount do
		self:static_image({
			images.bubble_fizz_1,
		}, x + random_neighbor(radius), y + random_neighbor(radius))
	end
end


-- FIXME: scotch
function ParticleSystem:spin_whoosh(x, y, flip_x, follow_actor)
	-- x, y, rot, life, scale, params
	self:static_image({
		images.spin_whoosh_1,
		images.spin_whoosh_2,
		images.spin_whoosh_3,
		images.spin_whoosh_4,
		images.spin_whoosh_5,
	}, x, y, 0, 0.25, nil, {
		flip_x = flip_x,
		follow_actor = follow_actor,
	})
end


function ParticleSystem:stomped_enemy(x, y, spr)
	self:add_particle(StompedEnemyParticle:new(x, y, spr))
end

function ParticleSystem:dead_player(x, y, spr, colors, dir_x)
	self:push_layer(PARTICLE_LAYER_FRONT)
	self:add_particle(DeadPlayerParticle:new(x, y, spr, colors, dir_x))
	self:pop_layer()
end

function ParticleSystem:ejected_player(spr, x, y, vx, vy, params)
	params = params or {}
	local x_sign = params.x_sign or random_sample{-1, 1}

	self:push_layer(PARTICLE_LAYER_FRONT)
	self:add_particle(EjectedPlayerParticle:new(spr, x, y, vx or (x_sign * random_range(100, 300)), vy or -random_range(400, 600)))
	self:pop_layer()
end

function ParticleSystem:smashed_player(spr, x, y, vx, vy)
	self:push_layer(PARTICLE_LAYER_FRONT)
	self:add_particle(SmashedPlayerParticle:new(spr, x, y, vx or 400, vy or -random_range(600, 600)))
	self:pop_layer()
end

function ParticleSystem:smash_flash(x, y, r, col)
	self:push_layer(PARTICLE_LAYER_FRONT)
	self:add_particle(SmashFlashParticle:new(x, y, r, col))
	self:pop_layer()
end

function ParticleSystem:letter(x, y, str, spawn_delay, col, stay_time, text_scale, outline_color, params)
	self:add_particle(TextParticle:new(x, y, str, spawn_delay, col, stay_time, text_scale, outline_color, params))
end

function ParticleSystem:word(x, y, str, col, stay_time, text_scale, outline_color, letter_time_spacing, params)
	params = params or {}
	stay_time = param(stay_time, 0)
	text_scale = param(text_scale, 1)
	local layer = param(params.layer, PARTICLE_LAYER_HUD)
	self:push_layer(layer)

	local x = x - (text_scale * get_text_width(str))/2
	for i=1, #str do
		local letter = utf8.sub(str, i,i)
		Particles:letter(x, y, letter, i*(letter_time_spacing or 0.05), col, stay_time, text_scale, outline_color, params)
		x = x + get_text_width(letter) * text_scale
	end

	self:pop_layer()
end

function ParticleSystem:opened_door(x, y, params)
	params = params or {}
	self:add_particle(OpenedDoorParticle:new(images.wooden_door, x, y, params))
end

function ParticleSystem:falling_cabin_back(x, y)
	self:push_layer(PARTICLE_LAYER_BACK)
	self:add_particle(FallingGridParticle:new(images.cabin_bg_w2, images.empty, x, y, {
		bounce_vel_threshold = 0.5,
		rot_3d_acc = -2,
		lifespan = 10.0
	}))
	self:pop_layer()
end

function ParticleSystem:falling_grid(x, y)
	self:push_layer(PARTICLE_LAYER_SHADOWLESS)
	self:add_particle(FallingGridParticle:new(images.cabin_grid, images.cabin_grid_platform, x, y))
	self:pop_layer()
end

function ParticleSystem:falling_grid_side(x, y)
	self:push_layer(PARTICLE_LAYER_SHADOWLESS)
	self:add_particle(FallingGridParticle:new(images.cabin_grid_platform, images.cabin_grid, x, y))
	self:pop_layer()
end

function ParticleSystem:spark(x, y, amount, params)
	amount = param(amount, 1)
	local life = 1 + random_neighbor(0.2)
	local g = nil
	local is_solid = false
	self:push_layer(PARTICLE_LAYER_FRONT)
	for i=1, amount do 
		self:add_particle(SparkParticle:new(x,y, life, g, is_solid))
	end
	self:pop_layer()
end

function ParticleSystem:speed_line(x, y, params)
	params = params or {}
	local amount = param(params.amount, 1)
	local life = params.life or (1 + random_neighbor(0.2))
	local g = 0
	local is_solid = false

	local final_x = x
	local final_y = y
	if params.random_x then   final_x = final_x + random_neighbor(params.random_x)   end
	if params.random_y then   final_y = final_y + random_neighbor(params.random_y)   end

	self:push_layer(params.particle_layer or PARTICLE_LAYER_FRONT)
	for i=1, amount do 
		self:add_particle(SparkParticle:new(final_x, final_y, life, g, is_solid, {
			vx = (params.vx or 0),
			vy = (params.vy or random_range(-800, -400)),
			colors = params.colors or {COL_WHITE, COL_LIGHTEST_GRAY, COL_LIGHT_GRAY}
		}))
	end
	self:pop_layer()
end

function ParticleSystem:rising_image(x, y, image, scale, spawn_delay, stay_time)
	self:push_layer(PARTICLE_LAYER_FRONT)
	self:add_particle(RisingImageParticle:new(x, y, image, scale, spawn_delay, stay_time))
	self:pop_layer()
end

function ParticleSystem:collected_upgrade(x, y, image, scale, spawn_delay, stay_time)
	self:add_particle(CollectedUpgradeParticle:new(x, y, image, scale, spawn_delay, stay_time))
end

ParticleSystem.text = ParticleSystem.word



return ParticleSystem