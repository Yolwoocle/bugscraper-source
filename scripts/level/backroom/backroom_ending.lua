require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local BackroomCityOutside = require "scripts.level.backroom.backroom_city_outside"
local BackgroundCity = require "scripts.level.background.background_city"
local Rect = require "scripts.math.rect"
local Loot = require "scripts.actor.loot"

local guns = require "data.guns"

local BackroomEnding = BackroomCityOutside:inherit() 

function BackroomEnding:init(params)
	params = params or {}
    BackroomEnding.super.init(self, params)
	self.name = "ending"

	self.draw_logo = true
end

function BackroomEnding:generate(world_generator)
	BackroomEnding.super.generate(self, world_generator)

	game.level:set_bounds(Rect:new(unpack(RECT_CREDITS_PARAMS)))

	game.music_player:set_disk("off")
	game.ambience_player:set_disk("tutorial")

	game.game_ui.logo_y = -70
	game.game_ui.logo_y_target = -70

	game.camera.max_x = 0
	game.camera.min_y = 16
	game.camera.max_y = 16

	local ceo_x = 20*16
	local ceo_y = 240

	-- todo add shaking and sweating to ceo 
	local ceo = game:new_actor(enemies.NPC:new(ceo_x, ceo_y, {
		npc_name = "ceo",
		animations = {
			normal = { images.ceo_npc_idle, 0.2, 4 },
			shocked = { images.ceo_npc_shocked, 0.2, 1 },
			airborne = { images.ceo_npc_airborne, 0.2, 1 },
			jetpack = { images.ceo_npc_jetpack, 0.2, 1 },
			clap = { images.ceo_npc_clap_hand, 0.02, 3, nil, { looping = false } },
			fainted = {images.ceo_npc_fainted, 0.1, 4},
			sitting = {images.ceo_npc_sitting, 0.1, 1},
			
			tangled_wires = {images.ceo_tangled_wires, 0.1, 1}, 
			tangled_wires_shocked = {images.ceo_tangled_wires_shocked, 0.1, 1},
			tangled_wires_fainted = {images.ceo_tangled_wires_fainted, 0.1, 4},
		},
		flip_x = true,
		extra_update = function(_self, dt)
			-- Init 
			_self.shake_time = _self.shake_time or 0.0
			_self.shake_amount = _self.shake_amount or 0.0

			_self.shake_amount = max(0.0, _self.shake_amount - dt*6)
			_self.spr:update_offset(random_neighbor(_self.shake_amount), 0)

			_self.shake_time = max(0.0, _self.shake_time - dt)
			if _self.shake_time <= 0 and not game.cutscene then
				_self.shake_time = _self.shake_time + 1.0

				_self.shake_amount = 3.0

				Particles:sweat(_self.x - 15, _self.y - 30, true)
			end
		end,
		extra_draw = function(_self)
			if _self.draw_faint_halo then
				draw_faint_halo(_self.mid_x, _self.y - 32, _self.t, images.star_small_2)
			end
		end
	}))
	ceo.draw_faint_halo = true
	ceo.gravity = 0
	ceo.is_affected_by_bounds = false

	ceo.spr:set_animation("fainted")
	ceo.gravity = ceo.default_gravity	 
	ceo.is_affected_by_bounds = true

	game:new_actor(Loot.Gun:new(15*16, 12*16, nil, 0, 0, guns.unlootable.ResignationLetter:new(), {
		life = math.huge,
		min_attract_dist = -1,
		remove_on_collect = true,
		run_on_collect = function(gun)
			game:play_cutscene("ceo_escape_w5")
		end
	}), 440, 105)
	
	
end

function BackroomEnding:get_default_player_position(player_n)
	return 3*16, 0*16
end

function BackroomEnding:get_default_player_gun()
	return guns.unlootable.EmptyGun:new()
end

function BackroomEnding:get_default_camera_position()
	return 0, -16
end

function BackroomEnding:can_exit()
	return false
end

function BackroomEnding:on_player_joined(player)
end

function BackroomEnding:update(dt)
	BackroomEnding.super.update(self, dt)
end

-- function BackroomEnding:on_fully_entered()
-- end

function BackroomEnding:draw_background()
	BackroomEnding.super.draw_background(self)

	if self.draw_logo then
		draw_centered(images.gamelogo, CANVAS_CENTER[1], -400 + CANVAS_CENTER[2])
	end
end

-- function BackroomEnding:draw_front_walls()
-- end

return BackroomEnding