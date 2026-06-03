local Cutscene = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local images = require "data.images"

return Cutscene:new("ceo_escape_w3", {
    CutsceneScene:new({
        description = "",

        duration = 0.01,
        enter = function(cutscene, data)
            for _, actor in pairs(game.actors) do
                if actor.is_shop then
                    actor:end_interaction(true)
                end 
            end

            if not Metaprogression:get("has_seen_w3_transition_cutscene") then
                game.menu_manager:set_can_pause(false)
                game.game_ui.cinematic_bars_enabled = true
                game.game_ui.cinematic_bar_color = COL_VERY_DARK_GRAY
                game.camera:set_target_offset(10000, 0)

                for _, player in pairs(game.players) do
                    player:set_input_mode(PLAYER_INPUT_MODE_CODE)
                    player:reset_virtual_controller()
                end
            end

            for _, actor in pairs(game.actors) do
                if actor.name == "npc" and actor.npc_name == "ceo" then
                    data.ceo = actor
                end
            end
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 0,
        enter = function(cutscene, data)
            data.ceo.gravity = 0
        end,
    }),
    CutsceneScene:new({
        description = "Wait for a bit",

        duration = 1.5,
        enter = function(cutscene, data)
        end,
        update = function(cutscene, data, dt)
        end,
    }),
    CutsceneScene:new({
        description = "Shocked",

        duration = 0.5,
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("shocked")
            data.shake = 3.0

            Particles:static_image(images.surprise_effect, data.ceo.x - 16, data.ceo.y - 30, 0, 0.3)
            data.ceo:play_sound("sfx_w1_cutscene_surprise")
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
        description = "Shocked (wait)",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
        update = function(cutscene, data, dt)
            if Metaprogression:get("has_seen_w3_transition_cutscene") then
                return true
            end
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        description = "Clap",

        duration = (0.02 * 3),
        enter = function(cutscene, data)
            data.ceo.spr:set_animation("clap")
        end,
    }),
    CutsceneScene:new({
        description = "Clap linger",

        duration = 1.0,
        enter = function(cutscene, data)
            data.shake = 3.0
            data.ceo:play_sound("sfx_w2_cutscene_clap")

            Particles:static_image(images.clap_effect, math.floor(data.ceo.x), math.floor(data.ceo.y - 32), 0, 0.3)
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
        description = "shake",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(2), random_neighbor(2))
        end,
    }),
    CutsceneScene:new({
        description = "Shake flash",

        duration = 1.0,
        enter = function(cutscene, data)
            data.t = 0
            data.ceo:play_sound("sfx_cutscene_ceo_leaving_binary")
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(2), random_neighbor(2))
            data.t = data.t + dt

            data.ceo.spr:set_color(COL_WHITE)
            data.ceo.spr:set_solid(data.t % 0.2 < 0.1)
        end,
        exit = function(cutscene, data)
        end
    }),
    CutsceneScene:new({
        description = "Levitate",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
        update = function(cutscene, data, dt)
            data.ceo.spr:update_offset(random_neighbor(2), random_neighbor(2))
            data.t = data.t + dt

            data.ceo.spr:set_color(COL_WHITE)
            data.ceo.spr:set_solid(data.t % 0.2 < 0.1)

            for i=1, 4 do
                Particles:static_image(random_sample{images.particle_bit_zero, images.particle_bit_one}, data.ceo.mid_x + random_neighbor(16), data.ceo.mid_y + random_range(-40, 0), 0, 0.25)
            end
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 3.5,
        enter = function(cutscene, data)
            data.vy = 0
        end,
        update = function(cutscene, data, dt)
            data.vy = data.vy - dt*50

            data.ceo.spr:update_offset(random_neighbor(2), random_neighbor(2))
            data.t = data.t + dt

            data.ceo.spr:set_color(COL_WHITE)
            data.ceo.spr:set_solid(data.t % 0.2 < 0.1)

            for i=1, 4 do
                Particles:static_image(random_sample{images.particle_bit_zero, images.particle_bit_one}, data.ceo.mid_x + random_neighbor(16), data.ceo.mid_y + random_range(-40, 0), 0, 0.25)
            end

            data.ceo.y = data.ceo.y + data.vy * dt
        end,
    }),


    CutsceneScene:new({
        description = "Give back control to players",
        duration = 0,
        enter = function(cutscene, data)
            if not Metaprogression:get("has_seen_w3_transition_cutscene") then
                game.menu_manager:set_can_pause(true)
                game.game_ui.cinematic_bars_enabled = false
                game.camera:set_target_offset(0, 0)

                for _, player in pairs(game.players) do
                    player:set_input_mode(PLAYER_INPUT_MODE_USER)
                    player:reset_virtual_controller()
                end

                Metaprogression:set("has_seen_w3_transition_cutscene", true)
            end
        end
    }),
})
