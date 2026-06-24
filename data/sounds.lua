require "scripts.util"
local Sound = require "scripts.audio.sound"

local function new_source(path, type, args)
	local source = love.audio.newSource("sounds/" .. path, type)
	if not args then return source end

	if args.looping then
		source:setLooping(true)
	end
	return source
end

local sounds = {}

local sfxnames = {
	["empty"] =                             { "empty.ogg", "static" },

	-- MUSIC
	["music_ground_floor_players_paused"] = { "music/music_ground_floor_players_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_ingame"] =   { "music/music_ground_floor_empty_ingame.ogg", "stream", { looping = true } },
	["music_ground_floor_empty_paused"] =   { "music/music_ground_floor_empty_paused.ogg", "stream", { looping = true } },
	["music_ground_floor_players_ingame"] = { "music/music_ground_floor_players_ingame.ogg", "stream", { looping = true } },
	["music_w1_ingame"] =                   { "music/music_w1_ingame.ogg", "stream", { looping = true } },
	["music_w1_paused"] =                   { "music/music_w1_paused.ogg", "stream", { looping = true } },
	["music_w2_ingame"] =                   { "music/music_w2_ingame.ogg", "stream", { looping = true } },
	["music_w2_paused"] =                   { "music/music_w2_paused.ogg", "stream", { looping = true } },
	["music_w3_ingame"] =                   { "music/music_w3_ingame.ogg", "stream", { looping = true } },
	["music_w3_paused"] =                   { "music/music_w3_paused.ogg", "stream", { looping = true } },
	["music_w4_ingame"] =                   { "music/music_w4_ingame.ogg", "stream", { looping = true } },
	["music_w4_paused"] =                   { "music/music_w4_paused.ogg", "stream", { looping = true } },
	["music_w5_ingame"] =                   { "music/music_w5_ingame.ogg", "stream", { looping = true } },
	["music_w5_paused"] =                   { "music/music_w5_paused.ogg", "stream", { looping = true } },
	["music_game_over"] =                   { "music/music_game_over.ogg", "stream", { looping = true } },
	["music_cafeteria_ingame"] =            { "music/music_cafeteria_ingame.ogg", "stream", { looping = true } },
	["music_cafeteria_paused"] =            { "music/music_cafeteria_paused.ogg", "stream", { looping = true } },
	["music_cafeteria_empty_ingame"] =      { "music/music_cafeteria_empty_ingame.ogg", "stream", { looping = true } },
	["music_credits"] =                     { "music/music_credits.ogg", "stream", { looping = false } },
	["music_cutscene_tutorial_end"] =       { "music/music_cutscene_tutorial_end.mp3", "stream"},
	["music_cutscene_enter_ceo_office"] =   { "music/music_cutscene_enter_ceo_office.ogg", "stream"},

	["music_boss_w1_ingame"] =              { "music/music_boss_w1_ingame.ogg", "stream", { looping = true } },
	["music_boss_w1_paused"] =              { "music/music_boss_w1_paused.ogg", "stream", { looping = true } },
	["music_boss_w2_ingame"] =              { "music/music_boss_w2_ingame.ogg", "stream", { looping = true } },
	["music_boss_w2_paused"] =              { "music/music_boss_w2_paused.ogg", "stream", { looping = true } },
	["music_boss_w3_ingame"] =              { "music/music_boss_w3_ingame.ogg", "stream", { looping = true } },
	["music_boss_w3_paused"] =              { "music/music_boss_w3_paused.ogg", "stream", { looping = true } },
	["music_boss_w4_ingame"] =              { "music/music_boss_w4_ingame.ogg", "stream", { looping = true } },
	["music_boss_w4_paused"] =              { "music/music_boss_w4_paused.ogg", "stream", { looping = true } },
	["music_boss_w5_ingame"] =              { "music/music_boss_w5_ingame.ogg", "stream", { looping = true } },
	["music_boss_w5_paused"] =              { "music/music_boss_w5_paused.ogg", "stream", { looping = true } },

	-- GUNS
	["sfx_weapon_peagun_shoot_{01-08}"] =           {"sfx/weapons/peagun/sfx_weapon_peagun_shoot_{}.ogg", "static"},
	["sfx_weapon_peagun_pickedup"] =                {"sfx/weapons/peagun/sfx_weapon_peagun_pickedup.ogg", "static"},
	["sfx_weapon_pollenburst_shoot_{01-06}"] =      {"sfx/weapons/pollenburst/sfx_weapon_pollenburst_shoot_{}.ogg", "static"},
	["sfx_weapon_pollenburst_pickedup"] =           {"sfx/weapons/pollenburst/sfx_weapon_pollenburst_pickedup.ogg", "static"},
	["sfx_weapon_seedminigun_shoot_{01-10}"] =      {"sfx/weapons/seedminigun/sfx_weapon_seedminigun_shoot_{}.ogg", "static"},
	["sfx_weapon_seedminigun_pickedup"] =           {"sfx/weapons/seedminigun/sfx_weapon_seedminigun_pickedup.ogg", "static"},
	["sfx_weapon_mushroomcannon_shoot_{01-04}"] =   {"sfx/weapons/mushroomcannon/sfx_weapon_mushroomcannon_shoot_{}.ogg", "static"},
	["sfx_weapon_mushroomcannon_pickedup"] =        {"sfx/weapons/mushroomcannon/sfx_weapon_mushroomcannon_pickedup.ogg", "static"},
	["sfx_weapon_bigberry_shoot_{01-04}"] =         {"sfx/weapons/bigberry/sfx_weapon_bigberry_shoot_{}.ogg", "static"},
	["sfx_weapon_bigberry_pickedup"] =              {"sfx/weapons/bigberry/sfx_weapon_bigberry_pickedup.ogg", "static"},
	["sfx_weapon_raspberryshotgun_shoot_{01-10}"] = {"sfx/weapons/raspberryshotgun/sfx_weapon_raspberryshotgun_shoot_{}.ogg", "static"},
	["sfx_weapon_raspberryshotgun_pickedup"] =      {"sfx/weapons/raspberryshotgun/sfx_weapon_raspberryshotgun_pickedup.ogg", "static"},
	["sfx_weapon_triplepepper_shoot_{01-08}"] =     {"sfx/weapons/triplepepper/sfx_weapon_triplepepper_shoot_{}.ogg", "static"},
	["sfx_weapon_triplepepper_pickedup"] =          {"sfx/weapons/triplepepper/sfx_weapon_triplepepper_pickedup.ogg", "static"},

	["sfx_weapon_dry_shoot_{01-06}"] =              {"sfx/weapons/dry/sfx_weapon_dry_shoot_{}.ogg", "static"},

	-- PLAYER
	["sfx_player_footstep_metal_{01-10}"] =  {"sfx/actor/player/walk/metal/sfx_player_footstep_metal_{}.ogg", "static"},
	["sfx_player_footstep_carpet_{01-10}"] = {"sfx/actor/player/walk/carpet/sfx_player_footstep_carpet_{}.ogg", "static"},
	["sfx_player_footstep_sand_{01-10}"] =   {"sfx/actor/player/walk/sand/sfx_player_footstep_sand_{}.ogg", "static"},
	["sfx_player_footstep_stone_{01-10}"] =  {"sfx/actor/player/walk/stone/sfx_player_footstep_stone_{}.ogg", "static"},
	["sfx_player_footstep_wood_{01-06}"] =   {"sfx/actor/player/walk/wood/sfx_player_footstep_wood_{}.ogg", "static"},
	["sfx_player_footstep_glass_{01-06}"] =  {"sfx/actor/player/walk/glass/sfx_player_footstep_glass_{}.ogg", "static"},

	["sfx_player_footstep_land_metal_{01-04}"] = {"sfx/actor/player/land/metal/sfx_player_footstep_land_metal_{}.ogg", "static"},
	["sfx_player_footstep_land_carpet_{01-04}"] = {"sfx/actor/player/land/carpet/sfx_player_footstep_land_carpet_{}.ogg", "static"},
	["sfx_player_footstep_land_sand_{01-04}"] = {"sfx/actor/player/land/sand/sfx_player_footstep_land_sand_{}.ogg", "static"},
	["sfx_player_footstep_land_stone_{01-04}"] = {"sfx/actor/player/land/stone/sfx_player_footstep_land_stone_{}.ogg", "static"},
	["sfx_player_footstep_land_wood_{01-04}"] = {"sfx/actor/player/land/wood/sfx_player_footstep_land_wood_{}.ogg", "static"},
	["sfx_player_footstep_land_glass_{01-04}"] = {"sfx/actor/player/land/glass/sfx_player_footstep_land_glass_{}.ogg", "static"},

	["sfx_player_wall_slide_metal_{01-02}"] = {"sfx/actor/player/slide/metal/sfx_player_wall_slide_metal_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stone_{01-02}"] = {"sfx/actor/player/slide/stone/sfx_player_wall_slide_stone_{}.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_glass_{01-02}"] = {"sfx/actor/player/slide/glass/sfx_player_wall_slide_glass_{}.ogg", "static", { looping = true }},

	["sfx_player_wall_slide_stamina_low"] =      {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_low.ogg", "static", { looping = true }},
	["sfx_player_wall_slide_stamina_very_low"] = {"sfx/actor/player/slide/sfx_player_wall_slide_stamina_very_low.ogg", "static", { looping = true }},

	["sfx_player_damage_normal"] =         {"sfx/actor/player/sfx_player_damage_normal.ogg", "static"},
	["sfx_player_damage_poison"] =         {"sfx/actor/player/sfx_player_damage_poison.ogg", "static"},
	["sfx_player_death"] =                 {"sfx/actor/player/sfx_player_death.ogg", "static"},
	["sfx_player_death_intro"] =           {"sfx/actor/player/sfx_player_death_intro.ogg", "static"},
	["sfx_player_death_punch"] =           {"sfx/actor/player/sfx_player_death_punch.ogg", "static"},
	["sfx_player_leave_game"] =            {"sfx/actor/player/sfx_player_leave_game.ogg", "static"},
	["sfx_player_leave_game_easter_egg"] = {"sfx/actor/player/sfx_player_leave_game_easter_egg.ogg", "static"},
	
	["sfx_player_jumplong"] = {"sfx/actor/player/jump/sfx_player_jumplong.ogg", "static"},

	-- ACTORS
	-- Jumping props
	["sfx_actor_jumping_prop_paper_stack_{01-06}"] = {"sfx/actor/jumping_prop/paper_stack/sfx_actor_jumping_prop_paper_stack_{}.ogg", "static"},
	["sfx_actor_jumping_prop_mug_{01-06}"] =         {"sfx/actor/jumping_prop/mug/sfx_actor_jumping_prop_mug_{}.ogg", "static"},
	-- ["sfx_actor_jumping_prop_plant_small_{01-03}"] = {"sfx/actor/jumping_prop/plant_small/sfx_actor_jumping_prop_plant_small_{}.ogg", "static"},
	["sfx_actor_jumping_prop_screen_{01-06}"] =      {"sfx/actor/jumping_prop/screen/sfx_actor_jumping_prop_screen_{}.ogg", "static"},
	["sfx_actor_jumping_prop_boba_{01-06}"] =        {"sfx/actor/jumping_prop/boba/sfx_actor_jumping_prop_boba_{}.ogg", "static"},
	["sfx_actor_jumping_prop_plant_big_{01-02}"] =   {"sfx/actor/jumping_prop/plant/sfx_actor_jumping_prop_plant_big_{}.ogg", "static"},
	["sfx_actor_jumping_prop_sign_{01-04}"] =        {"sfx/actor/jumping_prop/sign/sfx_actor_jumping_prop_sign_{}.ogg", "static"},

	-- Cocoon
	["sfx_actor_cocoon_damage_{01-07}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_damage_{}.ogg", "static"},
	["sfx_actor_cocoon_break"] = {"sfx/actor/cocoon/sfx_actor_cocoon_break.ogg", "static"},
	["sfx_actor_cocoon_revive_{01-02}"] = {"sfx/actor/cocoon/sfx_actor_cocoon_revive_{}.ogg", "static"},
	["sfx_actor_cocoon_break_{01-02}"] --[[ old sound ]] = {"sfx/actor/cocoon/sfx_actor_cocoon_break_{}.ogg", "static"},

	-- Upgrade display 
	["sfx_actor_upgrade_display_break_{01-04}"] = {"sfx/upgrades/display_break/sfx_actor_upgrade_display_break_{}.ogg", "static"},

	-- Health pickup
	["sfx_loot_health_collect"] = {"sfx/sfx_loot_health_collect.ogg", "static"},

	-- Button small
	["sfx_actor_button_small_glass_damage_{01-06}"] = {"sfx/actor/button/glass/sfx_actor_button_small_glass_damage_{}.ogg", "static"},
	["sfx_actor_button_small_glass_break"] = {"sfx/actor/button/glass/sfx_actor_button_small_glass_break.ogg", "static"},
	["sfx_actor_button_small_pressed"] = {"sfx/actor/button/sfx_actor_button_small_pressed.ogg", "static"},

	-- Dummy
	["sfx_actor_dummy_damage_{01-06}"] = {"sfx/tutorial/dummy/sfx_actor_dummy_damage_{}.ogg", "static"},
	["sfx_actor_dummy_stomp_{01-03}"] = {"sfx/tutorial/dummy/sfx_actor_dummy_stomp_{}.ogg", "static"},
	["sfx_actor_dummy_death_{01-03}"] = {"sfx/tutorial/dummy/sfx_actor_dummy_death_{}.ogg", "static"},

	-- ENEMIES 
	["sfx_enemy_damage"] = {"sfx/enemy/sfx_enemy_damage.ogg", "static"},

	["sfx_enemy_kill_general_crush_{01-10}"] = {"sfx/enemy/death_temp/crush/sfx_enemy_kill_general_crush_{}.ogg", "static"},
	["sfx_enemy_kill_general_glitch_{01-10}"] = {"sfx/enemy/death_temp/glitch/sfx_enemy_kill_general_glitch_{}.ogg", "static"},
	["sfx_enemy_kill_general_gore_{01-10}"] = {"sfx/enemy/death_temp/gore/sfx_enemy_kill_general_gore_{}.ogg", "static"},

	-- Snail
	["sfx_enemy_snail_bounce_{01-06}"] = {"sfx/enemy/snail/sfx_enemy_snail_bounce_{}.ogg", "static"},

	-- Boomshroom
	["sfx_enemy_boomshroom_explosion_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_explosion_{}.ogg", "static"},
	["sfx_enemy_boomshroom_flashing"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_flashing.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_{01-07}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_{}.ogg", "static"},
	["sfx_enemy_boomshroom_inflate_instant_{01-06}"] = {"sfx/enemy/boomshroom/sfx_enemy_boomshroom_inflate_instant_{}.ogg", "static"},

	-- Stink bug
	["sfx_enemy_poison_cloud_spawn_{01-04}"] = {"sfx/enemy/poison/sfx_enemy_poison_cloud_spawn_{}.ogg", "static"},

	-- Fly 
	["sfx_enemy_fly_ambient_{01-02}"] = {"sfx/enemy/fly/sfx_enemy_fly_ambient_{}.ogg", "stream", { looping = true }},

	-- Boss W1    
	["sfx_boss_intro_mrdung"] = {"sfx/enemy/mrdung/sfx_boss_intro_mrdung.ogg", "static"},
	["sfx_boss_mrdung_boss_activate_{01-08}"] = {"sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_{}.ogg", "static"},
	["sfx_boss_mrdung_death_{01-03}"] = {"sfx/enemy/mrdung/death/sfx_boss_mrdung_death_{}.ogg", "static"},
	["sfx_boss_mrdung_dying"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_dying.ogg", "static"},
	["sfx_boss_mrdung_land_in_dung"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_land_in_dung.ogg", "static"},
	["sfx_boss_mrdung_roll"] = {"sfx/enemy/mrdung/sfx_boss_mrdung_roll.ogg", "static", { looping = true }},
	["sfx_boss_mrdung_jump_{01-06}"] = {"sfx/enemy/mrdung/jump/sfx_boss_mrdung_jump_{}.ogg", "static"},
	["sfx_boss_mrdung_ball_triggered_{01-08}"] = {"sfx/enemy/mrdung/ball_triggered/sfx_boss_mrdung_ball_triggered_{}.ogg", "static"},
	["sfx_boss_mrdung_ball_hit_{01-06}"] = {"sfx/enemy/mrdung/ball/sfx_boss_mrdung_ball_hit_{}.ogg", "static"},
	["sfx_boss_mrdung_bump_{01-02}"] = {"sfx/enemy/mrdung/bump/sfx_boss_mrdung_bump_{}.ogg", "static"},
	["sfx_boss_mrdung_jump_telegraph_{01-04}"] = {"sfx/enemy/mrdung/jump_telegraph/sfx_boss_mrdung_jump_telegraph_{}.ogg", "static"},
	["sfx_boss_mrdung_jump_moment_{01-06}"] = {"sfx/enemy/mrdung/jump_moment/sfx_boss_mrdung_jump_moment_{}.ogg", "static"},
	
	-- CUTSCENE
	["sfx_cutscene_rocket"] =             {"sfx/cutscene/sfx_cutscene_rocket.ogg", "stream"},

	-- W1 CEO escape cutscene
	["sfx_w1_cutscene_surprise"] =        {"sfx/cutscene/sfx_w1_cutscene_surprise.ogg", "static"},
	["sfx_w1_cutscene_glass_break"] =     {"sfx/cutscene/sfx_w1_cutscene_glass_break.ogg", "static"},
	["sfx_w1_cutscene_jetpack"] =         {"sfx/cutscene/sfx_w1_cutscene_jetpack.ogg", "static"},
	
	-- W2 CEO escape cutscene
	["sfx_w2_cutscene_rumble"] =          {"sfx/cutscene/sfx_w2_cutscene_rumble.ogg", "static"},
	["sfx_w2_cutscene_clap"] =            {"sfx/cutscene/sfx_w2_cutscene_clap.ogg", "static"},
	["sfx_w2_cutscene_bees_beeingbees"] = {"sfx/cutscene/sfx_w2_cutscene_bees_beeingbees.ogg", "static"},
	["sfx_w2_cutscene_roof_breaking"] =   {"sfx/cutscene/sfx_w2_cutscene_roof_breaking.ogg", "static"},
	
	-- W3 CEO escape cutscene
	["sfx_cutscene_ceo_leaving_binary"] =   {"sfx/cutscene/sfx_cutscene_ceo_leaving_binary.ogg", "static"},
	
	-- W4 CEO office cutscene
	["sfx_cutscene_door_impact_{01-04}"] =   {"sfx/cutscene/door/sfx_cutscene_door_impact_{}.ogg", "static"},
	["sfx_cutscene_door_cracked"] =          {"sfx/cutscene/door/sfx_cutscene_door_cracked.ogg", "static"},
	["sfx_cutscene_door_break"] =            {"sfx/cutscene/door/sfx_cutscene_door_break.ogg", "static"},
	["sfx_cutscene_button_coming_out"] =     {"sfx/cutscene/sfx_cutscene_button_coming_out.ogg", "static"},
	["sfx_cutscene_ceo_jumps_button"] =      {"sfx/cutscene/sfx_cutscene_ceo_jumps_button.ogg", "static"},
	["sfx_cutscene_ceo_glass_stress"] =      {"sfx/cutscene/sfx_cutscene_ceo_glass_stress.ogg", "static"},
	["sfx_cutscene_rumbling"] =              {"sfx/cutscene/sfx_cutscene_rumbling.ogg", "static"},
	["sfx_cutscene_punch_{01-04}"] =         {"sfx/cutscene/punch/sfx_cutscene_punch_{}.ogg", "static"},
	["sfx_cutscene_numbers"] =               {"sfx/cutscene/sfx_cutscene_numbers.ogg", "static"},
	["sfx_cutscene_mio_impact_on_ground"] =  {"sfx/cutscene/sfx_cutscene_mio_impact_on_ground.ogg", "static"},

	-- CEO boss fight death cutscene
	["sfx_cutscene_rocket_flying"] =            {"sfx/cutscene/sfx_cutscene_rocket_flying.ogg", "static"},
	["sfx_cutscene_rocket_stops"] =             {"sfx/cutscene/sfx_cutscene_rocket_stops.ogg", "static"},
	["sfx_cutscene_rocket_explode"] =           {"sfx/cutscene/sfx_cutscene_rocket_explode.ogg", "static"},
	["sfx_cutscene_fall"] =                     {"sfx/cutscene/sfx_cutscene_fall.ogg", "static"},

	-- Falling to rocket
	["sfx_cutscene_mio_falling_to_rocket"] =    {"sfx/cutscene/sfx_cutscene_mio_falling_to_rocket.ogg", "static"},
	["sfx_cutscene_mio_crashes_rocket"] =       {"sfx/cutscene/sfx_cutscene_mio_crashes_rocket.ogg", "static"},
	["sfx_cutscene_rocket_rumble_lp"] =         {"sfx/cutscene/sfx_cutscene_rocket_rumble_lp.ogg", "static", {looping=true}},
	["sfx_cutscene_voice_countdown"] =          {"sfx/cutscene/sfx_cutscene_voice_countdown.ogg", "static"},
	["sfx_cutscene_rocket_takeoff"] =           {"sfx/cutscene/sfx_cutscene_rocket_takeoff.ogg", "static"},

	-- Final "W5 escape" CEO cutscene
	["sfx_cutscene_pickup_letter"] =            {"sfx/cutscene/sfx_cutscene_pickup_letter.ogg", "static"},
	["sfx_cutscene_ceo_afraid_anger_{01-04}"] = {"sfx/cutscene/ceo_afraid_anger/sfx_cutscene_ceo_afraid_anger_{}.ogg", "static"},
	["sfx_cutscene_ceo_boingboing"] =           {"sfx/cutscene/sfx_cutscene_ceo_boingboing.ogg", "static"},
	["sfx_cutscene_mio_slaps_ceo"] =            {"sfx/cutscene/sfx_cutscene_mio_slaps_ceo.ogg", "static"},
	["sfx_cutscene_door_slam"] =                {"sfx/cutscene/door/sfx_cutscene_door_slam.ogg", "static"},
	["sfx_cutscene_door_open"] =                {"sfx/cutscene/door/sfx_cutscene_door_open.ogg", "static"},

	["sfx_cutscene_boss_claps"] =               {"sfx/cutscene/sfx_cutscene_boss_claps.ogg", "static"},
	["sfx_cutscene_endingscreen_part1"] =       {"sfx/cutscene/opening_ending_screen/sfx_cutscene_endingscreen_part1.ogg", "static"},
	["sfx_cutscene_endingscreen_part2"] =       {"sfx/cutscene/opening_ending_screen/sfx_cutscene_endingscreen_part2.ogg", "static"},
	["sfx_cutscene_openingscreen_part1"] =      {"sfx/cutscene/opening_ending_screen/sfx_cutscene_openingscreen_part1.ogg", "static"},
	["sfx_cutscene_openingscreen_part2"] =      {"sfx/cutscene/opening_ending_screen/sfx_cutscene_openingscreen_part2.ogg", "static"},

	-- W2	
	-- Timed spikes
	["sfx_enemy_timed_spikes_hit_{01-04}"] = {"sfx/enemy/timed_spikes/sfx_enemy_timed_spikes_hit_{}.ogg", "static"},
	["sfx_enemy_timed_spikes_unearth_{01-05}"] = {"sfx/enemy/timed_spikes/sfx_enemy_timed_spikes_unearth_{}.ogg", "static"},

	-- Bee
	["sfx_enemy_bee_attack_{01-05}"] = {"sfx/enemy/bee/sfx_enemy_bee_attack_{}.ogg", "static"},

	-- Stabee
	["sfx_enemy_stabee_land_{01-04}"] = {"sfx/enemy/stabee/sfx_enemy_stabee_land_{}.ogg", "static"},
	["sfx_enemy_stabee_unstuck_{01-04}"] = {"sfx/enemy/stabee/sfx_enemy_stabee_unstuck_{}.ogg", "static"},

	-- Drill bee
	["sfx_enemy_drill_bee_attack_{01-04}"] = {"sfx/enemy/drill_bee/sfx_enemy_drill_bee_attack_{}.ogg", "static"},
	["sfx_enemy_drill_bee_explosion_{01-03}"] = {"sfx/enemy/drill_bee/sfx_enemy_drill_bee_explosion_{}.ogg", "static"},
	
	-- Beelet
	["sfx_enemy_beelet_telegraph_{01-04}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_telegraph_{}.ogg", "static"},
	["sfx_enemy_beelet_attack_{01-04}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_attack_{}.ogg", "static"},
	["sfx_enemy_beelet_bounce_{01-06}"] = {"sfx/enemy/beelet/sfx_enemy_beelet_bounce_{}.ogg", "static"},

	-- Flying nest 
	["sfx_enemy_flying_nest_ambient_lp"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_ambient_lp.ogg", "stream", { looping = true }},
	["sfx_enemy_flying_nest_death"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_death.ogg", "static"},
	["sfx_enemy_flying_nest_shoot_larva_{01-03}"] = {"sfx/enemy/flying_nest/sfx_enemy_flying_nest_shoot_larva_{}.ogg", "static"},
	
	-- Comball
	["sfx_enemy_comball_bounce_{01-06}"] = {"sfx/enemy/comball/sfx_enemy_comball_bounce_{}.ogg", "static"},
	["sfx_enemy_comball_flash_{01-06}"] = {"sfx/enemy/comball/sfx_enemy_comball_flash_{}.ogg", "static"},
	["sfx_enemy_comball_death"] = {"sfx/enemy/comball/sfx_enemy_comball_death.ogg", "static"},

	-- Honeypot ant 
	["sfx_enemy_honeypot_liquid_splash_{01-04}"] = {"sfx/enemy/honeypot/splash/sfx_enemy_honeypot_liquid_splash_{}.ogg", "static"},
	["sfx_enemy_honeypot_liquid_falling_{01-04}"] = {"sfx/enemy/honeypot/falling/sfx_enemy_honeypot_liquid_falling_{}.ogg", "static"},

	-- Her Majesty
	["sfx_boss_intro_majesty"] = {"sfx/enemy/majesty/sfx_boss_intro_majesty.ogg", "static"},
	["sfx_boss_intro_spotlights_{01-03}"] = {"sfx/enemy/majesty/spotlights/sfx_boss_intro_spotlights_{}.ogg", "static"},
	["sfx_boss_majesty_hit_{01-06}"] = {"sfx/enemy/majesty/hit/sfx_boss_majesty_hit_{}.ogg", "static"},
	["sfx_boss_majesty_thwomp_attack_{01-07}"] = {"sfx/enemy/majesty/thwomp/sfx_boss_majesty_thwomp_attack_{}.ogg", "static"},
	["sfx_boss_majesty_thwomp_impact_{01-03}"] = {"sfx/enemy/majesty/thwomp/sfx_boss_majesty_thwomp_impact_{}.ogg", "static"},
	["sfx_boss_majesty_pong_telegraph_{01-04}"] = {"sfx/enemy/majesty/pong/sfx_boss_majesty_pong_telegraph_{}.ogg", "static"},
	["sfx_boss_majesty_pong_bounce_{01-10}"] = {"sfx/enemy/majesty/pong/sfx_boss_majesty_pong_bounce_{}.ogg", "static"},
	["sfx_boss_majesty_minions_spawn_{01-08}"] = {"sfx/enemy/majesty/minions_spawn/sfx_boss_majesty_minions_spawn_{}.ogg", "static"},
	["sfx_boss_majesty_death"] = {"sfx/enemy/majesty/sfx_boss_majesty_death.ogg", "static"},
	["sfx_boss_majesty_crowd_happy_{01-04}"] = {"sfx/enemy/majesty/crowd/happy/sfx_boss_majesty_crowd_happy_{}.ogg", "stream"},
	["sfx_boss_majesty_crowd_ambient"] = {"sfx/enemy/majesty/crowd/sfx_boss_majesty_crowd_ambient.ogg", "stream"},
	["sfx_boss_majesty_crowd_cheer"] = {"sfx/enemy/majesty/crowd/sfx_boss_majesty_crowd_cheer.ogg", "stream"},

	-- W3 
	-- Electric Arc 
	["sfx_enemy_electricarc_lp_{01-02}"] = {"sfx/enemy/electricarc/sfx_enemy_electricarc_lp_{}.ogg", "stream", {looping=true}},
	
	-- Metal fly
	["sfx_enemy_metalfly_fly_ambient_{01-02}"] = {"sfx/enemy/metalfly/sfx_enemy_metalfly_fly_ambient_{}.ogg", "stream", {looping=true}},
	
	-- Chipper
	["sfx_enemy_chipper_trigger"] = {"sfx/enemy/chipper/sfx_enemy_chipper_trigger.ogg", "static"},
	["sfx_enemy_chipper_crawl_lp_{01-04}"] = {"sfx/enemy/chipper/sfx_enemy_chipper_crawl_lp_{}.ogg", "stream", {looping=true}},

	-- Grasshopper
	["sfx_enemy_grasshopper_jump_{01-06}"] = {"sfx/enemy/grasshopper/sfx_enemy_grasshopper_jump_{}.ogg", "static"},

	-- Motherboard boss
	["sfx_enemy_motherboard_intro"] = {"sfx/enemy/motherboard/sfx_enemy_motherboard_intro.ogg", "static"},
	["sfx_enemy_motherboard_crash"] = {"sfx/enemy/motherboard/sfx_enemy_motherboard_crash.ogg", "static"},
	["sfx_enemy_motherboardbutton_press_{01-06}"] = {"sfx/enemy/motherboard/sfx_enemy_motherboardbutton_press_{}.ogg", "static"},
	["sfx_enemy_motherboard_phase2"] = {"sfx/enemy/motherboard/sfx_enemy_motherboard_phase2.ogg", "static"},
	["sfx_enemy_motherboard_phase3"] = {"sfx/enemy/motherboard/sfx_enemy_motherboard_phase3.ogg", "static"},
	["sfx_enemy_motherboard_death"] = {"sfx/enemy/motherboard/sfx_enemy_motherboard_death.ogg", "static"},
	
	-- Big beelet (Big chipper)
	["sfx_enemy_bigbeelet_telegraph_{01-04}"] = {"sfx/enemy/bigbeelet/sfx_enemy_bigbeelet_telegraph_{}.ogg", "static"},
	["sfx_enemy_bigbeelet_attack_{01-04}"] = {"sfx/enemy/bigbeelet/sfx_enemy_bigbeelet_attack_{}.ogg", "static"},
	["sfx_enemy_bigbeelet_bounce_{01-06}"] = {"sfx/enemy/bigbeelet/sfx_enemy_bigbeelet_bounce_{}.ogg", "static"},

	-- Pendulum
	["sfx_enemy_pendulum_ambient"] = {"sfx/enemy/pendulum/sfx_enemy_pendulum_ambient.ogg", "stream"},
	["sfx_enemy_pendulum_swing_{01-06}"] = {"sfx/enemy/pendulum/sfx_enemy_pendulum_swing_{}.ogg", "stream"},

	["fly_buzz"] = {"empty.ogg", "static"}, -- TODO change to actual sound
	
	-- W4 
	-- CloudStorm
	["sfx_enemy_cloudstorm_charge_{01-03}"] = {"sfx/enemy/cloudstorm/sfx_enemy_cloudstorm_charge_{}.ogg", "static"}, -- TODO change to actual sound
	["sfx_enemy_cloudstorm_thunder_{01-03}"] = {"sfx/enemy/cloudstorm/sfx_enemy_cloudstorm_thunder_{}.ogg", "static"}, -- TODO change to actual sound

	-- Rollopod
	["sfx_enemy_rollopod_balling_{01-04}"] = {"sfx/enemy/rollopod/sfx_enemy_rollopod_balling_{}.ogg", "static"},
	["sfx_enemy_rollopod_dash_lp_{01-02}"] = {"sfx/enemy/rollopod/sfx_enemy_rollopod_dash_lp_{}.ogg", "static", {looping=true}},
	["sfx_enemy_rollopod_impact_{01-04}"] = {"sfx/enemy/rollopod/sfx_enemy_rollopod_impact_{}.ogg", "static"},

	-- Shooter
	["sfx_enemy_shooter_charge_{01-02}"] = {"sfx/enemy/shooter/sfx_enemy_shooter_charge_{}.ogg", "static"},
	["sfx_enemy_shooter_burst_{01-06}"] = {"sfx/enemy/shooter/sfx_enemy_shooter_burst_{}.ogg", "static"},	

	-- Dropper
	["sfx_ennemy_dropper_trigger_{01-04}"] = {"sfx/enemy/dropper/sfx_ennemy_dropper_trigger_{}.ogg", "static"},
	
	-- Centipede
	["sfx_enemy_centipede_lp"] = {"sfx/enemy/centipede/sfx_enemy_centipede_lp.ogg", "static", {looping=true}},
	["sfx_enemy_centipede_damage_{01-04}"] = {"sfx/enemy/centipede/sfx_enemy_centipede_damage_{}.ogg", "static"},
	
	-- Golden Beetle
	["sfx_enemy_goldenbeetle_trigger"] = {"sfx/enemy/goldenbeetle/sfx_enemy_goldenbeetle_trigger.ogg", "static"},
	["sfx_enemy_goldenbeetle_explode_{01-03}"] = {"sfx/enemy/goldenbeetle/sfx_enemy_goldenbeetle_explode_{}.ogg", "static"},
	["sfx_enemy_goldenbeetle_beep"] = {"sfx/enemy/goldenbeetle/sfx_enemy_goldenbeetle_beep.ogg", "static"},
	
	-- Rollossus
	["sfx_boss_rollossus_intro"] =                     {"sfx/enemy/rollossus/sfx_boss_rollossus_intro.ogg", "static"},
	["sfx_boss_rollossus_minion_bump_{01-06}"] =       {"sfx/enemy/rollossus/minion_bump/sfx_boss_rollossus_minion_bump_{}.ogg", "static"},
	["sfx_boss_rollossus_dig_in_{01-03}"] =            {"sfx/enemy/rollossus/digging/sfx_boss_rollossus_dig_in_{}.ogg", "static"},
	["sfx_boss_rollossus_digging_lp_{01-02}"] =        {"sfx/enemy/rollossus/digging/sfx_boss_rollossus_digging_lp_{}.ogg", "static", {looping = true}},
	["sfx_boss_rollossus_telegraph_dig_out_{01-04}"] = {"sfx/enemy/rollossus/digging/sfx_boss_rollossus_telegraph_dig_out_{}.ogg", "static"},
	["sfx_boss_rollossus_dig_out_{01-03}"] =           {"sfx/enemy/rollossus/digging/sfx_boss_rollossus_dig_out_{}.ogg", "static"},
	["sfx_boss_rollossus_telegraph_jumping_{01-04}"] = {"sfx/enemy/rollossus/jumping/sfx_boss_rollossus_telegraph_jumping_{}.ogg", "static"},
	["sfx_boss_rollossus_jumping_impact_{01-05}"] =    {"sfx/enemy/rollossus/jumping/sfx_boss_rollossus_jumping_impact_{}.ogg", "static"},
	["sfx_boss_rollossus_telegraph_rolling_{01-03}"] = {"sfx/enemy/rollossus/rolling/sfx_boss_rollossus_telegraph_rolling_{}.ogg", "static"},
	["sfx_boss_rollossus_rolling_lp"] =                {"sfx/enemy/rollossus/rolling/sfx_boss_rollossus_rolling_lp.ogg", "static", {looping = true}},
	["sfx_boss_rollossus_damage_{01-06}"] =            {"sfx/enemy/rollossus/damage/sfx_boss_rollossus_damage_{}.ogg", "static"},
	["sfx_boss_rollossus_death"] =                     {"sfx/enemy/rollossus/sfx_boss_rollossus_death.ogg", "static"},

	-- W5 
	["sfx_boss_ceo_intro"] =                           {"sfx/enemy/ceo/sfx_boss_ceo_intro.ogg", "static"},
	["sfx_boss_ceo_fish_stomp_{01-06}"] =              {"sfx/enemy/ceo/fish/sfx_boss_ceo_fish_stomp_{}.ogg", "static"},
	["sfx_boss_ceo_fish_starring_lp"] =                {"sfx/enemy/ceo/fish/sfx_boss_ceo_fish_starring_lp.ogg", "stream", {looping=true}},
	["sfx_boss_ceo_telegraph_dash_{01-04}"] =          {"sfx/enemy/ceo/dash/sfx_boss_ceo_telegraph_dash_{}.ogg", "static"},
	["sfx_boss_ceo_dash_{01-06}"] =                    {"sfx/enemy/ceo/dash/sfx_boss_ceo_dash_{}.ogg", "static"},
	["sfx_boss_ceo_telegraph_stomp_{01-04}"] =         {"sfx/enemy/ceo/stomp/sfx_boss_ceo_telegraph_stomp_{}.ogg", "static"},
	["sfx_boss_ceo_stomp_{01-04}"] =                   {"sfx/enemy/ceo/stomp/sfx_boss_ceo_stomp_{}.ogg", "static"},
	["sfx_boss_ceo_telegraph_lob_{01-04}"] =           {"sfx/enemy/ceo/lob/sfx_boss_ceo_telegraph_lob_{}.ogg", "static"},
	["sfx_boss_ceo_phase2"] =                          {"sfx/enemy/ceo/sfx_boss_ceo_phase2.ogg", "static"},
	["sfx_boss_ceo_death"] =                           {"sfx/enemy/ceo/sfx_boss_ceo_death.ogg", "static"},

	-- UPGRADES
	["sfx_upgrades_apple_juice_pickedup"] = {"sfx/upgrades/sfx_upgrades_apple_juice_pickedup.ogg", "static"},
	["sfx_upgrades_boba_pickedup"] = {"sfx/upgrades/sfx_upgrades_boba_pickedup.ogg", "static"},
	["sfx_upgrades_energydrink_pickedup"] = {"sfx/upgrades/sfx_upgrades_energydrink_pickedup.ogg", "static"},
	["sfx_upgrades_espresso_pickedup"] = {"sfx/upgrades/sfx_upgrades_espresso_pickedup.ogg", "static"},
	["sfx_upgrades_milk_pickedup"] = {"sfx/upgrades/sfx_upgrades_milk_pickedup.ogg", "static"},
	["sfx_upgrades_peanut_pickedup"] = {"sfx/upgrades/sfx_upgrades_peanut_pickedup.ogg", "static"},
	["sfx_upgrades_soda_pickedup"] = {"sfx/upgrades/sfx_upgrades_soda_pickedup.ogg", "static"},
	["sfx_upgrades_tea_pickedup"] = {"sfx/upgrades/sfx_upgrades_tea_pickedup.ogg", "static"},
	["sfx_upgrades_hot_sauce_pickedup"] = {"sfx/upgrades/sfx_upgrades_hot_sauce_pickedup.ogg", "static"},
	["sfx_upgrades_coconut_water_pickedup"] = {"sfx/upgrades/sfx_upgrades_coconut_water_pickedup.ogg", "static"},
	["sfx_upgrades_hot_chocolate_pickedup"] = {"sfx/upgrades/sfx_upgrades_hot_chocolate_pickedup.ogg", "static"},
	["sfx_upgrades_pomegranate_juice_pickedup"] = {"sfx/upgrades/sfx_upgrades_pomegranate_juice_pickedup.ogg", "static"},
	["sfx_upgrades_fizzy_lemonade_pickedup"] = {"sfx/upgrades/sfx_upgrades_fizzy_lemonade_pickedup.ogg", "static"},
	["sfx_upgrades_gazpacho_pickedup"] = {"sfx/upgrades/sfx_upgrades_gazpacho_pickedup.ogg", "static"},
	["sfx_upgrades_water_pickedup"] = {"sfx/upgrades/sfx_upgrades_water_pickedup.ogg", "static"},

	["sfx_upgrades_general_hover"] = {"sfx/upgrades/sfx_upgrades_general_hover.ogg", "static"},


	-- UI
	["ui_menu_pause"] = {"sfx/ui/ui_menu_pause.ogg", "static"},
	["ui_menu_unpause"] = {"sfx/ui/ui_menu_unpause.ogg", "static"},
	["ui_menu_hover_{01-04}"] = {"sfx/ui/ui_menu_hover_{}.ogg", "static"},
	["ui_menu_select_{01-04}"] = {"sfx/ui/ui_menu_select_{}.ogg", "static"},
	["ui_slider_increase"] = {"sfx/ui/ui_slider_increase.ogg", "static"},
	["ui_slider_decrease"] = {"sfx/ui/ui_slider_decrease.ogg", "static"},

	-- Achievements
	["sfx_ui_achievement"] = {"sfx/ui/sfx_ui_achievement.ogg", "static"},
	["sfx_ui_unlock"] = {"sfx/ui/sfx_ui_unlock.ogg", "static"},
	["sfx_ui_xpbar_tick"] = {"sfx/ui/sfx_ui_xpbar_tick.ogg", "static"},

	-- LEVEL
	["sfx_door_open"] = {"sfx/level/door/sfx_door_open.ogg", "static"},
	["sfx_door_close"] = {"sfx/level/door/sfx_door_close.ogg", "static"},
	["sfx_door_ding"] = {"sfx/level/door/sfx_door_ding.ogg", "static"},

	["sfx_tutorial_wall_damage_{01-03}"] = {"sfx/tutorial/sfx_tutorial_wall_damage_{}.ogg", "static"},
	["sfx_tutorial_wall_destroy"] = {"sfx/tutorial/sfx_tutorial_wall_destroy.ogg", "static"},


	-- PLACEHOLDER
	["sfx_bullet_bounce_{01-02}"] = {"placeholder/sfx_bullet_bounce_{}.ogg", "static"},
	["chipper_telegraph"] = {"placeholder/chipper_telegraph.ogg", "static"},
	["sfx_enemy_death"] = {"placeholder/sfx_enemy_death.ogg", "static"},

	-- Ambience
	["amb_pad_cafeteria_lp"] = {"sfx/ambience/amb_pad_cafeteria_lp.ogg", "stream", {looping = true}},
	["amb_pad_lobby_lp"] = {"sfx/ambience/amb_pad_lobby_lp.ogg", "stream", {looping = true}},
	["amb_pad_tutorial_lp"] = {"sfx/ambience/amb_pad_tutorial_lp.ogg", "stream", {looping = true}},
	["amb_pad_world1_lp"] = {"sfx/ambience/amb_pad_world1_lp.ogg", "stream", {looping = true}},
	["amb_pad_world2_lp"] = {"sfx/ambience/amb_pad_world2_lp.ogg", "stream", {looping = true}},
	["amb_pad_world3_lp"] = {"sfx/ambience/amb_pad_world3_lp.ogg", "stream", {looping = true}},
	["amb_pad_world4_lp"] = {"sfx/ambience/amb_pad_world4_lp.ogg", "stream", {looping = true}},
	["amb_pad_world5_lp"] = {"sfx/ambience/amb_pad_world5_lp.ogg", "stream", {looping = true}},
}


local start = love.timer.getTime()
print("Loading sounds...")

local sound_load_times = {}

local function timed_new_source(key, path, ...)
    local t0 = love.timer.getTime()
    local src = new_source(path, ...)
    local t1 = love.timer.getTime()

    sound_load_times[#sound_load_times + 1] = {
        key = key,
        path = path,
        time = t1 - t0,
		is_music = string.sub(key, 1, 5) == "music",
    }

    return src
end

for key, params in pairs(sfxnames) do
	local start_s, end_s = key:match("{(.-)%-(.-)}")
	local t0 = love.timer.getTime()
	
	assert(params and #params > 0, "Empty table given for "..tostring(key))
	local path = params[1]
	local r = path:match("{}")
    if start_s and end_s and r then
        local len = math.max(#start_s, #end_s)
        local a = tonumber(start_s)
        local b = tonumber(end_s)
        assert(a and b, "Invalid number range in pattern")

        for i = a, b do
            local formatted = string.format("%0"..len.."d", i)
            local new_key = key:gsub("{(.-)%-(.-)}", formatted)
			local new_path = path:gsub("{}", formatted)
			sounds[new_key] = timed_new_source(
                new_key,
                new_path,
                params[2],
                params[3]
            )
        end
    else
        -- If no pattern, just apply the function directly
		sounds[key] = timed_new_source(
            key,
            params[1],
            params[2],
            params[3]
        )
    end
end

--[[ Comment out to display a table of the biggest sound load times
-- Display slowest loaded sounds
table.sort(sound_load_times, function(a, b)
    return a.time > b.time
end)

local number_of_slowest_sounds_to_display = 40

print(string.format("\nTop %d slowest sound loads:", number_of_slowest_sounds_to_display))
print(string.format("%-4s %-40s %-10s %s", "#", "Key", "Time (ms)", "Path"))

for i = 1, math.min(number_of_slowest_sounds_to_display, #sound_load_times) do
    local e = sound_load_times[i]
    print(string.format(
        "%-4d %-40s %-10.3f %s",
        i,
        e.key,
        e.time * 1000,
        e.path
    ))
end

---
table.sort(sound_load_times, function(a, b)
	local ta = ternary(a.is_music, a.time, 0)
	local tb = ternary(b.is_music, b.time, 0)
    return ta > tb
end)

print(string.format("\nMusic load times:"))
print(string.format("%-4s %-40s %-10s %s", "#", "Key", "Time (ms)", "Path"))

for i = 1, #sound_load_times do
	if sound_load_times[i].is_music then
		local e = sound_load_times[i]
		print(string.format(
			"%-4d %-40s %-10.3f %s",
			i,
			e.key,
			e.time * 1000,
			e.path
		))
	end
end

print(string.format(
    "\nTotal sound loading time: %.3f ms",
    (love.timer.getTime() - start) * 1000
))
---]]


-- All sources are tables to support multiple sounds playing at once without using Source:clone()
for k, snd in pairs(sounds) do
	sounds[k] = Sound:new(
		snd,
		snd:getPitch(),
		snd:getVolume(),
		{
			looping = snd:isLooping(),
		}
	)
end

print(concatsep({"Finished loading", table_key_count(sounds), "sounds. (", (love.timer.getTime() - start) * 1000 ,"ms)"}))

return sounds
