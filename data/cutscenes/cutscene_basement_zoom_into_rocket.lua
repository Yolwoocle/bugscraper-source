local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light = require "scripts.graphics.light.light_spotlight"
local Rect = require "scripts.math.rect"
local images = require "data.images"
local guns = require "data.guns"
local BackroomBasement = require "scripts.level.backroom.backroom_basement"
local LightPoint      = require "scripts.graphics.light.light_point"

return Cutscene:new("basement_zoom_into_rocket", {
    CutsceneScene:new({
        description = "",
        duration = 1.5,
        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(false)
        end,
        update = function(cutscene, data, dt)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 3.0,
        enter = function(cutscene, data)
            game.ambience_player:set_disk("basement_rocket_rumble")
        end,
        update = function(cutscene, data, dt)
            game:screenshake(1)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_voice_countdown")
            game.game_ui.ending_counter_text = "3"
        end,
        update = function(cutscene, data, dt)
            game:screenshake(1)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui.ending_counter_text = "2"
        end,
        update = function(cutscene, data, dt)
            game:screenshake(2)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui.ending_counter_text = "1"
        end,
        update = function(cutscene, data, dt)
            game:screenshake(4)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui.ending_counter_text = "0"
        end,
        update = function(cutscene, data, dt)
            game:screenshake(4)
        end
    }),
    CutsceneScene:new({
        description = "Rocket rise",
        duration = 2.0,
        enter = function(cutscene, data)
            game.game_ui.ending_counter_text = nil

            data.rocket_vy = 0.0
            data.rocket_ay = -20.0

            Audio:play("sfx_cutscene_rocket_takeoff")
        end,
        update = function(cutscene, data, dt)
            data.new_rocket_ptc = function()
                data.rocket_vy = data.rocket_vy - data.rocket_ay * dt
                game.level.backroom.rocket_y = game.level.backroom.rocket_y - data.rocket_vy * dt
                --  = game.level.backroom.rocket_y - data.rocket_vy * dt
                table.insert(game.level.backroom.bg_particles, {
                    x = random_neighbor(6),
                    y = game.level.backroom.rocket_y + images.basement_rocket_small:getHeight() + random_neighbor(6),
                    life = random_range(0.8, 1.5),
                    type = "circle",
                    color = {
                        type = "gradient",
                        COL_BLACK_BLUE, COL_DARK_GRAY, COL_DARK_RED, COL_ORANGE, COL_YELLOW, COL_WHITE  
                    }, 
                })
            end
            data.new_rocket_ptc()

            game:screenshake(4)
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.ambience_player:fade_out("off", 1.0)

            game.game_ui.ending_counter_text = nil

        	local cx, cy = math.floor(game.camera:get_real_position())
            local x = game.level.backroom:get_rocket_x() + images.basement_rocket_small:getWidth()/2
            local y = game.level.backroom.rocket_y + 32
            game.game_ui:start_iris_transition(x - cx, y, 1.0, CANVAS_WIDTH, 0)
        end,
        update = function(cutscene, data, dt)            
            data.rocket_vy = data.rocket_vy - data.rocket_ay * dt
            game.level.backroom.rocket_y = game.level.backroom.rocket_y - data.rocket_vy * dt

            game:screenshake(4)
            data.new_rocket_ptc()
        end
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
        	Audio:set_effect(nil)
        end,
    }),

    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(true)

            game.level.slowdown_timer_override = 2.0
            game.level.backroom.can_exit_basement = true

            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_USER)
                player:reset_virtual_controller()

                local px = lerp(game.level.cabin_inner_rect.ax+16, game.level.cabin_inner_rect.ax+16*4, (player.n-1) / (MAX_NUMBER_OF_PLAYERS-1))
                player:set_position(px, game.level.door_rect.by)

                game.level:set_bounds(Rect:new(unpack(RECT_ELEVATOR_PARAMS)))

                player.gravity_mult = 1.0
            end
        end,
    }),
    
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            local x = lerp(game.level.cabin_inner_rect.ax+16, game.level.cabin_inner_rect.ax+16*4, 0.5)
            game.game_ui:start_iris_transition(x, game.level.door_rect.by, 1.0, 0, 64)
        end,
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:start_iris_transition(nil, nil, 1.0, nil, CANVAS_WIDTH)            
            game.draw_shadows = true
        end,
    }),
    CutsceneScene:new({
        description = "",
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:set_iris(false)

            game.level.slowdown_timer_override = nil
        end,
    }),
})
