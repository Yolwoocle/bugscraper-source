local menu_util             = require "scripts.ui.menu.menu_util"
local Menu                  = require "scripts.ui.menu.menu"
local BossIntroMenu         = require "scripts.ui.menu.boss_intro_menu"
local RangeOptionMenuItem   = require "scripts.ui.menu.items.range_option_menu_item"
local BoolOptionMenuItem    = require "scripts.ui.menu.items.bool_option_menu_item"
local EnumOptionMenuItem    = require "scripts.ui.menu.items.enum_option_menu_item"
local StatsMenuItem         = require "scripts.ui.menu.items.menu_item_stats"
local ControlsMenuItem      = require "scripts.ui.menu.items.controls_menu_item"
local CustomDrawMenuItem    = require "scripts.ui.menu.items.menu_item_custom_draw"
local debug_draw_waves      = require "scripts.debug.draw_waves"
local images                = require "data.images"
local DebugCommandMenu      = require "scripts.ui.menu.debug_command_menu"
local NewRewardMenu         = require "data.menus.menu_new_reward"
local BackroomTutorial      = require "scripts.level.backroom.backroom_tutorial"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local empty_func            = menu_util.empty_func
local func_set_menu         = menu_util.func_set_menu
local func_url              = menu_util.func_url
local PROMPTS_NORMAL        = menu_util.PROMPTS_NORMAL
local PROMPTS_GAME_OVER     = menu_util.PROMPTS_GAME_OVER
local PROMPTS_CONTROLS      = menu_util.PROMPTS_CONTROLS

-----------------------------------------------------
------ [[[[[[[[[[[[[[[[ MENUS ]]]]]]]]]]]]]]]] ------
-----------------------------------------------------

local function generate_menus()
    local menus = {}

    menus.debug_command = DebugCommandMenu:new(game)

    menus.w1_boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, Text:text("enemy.boss_1"), "sfx_boss_intro_mrdung", {
        { image = images.boss_intro_dung_layer5, z_mult = 0.3 },
        { image = images.boss_intro_dung_layer4, z_mult = 0.5 },
        { image = images.boss_intro_dung_layer3, z_mult = 0.7 },
        { image = images.boss_intro_dung_layer2, z_mult = 0.9 },
        { image = images.boss_intro_dung_layer1, z_mult = 1.4 },
        { image = images.boss_intro_dung_layer0, z_mult = 1.5 },
    })

    menus.w2_boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, Text:text("enemy.boss_2"), "sfx_boss_intro_majesty", {
        { image = images.boss_intro_bee_layer7, z_mult = 0.2 },
        { image = images.boss_intro_bee_layer6, z_mult = 0.4 },
        { image = images.boss_intro_bee_layer5, z_mult = 0.5 },
        { image = images.boss_intro_bee_layer4, z_mult = 0.95 },
        { image = images.boss_intro_bee_layer3, z_mult = 1.0 },
        { image = images.boss_intro_bee_layer2, z_mult = 1.05 },
        { image = images.boss_intro_bee_layer1, z_mult = 1.5 },
        { image = images.boss_intro_bee_layer0, z_mult = 1.6 },
    })

    menus.w2 = menus.w2_boss_intro

    menus.w3_boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, Text:text("enemy.boss_3"), "sfx_enemy_motherboard_intro",
        {
            -- Zeros
            { image = images.boss_intro_motherboard_layer0, z_mult = 0.5 },

            -- Button bases
            { image = images.boss_intro_motherboard_layer2, z_mult = 0.8 },
            { image = images.boss_intro_motherboard_layer3, z_mult = 0.9 },
            { image = images.boss_intro_motherboard_layer4, z_mult = 1.0 },

            -- legs back 
            { image = images.boss_intro_motherboard_layer5, z_mult = 0.8 }, 
            { image = images.boss_intro_motherboard_layer6, z_mult = 0.85 },

            -- legs front
            { image = images.boss_intro_motherboard_layer7, z_mult = 1.02 },
            { image = images.boss_intro_motherboard_layer8, z_mult = 1.04 },
            { image = images.boss_intro_motherboard_layer9, z_mult = 1.06 },
            { image = images.boss_intro_motherboard_layer10, z_mult = 1.08 },

            -- bases
            { image = images.boss_intro_motherboard_layer11, z_mult = 0.9 },
            { image = images.boss_intro_motherboard_layer12, z_mult = 1.0 },
            { image = images.boss_intro_motherboard_layer15, z_mult = 1.0 },
            { image = images.boss_intro_motherboard_layer13, z_mult = 0.95 },

            -- zeros front
            { image = images.boss_intro_motherboard_layer1, z_mult = 1.3 },

            -- lightning
            { image = images.boss_intro_motherboard_layer14, z_mult = 1.5 },
        }
    )
    
    menus.w4_boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, Text:text("enemy.boss_4"), "sfx_boss_rollossus_intro", {
        { image = images.boss_intro_mole_boss_layer0, z_mult = 0.5 },
        { image = images.boss_intro_mole_boss_layer1, z_mult = 0.6 },
        { image = images.boss_intro_mole_boss_layer2, z_mult = 0.65 },
        { image = images.boss_intro_mole_boss_layer3, z_mult = 0.7 },
        { image = images.boss_intro_mole_boss_layer4, z_mult = 0.85 },
        { image = images.boss_intro_mole_boss_layer5, z_mult = 0.9 },
        { image = images.boss_intro_mole_boss_layer6, z_mult = 1.0 },
        { image = images.boss_intro_mole_boss_layer7, z_mult = 1.1 },
        { image = images.boss_intro_mole_boss_layer8, z_mult = 1.3 },
        { image = images.boss_intro_mole_boss_layer9, z_mult = 1.5 },
    })
    
    menus.w5_boss_intro = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, Text:text("enemy.boss_5"), "sfx_boss_ceo_intro", {
        { image = images.boss_intro_ceo_layer0, z_mult = 0.75 },
        { image = images.boss_intro_ceo_layer1, z_mult = 1.0 },
        { image = images.boss_intro_ceo_layer2, z_mult = 0.85 },
        { image = images.boss_intro_ceo_layer3, z_mult = 0.95 },
        { image = images.boss_intro_ceo_layer4, z_mult = 1.0 },
        { image = images.boss_intro_ceo_layer5, z_mult = 1.05 },
        { image = images.boss_intro_ceo_layer6, z_mult = 1.1 },
        { image = images.boss_intro_ceo_layer7, z_mult = 1.1 },
        { image = images.boss_intro_ceo_layer8, z_mult = 1.1 },
        { image = images.boss_intro_ceo_layer9, z_mult = 1.4 },
        { image = images.boss_intro_ceo_layer10, z_mult = 1.4 },
    })

    menus.ceo_slap = BossIntroMenu:new(game, { 38 / 255, 43 / 255, 68 / 255, 0.8 }, "", "",
        {
            { image = images.boss_intro_ceo_slap0, z_mult = 0.7 },
        }
    )

    menus.new_reward = NewRewardMenu:new(game)

    menus.options = require "data.menus.menu_options"

    menus.view_waves = Menu:new(game, "waves", {
        { CustomDrawMenuItem, debug_draw_waves },
        { "",                 empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func },
        { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func }, { "", empty_func },
    }, DEFAULT_MENU_BG_COLOR, {}, empty_func
    )

    menus.confirm_retry = Menu:new(game, "", {
        { "{menu.leave_menu}" },
        { "❌ {menu.no}", function()
            game.menu_manager:back()
        end },
        { "✓ {menu.yes}", function()
            if game.level and game.level.backroom and game.level.backroom.name == "tutorial" and Metaprogression:get("has_played_tutorial") then
                game:new_game({})
            elseif game.level and game.level.backroom and game.level.backroom.name == "credits" then
                game:new_game({})
            else
                game:new_game({
                    backroom = game.start_params.backroom,
                })
            end
        end },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.confirm_tutorial = Menu:new(game, "", {
        { "{menu.leave_menu}" },
        { "❌ {menu.no}", function()
            game.menu_manager:back()
        end },
        { "✓ {menu.yes}", function()
            game:new_game({ backroom = BackroomTutorial:new() })
        end },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)


    menus.quit = Menu:new(game, "", {
        { "{menu.quit.description}" },
        { "❌ {menu.no}",              function() game.menu_manager:back() end },
        { "✓ {menu.yes}",             quit_game },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)


    menus.pause = require "data.menus.menu_pause"

    menus.achievements = require "data.menus.menu_achievements"

    menus.feedback = Menu:new(game, "{menu.feedback.title}", {
        { "{menu.feedback.bugs} / {menu.feedback.features}" },
        { " " },
        { "{menu.pause.discord} 🔗", func_url("https://bugscraper.net/discord") },
        { "{menu.pause.github} 🔗", func_url("https://github.com/yolwoocle/bugscraper") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)
    
    menus.options = require "data.menus.menu_options"

    menus.options_language = require "data.menus.menu_options_language"
    
    menus.options_confirm_language = Menu:new(game, "", {
        { "{menu.options.confirm_language.description}" },
        { "❌ {menu.no}", function()
            game.menu_manager:back()
        end },
        { "✓ {menu.yes}", function()
            if game.buffered_language then
                Options:set("language", game.buffered_language)
            end
            quit_game(true)
        end },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)
    
    menus.options_language_basic = require "data.menus.menu_options_language_basic"

    menus.options_language_confirm_basic = require "data.menus.menu_options_language_confirm_basic"

    menus.options_input = Menu:new(game, "{menu.options.input_submenu.title}", {
        { "<<< {menu.options.input_submenu.keyboard} >>>" },
        { "⌨ {menu.options.input_submenu.keyboard_solo}", func_set_menu("controls_keyboard_solo") },
        { "🗄 {menu.options.input_submenu.keyboard_p1}", func_set_menu("controls_keyboard_split_p1") },
        { "🗄 {menu.options.input_submenu.keyboard_p2}", func_set_menu("controls_keyboard_split_p2") },
        { "" },
        { "<<< {menu.options.input_submenu.controller} >>>" },
        { "🎮 {menu.options.input_submenu.controller_p1}", func_set_menu("controls_controller_p1") },
        { "🎮 {menu.options.input_submenu.controller_p2}", func_set_menu("controls_controller_p2") },
        { "🎮 {menu.options.input_submenu.controller_p3}", func_set_menu("controls_controller_p3") },
        { "🎮 {menu.options.input_submenu.controller_p4}", func_set_menu("controls_controller_p4") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    ------------------------------------------------------------
    
    local create_keyboard_controls_menu = require "data.menus.create_keyboard_controls_menu"
    local create_controller_controls_menu = require "data.menus.create_controller_controls_menu"

    menus.controls_keyboard_solo = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_solo"),
        "keyboard_solo")
    menus.controls_keyboard_split_p1 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p1"),
        "keyboard_split_p1")
    menus.controls_keyboard_split_p2 = create_keyboard_controls_menu(Text:text("menu.options.input_submenu.keyboard_p2"),
        "keyboard_split_p2")
    menus.controls_controller_p1 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p1"),
        "controller_1", 1)
    menus.controls_controller_p2 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p2"),
        "controller_2", 2)
    menus.controls_controller_p3 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p3"),
        "controller_3", 3)
    menus.controls_controller_p4 = create_controller_controls_menu(Text:text("menu.options.input_submenu.controller_p4"),
        "controller_4", 4)

    menus.game_over = require "data.menus.menu_game_over"

    menus.win = require "data.menus.menu_win"

    menus.demo_end = require "data.menus.menu_demo_end"

    menus.stats = require "data.menus.menu_stats"

    menus.credits = require "data.menus.menu_credits"

    menus.open_source = Menu:new(game, "{menu.open_source.title}", {
        -- { Text:text("menu.credits.asset_item", "", "", ""), func_url()}
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    menus.credits_sounds = Menu:new(game, "freesound.org", {
        { Text:text("menu.credits.asset_item", "'jf Glass Breaking.wav'", "cmusounddesign", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/people/cmusounddesign/sounds/85168/") },
        { Text:text("menu.credits.asset_item", "'Glass Break'", "avrahamy", "CC0") .. " 🔗", func_url("https://freesound.org/people/avrahamy/sounds/141563/") },
        { Text:text("menu.credits.asset_item", "'Glass shard tinkle texture'", "el-bee", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/el-bee/sounds/636238/") },
        { Text:text("menu.credits.asset_item", "'Bad Beep (Incorrect)'", "RICHERlandTV", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/people/RICHERlandTV/sounds/216090/") },
        { Text:text("menu.credits.asset_item", "[Keyboard press]", "MattRuthSound", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/people/MattRuthSound/sounds/561661/") },
        { Text:text("menu.credits.asset_item", "'Paper Throw Into Air(fuller) 2'", "RossBell", "CC0") .. " 🔗", func_url("https://freesound.org/people/RossBell/sounds/389442/") },
        { Text:text("menu.credits.asset_item", "'Slime'", "Lukeo135", "CC0") .. " 🔗", func_url("https://freesound.org/people/Lukeo135/sounds/530617/") },
        { Text:text("menu.credits.asset_item", "'brushes_on_snare'", "Heigh-hoo", "CC0") .. " 🔗", func_url("https://freesound.org/people/Heigh-hoo/sounds/20297/") },
        { Text:text("menu.credits.asset_item", "'01 Elevator UP'", "soundslikewillem", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/soundslikewillem/sounds/340747/") },
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_open'", "joedeshon", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/joedeshon/sounds/368737/") },
        { Text:text("menu.credits.asset_item", "'indsustrial_elevator_door_close'", "joedeshon", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/joedeshon/sounds/368738/") },
        { Text:text("menu.credits.asset_item", "'Footsteps on gravel'", "Joozz", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/Joozz/sounds/531952/") },
        { Text:text("menu.credits.asset_item", "'THE CRASH'", "sandyrb", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/sandyrb/sounds/95078/") },
        { Text:text("menu.credits.asset_item", "'Door slam - Gun shot'", "coolguy244e", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/coolguy244e/sounds/266915/") },
        { Text:text("menu.credits.asset_item", "'bee fly'", "soundmary", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/soundmary/sounds/194932/") },
        { Text:text("menu.credits.asset_item", "'Pop, Low, A (H1)'", "InspectorJ", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/InspectorJ/sounds/411639/") },
        { Text:text("menu.credits.asset_item", "'Crack 1'", "JustInvoke", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/people/JustInvoke/sounds/446118/") },
        { Text:text("menu.credits.asset_item", "'Emergency Siren'", "onderwish", "CC0") .. " 🔗", func_url("https://freesound.org/people/onderwish/sounds/470504/") },
        { Text:text("menu.credits.asset_item", "'Wood burning in the stove'", "smand", "CC0") .. " 🔗", func_url("https://freesound.org/people/smand/sounds/521118/") },
        { Text:text("menu.credits.asset_item", "'Bike falling down an escalator'", "dundass", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/people/dundass/sounds/509831/") },
        { Text:text("menu.credits.asset_item", "'squishing and squeezing a wet sponge in a bowl'", "breadparticles", "CC0") .. " 🔗", func_url("https://freesound.org/people/breadparticles/sounds/575332/#comments") },
        { Text:text("menu.credits.asset_item", "'Insect Bug Smash & Crush'", "EminYILDIRIM", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/people/EminYILDIRIM/sounds/570767/") },
        { Text:text("menu.credits.asset_item", "'Inhaler  Puff 170427_1464'", "megashroom", "CC0") .. " 🔗", func_url("https://freesound.org/s/390174/") },
        { Text:text("menu.credits.asset_item", "'Poof/Puff'", "JustInvoke", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/446124/") },
        { Text:text("menu.credits.asset_item", "'rolling bag'", "Sunejackie", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/542402/") },
        -- { Text:text("menu.credits.asset_item", "'Ruler Bounce 3'", "belanhud", "CC0"),                         func_url("https://freesound.org/s/537904/")},
        { Text:text("menu.credits.asset_item", "'Springboard A'", "lmbubec", "CC0") .. " 🔗", func_url("https://freesound.org/s/119793/") },
        { Text:text("menu.credits.asset_item", "'Springboard B'", "lmbubec", "CC0") .. " 🔗", func_url("https://freesound.org/s/119794/") },
        { Text:text("menu.credits.asset_item", "'80s alarm'", "tim.kahn", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/83280/") },
        { Text:text("menu.credits.asset_item", "'Metal container impact firm'", "jorickhoofd", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/160077/") },
        { Text:text("menu.credits.asset_item", "'Roller blind circuit breaker'", "newlocknew", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/583451/") },
        { Text:text("menu.credits.asset_item", "'Digging, Ice, Hammer, A'", "InspectorJ", "CC BY 4.0") .. " 🔗", func_url("https://freesound.org/s/420878/ ") },
        { Text:text("menu.credits.asset_item", "'Whoosh For Whip Zoom'", "BennettFilmTeacher", "CC0") .. " 🔗", func_url("https://freesound.org/s/420878/ ") },
        { Text:text("menu.credits.asset_item", "'Balloon_Inflate_Quick_Multiple'", "Terhen", "CC BY 3.0") .. " 🔗", func_url("https://freesound.org/s/420878/ ") },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)

    local items = {
        { StatsMenuItem, Text:text("menu.game_over.kills"), function(self)
            return game.stats
                .kills
        end },
        { StatsMenuItem, Text:text("menu.game_over.time"), function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, Text:text("menu.game_over.floor"), function(self)
            return concat(game.stats.floor, "/",
                game.level.max_floor)
        end },
        { "" },
        { "❤ " .. Text:text("menu.win.wishlist") .. " 🔗", func_url("steam://advertise/2957130/") },
        { "▶ " .. Text:text("menu.win.continue"), function()
            --scotch
            game.has_seen_controller_warning = true
            game:new_game()
        end },
        { "" },

    }

    if BUILD_TYPE ~= "demo" then
        table.remove(items, 5) -- Remove whishlist if not demo
    end

    ------------------------------------------------------------

    menus.joystick_removed = Menu:new(game, "{menu.joystick_removed.title}", {
        { "{menu.joystick_removed.description}" },
        { "", nil,
            function(self)
                local keyset = {}
                for joystick, _ in pairs(game.menu_manager.joystick_wait_set) do
                    local player_n = Input:get_joystick_user_n(joystick)
                    table.insert(keyset, { player_n, joystick:getName() })
                end
                table.sort(keyset, function(a, b) return a[1] < b[1] end)

                local s = ""
                for _, value in pairs(keyset) do
                    s = s .. "🎮 " .. Text:text("menu.joystick_removed.item", value[1], value[2]) .. "\n"
                end

                self:set_label_text(s)
                --..concat("\n", game.menu_manager.joystick_wait_cooldown, " (", game.menu_manager.joystick_wait_mode, ")")
            end,
        },
        { "" },
        { "" },
        { "" },
        { "" },
        { "⚠ " .. Text:text("menu.joystick_removed.continue"),
            function(self)
                if game.menu_manager.joystick_wait_cooldown > 0 then
                    return
                end
                game.menu_manager:disable_joystick_wait_mode()
            end,
        },
        { "" },
    }, DEFAULT_MENU_BG_COLOR, PROMPTS_GAME_OVER, nil, { is_backable = false })

    return menus
end

return generate_menus
