local Cutscene      = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local images        = require "data.images"
local guns          = require "data.guns"
local BackroomCredits = require "scripts.level.backroom.backroom_credits"
local Rect = require "scripts.math.rect"


local function dust_particles(data)
    -- local vx = random_range(40, 60)
    -- Particles:dust(data.ceo.x, data.ceo.y, COL_WHITE, 8, nil, 0, {
    --     vx1 = -vx, vx2 = -vx, vy1 = 0, vy2 = 0
    -- })
    -- Particles:dust(data.ceo.x, data.ceo.y, COL_WHITE, 8, nil, 0, {
    --     vx1 = vx, vx2 = vx, vy1 = 0, vy2 = 0
    -- })

	Particles:smoke(data.ceo.x, data.ceo.y)
end

return Cutscene:new("ceo_escape_w5", {
    
    CutsceneScene:new({
        description = "",

        duration = 0.0,
        enter = function(cutscene, data)
            for _, actor in pairs(game.actors) do
                if actor.is_shop then
                    actor:end_interaction(true)
                end 
            end

            data.init_ceo_x = 20*16

            game.menu_manager:set_can_pause(false)
            game.game_ui.cinematic_bars_enabled = true
            game.game_ui.cinematic_bar_color = COL_BLACK_BLUE
            game.game_ui.offscreen_indicators_enabled = false
            game.camera:set_target_offset(10000, 0)

            data.resigning_player = nil
            for _, player in pairs(game.players) do
                player.show_hud = false
                if player.gun.name == "resignation_letter" then
                    data.resigning_player = player
                end
                
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end
            assert(data.resigning_player ~= nil)

            for _, actor in pairs(game.actors) do
                if actor.name == "npc" and actor.npc_name == "ceo" then
                    data.ceo = actor
                end
            end
        end,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.0,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
        
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(data.init_ceo_x - 64)

            local n = 1
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
                if player ~= data.resigning_player then
                    player:set_code_input_mode_target_x(data.init_ceo_x - 80 - n * 16)
                    n = n + 1
                end
            end
        end,
    }),
    CutsceneScene:new({
        description = "Shocked",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("shocked")
            data.ceo.draw_faint_halo = false
            
            data.shake = 3.0
            data.ceo:play_sound("sfx_cutscene_ceo_afraid_anger_01")

            Particles:static_image(images.surprise_effect, data.ceo.x - 16, data.ceo.y - 30, 0, 0.3)
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(data.shake), random_neighbor(data.shake))
            data.shake = math.max(0, data.shake - dt * 6)
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
    }),

    CutsceneScene:new({
        description = "Shake",

        duration = 1.0,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("sitting")
            data.shake = 3.0
			Particles:sweat(data.ceo.x - 15, data.ceo.y - 30, true)

            data.ceo:play_sound("sfx_cutscene_ceo_afraid_anger_02")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(data.shake), 0)
            data.shake = math.max(0, data.shake - dt * 6)
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),

    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.spr:set_animation("shocked")
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "Jump",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(data.init_ceo_x - 32)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 1.0,
        enter = function(cutscene, data)
            data.ceo:play_sound("sfx_cutscene_ceo_afraid_anger_03")
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(data.init_ceo_x - 16)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound("sfx_cutscene_ceo_afraid_anger_04")
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps away",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vx = 200
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player walks to boss",

        duration = 1.0,
        enter = function(cutscene, data)
            data.resigning_player:set_code_input_mode_target_x(data.init_ceo_x + 16)
        end,
    }),

    CutsceneScene:new({
        description = "Big ass slap in the face (jump)",

        duration = 0.37,
        enter = function(cutscene, data)
            data.resigning_player.virtual_controller.actions["jump"] = true
            data.frames = 0
        end,
        update = function(cutscene, data, dt)
            data.frames = data.frames + 1
            if data.frames > 3 then
                data.resigning_player.virtual_controller.actions["jump"] = false
            end
        end,
        exit = function(cutscene, data)
            data.resigning_player.virtual_controller.actions["jump"] = false
        end,
    }),
    CutsceneScene:new({
        description = "Big ass slap in the face (bammm)",

        duration = 0.3,
        enter = function(cutscene, data)
            data.ceo:play_sound("sfx_cutscene_mio_slaps_ceo")
            game:frameskip(20)
            game:screenshake(5)

            Particles:push_layer(PARTICLE_LAYER_BACK)
            Particles:static_image(
                images.star_big, 
                (data.resigning_player.mid_x + data.ceo.mid_x)/2, 
                data.resigning_player.mid_y, 
                0, 0.3, 0.8, {
                color = COL_WHITE
            })
            Particles:pop_layer()

            data.resigning_player:equip_gun(guns.unlootable.EmptyGun:new(data.resigning_player))

            data.ceo.spr:set_animation("sitting")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(3), random_neighbor(3))
        end,
        exit = function(cutscene, data)
            data.ceo.spr:update_offset(0, 0)
        end
    }),
    -- CutsceneScene:new({
    --     description = "Image of the big ass slap in the face",

    --     duration = 0.5,
    --     enter = function(cutscene, data)
    --         game.menu_manager:set_menu("ceo_slap")
    --         data.timer = 0.5
    --     end,
    --     update = function(cutscene, data, dt)
    --         data.ceo.spr:update_offset(random_neighbor(data.timer*6), random_neighbor(data.timer*6))
    --         data.timer = math.max(0.0, data.timer - dt)
    --     end,
    --     exit = function(cutscene, data)
    --         data.ceo.spr:update_offset(0, 0)
    --     end
    -- }),

    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),

    CutsceneScene:new({
        description = "Blink (closed)",

        duration = 0.05,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("sitting")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (open)",

        duration = 0.2,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("shocked")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (closed)",

        duration = 0.05,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("sitting")
        end,
    }),
    CutsceneScene:new({
        description = "Blink (open)",

        duration = 0.2,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("shocked")
        end,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
        enter = function(cutscene, data)
        end,
    }),

    CutsceneScene:new({
        description = "Resigning player goes away",

        duration = 0.5,
        enter = function(cutscene, data)
            -- Open hole in building
        	game.level.world_generator:write_rect_fill(Rect:new(0, 11, 2, 12),  TILE_AIR)
            -- game.level:set_bounds(Rect:new(unpack({-10, -2, 31, 16})))

            data.resigning_player:set_input_mode(PLAYER_INPUT_MODE_CODE)
            data.resigning_player:set_code_input_mode_target_x()
            data.resigning_player:reset_virtual_controller()
            data.resigning_player.virtual_controller.actions["left"] = true
        end,
    }),
    CutsceneScene:new({
        description = "Remaining players go away",

        duration = 3.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do            
                if player ~= data.resigning_player then
                    player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                    player:set_code_input_mode_target_x()
                    player:reset_virtual_controller()
                    
                    player.virtual_controller.actions["left"] = true
                end
            end
        end,

        update = function(cutscene, data, dt)
            for _, player in pairs(game.players) do
                if 10*16 <= player.x and player.x <= 12*16 then
                    player.virtual_controller.actions["jump"] = true
                else
                    player.virtual_controller.actions["jump"] = false
                end

                if player.x <= 4*16 and not data.__has_opened_door then
                    data.__has_opened_door = true
                    Particles:opened_door(3*16-1, 10*16, {linger_time = 1.0})
                end

                player.walk_sfx_volume = clamp(map_range(player.x, 32, 4, 1, 0), 0.0, 1.0)
            end
        end,
    }),

    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Iris phase 1",

        duration = 0.8,
        enter = function(cutscene, data)
        end,
    }),

    
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),
    CutsceneScene:new({
        description = "CEO jumps",

        duration = 0.4,
        enter = function(cutscene, data)
            data.ceo:play_sound_var("sfx_cutscene_ceo_boingboing", 0.1, 1.2, {volume=0.7})
            data.ceo.vy = -200
            dust_particles(data)
        end,
    }),

    CutsceneScene:new({
        description = "Wait",

        duration = 1.0,
        enter = function(cutscene, data)            
        end,
    }),
    
    CutsceneScene:new({
        description = "Pan Camera",

        duration = 3.0,
        enter = function(cutscene, data)
            game.camera.follows_players = false
            game.camera.max_speed = 10000000
            game.camera.min_y = -2000000
            data.camera_start_y = game.camera.y

            game.ambience_player:fade_out("off", 3.0)
            game.music_player:set_disk("credits")
        end,
        update = function(cutscene, data, dt)
            local r = cutscene:get_current_scene_time_ratio()
            local ty = easeinoutquart(data.camera_start_y, -400, r)
            if math.abs(-400 - game.camera.y) < 2 then
                game.camera:set_position(game.camera.x, -400)
            end
            game.camera:set_position(game.camera.x, ty)
        end,
        exit = function(cutscene, data)
            Achievements:grant("ach_complete_end")
            if game.level.last_damage_wave == 0 then
                Achievements:grant("ach_no_damage_full")
            end

            game:on_end_game()
        end,
    }),
    
    CutsceneScene:new({
        description = "Credits",

        duration = 0,
        enter = function(cutscene, data)
            game:play_cutscene("credits")
        end,
    }),
})
