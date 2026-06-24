require "scripts.util"
local images              = require "data.images"
local BackroomWithDoor    = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local Rect                = require "scripts.math.rect"
local TvPresentation      = require "scripts.level.background.tv_presentation"
local upgrades            = require "data.upgrades"
local enemies             = require "data.enemies"
local cutscenes           = require "data.cutscenes"
local Loot = require "scripts.actor.loot"
local guns = require "data.guns"
local npcs = require "data.npcs"
local HeartJar = require "scripts.actor.enemies.heart_jar"

local BackroomCafeteria   = BackroomWithDoor:inherit()

function BackroomCafeteria:init(params)
	params = params or {}
	BackroomCafeteria.super.init(self, params)
	self.name = "cafeteria"

	self.cafeteria_background = BackgroundCafeteria:new(self)
	self.tv_presentation = TvPresentation:new(349 - 16, 112 - 16)

	self:open_door(false)
	self.door:set_images(
		images.cabin_door_brown_left_far,
		images.cabin_door_brown_left_center,
		images.cabin_door_brown_right_far,
		images.cabin_door_brown_right_center
	)

	self.cafeteria_glass_hole = false
	self.cafeteria_glass_hole_x = nil
	self.cafeteria_glass_hole_y = nil

	self.ceo_info = params.ceo_info
	self.empty_cafeteria = param(params.empty_cafeteria, false)
end

function BackroomCafeteria:generate(world_generator)
	game.level:set_bounds(Rect:new(unpack(RECT_CAFETERIA_PARAMS)))

	world_generator:reset()
	world_generator:write_rect(Rect:new(2, 2, 58, 15), TILE_STONE) -- Walls
	world_generator:write_rect(Rect:new(2, 15, 58, 15), TILE_WOOD) -- Floor
	world_generator:write_rect(Rect:new(28, 13, 41, 13), TILE_WOOD_SEMISOLID) -- Counter
	world_generator:write_rect(Rect:new(4, 13, 8, 13), TILE_WOOD_SEMISOLID) -- Armoire
	if not self.empty_cafeteria then
		world_generator:write_rect(Rect:new(46, 13, 48, 13), TILE_METAL_SEMISOLID) -- Tables
		world_generator:write_rect(Rect:new(51, 13, 53, 13), TILE_METAL_SEMISOLID)
	end

	self:assign_cafeteria_upgrades()

	game.camera.max_x = CANVAS_WIDTH

	self:spawn_ceo()

	local loc_data = {
		{x = 683, y = 226, flip_x = false},
		{x = 720, y = 226, flip_x = "rand"},
		{x = 770, y = 226, flip_x = "rand"},
		{x = 790, y = 226, flip_x = "rand"},
	}
	
	if not self.ceo_info then
		table.insert(loc_data, {x = 845, y = 226, flip_x = false})
		table.insert(loc_data, {x = 880, y = 226, flip_x = true})
	end
	local nb_npcs = random_range_int(1, 2)
	local sampled_loc_data = random_subtable(loc_data, nb_npcs)
	local sampled_spr_data = random_subtable(npcs, nb_npcs)

	for i=1, nb_npcs do
		local loc_data = sampled_loc_data[i]
		local spr_data = sampled_spr_data[i]
		local npc = game:new_actor(enemies.NPC:new(loc_data.x, loc_data.y, {
			npc_name = spr_data.key,
			animation = spr_data.animation,
			flip_x = ternary(loc_data.flip_x == "rand", random_sample{true, false}, loc_data.flip_x),
		}))
		npc.z = -2
	end
end

function BackroomCafeteria:spawn_ceo()
	if not self.ceo_info then
		return
	end

	local ceo_x = 866
	local ceo_y = 223
	if self.ceo_info == 5 then
		ceo_x = 805
		ceo_y = 240
	end

	local ceo = game:new_actor(enemies.NPC:new(ceo_x, ceo_y, {
		npc_name = "ceo",
		animations = {
			normal = { images.ceo_npc_idle, 0.2, 4 },
			shocked = { images.ceo_npc_shocked, 0.2, 1 },
			airborne = { images.ceo_npc_airborne, 0.2, 1 },
			jetpack = { images.ceo_npc_jetpack, 0.2, 1 },
			clap = { images.ceo_npc_clap_hand, 0.02, 3, nil, { looping = false } },
			tangled_wires = {images.ceo_tangled_wires, 0.1, 1},
			tangled_wires_shocked = {images.ceo_tangled_wires_shocked, 0.1, 1},
		},
		flip_x = true,
	}))
	ceo.gravity = 0
	ceo.is_affected_by_bounds = false

	if self.ceo_info == 1 then
		game:new_actor(enemies.PlayerTrigger:new(46 * 16, 3 * 16, 2 * 16, 12 * 16, function()
			game:play_cutscene("ceo_escape_w1")
		end, { min_player_trigger = 1 }))

		game:new_actor(enemies.JumpingProp:new(827, 190, images.ground_floor_boba, "sfx_actor_jumping_prop_boba_{01-06}"))
		game:new_actor(enemies.JumpingProp:new(833, 190, images.ground_floor_laptop, "sfx_actor_jumping_prop_screen_{01-06}"))

	elseif self.ceo_info == 2 then
		game:new_actor(enemies.PlayerTrigger:new(46 * 16, 3 * 16, 2 * 16, 12 * 16, function()
			game:play_cutscene("ceo_escape_w2")
		end, { min_player_trigger = 1 }))

		local bee1 = game:new_actor(enemies.NPC:new(854, 270, {
			npc_name = "bee1",
			animations = {
				normal = { images.bee, 0.05, 2 },
			},
			flip_x = false,
		}))
		bee1.gravity = 0
		bee1.is_affected_by_bounds = false
		bee1.is_affected_by_walls = false
		bee1.z = -1

		local bee2 = game:new_actor(enemies.NPC:new(866, 270, {
			npc_name = "bee2",
			animations = {
				normal = { images.bee, 0.05, 2 },
			},
			flip_x = true,
		}))
		bee2.gravity = 0
		bee2.is_affected_by_bounds = false
		bee2.is_affected_by_walls = false
		bee2.z = -1

		local bee3 = game:new_actor(enemies.NPC:new(878, 270, {
			npc_name = "bee3",
			animations = {
				normal = { images.bee, 0.05, 2 },
			},
			flip_x = true,
		}))
		bee3.gravity = 0
		bee3.is_affected_by_bounds = false
		bee3.is_affected_by_walls = false
		bee3.z = -1

		local prop
		prop = game:new_actor(enemies.JumpingProp:new(827, 190, images.ground_floor_chcolate_mug, "sfx_actor_jumping_prop_mug_{01-06}"))
		prop.z = -2
		prop = game:new_actor(enemies.JumpingProp:new(833, 190, images.ground_floor_laptop, "sfx_actor_jumping_prop_screen_{01-06}"))
		prop.z = -2
	
	
	elseif self.ceo_info == 3 then
		game:new_actor(enemies.PlayerTrigger:new(46 * 16, 3 * 16, 2 * 16, 12 * 16, function()
			game:play_cutscene("ceo_escape_w3")
		end, { min_player_trigger = 1 }))
		ceo.is_affected_by_bounds = false
		ceo.is_affected_by_walls = false

	elseif self.ceo_info == 5 then
		ceo.spr:set_animation("tangled_wires")
		ceo.gravity = ceo.default_gravity	
		ceo.is_affected_by_bounds = true

		game:new_actor(enemies.PlayerTrigger:new(46 * 16, 3 * 16, 2 * 16, 12 * 16, function()
			game:play_cutscene("ceo_escape_w5")
		end, { 
			min_player_trigger = 1,
			condition_func = function()
				for _, p in pairs(game.players) do
					if p.gun.name == "resignation_letter" then
						return true
					end
				end
				return false
			end
		}))

		game:new_actor(Loot.Gun:new(35*16, 12*16, nil, 0, 0, guns.unlootable.ResignationLetter:new(), {
			life = math.huge,
			min_attract_dist = -1,
		}), 440, 105)
	end
end

function BackroomCafeteria:can_exit()
	for _, a in pairs(game.actors) do
		if a.is_shop then
			return false
		end
	end

	return BackroomCafeteria.super.can_exit(self)
end

function BackroomCafeteria:update(dt)
	BackroomCafeteria.super.update(self, dt)

	self.tv_presentation:update(dt)
end

function BackroomCafeteria:on_fully_entered()
	self:close_door()
end

function BackroomCafeteria:assign_cafeteria_upgrades()
	for _, actor in pairs(game.actors) do
		if actor.is_shop then
			actor:assign_random_upgrades()
		end
	end
end

function BackroomCafeteria:draw_background()
	self.cafeteria_background:draw()
	love.graphics.draw(images.elevator_through_door, self.door.x, self.door.y)

	Particles:draw_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)
	for _, actor in pairs(game.actors) do
		if actor.draw_behind_windows_in_cafeterias then
			actor:draw()
		end
	end
end

function BackroomCafeteria:draw_items()
	self.door:draw()
	love.graphics.draw(images.cafeteria, -16, -16)
	if self.cafeteria_glass_hole then
		love.graphics.draw(images.cafeteria_glass_hole, self.cafeteria_glass_hole_x, self.cafeteria_glass_hole_y)
	end
	game.level.elevator:draw_counter()
	
	-- Tables
	if not self.empty_cafeteria then
		love.graphics.draw(images.cafeteria_table_foot, 764-16, 229-16)
		love.graphics.draw(images.cafeteria_table_foot, 844-16, 229-16)

		love.graphics.draw(images.cafeteria_chair_left, 731-16, 220-16)
		love.graphics.draw(images.cafeteria_chair_left, 815-16, 220-16)
		love.graphics.draw(images.cafeteria_chair_right, 875-16, 220-16)
	end
	self.tv_presentation:draw()
end

function BackroomCafeteria:draw_front_walls()
	love.graphics.draw(images.cafeteria_front, -16, -16)
	
	if not self.empty_cafeteria then
		love.graphics.draw(images.cafeteria_table_head, 46*16, 13*16)
		love.graphics.draw(images.cafeteria_table_head, 51*16, 13*16)
	end
end

return BackroomCafeteria
