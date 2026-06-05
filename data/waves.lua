require "scripts.util"
local backgrounds       = require "data.backgrounds"
local enemies           = require "data.enemies"
local cutscenes         = require "data.cutscenes"
local images            = require "data.images"
local bit               = require "bit"

local Rect              = require "scripts.math.rect"
local LevelGeometry     = require "scripts.level.level_geometry"
local Wave              = require "scripts.level.wave"
local BackroomCafeteria = require "scripts.level.backroom.backroom_cafeteria"
local BackroomCEOOffice = require "scripts.level.backroom.backroom_ceo_office"
local E                 = require "data.enemies"

local ElevatorW1        = require "scripts.level.elevator.elevator_w1"
local ElevatorW2        = require "scripts.level.elevator.elevator_w2"
local ElevatorW3        = require "scripts.level.elevator.elevator_w3"
local ElevatorW4        = require "scripts.level.elevator.elevator_w4"
local ElevatorW0        = require "scripts.level.elevator.elevator_w0"
local ElevatorRocket    = require "scripts.level.elevator.elevator_rocket"

local utf8              = require "utf8"

RECT_ELEVATOR           = Rect:new(unpack(RECT_ELEVATOR_PARAMS))
RECT_CAFETERIA          = Rect:new(unpack(RECT_CAFETERIA_PARAMS))
RECT_CEO_OFFICE         = Rect:new(unpack(RECT_CEO_OFFICE_PARAMS))

local function new_cafeteria(params)
    params = params or {}

    local run_func = params.run_func or function(...) end
    local wave_enemies = {
        { E.ShopCafeteria, 1, position = { params.shopkeeper_x_override or 35*16, 13*16 }, ignore_position_clamp = true },
    }
    if params.empty_cafeteria then
        wave_enemies = {}
    end

    return Wave:new({
        floor_type = FLOOR_TYPE_CAFETERIA,
        roll_type = WAVE_ROLL_TYPE_FIXED,
        music = "cafeteria",
        ambience = "cafeteria",
        push_music_buffer = true, 

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end
            end

            for i=1, MAX_NUMBER_OF_PLAYERS do
                if game.waves_until_respawn[i][2] then
                    game.waves_until_respawn[i][1] = -1
                end
            end

            run_func(self, level)
        end,

        min = 1,
        max = 1,
        enemies = wave_enemies,

        backroom = BackroomCafeteria,
        backroom_params = {
            ceo_info = params.ceo_info,
            empty_cafeteria = param(params.empty_cafeteria, false)
        },

        achievements = params.achievements,
    })
end

local function new_wave(params)
    params.bounds = params.bounds or RECT_ELEVATOR
    return Wave:new(params)
end

local function get_world_prefix(n)
    return Text:text("level.world_prefix", tostring(n))
end

local function get_world_name(n)
    return Text:text("level.world_" .. tostring(n))
end

local function spawn_timed_spikes()
    local j = 0
    local x2 = CANVAS_WIDTH / 16 - 4
    for ix = 3, x2 do
        local spikes = enemies.TimedSpikes:new(
            ix * BW, CANVAS_HEIGHT * 0.85, 
            6, 1, 0.5, j * 0.3, 
            {
                do_standby_warning = x2 - 4 <= ix
            }
        )
        spikes.z = 3 - j / 100
        game:new_actor(spikes)
        j = j + 1
    end
end

local function spawn_timed_spikes_w5()
    local j = 0
    local x2 = CANVAS_WIDTH / 16 - 4
    for ix = 3, x2 do
        local spikes = enemies.TimedSpikes:new(
            ix * BW, CANVAS_HEIGHT * 0.85, 
            4, 0.5, 0.2, j * 0.1 + 2.0, 
            {
                do_standby_warning = x2 - 4 <= ix
            }
        )
        spikes.z = 3 - j / 100
        game:new_actor(spikes)
        j = j + 1
    end
end

local function get_w4_vines_points_func_2()
    return function()
        local pts = {}
        local center = (game.level.cabin_inner_rect.ax + game.level.cabin_inner_rect.bx) / 2

        local ix = 0
        for ix = 0, CANVAS_WIDTH, 16 do
            table.insert(pts, { ix, game.level.cabin_inner_rect.by - math.cos((ix-CANVAS_WIDTH/2)/32) * 24 })
        end

        return pts
    end
end

local function get_w4_vines_points_func_3()
    -- spiral
    return function()
        local pts = {}
        local cx = (game.level.cabin_inner_rect.ax + game.level.cabin_inner_rect.bx) / 2
        local cy = (game.level.cabin_inner_rect.ay + game.level.cabin_inner_rect.by) / 2

        local theta_step = 0.4
        local a = 8
        local max_theta = 8 * math.pi
        local theta = max_theta

        local function get_point(theta_)
            local r = a * theta_
            local x = cx + math.cos(theta_) * r
            local y = cy + math.sin(theta_) * r
            return x, y
        end

        local x1, y1 = get_point(theta - theta_step)
        local x2, y2 = get_point(theta)
        local nx, ny = normalize_vect(x2 - x1, y2 - y1)
        local norm = dist(x2 - x1, y2 - y1)
        local x3, y3 = x2 + nx*150, y2 + ny*150
        table.insert(pts, {x3, y3})

        while theta >= 0 do
            local x, y = get_point(theta)
            table.insert(pts, {x, y})
            theta = theta - theta_step
        end

        return pts
    end
end

local function parse_waves_table(waves)
    local parsed_waves = {}

    local current_world = nil
    local current_background = nil
    local current_elevator = nil
    local current_music = nil
    local current_ambience = nil
    for i = 1, #waves do
        local wave_params = waves[i]

        current_world = wave_params.world or current_world
        -- current_background = wave_params.background or current_background
        current_elevator = wave_params.elevator or current_elevator
        current_music = wave_params.music or current_music
        current_ambience = wave_params.ambience or current_ambience

        wave_params.world = current_world
        -- wave_params.background = current_background
        wave_params.elevator = current_elevator
        wave_params.music = current_music
        wave_params.ambience = current_ambience

        -- current_background = wave_params.backgroud_transition or current_background

        parsed_waves[i] = new_wave(wave_params)

    end
    return parsed_waves
end

local thorns_arc_params = {
    lightning_params = {
        style = LIGHTNING_STYLE_THORNS, 
        min_step_size = 10,
        max_step_size = 10,
        min_line_width = 0,
        max_line_width = 0,
        jitter_width = 0,
    }
}

local waves_defs = {

    { -- FINAL BOSS
        roll_type = WAVE_ROLL_TYPE_FIXED,

        min = 1,
        max = 1,
        enemies = {
            { E.FinalBoss, 1, 
                position = { 12.5 * 16, 10 * 16 + 8 }, 
                life = 1,
                args = {{init_state = "introduction"}} }
        },

        -- cutscene = "final_boss_enter",

        counter_display_func = function(_)
            -- Pseudo random looking floor counter
            local frame = math.floor(game.in_game_frame / 5)
            local nb = (32849 * frame) % 999
            return math.floor(clamp(nb, 100, 999))
        end,

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "final_boss" then
                    actor.state_machine:set_state("start")
                end
            end

            level.freeze_fury_override = false
        end
    },

    -- {
    --     min = 0,
    --     max = 0,
    --     enemies = {
    --         { E.Larva, 3, entrances = { "main" } },
    --     },
    --     music = "w1",
    --     fade_out_music = false,
    --     ambience = "w1",

    --     over_title = get_world_prefix(1),
    --     title = get_world_name(1),
    --     over_title_color = COL_LIGHT_GRAY,
    --     title_color = {COL_LIGHTEST_GRAY, COL_WHITE, COL_MID_GRAY, COL_MID_GRAY, stacked=true},
    --     title_outline_color = COL_BLACK_BLUE,

    --     elevator = ElevatorW1,
    -- },

    
    -- -- CEO's office
    -- {
    --     floor_type = FLOOR_TYPE_CAFETERIA,
    --     roll_type = WAVE_ROLL_TYPE_FIXED,
    --     music = "off",
    --     ambience = "off",
        
    --     run = function(self, level)
    --         for _, actor in pairs(game.actors) do
    --             if actor.name == "poison_cloud" then
    --                 actor.lifespan = 1
    --             end
    --             if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
    --                 actor:remove()
    --             end   
    --         end
    --         game.actor_manager:remove_actors_with_name("progressing_arc")
    --     end, 

    --     min = 1,
    --     max = 1,
    --     enemies = {},

    --     bounds = RECT_CEO_OFFICE,
    --     backroom = BackroomCEOOffice,

    --     achievements = {"ach_complete_w4"},
    -- },
    
    --- --- --- --- --- --- --- --- --- --- --- ---

    {
        min = 5,
        max = 5,
        enemies = {
            { E.Larva, 3, entrances = { "main" } },
        },
        music = "w1",
        fade_out_music = false,
        ambience = "w1",

        over_title = get_world_prefix(1),
        title = get_world_name(1),
        over_title_color = COL_LIGHT_GRAY,
        title_color = {COL_LIGHTEST_GRAY, COL_WHITE, COL_MID_GRAY, COL_MID_GRAY, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        elevator = ElevatorW1,
    },


    {
        -- Woodlouse intro
        min = 4,
        max = 6,
        enemies = {
            { E.Woodlouse, 2, entrances = { "main" } },
        },
    },

    {
        min = 4,
        max = 6,
        enemies = {
            { E.Larva,     2, entrances = { "main" } },
            { E.Fly,       3, entrances = { "main" } },
            { E.Woodlouse, 2, entrances = { "main" } },
        },
    },

    {
        -- Slug intro
        min = 4,
        max = 6,
        enemies = {
            { E.Larva, 2 },
            { E.Fly,   2 },
            { E.Slug,  4 },
        },
    },


    {
        min = 3,
        max = 5,
        enemies = {
            -- Shelled Snail intro
            { E.SnailShelled, 3 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            --
            { E.Larva,        4 },
            { E.Fly,          4 },
            { E.Woodlouse,    2 },
            { E.SnailShelled, 3 },
            { E.Slug,         2 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.SnailShelled, 4 },
            { E.SpikedFly,    3 },
            { E.Fly,          3 },
        },
    },

    {
        -- Mushroom ant intro
        roll_type = WAVE_ROLL_TYPE_FIXED,
        enemies = {
            { E.Fly,        2 },
            { E.Boomshroom, 4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          5 },
            { E.Slug,         2 },
            { E.SpikedFly,    4 },
            { E.Woodlouse,    4 },
            { E.SnailShelled, 4 },
        },
    },

    new_cafeteria(),

    {
        -- Spiked Fly intro
        min = 6,
        max = 8,
        music = "w1",
        ambience = "w1",
        pull_music_buffer = true, 

        enemies = {
            { E.Larva,     1 },
            { E.Fly,       2 },
            { E.SpikedFly, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,        1 },
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   4 },
            { E.Slug,         2 },
            { E.SnailShelled, 2 },
        },
    },

    {
        -- Spider intro
        min = 6,
        max = 8,
        enemies = {
            { E.Larva,  1 },
            { E.Slug,   2 },
            { E.Spider, 4 },
        },
    },

    {
        min = 6,
        max = 8,
        enemies = {
            { E.Fly,          2 },
            { E.SnailShelled, 2 },
            { E.Spider,       4 },
        },
    },

    {
        min = 8,
        max = 9,
        enemies = {
            { E.Fly,          2 },
            { E.SpikedFly,    2 },
            { E.SnailShelled, 2 },
            { E.Slug,         2 },
            { E.Spider,       4 },
        },
    },

    {
        -- Stink bug intro
        min = 5,
        max = 6,
        enemies = {
            { E.StinkBug, 3 },
        },
    },

    {
        min = 7,
        max = 9,
        enemies = {
            { E.Larva,        1 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     4 },
        },
    },

    {
        min = 8,
        max = 10,
        enemies = {
            { E.Fly,          2 },
            { E.Slug,         2 },
            { E.Woodlouse,    2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     2 },
        },
    },

    {
        -- roll_type = WAVE_ROLL_TYPE_FIXED,
        min = 1,
        max = 1,
        enemies = {
            { E.Dung, 1, position = { CANVAS_WIDTH / 2 - 24 / 2, 200 } },
        },
        music = "boss_w1",
        cutscene = "dung_boss_enter",
    },

    new_cafeteria({ ceo_info = 1, achievements = {"ach_complete_w1"} }),



    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W2: beehive / factory
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------


    {
        min = 6,
        max = 7,

        enemies = {
            { E.Larva, 2 },
            { E.Bee,   2 },
        },

        background = backgrounds.BackgroundFactory:new(),
        music = "w2",
        ambience = "w2",

        elevator = ElevatorW2,

        over_title = get_world_prefix(2),
        title = get_world_name(2),
        over_title_color = COL_ORANGE,
        title_color = {COL_LIGHT_YELLOW, COL_WHITE, COL_ORANGE, COL_ORANGE, stacked=true},
        title_outline_color = COL_BLACK_BLUE,
    },

    {
        min = 5,
        max = 7,

        enemies = {
            { E.Larva,  2 },
            { E.Bee,    2 },
            { E.Stabee, 4 },
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.Beelet, 2 },
        },
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.Larva,      4 },
            { E.Bee,        4 },
            { E.Boomshroom, 4 },
            { E.Beelet,     2 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         4 },
            { E.HoneypotAnt, 4 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,    4 },
            { E.Beelet, 3 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         3 },
            { E.HoneypotAnt, 4 },
            { E.Stabee,      3 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        }
    },

    {
        min = 10,
        max = 10,

        enemies = {
            { E.SnailShelled, 1 },
            { E.Bee,          3 },
            { E.HoneypotAnt,  1 },
            { E.Stabee,       2 },
            { E.Larva,        2 },
        },
    },


    {
        min = 6,
        max = 6,

        enemies = {
            { E.Beelet, 8 },
        },
        fixed_enemies = {
            { E.Comball, 1 },
        },
    },

    ---------------------------------------------
    new_cafeteria(),
    ---------------------------------------------

    {
        min = 4,
        max = 4,

        enemies = {
            { E.DrillBee, 3 },
        },

        music = "w2",
        ambience = "w2",
        pull_music_buffer = true, 
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.Bee,   3 },
            { E.Larva, 3 },
        },

        run = function(self, level)
            spawn_timed_spikes()
        end,
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Bee,         3 },
            { E.Larva,       3 },
            { E.HoneypotAnt, 2 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.Stabee,      10 },
            { E.HoneypotAnt, 2 },
        },
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.DrillBee,   30 },
        },
        fixed_enemies = {
            { E.DrillBee, 1 },
        }
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.Larva,       3 },
            { E.HoneypotAnt, 4 },
            { E.Bee,      3 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        },
    },


    {
        min = 7,
        max = 7,

        enemies = {
            { E.Bee,      3 },
            { E.DrillBee, 3 },
        },
    },


    {
        min = 7,
        max = 7,

        enemies = {
            { E.Larva,       3 },
            { E.Bee,         3 },
            { E.Stabee,      3 },
            { E.DrillBee,    3 },
            { E.HoneypotAnt, 3 },
            { E.Boomshroom,  3 },
        },
    },

    {
        -- roll_type = WAVE_ROLL_TYPE_FIXED,
        min = 1,
        max = 1,
        enemies = {
            { E.BeeBoss, 1, position = { 240 - 16, 200 } },
        },
        music = "boss_w2",
        ambience = "bee_boss_crowd_normal",

        run = function(self, level)
            for _, actor in pairs(level.game.actors) do
                if actor.name == "timed_spikes" then
                    actor:remove()
                end
            end
        end,

        cutscene = "bee_boss_enter",
    },

    new_cafeteria({ 
        run_func = function()
            for _, a in pairs(game.actors) do
                if a.name == "timed_spikes" then
                    a:remove()
                end
            end

            game.is_light_on = true
            game.light_world:reset_lights()
        end,
        ceo_info = 2,
        achievements = {"ach_complete_w2"},
    }),

    ------

    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W3: server room
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    -- Floor
    {
        min = 4,
        max = 4,
        enemies = {
            { E.Chipper, 1 },
        },
        background = backgrounds.BackgroundServers:new(),
        music = "w3",
        ambience = "w3",

        elevator = ElevatorW3,

        elevator_layers = {
            ["bg_grid"] = true,
            ["fg_grid"] = false,
        },

        over_title = get_world_prefix(3),
        title = get_world_name(3),
        over_title_color = COL_MID_GREEN,
        title_color = {COL_LIGHT_GREEN, COL_WHITE, COL_MID_GREEN, COL_MID_GREEN, stacked=true},
        title_outline_color = COL_BLACK_BLUE,
    },

    {
        min = 5,
        max = 5,
        enemies = {
            { E.Chipper,   2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        },
    },

    {
        min = 5,
        max = 7,
        enemies = {
            { E.Slug,      2 },
            { E.StinkBug,  2 },
            { E.Chipper,   2 },
            { E.BulbBuddy, 1 },
        },
    },

    {
        min = 6,
        max = 6,
        enemies = {
            { E.Grasshopper,  2 },
            { E.SnailShelled, 2 },
            { E.Woodlouse,    2 },
        },
    },

    {
        level_geometry = LevelGeometry:new({
            { rect = Rect:new(3, 8, 8, 8),   tile = TILE_METAL_SEMISOLID },
            { rect = Rect:new(21, 8, 26, 8), tile = TILE_METAL_SEMISOLID },
        }),
        elevator_layers = {
            ["bg_grid"] = false,
        },
        run = function(self, level)
            local cabin_rect = game.level.cabin_rect
            Particles:falling_grid(cabin_rect.ax + 16, cabin_rect.ay + 6 * 16)
            Particles:falling_grid(cabin_rect.bx - 7 * 16, cabin_rect.ay + 6 * 16)
            if level.elevator.start_grid_timer then
                level.elevator:start_grid_timer(2.5)
            end
        end,

        fixed_enemies = {
            {
                E.ElectricRays,
                1,
                position = { CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 8 },
                args = { {
                    n_rays = 1,
                    activation_delay = 2,
                    init_angle = pi / 2,
                    angle_speed = 0,
                } }
            },
        },

        min = 6,
        max = 7,
        enemies = {
            { E.Grasshopper, 2 },
            { E.Chipper, 2 },
        },
    },

    {
        min = 3,
        max = 4,
        enemies = {
            { E.MetalFly, 4 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        },

        run = function(self, level)
            for _, enemy in pairs(game.actors) do
                if enemy.name == "electric_rays" then
                    enemy.angle_speed = 0.3
                end
            end
        end,
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.Slug,        4 },
            { E.StinkBug,    4 },
            { E.Chipper,     4 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    {
        min = 6,
        max = 7,
        enemies = {
            { E.Fly,         2 },
            { E.MetalFly,    4 },
            { E.Chipper,     4 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    {
        min = 8,
        max = 8,
        enemies = {
            { E.MetalFly,    4 },
            { E.Chipper,     4 },
            { E.StinkBug,  2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        }
    },

    ------------------------------------------------
    -- Cafeteria
    new_cafeteria({ run_func = function()
        game.actor_manager:remove_actors_with_name("electric_rays")
    end }),
    ------------------------------------------------

    {
        min = 4,
        max = 5,
        enemies = {
            { E.SnailShelledBouncy, 2 },
        },
        elevator_layers = {
            ["bg_grid"] = false,
            ["fg_grid"] = false,
        },

        fixed_enemies = {
            {
                E.ElectricRays,
                1,
                position = { CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 8 },
                args = {
                    {
                        n_rays = 1,
                        activation_delay = 2,
                        angle_speed = 0.3,
                    }
                }
            },
        },
        music = "w3",
        ambience = "w3",
        pull_music_buffer = true, 

        floating_text = "🈶 {input.prompts.jetpack}"
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.Grasshopper,        2 },
            { E.StinkBug,           2 },
            { E.SnailShelledBouncy, 2 },
        },

        floating_text = nil,
    },

    {
        min = 5,
        max = 6,
        enemies = {
            { E.SnailShelledBouncy, 2 },
            { E.Chipper,            2 },
            { E.Boomshroom,         2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 2 }
        }
    },

    {
        min = 7,
        max = 7,
        enemies = {
            { E.SnailShelledBouncy, 2 },
            { E.Boomshroom,  2 },
            { E.DrillBee,  1 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 }
        }
    },

    {
        min = 7,
        max = 7,
        enemies = {
            { E.Chipper,  2 },
            { E.StinkBug, 2 },
        },

        -- run = function(self, level)
        --     for _, player in pairs(game.players) do
        --         local arc = enemies.ElectricArc:new(CANVAS_WIDTH*0.5, CANVAS_HEIGHT*0.5)
        --         arc:set_arc_target(player)
        --         arc.arc_damage = 2.5
        --         game:new_actor(arc)
        --     end
        -- end,
    },

    {
        min = 6,
        max = 7,

        enemies = {
            { E.SnailShelled, 2 },
            { E.Chipper, 2 },
            { E.DrillBee, 1 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.Spider,    20 },
            { E.MetalFly,  20 },
            { E.BulbBuddy, 5 }
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 }
        }
    },

    {
        min = 8,
        max = 8,

        enemies = {
            { E.Spider,    2 },
            { E.MetalFly,  2 },
            { E.SpikedFly, 2 },
            { E.Chipper,   2 },
            { E.StinkBug,  2 },
        },
        fixed_enemies = {
            { E.BulbBuddy, 1 }
        }
    },


    {
        min = 1,
        max = 1,

        enemies = {
            { E.Motherboard, 1, position = { 3 * 16, -40 } },
        },
        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "electric_arc" then
                    actor:start_disable_timer(1)
                end
            end
        end,

        music = "boss_w3",
    },

    ------
    -- Cafeteria
    new_cafeteria({ 
        run_func = function()
            game.actor_manager:remove_actors_with_name("electric_rays")
        end, 
        ceo_info = 3,

        achievements = {"ach_complete_w3"},
    }),

    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W4: the gardens
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    -- E.GoldenBeetle
    -- E.CloudStorm
    -- E.Rollopod
    -- E.Shooter
    -- E.Centipede
    
    -- E.CloudDropper
    -- E.MushroomAnt
    -- E.SquidMother

    {
        min = 4,
        max = 4,

        enemies = {
            { E.CloudDropper, 20 },
        },

        elevator_layers = {
            ["bg_grid"] = false,
        },

        background = backgrounds.BackgroundGreenhouse:new(),
        music = "w4",
        ambience = "w4",

        elevator = ElevatorW4,

        over_title = get_world_prefix(4),
        title = get_world_name(4),
        over_title_color = COL_DARK_PURPLE,
        title_color = {COL_PURPLE, COL_PINK, COL_DARK_PURPLE, COL_DARK_PURPLE, stacked=true},
        title_outline_color = COL_BLACK_BLUE,
    },


    {
        min = 3,
        max = 3,

        enemies = {
            { E.Bee, 3 },
            { E.Rollopod, 2 },
        },
        fixed_enemies = {
            { E.Rollopod, 2 },
        },
    },
    
    {
        min = 4,
        max = 4,

        enemies = {
            { E.Rollopod, 20 },
            { E.CloudDropper, 20 }
        },
        fixed_enemies = {
            { E.CloudStormZone, 2 },
        },
    },
    
    {
        min = 6,
        max = 6,

        enemies = {
            { E.Rollopod, 1 },
            { E.Bee, 1 },
            { E.CloudDropper, 1 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.CloudDropper, 30 },
            { E.Bee, 30 },
        },

        fixed_enemies = {
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_2(),
                interval_size = 150,
                progress_speed = 80,
                arc_params = thorns_arc_params,
                is_front = true,
            }}},
        }
    },
    
    {
        min = 7,
        max = 7,

        enemies = {
            { E.CloudStormZone, 30 },
            { E.Rollopod, 30 },
        },
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.CloudDropper, 30 },
            { E.Rollopod, 30 },
            { E.Bee, 30 },
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.Bee, 30 },
            { E.CloudStormZone, 30 },
            { E.Rollopod, 30 },
        },
    },
    
    {
        min = 5,
        max = 5,
        
        enemies = {
            { E.Bee, 30 },
            { E.CloudDropper, 30 },
        },
        fixed_enemies = {
            { E.Centipede, 1, args = { 15 }, position = { CANVAS_WIDTH / 2 - 10 / 2, 200 } },
        },
        run = function ()
            game.actor_manager:remove_actors_with_name("progressing_arc")
        end
    },

    ---------------------------------------------
    new_cafeteria({
        run_func = function ()
            game.actor_manager:remove_actors_with_name("progressing_arc")
        end
    }),
    ---------------------------------------------

    {
        min = 4,
        max = 4,

        enemies = {
            { E.Shooter, 30 },
        },

        music = "w4",
        ambience = "w4",
        pull_music_buffer = true, 
    },


    {
        min = 5,
        max = 5,

        enemies = {
            { E.Rollopod, 30 },
            { E.Shooter, 10 },
        },  
        fixed_enemies = {
            { E.Shooter, 1 },
        }
    },

    {
        min = 3,
        max = 3,

        enemies = {
            { E.Larva, 20 },
            { E.Bee, 20 },
        },  
        fixed_enemies = {
            { E.GoldenBeetle, 3 },
        }
    },

    {
        min = 5,
        max = 5,

        enemies = {
            { E.CloudDropper, 30 },
            { E.Rollopod, 30 },
            { E.GoldenBeetle, 30 },
        },
        
        fixed_enemies = {
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_3(),
                interval_size = 150,
                progress_speed = 160,
                arc_params = thorns_arc_params,
                is_front = true,
            }}},
        },
    },

    {
        min = 7,
        max = 7,

        enemies = {
            { E.GoldenBeetle, 30 },
            { E.CloudStormZone, 20 },
            { E.Shooter, 30 },
        },
    },
    
    {
        min = 4,
        max = 4,
        
        enemies = {
            { E.Rollopod, 30 },
            { E.Bee, 30 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        }
    },

    {
        min = 6,
        max = 6,

        enemies = {
            { E.GoldenBeetle, 30 },
            { E.CloudDropper, 30 },
            { E.CloudStormZone, 30 },
            { E.Rollopod, 30 },
        },
    },

    {
        min = 4,
        max = 4,

        enemies = {
            { E.GoldenBeetle, 30 },
            { E.Rollopod, 30 },
            { E.CloudDropper, 30 },
        },
        fixed_enemies = {
            { E.Centipede, 1 },
        },
    },

    {
        min = 1,
        max = 1,
        
        enemies = {
            { E.Rollossus, 30, position={CANVAS_WIDTH / 2 - 40, 160} },
        },

        run = function(self, level)
            game.actor_manager:remove_actors_with_name("progressing_arc")
        end,

        background = backgrounds.BackgroundGreenhouse:new(),

        cutscene = "rollossus_enter",
        music = "boss_w4",
    },

    -- CEO's office
    {
        floor_type = FLOOR_TYPE_CAFETERIA,
        roll_type = WAVE_ROLL_TYPE_FIXED,
        music = "off",
        ambience = "off",
        
        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end   
            end
            game.actor_manager:remove_actors_with_name("progressing_arc")
        end, 

        min = 1,
        max = 1,
        enemies = {},

        bounds = RECT_CEO_OFFICE,
        backroom = BackroomCEOOffice,

        achievements = {"ach_complete_w4"},
    },

    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    --- W0 to W4
    ----------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------

    -- { E.Larva, 3 },
    -- { E.Woodlouse, 2 },
    -- { E.Fly, 3 },
    -- { E.Slug,  4 },
    -- { E.SnailShelled, 3 },
    -- { E.SpikedFly,    3 },
    -- { E.Boomshroom, 4 },
    -- { E.Spider, 4 },
    
    {
        min = 7,
        max = 7,
        enemies = {
            { E.Larva, 3 },
            { E.Woodlouse, 2 },
        },
        ambience = "w5",
        music = "w5",

        over_title = get_world_prefix(0),
        title = get_world_name(0),
        over_title_color = COL_MID_GRAY,
        title_color = {COL_MID_GRAY, COL_LIGHT_GRAY, COL_DARKEST_GRAY, COL_DARKEST_GRAY, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        counter_display_func = function(number)
            return 5*(number-84)
        end,

        background = backgrounds.BackgroundW0:new(),
        background_transition = backgrounds.BackgroundW0:new(),
        background_speed_multiplier = 2.5,
        elevator = ElevatorRocket,

        run = function()
            game.level.do_level_slowdown_on_new_wave = false
            game.level.background_speed_lines = true
        end
    },
    
    -- [[
    {
        min = 7,
        max = 7,
        enemies = {
            { E.Woodlouse, 3 },
            { E.Larva, 3 },
            { E.Fly,       3 },
        },
    },
    
    {
        min = 8,
        max = 8,
        enemies = {
            { E.Woodlouse, 2 },
            { E.Slug,  2 },
            { E.Larva, 3 },
            { E.Fly, 3 },
        },
    },
    
    -- W1

    {
        min = 10,
        max = 10,
        enemies = {
            { E.SpikedFly, 3 },
            { E.Woodlouse, 2 },
            { E.Slug,  2 },
            { E.Larva, 3 },
            { E.Fly, 3 },
        }, 

        over_title = get_world_prefix(1),
        title = get_world_name(1),
        over_title_color = COL_LIGHT_GRAY,
        title_color = {COL_LIGHTEST_GRAY, COL_WHITE, COL_MID_GRAY, COL_MID_GRAY, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        background_transition = backgrounds.BackgroundW1:new(),
    },
    
    {
        min = 10,
        max = 10,
        enemies = {
            { E.SpikedFly,    3 },
            { E.Fly, 2 },
            { E.SnailShelled, 3 },
            { E.Spider, 5 },
            { E.Larva, 3, entrances = { "main" } },
            { E.Boomshroom, 6 },
        },
    },
    
    {
        min = 12,
        max = 12,
        enemies = {
            { E.Spider, 3 },
            { E.StinkBug, 2 },
            { E.Slug,  4 },
            { E.Fly,  2 },
            { E.Larva,  2 },
        },
    },
    
    {
        min = 15,
        max = 15,
        enemies = {
            { E.Fly,          2 },
            { E.Slug,         2 },
            { E.Woodlouse,    2 },
            { E.SpikedFly,    2 },
            { E.Boomshroom,   2 },
            { E.SnailShelled, 2 },
            { E.Spider,       2 },
            { E.StinkBug,     2 },

        },
    },
    
    -- W2

    {
        min = 8,
        max = 8,
        enemies = {
            { E.Larva, 2 },
            { E.Bee,   2 },
            { E.Stabee, 4 },
        },

        over_title = get_world_prefix(2),
        title = get_world_name(2),
        over_title_color = COL_ORANGE,
        title_color = {COL_LIGHT_YELLOW, COL_WHITE, COL_ORANGE, COL_ORANGE, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        background_transition = backgrounds.BackgroundFactory:new(),

        run = function(self, level)
            spawn_timed_spikes_w5()
        end,
    },
    
    {
        min = 8,
        max = 8,
        enemies = {
            { E.Larva, 2 },
            { E.Bee,   2 },
            { E.Beelet, 2 },
            { E.Stabee, 4 },
        },
    },
    
    {
        min = 12,
        max = 12,
        enemies = {
            { E.Larva, 2 },
            { E.Stabee, 2 },
            { E.HoneypotAnt, 4 },
            { E.DrillBee, 3 },
        },
        fixed_enemies = {
            { E.FlyingSpawner, 1 },
        },
    },
    
    {
        min = 12,
        max = 12,
        enemies = {
            { E.Larva, 3, entrances = { "main" } },
            { E.Beelet, 3, entrances = { "main" } },
            { E.Stabee, 2 },
            { E.HoneypotAnt, 4 },
            
        },
        
        fixed_enemies = {
            { E.Comball, 1 },
        },
    },
    
    -- W3

    {
        min = 8,
        max = 8,
        enemies = {
            { E.Chipper, 2 },
            { E.Grasshopper, 2 },
        },
        fixed_enemies = {            
            {
                E.ElectricRays,
                1,
                position = { CANVAS_WIDTH / 2, CANVAS_HEIGHT / 2 + 8 },
                args = { {
                    n_rays = 1,
                    activation_delay = 2,
                    init_angle = pi / 2,
                    angle_speed = 0.5,
                } }
            },
        },

        over_title = get_world_prefix(3),
        title = get_world_name(3),
        over_title_color = COL_MID_GREEN,
        title_color = {COL_LIGHT_GREEN, COL_WHITE, COL_MID_GREEN, COL_MID_GREEN, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        background_transition = backgrounds.BackgroundServers:new(),

        run = function()
            for _, a in pairs(game.actors) do
                if a.name == "timed_spikes" then
                    a:remove()
                end
            end
        end,
    },
    
    {
        min = 7,
        max = 7,
        enemies = {
            { E.Chipper, 3 },
            { E.StinkBug, 3 },
            { E.MetalFly, 1 },
        },
        
        fixed_enemies = {
            { E.BulbBuddy, 1 },
        },
    },
    
    {
        min = 10,
        max = 10,
        enemies = {
            { E.Chipper, 2 },
            { E.SnailShelledBouncy, 2 },
            { E.MetalFly,    4 },
            { E.Grasshopper, 2 },
            { E.StinkBug, 2 },
        },
    },
    
    {
        min = 13,
        max = 13,
        enemies = {
            { E.SpikedFly, 2 },
            { E.MetalFly,    4 },
            { E.Chipper, 2 },
            { E.SnailShelledBouncy, 2 },
            { E.Grasshopper, 2 },
            { E.StinkBug, 2 },
        },
    },

    -- W4
    
    {
        min = 10,
        max = 10,
        enemies = {
            { E.GoldenBeetle, 2 },
            { E.CloudStormZone, 2 },
            { E.Rollopod, 2 },
        },

        over_title = get_world_prefix(4),
        title = get_world_name(4),
        over_title_color = COL_DARK_PURPLE,
        title_color = {COL_PURPLE, COL_PINK, COL_DARK_PURPLE, COL_DARK_PURPLE, stacked=true},
        title_outline_color = COL_BLACK_BLUE,

        fixed_enemies = {
            {E.ProgressingArc, 1, args = {{
                points = get_w4_vines_points_func_3(),
                interval_size = 150,
                progress_speed = 160,
                arc_params = thorns_arc_params,
                is_front = true,
            }}},
        },

        background_transition = backgrounds.BackgroundGreenhouse:new(),

        run = function()
            game.actor_manager:remove_actors_with_name("electric_rays")
        end
    },
        
    {
        min = 10,
        max = 10,
        enemies = {
            { E.MushroomAnt, 2 },
            { E.CloudStormZone, 2 },
            { E.CloudDropper, 2 },
            { E.Rollopod, 2 },
        },
    },
    
    
    {
        min = 8,
        max = 8,
        enemies = {
            { E.Shooter, 1 },
            { E.CloudStormZone, 2 },
            { E.CloudDropper, 2 },
            { E.GoldenBeetle, 2 },
            { E.Rollopod, 2 },
        },
        fixed_enemies = {
            { E.Centipede, 1, args = { 15 } }, 
        },
    },
    
    
    {
        min = 1,
        max = 1,

        roll_type = WAVE_ROLL_TYPE_FIXED,

        enemies = {
            { E.ShopVendingMachine, 1, position = { CANVAS_WIDTH / 2, 16*15 } },
            { E.HeartJar, 1, position = { 200 - 14, 16*14 - 14 }, args = {{heart_count_per_player = 2}}},

        },

        music = "off",
        override_spawn_cocoons = true,

        run = function(self, level)
            level.freeze_fury_override = true

            for _, actor in pairs(game.actors) do
                if actor.name == "poison_cloud" then
                    actor.lifespan = 1
                end
                if actor.name == "floor_hole_spawner" or actor.name == "pendulum" then
                    actor:remove()
                end   
            end
            game.actor_manager:remove_actors_with_name("progressing_arc")
        end,
    },
    

    {
        roll_type = WAVE_ROLL_TYPE_FIXED,

        min = 1,
        max = 1,
        enemies = {
            { E.FinalBoss, 1, position = { 12.5 * 16, 10 * 16 + 8 }, args = {{init_state = "introduction"}} }
        },

        cutscene = "final_boss_enter",

        counter_display_func = function(_)
            -- Pseudo random looking floor counter
            local frame = math.floor(game.in_game_frame / 5)
            local nb = (32849 * frame) % 999
            return math.floor(clamp(nb, 100, 999))
        end,

        run = function(self, level)
            for _, actor in pairs(game.actors) do
                if actor.name == "final_boss" then
                    actor.state_machine:set_state("start")
                end
            end

            level.freeze_fury_override = false
        end
    },
}

-- This is for debugging only 
if BUILD_TYPE == "demo" then
    waves_defs[20] = new_cafeteria({ achievements = {"ach_complete_w1"} })
    waves_defs[30] = new_cafeteria({ ceo_info = 1, shopkeeper_x_override = 5000 })
end

local waves = parse_waves_table(waves_defs)

local function sanity_check_waves()
    for i, wave in ipairs(waves) do
        assert((wave.min <= wave.max), "max > min for wave " .. tostring(i))

        for j, enemy_pair in ipairs(wave.enemies) do
            local enemy_class = enemy_pair[1]
            local weight = enemy_pair[2]

            assert(enemy_class ~= nil, "enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " doesn't exist")
            assert(type(weight) == "number",
                "weight for enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " isn't a number")
            assert(weight >= 0, "weight for enemy " .. tostring(j) .. " for wave " .. tostring(i) .. " is negative")
        end
    end
end

sanity_check_waves()

for i, wave in pairs(waves) do
    table.sort(wave.enemies, function(a, b) return a[2] > b[2] end)
end

return waves