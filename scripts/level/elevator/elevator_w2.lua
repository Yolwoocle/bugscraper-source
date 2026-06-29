require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local images = require "data.images"

local ElevatorW2 = Elevator:inherit()

function ElevatorW2:init(level)
	ElevatorW2.super.init(self, level)

	self.name = "elevator_w2"

	self.layers["cabin_bg"] = images.cabin_bg_w2
	self.layers["walls"] = images.cabin_walls_w2
	
	self.bg_fan_spin = 0
	self.bg_fan_spin_speed = 2

	self:get_door("main"):set_images(
		images.cabin_door_bee_left_far,
		images.cabin_door_bee_left_center,
		images.cabin_door_bee_right_far,
		images.cabin_door_bee_right_center
	)

	self:init_audience_bees()
end

function ElevatorW2:init_audience_bees()
	
	self.audience_bees = {
		-- toptop row
		{spr = 2, x = -10, y = 210},
		{spr = 1, x = 12, y = 210},

		-- top row
		{spr = 1, x = 1, y = 226},
		{spr = 2, x = 23, y = 226},

		-- middle row
		{spr = 1, x = -10, y = 242},
		{spr = 2, x = 12, y = 242},
		{spr = 1, x = 34, y = 242},
		
		-- bottom row
		{spr = 2, x = 1, y = 258},
		{spr = 1, x = 23, y = 258},
		{spr = 2, x = 45, y = 258},
		
		-- bottom bottom row
		{spr = 3, x = 0, y = 274},
		{spr = 4, x = 32, y = 274},
		{spr = 3, x = 64, y = 274},
	}
	local n = #self.audience_bees
	for i = 1, n do
		local bee = self.audience_bees[i]
		local new_bee = copy_table_shallow(bee)
		new_bee.flip_x = true
		new_bee.x = CANVAS_WIDTH - new_bee.x
		table.insert(self.audience_bees, new_bee)
	end

	self.bee_sprs = {
		AnimatedSprite:new({
			default = {images.audience_bee, 0.05, 2},
		}, "default", SPRITE_ANCHOR_CENTER_CENTER),
		AnimatedSprite:new({
			default = {images.audience_bee, 0.05, 2},
		}, "default", SPRITE_ANCHOR_CENTER_CENTER, {start_frame = 2}),

		AnimatedSprite:new({
			default = {images.audience_bee_big, 0.05, 2},
		}, "default", SPRITE_ANCHOR_CENTER_CENTER),
		AnimatedSprite:new({
			default = {images.audience_bee_big, 0.05, 2},
		}, "default", SPRITE_ANCHOR_CENTER_CENTER, {start_frame = 2}),
	}

	self.bee_frame2_oy = 1

	self.audience_oy = 300
	self.audience_oy_target = 300

	self.cheer_timer = 0.0
end

function ElevatorW2:update(dt)
	ElevatorW2.super.update(self, dt)

	self.bg_fan_spin = self.bg_fan_spin + self.bg_fan_spin_speed * dt
	for _, bee_spr in pairs(self.bee_sprs) do
		bee_spr:update(dt)
	end

	self.audience_oy = lerp(self.audience_oy, self.audience_oy_target, 0.02)

	self.cheer_timer = math.max(self.cheer_timer - dt, 0.0)
	if self.cheer_timer <= 0 then
		self.bee_frame2_oy = 1
	end
end

function ElevatorW2:draw(enemy_buffer, wave_progress)
	ElevatorW2.super.draw(self, enemy_buffer)
end

function ElevatorW2:draw_front()
	ElevatorW2.super.draw_front(self)

	for _, bee in pairs(self.audience_bees) do
		local spr = self.bee_sprs[bee.spr]
		spr:set_flip_x(bee.flip_x)
		local y = bee.y + self.audience_oy
		if spr.frame_i == 2 then
			y = y + self.bee_frame2_oy
		end
		spr:draw(bee.x, y, 1, 1)
	end
end

function ElevatorW2:draw_cabin()
	ElevatorW2.super.draw_cabin(self)

	local cabin_rect = self.level.cabin_rect

	draw_centered(images.cabin_bg_w2_fan, cabin_rect.ax + 367, cabin_rect.ay + 42, self.bg_fan_spin)
end

function ElevatorW2:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

function ElevatorW2:cheer_audience(duration)
	self.bee_frame2_oy = 3
	self.cheer_timer = duration
end

function ElevatorW2:cheer_audience_intense(duration)
	self.bee_frame2_oy = 6
	self.cheer_timer = duration
end

return ElevatorW2