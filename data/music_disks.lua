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
    }, { loop_start = 13.708, loop_end = 60+54.857 }),
    ["w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w2_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w2_paused.source,
    }),
    ["w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w3_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w3_paused.source,
    }),
    ["w4"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w4_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w4_paused.source,
    }, { loop_start = 3.609, loop_end = 60+48.270 }),
    ["w5"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w5_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w5_paused.source,
    }),

    
    ["boss_w1"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w1_paused.source,
    }),
    ["boss_w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w2_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w2_paused.source
    }),
    ["boss_w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w3_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w3_paused.source,
    }, { loop_start = 5.741, loop_end = 60+58.333 }),
    ["boss_w4"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w4_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w4_paused.source,
    }),
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
