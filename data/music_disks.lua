local MusicDisk    = require "scripts.audio.music_disk"
local MusicDiskWeb = require "scripts.audio.music_disk_web"
local sounds       = require "data.sounds"

local disk_class   = ternary(OPERATING_SYSTEM == "Web", MusicDiskWeb, MusicDisk)

return {
    ["ground_floor_empty"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_ground_floor_empty_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_ground_floor_empty_paused.source
    }, { volume = 0.75 }),
    ["ground_floor_players"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_ground_floor_players_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_ground_floor_players_paused.source,
    }, { volume = 0.75 }),

    
    ["w1"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w1_paused.source,
    }, { loop_start = 17.994, loop_end = 60+59.142 }), -- BPM: 140, 8 + 2.5 mesures intro
    ["w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w2_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w2_paused.source,
    }, { loop_start = 6.452, loop_end = 60*4+24.512 }), -- BPM: 93, 2.5 mesures intro
    ["w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w3_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w3_paused.source,
    }, { loop_start = 5.714, loop_end = 60*2+4.571 }), -- BPM: 105, 2.5 mesures intro
    ["w4"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w4_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w4_paused.source,
    }, { loop_start = 8.120, loop_end = 60+56.391 }), -- BPM: 133, 2 + 2.5 mesures intro
    ["w5"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w5_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w5_paused.source,
    }, { loop_start = 5.172, loop_end = 60+50.683 }), -- BPM: 116, 2.5 mesures intro

    
    ["boss_w1"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w1_paused.source,
    }, { loop_start = 10.212, loop_end = 60*2+37.907 }), -- BPM: 152.75, 4 + 2.5 mesures intro
    ["boss_w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w2_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w2_paused.source
    }, { loop_start = 12.903, loop_end = 2*60 + 6.452 }), -- BPM: 93, 5 mesures intro
    ["boss_w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w3_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w3_paused.source,
    }, { loop_start = 9.619, loop_end = 60*2+2.215 }), -- BPM: 162, intro: idk
    ["boss_w4"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w4_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w4_paused.source,
    }, { loop_start = 0, loop_end = 0 }),
    ["boss_w5"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w5_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w5_paused.source,
    }),


    ["game_over"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_game_over.source,
        [MUSIC_MODE_PAUSE] = sounds.music_game_over.source,
    }),
    ["cafeteria"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cafeteria_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cafeteria_paused.source,
    }),
    ["cafeteria_empty"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cafeteria_empty_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cafeteria_paused.source,
    }),
    ["cutscene_tutorial_end"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cutscene_tutorial_end.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cutscene_tutorial_end.source,
    }),
    ["cutscene_enter_ceo_office"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cutscene_enter_ceo_office.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cutscene_enter_ceo_office.source,
    }),
    ["credits"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_credits.source,
        [MUSIC_MODE_PAUSE] = sounds.music_credits.source,
    }),
}
