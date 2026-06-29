local Cutscene      = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local images        = require "data.images"

return Cutscene:new("credits", {
    -- [[
    CutsceneScene:new({
        description = "Linger on logo",

        duration = 5.0,
        enter = function(cutscene, data)
            game.level.backroom.draw_logo = true
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 0.5,
        enter = function(cutscene, data)
            game.level.backroom.draw_logo = false
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("{menu.credits.ninesliced_presents}", "", "", 0.5, 5.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 7.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("{menu.credits.leo_bernard}", "Yolwoocle", "{menu.credits.game_by}", 0.5, 5.0, 0.5, {
                image = images.credits_mio_beach,
                image_x = 62,
                image_y = 92,
            })
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 7.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("OLX", "Alexandre Mercier", "{menu.credits.music} + {menu.credits.sound_design}", 0.5, 5.0, 0.5, {
                image = images.credits_cap,
                image_x = CANVAS_WIDTH - 62 - 64,
                image_y = 92,
            })
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 7.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("Martin Domergue", "Verbaudet", "{menu.credits.sound_design}", 0.5, 5.0, 0.5, {
                image = images.credits_nob,
                image_x = 62,
                image_y = 92,
            })
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Noam Goldfarb (Sslime7)",
                "Colin Roullé (OHX)",
                "caridescent",
            }, "", "{menu.credits.additional_art}", 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "< {language.pl} >",
                "Jakub Piłasiewicz",
                "",
                "< {language.pt_BR} >" ,
                "Nicole Sanches (rhysuki)",
                "kiwisky",
                "Marina Pais (parinamais)",
            }, "", "{menu.credits.localization}", 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "< {language.es} >",
                "Alejandro Alzate Sánchez", 
                "",
                "< {language.ja} >" ,
                "Sora",
                "Clément Macheret",
                "",
                "Polyglot Project",
            }, "", "{menu.credits.localization}", 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "LinkyLorelei",
                "{menu.credits.leo_bernard} (Yolwoocle)"
            }, "", "{menu.credits.trailer}", 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            -- game.game_ui:start_title({
            --     Text:text("menu.credits.x_by_y", "'Graphs'", "Sslime7"),
            --     Text:text("menu.credits.x_by_y", "'Hot dogs'", "Alexis Belmonte"),
            --     Text:text("menu.credits.x_by_y", "'Mio rotate'", "Corentin Vaillant"),
            --     Text:text("menu.credits.x_by_y", "'Mio explode'", "Corentin Vaillant"),
            --     Text:text("menu.credits.x_by_y", "'Bugs With Guns'", "Yolwoocle"),
            --     Text:text("menu.credits.x_by_y", "'Löve, Öbey'", "ellraiser"),
            --     Text:text("menu.credits.x_by_y", "'Need your duck taped?'", "Joseph (Jedi)"),  
            --     Text:text("menu.credits.x_by_y", "'Starbugs Green Tea'", "Goyome"),
            --     Text:text("menu.credits.x_by_y", "'Binarion'", "Hector SK  (Nextop Games)"),    
            --     Text:text("menu.credits.x_by_y", "'Injured? Good'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Snail Ball Run'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Bluescreen'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Bluescreen (2)'", "418cat"),
            --     Text:text("menu.credits.x_by_y", "'No queen?'", "Behck"),
            --     Text:text("menu.credits.x_by_y", "'Splat'", "Sarcose"),
            --     Text:text("menu.credits.x_by_y", "'End toastal abuse'", "Clem"),
            --     Text:text("menu.credits.x_by_y", "'A-salt rifle'", "Clem"),
            --     Text:text("menu.credits.x_by_y", "'Beatleblock'", "Daphne Sophinos (DPS2004)"),  
            --     Text:text("menu.credits.x_by_y", "'Bugscrapers aren't enough'", "pkhead"),
            --     Text:text("menu.credits.x_by_y", "'Optical Studio'", "pkhead"),
            --     Text:text("menu.credits.x_by_y", "'Soon (TM)'", "pixelbath"),
            --     Text:text("menu.credits.x_by_y", "'You are a bug'", "kiwisky"),
            -- }, "", "{menu.credits.playtesting}", 0.5, 5.0, 0.5)
            game.game_ui:start_title_tv({
                {"slide_001"},
                {"slide_002"},
                {"slide_003"},
                {"slide_004"},
                {"slide_005"},
                {"slide_006"},
                {"slide_007"},
                {"slide_008"},
            }, 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title_tv({
                {"slide_009"},
                {"slide_010"},
                {"slide_011"},
                {"slide_012"},
                {"slide_013"},
                {"slide_014"},
                {"slide_015"},
                {"slide_016"},
            }, 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title_tv({
                {"slide_017"},
                {"slide_018"},
                {"slide_019"},
                {"slide_020"},
                {"slide_021"},
                {"slide_022"},
                {"bluescreen_1"},
                {"bluescreen_2"},
            }, 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 8.0,  
        
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Alexis Belmonte",
                "Azuras03 (NicolasYT)",
                "AuramoBalzoni",
                "Axel 'Vlad' Born",
                "Bettina Delaveaud",
                "Binary Sunrise",
                "Corentin Vaillant",
                "Fabien Delpiano",
                "Fantine Delpiano-Manfrini",
                "Feishiko",
                "Gaspard Delpiano-Manfrini",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Guillaume Tran",
                "hades140701",
                "Herweins",
                "Indie Game Lyon",
                "Jan Willem Nijman",
                "Kaïs",
                "Lars Loe (MadByte)",
                "Léo Lanteri Thauvin",
                "LinkyLorelei",
                "Louie Chapman",
                "LÖVE contributors",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "LÖVE Discord members",
                "Lucas Froehlinger 😎",
                "Maman & Papa ❤",      
                "MatthJ4",
                "Médiathèque José Cabanis",
                "Noba",
                "NerdOfGamers + partner",
                "Nolan Carlisi (arkanyota)",
                "oat_addict",
                "Play Sorbonne Université",
                "Quentin Picault",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Raphytator",
                "Solluco",
                "Sylvain Fraresso",
                "Tahina Dombrowski",
                "Théodore Billotte",
                "Thomas Saurel",
                "Tom Le Ber",
                "Toulouse Game Dev",
                "",
                "{menu.credits.more}",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 8.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "{menu.credits.thank_you_for_playing}",
            }, "", "", 0.5, 7.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "Wait for a bit",
        
        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({""}, "", "", 0.5, 10.0, 0.5, {
                image = images.credits_metal_bee,
                image_x = CANVAS_CENTER[1] - 112/2,
                image_y = CANVAS_CENTER[2] - 80/2,
            })
        end,

        exit = function(cutscene, data)
        end
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 1.0,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_endingscreen")
            game.game_ui:start_iris_transition(CANVAS_CENTER[1], CANVAS_CENTER[2], 0.5, CANVAS_WIDTH, 90)
            game.music_player:fade_out("off", 3.0)
        end,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 1.0,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 1.0,
        enter = function(cutscene, data)
            Audio:play("sfx_cutscene_endingscreen")
            game.game_ui:start_iris_transition(CANVAS_CENTER[1], CANVAS_CENTER[2], 0.5, 90, 0)
        end,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 1.0,
    }),
    CutsceneScene:new({
        description = "",
        
        duration = 0.0,
        enter = function(cutscene, data)
            game.music_player:set_disk("off")
        	game.menu_manager:set_menu("win")
        end,
    }),
})
