require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local BackroomCityOutside = require "scripts.level.backroom.backroom_city_outside"
local BackgroundCity = require "scripts.level.background.background_city"
local Rect = require "scripts.math.rect"
local Loot = require "scripts.actor.loot"

local cutscenes = require "data.cutscenes"
local guns = require "data.guns"

local BackroomTutorial = BackroomCityOutside:inherit()

function BackroomTutorial:init(params)
	params = params or {}
    BackroomTutorial.super.init(self, params)
	self.name = "tutorial"

	self.freeze_fury = false
end

function BackroomTutorial:generate(world_generator)
	BackroomTutorial.super.generate(self, world_generator)
	
	-- Exit sign
	local sign = game:new_actor(enemies.ExitSign:new(50, 160))
	sign.smash_easter_egg_probability = 0

	-- Exit trigger
	game:new_actor(enemies.PlayerTrigger:new(87*16, 9*16, 8*16, 5*16, function()
		game:play_cutscene("tutorial_end")
		game.game_ui.offscreen_indicators_enabled = false

		local ax, ay, bx, by = unpack(RECT_TUTORIAL_PARAMS)
		game.level:set_bounds(Rect:new(ax, ay, bx + 4, by))
	end, {min_player_trigger = 0}))

	
	-- Walls, dummies
	game:new_actor(enemies.BreakableWall:new(47*16, 6*16))
	game:new_actor(enemies.Dummy:new(72*16, 13*16))
	game:new_actor(enemies.Dummy:new(75*16, 13*16))
	game:new_actor(enemies.Dummy:new(78*16, 13*16))
	self.gun = game:new_actor(Loot.Gun:new(40*16, 12*16, nil, 0, 0, guns.unlootable.Machinegun:new(), {
		life = math.huge,
		min_attract_dist = -1,
		player_filter = function(player)
			return player.gun and player.gun.name == "empty_gun"
		end,
		remove_on_collect = true,
	}), 440, 105)

	-- TODO add wrning sign at 418 181
	for _, prop_data in pairs({
		{x = 418, y = 181, z = 0, img = images.ground_floor_caution_sign,          sound = "sfx_actor_jumping_prop_sign_{01-04}"},
		{x = 943, y = 68,  z = 0, img = images.ground_floor_warning_sign,          sound = "sfx_actor_jumping_prop_sign_{01-04}"},
	}) do
		local prop = enemies.JumpingProp:new(prop_data.x, prop_data.y, prop_data.img, prop_data.sound)
		if prop_data.z then
			prop.z = prop_data.z
		end
		game:new_actor(prop)
	end
		


	-- Camera, music, stuff
	game.camera.max_x = 67*16
	game.music_player:set_disk("off")
	game.ambience_player:set_disk("tutorial")

	-- Start cutscene
	if not Metaprogression:get("has_seen_intro_credits") then
		game:play_cutscene("tutorial_start")
	end
end

function BackroomTutorial:get_default_player_position(player_n)
	return 3*16, 12*16
end

function BackroomTutorial:get_default_player_gun()
	return guns.unlootable.EmptyGun:new()
end

function BackroomTutorial:get_default_camera_position()
	return 0, 48
end

function BackroomTutorial:get_x_target_after_join_game()
	return 95
end

function BackroomTutorial:on_player_joined(player)
	Particles:opened_door(3*16-1, 10*16)
end

function BackroomTutorial:can_exit()
	return false
end

function BackroomTutorial:update(dt)
	BackroomTutorial.super.update(self, dt)

	if self.gun and self.gun.is_removed then
		self.gun = game:new_actor(Loot.Gun:new(40*16, 12*16, nil, 0, 0, guns.unlootable.Machinegun:new(), {
			life = math.huge,
			min_attract_dist = -1,
			player_filter = function(player)
				return player.gun and player.gun.name == "empty_gun"
			end,
			remove_on_collect = true,
		}), 440, 105)
	end
end

function BackroomTutorial:on_fully_entered()
end

function BackroomTutorial:draw_background()
	BackroomTutorial.super.draw_background(self)
end

function BackroomTutorial:draw_items()
	BackroomTutorial.super.draw_items(self)

	if not Input:get_user(1) then
		return 
	end

	-- Input:draw_input_prompt(1, {"jump"}, Text:text("input.prompts.jump"), COL_WHITE, 24*16, 8*16, {
	-- 	alignment = "center",
	-- 	background_color = transparent_color(COL_BLACK_BLUE, 0.5),
	-- })
	-- Input:draw_input_prompt(1, {"jump", "right"}, Text:text("input.prompts.wall_jump"), COL_WHITE, 32.5*16, 4*16, {
	-- 	alignment = "center",
	-- 	background_color = transparent_color(COL_BLACK_BLUE, 0.5),
	-- })
	-- Input:draw_input_prompt(1, {"shoot"}, Text:text("input.prompts.shoot"), COL_WHITE, 40*16, 9*16, {
	-- 	alignment = "center",
	-- 	background_color = transparent_color(COL_BLACK_BLUE, 0.5),
	-- })
	Input:draw_input_prompt(1, {}, "⬇ + {input.prompts.shoot} = {input.prompts.jetpack}", COL_WHITE, 54*16, 4*16, {
		alignment = "center",
		background_color = transparent_color(COL_BLACK_BLUE, 0.5),
	})
end

function BackroomTutorial:draw_front_walls()
	BackroomTutorial.super.draw_front_walls(self)
end

return BackroomTutorial