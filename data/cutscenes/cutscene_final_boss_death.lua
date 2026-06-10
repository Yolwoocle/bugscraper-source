local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local backgrounds = require "data.backgrounds"
local BackgroundFinalBossIntro = require "scripts.level.background.background_final_boss_intro"
local BackgroundAboveCity = require "scripts.level.background.background_above_city"
local BackgroundCity = require "scripts.level.background.background_city"
local BackgroundFinalBossDeath = require "scripts.level.background.background_final_boss_death"
local BackroomEnding  = require "scripts.level.backroom.backroom_ending"
local guns            = require "data.guns"
local InvisibleDummy = require "scripts.actor.enemies.invisible_dummy"

local Rect = require "scripts.math.rect"
local images = require "data.images"

return Cutscene:new("final_boss_death", {
    CutsceneScene:new({
        duration = 2.0,

        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(false)
        end
    }),

    CutsceneScene:new({
        description = "setup",

        duration = 0.0,
        enter = function(cutscene, data)
            for _, actor in pairs(game.actors) do
                if not actor.is_player then
                    actor:remove()
                end
            end
            game:new_actor(InvisibleDummy:new(0, 0))
            
            -- Init players
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()

                player.do_fury_trail = false
                player.is_visible = false
            end

            game.game_ui:set_gameplay_hud_visible(false)
            game.game_ui.cinematic_bars_enabled = true
            game.game_ui.cinematic_bar_color = COL_BLACK_BLUE
            game.level.show_cabin = false

            game.camera.do_camera_position_clamping = false
            game.camera:set_position(CANVAS_WIDTH, 0)

            data.bg = BackgroundFinalBossDeath:new()
            data.bg.offset_y = 100
            game.level:set_background(data.bg)
            game.level.background_speed_lines = false

            game.ambience_player:set_disk("off")
        end,
    }),

    CutsceneScene:new({ 
        description = "Rocket",

        duration = 5,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_rocket_flying")

            data.rocket_shake = 3
            data.t = 0

            data.cutscene_update = function(dt)
                data.t = data.t + dt
                Particles:push_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)

                game:screenshake(2)
                
                Particles:speed_line(random_range(CANVAS_WIDTH, CANVAS_WIDTH*2), -64, {
                    vy = random_range(2000, 3000),
                    particle_layer = PARTICLE_LAYER_CAFETERIA_BACKGROUND, 
                })

                data.bg.rocket_y = CANVAS_CENTER[2] - 60
                data.bg.rocket_ox = random_neighbor(data.rocket_shake)
                data.bg.rocket_oy = random_neighbor(data.rocket_shake)

                if data.t > 2.0 then
                    data.rocket_shake = data.rocket_shake + dt*3
                end

                data.bg.camera_oy = data.bg.camera_oy + 100*dt

                Particles:smoke_big(CANVAS_WIDTH*1.5, data.bg.rocket_y+120, {
                        type = "gradient",
                        COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
                    }, 
                    12, -- rad
                    10, -- quantity
                    {
                        vx = 0, 
                        vx_variation = 20, 
                        vy = 300, 
                        vy_variation = 30,
                        min_spawn_delay = 0,
                        max_spawn_delay = 0.2,
                    }
                )

                Particles:pop_layer()
            end
        end,
        update = function(cutscene, data, dt)
            data.cutscene_update(dt)
        end,
    }),

    CutsceneScene:new({ 
        duration = 0.02,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_rocket_stops")

            game:frameskip(30)
            game:reset_screenshake()
            data.bg.draw_star = true

            data.bg.rocket_ox = 0
            data.bg.rocket_oy = 0

            for _, player in pairs(game.players) do
                player:set_position(game.level.cabin_inner_rect.ax + player.n * 24, player.y)
            end
            data.frame = 0
        end,
        update = function(cutscene, data, dt)
            data.frame = data.frame + 1
            if data.frame > 1 then
                data.bg.draw_star = false
            end
        end,
    }),

    CutsceneScene:new({ 
        description = "Rocket explodes",

        duration = 3.0,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_rocket_explode")

            game:screenshake(40)

            data.bg.rocket_y = 4000 

            game:frameskip(4)
            Particles:push_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)
            Particles:explosion(CANVAS_WIDTH*1.5, CANVAS_HEIGHT*0.5, 80)
            Particles:image(
                CANVAS_WIDTH*1.5, CANVAS_HEIGHT*0.5, 
                200, --numner
                {
                    images.cabin_fragment_1,
                    images.cabin_fragment_2,
                    images.cabin_fragment_3,
                    images.button_fragment_1,
                    images.button_fragment_2,
                    images.button_fragment_3,
                    images.button_fragment_4,
                    images.button_fragment_5,
                }, 
                40, 3.0, 1.0, nil, -- spw_rad, life, vs, g,
                {
                    clamp_to_cabin_rect = false,
                    is_solid = false,
                    vx1 = -150 * 1.5,
                    vx2 = 150 * 1.5,
                    vy1 = 80 * 1.5,
                    vy2 = -200 * 1.5,

                    scale = 1.5,
                }
            )
            Particles:pop_layer()
        end,
        update = function(cutscene, data, dt)
        end,
    }),
    
    CutsceneScene:new({ 
        description = "Players fall",

        duration = 3.0,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_fall")

            game.camera:set_position(0, 0)
            
            local bg = BackgroundAboveCity:new(100000)
            game.level:set_background(bg)
            game.draw_shadows = false

            local num_players = game:get_number_of_alive_players()
            local n = 0
            for _, player in pairs(game.players) do
                player.is_affected_by_bounds = false
                player.is_affected_by_walls = false
                player.is_vulnerable_to_kill_zone = false

                local sp = 32
                player:set_position(CANVAS_WIDTH/2 - sp*(num_players-1)*0.5 + n*sp, CANVAS_HEIGHT/2 + random_neighbor(32))
				player.gravity_mult = 0
                player.is_visible = true
                player.friction_x = 0.0
                
				player.vx = 0
				player.vy = 0

                player.spr:set_rotation(0)--random_range_int(0, 3) * pi/2)

                player:reset_virtual_controller()
                player.spr:set_animation("airborne")
                player.spr:set_shake(2)
                player:equip_gun(guns.unlootable.EmptyGun:new(player))

                n = n + 1
            end
        end,
        update = function(cutscene, data, dt)
            data.upd = function(dt)
                local dx, dy = normalize_vect(1, -3)
                data.fall_dir_dx = dx
                data.fall_dir_dy = dy
                local r = random_range(2000, 3000)

                Particles:speed_line(random_range(0, CANVAS_WIDTH), CANVAS_HEIGHT + 64, {
                    vx = data.fall_dir_dx * r, 
                    vy = data.fall_dir_dy * r, 
                })
    
                for _, player in pairs(game.players) do
                    player.spr:set_animation("dead")
                    player.spr.rot = player.spr.rot + dt * 5
                end
            end
            game.level.level_speed = -1000
            data.upd(dt)
        end,
    }),

    CutsceneScene:new({ 
        description = "Pan players down",

        duration = 2.0,
        enter = function(cutscene, data)
            data.cam_vel = 0
        end,
        update = function(cutscene, data, dt)
            data.upd(dt)
            
            data.cam_vel = data.cam_vel + 200*dt
            for _, player in pairs(game.players) do
                player:set_position(
                    player.x - data.fall_dir_dx * data.cam_vel * dt, 
                    player.y - data.fall_dir_dy * data.cam_vel * dt
                )
            end
        end,
    }),

    CutsceneScene:new({ 
        description = "Tutorial area",

        duration = 2.0,
        enter = function(cutscene, data)
            Particles:clear()

            for _, actor in pairs(game.actors) do
                if not actor.is_player then
                    actor:remove()
                end
            end

            for _, player in pairs(game.players) do
                player:reset()
                player:set_position(7*16 + player.n*16, 0*16)
                player.spr.rot = 0.0
                player.show_hud = false

                player.vx = -300
                player.friction_x = 1.0
                player.gravity_mult = 3.0
                player.gravity_cap = math.huge
                
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end

            game.level:begin_backroom(BackroomEnding:new())
            game.level:set_backroom_on()
        end,
        update = function(cutscene, data)
            for _, player in pairs(game.players) do
                if player.is_grounded then
                    return true
                end
            end
        end,
    }),

    CutsceneScene:new({ 
        description = "Bring back players",

        duration = 1.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:reset()
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
                player.show_hud = false
            end
            
            game:screenshake(14)
            
            local n = 1
            for _, player in pairs(game.players) do
                if n == 1 then
                    player:play_sound("sfx_cutscene_mio_impact_on_ground")
                end
                Particles:image(
                    player.mid_x, player.y + player.h, 
                    200, --numner
                    {
                        images.cabin_fragment_1,
                        images.cabin_fragment_2,
                        images.cabin_fragment_3,
                    }, 
                    4, 3.0, 1.0, nil, -- spw_rad, life, vs, g,
                    {
                        clamp_to_cabin_rect = false,
                        is_solid = false,
                        vx1 = -150 * 0.7,
                        vx2 = 150 * 0.7,
                        vy1 = 80 * 0.7,
                        vy2 = -200 * 0.7,
                    }
                )
            end
        end,
        update = function(cutscene, data)
            for _, player in pairs(game.players) do
                if player.is_grounded then
                    return
                end
            end
        end,
    }),

    CutsceneScene:new({ 
        duration = 1.0,
    }),

    CutsceneScene:new({ 
        duration = 0.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_USER)
                player:reset_virtual_controller()
            end

            game.game_ui.cinematic_bars_enabled = false
            game.game_ui.cinematic_bar_color = COL_BLACK_BLUE

            game.menu_manager:set_can_pause(true)
        end
    })
})