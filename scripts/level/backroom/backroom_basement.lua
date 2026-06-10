require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local npcs = require "data.npcs"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local TvPresentation    = require "scripts.level.background.tv_presentation"
local WaterDispenser   = require "scripts.actor.enemies.vending_machine.water_dispenser"
local Rect = require "scripts.math.rect"
local shaders = require "data.shaders"

local hangar = require "data.models.hangar"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local BackroomGroundFloor = BackroomWithDoor:inherit()

function BackroomGroundFloor:init(params)
	params = params or {}
    BackroomGroundFloor.super.init(self, params)
	self.name = "ground_floor"

	self.all_in_front = false

	self.close_door_timer = 0.5
	self.tv_presentation = TvPresentation:new(715, 100)

	self.has_opened_door = false
	self.freeze_fury = true

    self.def_3d_scale = 140
    self.object_3d = Object3D:new(hangar)
    self.renderer = Renderer3D:new({self.object_3d})
    self.object_3d.scale:sset(self.def_3d_scale, -self.def_3d_scale, self.def_3d_scale)
    self.object_3d.position.y = -120
    self.object_3d.position.z = 40
    self.object_3d.rotation.y = pi/2

	self.renderer.orthographic = false
	self.renderer.fov = 300
	self.renderer.render_offset.x = 200
	self.renderer.render_offset.y = 200
	self.renderer.line_color = COL_DARK_GRAY

	self.rocket_y = 82

	self.renderer:update(0)

	self.show_basement_bg = false

	self.number_of_exited_players = 0 -- TODO
	self.exited_players = {}
	self.last_exited_player_n = nil

	self.bg_particles = {}

	self.tutorial_timer = math.huge

	self.can_exit_basement = false
	self.stop_cutscene_on_exit = false

	self.background_clear_color = COL_VERY_DARK_GRAY
end

function BackroomGroundFloor:generate(world_generator)
	game.level:set_bounds(Rect:new(unpack(RECT_BASEMENT)))

	game.camera.max_x = CANVAS_WIDTH + 11*16
	
    world_generator:reset()
	world_generator:write_rect(Rect:new(2, -1, 2, 15), TILE_METAL) -- Wall left
	world_generator:write_rect(Rect:new(68, -1, 68, 15), TILE_METAL) -- Wall right
	world_generator:write_rect(Rect:new(2, 0, 68, 15), TILE_METAL) -- Wall
	world_generator:write_rect(Rect:new(2, 15, 68, 15), TILE_STONE) -- Floor

	game.ambience_player:set_disk("off")

	local b = create_actor_centered(enemies.ButtonSmallGlass, floor(15*16), floor(15*16))
	b.fury_damage_multiplier = 0.0
	b.fury_stomp_multiplier = 0.0
	b.death_counts_for_fury_combo = false
	b.spawned_actor = enemies.ButtonSmallRocket
	game:new_actor(b)

	game:new_actor(enemies.PlayerTrigger:new(3 * 16, -16, 66 * 16, 16, function()
		for _, player in pairs(game.players) do
			if player.y < 0 then
				player.gravity_mult = 0
				player.vy = -300

                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()

				player.wall_slide_stamina = player.wall_slide_max_stamina

				Audio:play_var("sfx_cutscene_mio_falling_to_rocket", 0.1, 1.1)

				if not self.exited_players[player.n] then
					self.number_of_exited_players = self.number_of_exited_players + 1
					self.exited_players[player.n] = {
						y = -10.0,
						vy = 0.0,
						shake_x = 0.0,
						shake_y = 0.0,
						sprite = player.skin.img_airborne,

						ox = random_neighbor(8),
					}

					if self.number_of_exited_players >= game:get_number_of_alive_players() then
						self.last_exited_player_n = player.n
					end
				end 
			end
		end
	end, { 
		min_player_trigger = 1, 
		triggers = math.huge,
	}))

	game:set_actor_draw_color(COL_BLACK_BLUE)

	Audio:set_effect("echo")
end

function BackroomGroundFloor:get_default_camera_position()
	return 312 - 16, 48
end

function BackroomGroundFloor:can_exit()
	return self.can_exit_basement
end

function BackroomGroundFloor:on_exit()
	BackroomGroundFloor.super.on_exit(self)
end

function BackroomGroundFloor:update(dt)
	BackroomGroundFloor.super.update(self, dt)

	local cx, cy = math.floor(game.camera:get_real_position())
    self.renderer.render_offset.x = CANVAS_WIDTH/2 + cx
    self.object_3d.position.x = -cx * 0.1 + 20

	-- Update exiting players
	for n, exited_player in pairs(self.exited_players) do
		exited_player.vy = exited_player.vy + 5*dt
		exited_player.y = exited_player.y + exited_player.vy*dt

		exited_player.shake_x = random_neighbor(1)
		exited_player.shake_y = random_neighbor(1)

		if random_range(0, 1) < 0.4 then
			table.insert(self.bg_particles, {
				x = exited_player.ox + random_neighbor(2),
				y = exited_player.y,
				life = random_range(0.2, 0.8),
				type = "point",
			})
		end
		
		if exited_player.y > self.rocket_y + 32 then
			self.exited_players[n] = nil

			Audio:play_var("sfx_cutscene_mio_crashes_rocket", 0.1, 1.1)
			game:screenshake(2)
			for i=1, 10 do
				table.insert(self.bg_particles, {
					x = exited_player.ox + random_neighbor(6),
					y = exited_player.y + random_neighbor(6),
					life = random_range(0.2, 0.8),
					type = "circle",
				})
			end

			if n == self.last_exited_player_n then
				game:play_cutscene("basement_zoom_into_rocket")
			end
		end
	end 

	-- Update particles
	for i, ptc in pairs(self.bg_particles) do
		ptc.life = ptc.life - dt
		if ptc.dx then
			ptc.x = ptc.x + ptc.dx * dt
		end
		if ptc.dy then
			ptc.y = ptc.y + ptc.dy * dt
		end
		if ptc.life < 0 then
			table.remove(self.bg_particles, i)
		end
	end

	-- Tutorial 
	self.tutorial_timer = self.tutorial_timer - dt
	if self.tutorial_timer <= 0 then
        game.game_ui:enable_floating_text("🈶 {input.prompts.jetpack}")
		self.tutorial_timer = math.huge
	end

	if self.number_of_exited_players > 0 then
		game.game_ui:disable_floating_text()
	end

	-- Update 3D renderer
	self.renderer:update(dt)
end

function BackroomGroundFloor:draw_background()
	love.graphics.clear(self.background_clear_color)
end

function BackroomGroundFloor:get_rocket_x()
	local cx, cy = math.floor(game.camera:get_real_position())
	return math.floor(227 + cx*0.965)
end

function BackroomGroundFloor:draw_items()
	if not self.show_basement_bg then
		return
	end 
	
    self.renderer:draw()
	-- love.graphics.draw(images.basement,        round(-16 + cx*0.9), -16)
	local rocket_x = self:get_rocket_x()

	for i, ptc in pairs(self.bg_particles) do
		local px = rocket_x + images.basement_rocket_small:getWidth()/2 + ptc.x
		if ptc.type == "point" then
			local col = ternary(ptc.life < 0.2, COL_DARKEST_GRAY, COL_BLACK_BLUE)
			rect_color(col, "fill", px, ptc.y, 1, 1)
		end
	end

	for n, exited_player in pairs(self.exited_players) do
		local px = rocket_x + images.basement_rocket_small:getWidth()/2 + exited_player.ox
		rect_color(COL_BLACK_BLUE, "fill", px + exited_player.shake_x, exited_player.y + exited_player.shake_y, 2, 2)
	end 

	love.graphics.draw(images.basement_rocket_small, rocket_x, self.rocket_y, 0)
	
	for i, ptc in pairs(self.bg_particles) do
		local px = rocket_x + images.basement_rocket_small:getWidth()/2 + ptc.x
		if ptc.type == "circle" then
			local col = ptc.color or COL_LIGHT_GRAY
			if col.type == "gradient" then
				col = col[clamp(round(ptc.life*4), 1, #col)]
			end
			circle_color(col, "fill", px, ptc.y, ptc.life * 4)
		end
	end
end

function BackroomGroundFloor:draw_front_walls()
	local draw = function()
		love.graphics.draw(images.basement_front, -16, -16)
	end

	if not self.show_basement_bg then
		shaders.draw_in_color:sendColor("fillColor", COL_BLACK_BLUE)
		exec_using_shader(shaders.draw_in_color, draw)
	else
		draw()
	end
end

return BackroomGroundFloor