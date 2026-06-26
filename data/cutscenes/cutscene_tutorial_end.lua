local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"

return Cutscene:new("tutorial_end", {
    CutsceneScene:new({
        description = "Start",
        duration = 1.0,
        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(false)

            for _, player in pairs(game.players) do
                player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                player:reset_virtual_controller()
            end

            game.can_join_game = false 
            game.game_ui.logo_y_target = -70
            game.game_ui.cinematic_bars_enabled = true

            game.music_player:set_disk("cutscene_tutorial_end")
        end,
    }),
    CutsceneScene:new({
        description = "All players walk into position",
        duration = 3.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(88*16 + player.n*16)
            end
        end,
    }),
    CutsceneScene:new({
        description = "Players walk into the building",
        duration = 2.0,
        enter = function(cutscene, data)
            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(9999999)
            end
        end,
        update = function(cutscene, data, dt)
            for _, player in pairs(game.players) do
                player.walk_sfx_volume = cutscene.timer:get_inverse_ratio()
            end
        end,
    }),
    CutsceneScene:new({
        description = "Pan camera up",

        duration = 4.0,
        enter = function(cutscene, data)
            game.camera.follows_players = false
            game.camera.max_speed = DEFAULT_CAMERA_MAX_SPEED*2
            game.camera.min_y = -2000000    
            data.camera_start_y = game.camera.y

            for _, player in pairs(game.players) do
                player:set_code_input_mode_target_x(nil)
                player:reset_virtual_controller()
            end
        end,

        update = function(cutscene, data, dt)
            local r = cutscene:get_current_scene_time_ratio()
            local ty = easeinoutquart(data.camera_start_y, -2350, r)
            ty = game.camera.y + min(ty - game.camera.y, 10*dt)
            game.camera:set_position(game.camera.x, ty)
        end
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 4.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        description = "Start dark fadeout",

        duration = 2.0,
        enter = function(cutscene, data)
            Metaprogression:set("has_played_tutorial", true)
            game.game_ui.dark_overlay_alpha_target = 1.0
        end,
    }),
    CutsceneScene:new({
        description = "End dark fadeout",
        duration = 0.02,

        enter = function(cutscene, data)
            game.menu_manager:set_can_pause(true)
            game.game_ui.dark_overlay_alpha = 0.0
            game.game_ui.dark_overlay_alpha_target = 0.0
            game:new_game({
                dark_overlay_alpha = 1.0,
                dark_overlay_alpha_target = 0.0,
            })
            game.game_ui.cinematic_bars_enabled = false

            game.camera.max_speed = DEFAULT_CAMERA_MAX_SPEED
        end
    })
})
