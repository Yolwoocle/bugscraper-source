require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"

DEBUG_IMAGE_TO_COL = {}

local function load_image(name)
	local im = love.graphics.newImage("images/"..name)
	im:setFilter("nearest", "nearest")
	return im 
end

local function load_spritesheet(name, number)
	local image = load_image(name)
	local sheet = {
		type = "spritesheet",
		image = image,
		quads = {},
	}
	local width = math.floor(image:getWidth()/number)

	for x = 0, image:getWidth(), width do
		table.insert(sheet.quads, love.graphics.newQuad(x, 0, width, image:getHeight(), image:getDimensions()))
	end

    return sheet
end

-----------------------------------------------------

local img_names = {
	empty = "empty",

	-----------------------------------------------------

	-- test
	_test_window = "_test_window",
	_test_shine = "_test_shine",

	-----------------------------------------------------

	gamelogo =         "gamelogo",

	-- players
	mio_idle =         "actors/players/mio_idle",
	mio_walk_down =    "actors/players/mio_walk_down",
	mio_airborne =     "actors/players/mio_airborne",
	mio_wall_slide =   "actors/players/mio_wall_slide",
	mio_dead =         "actors/players/mio_dead",

	cap_idle =         "actors/players/cap_idle",
	cap_walk_down =    "actors/players/cap_walk_down",
	cap_airborne =     "actors/players/cap_airborne",
	cap_wall_slide =   "actors/players/cap_wall_slide",
	cap_dead =         "actors/players/cap_dead",

	zia_idle =         "actors/players/zia_idle",
	zia_walk_down =    "actors/players/zia_walk_down",
	zia_airborne =     "actors/players/zia_airborne",
	zia_wall_slide =   "actors/players/zia_wall_slide",
	zia_dead =         "actors/players/zia_dead",

	tok_idle =         "actors/players/tok_idle",
	tok_walk_down =    "actors/players/tok_walk_down",
	tok_airborne =     "actors/players/tok_airborne",
	tok_wall_slide =   "actors/players/tok_wall_slide",
	tok_dead =         "actors/players/tok_dead",
	
	nel_idle =         "actors/players/nel_idle",
	nel_walk_down =    "actors/players/nel_walk_down",
	nel_airborne =     "actors/players/nel_airborne",
	nel_wall_slide =   "actors/players/nel_wall_slide",
	nel_dead =         "actors/players/nel_dead",
	
	amb_idle =         "actors/players/amb_idle",
	amb_walk_down =    "actors/players/amb_walk_down",
	amb_airborne =     "actors/players/amb_airborne",
	amb_wall_slide =   "actors/players/amb_wall_slide",
	amb_dead =         "actors/players/amb_dead",

	rabbit_1 =         "actors/players/rabbit_1",
	rabbit_2 =         "actors/players/rabbit_2",
	rabbit_dead =      "actors/players/rabbit_dead",
	
	dodu_idle =        "actors/players/dodu_idle",
	dodu_walk_down =   "actors/players/dodu_idle",
	dodu_airborne =    "actors/players/dodu_idle",
	dodu_wall_slide =  "actors/players/dodu_idle",
	dodu_dead =        "actors/players/dodu_dead",

	yv_idle =          "actors/players/yv_idle",
	yv_walk_down =     "actors/players/yv_walk_down",
	yv_airborne =      "actors/players/yv_airborne",
	yv_wall_slide =    "actors/players/yv_wall_slide",
	yv_dead =          "actors/players/yv_dead",

	nob_idle =          "actors/players/nob_idle",
	nob_walk_down =     "actors/players/nob_walk_down",
	nob_airborne =      "actors/players/nob_airborne",
	nob_wall_slide =    "actors/players/nob_wall_slide",
	nob_dead =          "actors/players/nob_dead",

	leo =              "actors/players/leo",
	duck =             "actors/players/duck",

	-- NPCs
	npc_brown =        "actors/npc/npc_brown",
	npc_bee_tea =      "actors/npc/npc_bee_tea",
	npc_gagagougou =   "actors/npc/npc_gagagougou",
	npc_jalapenos =    "actors/npc/npc_jalapenos",
	npc_boba =         "actors/npc/npc_boba",
	npc_disco =        "actors/npc/npc_disco",
	npc_lizard =       "actors/npc/npc_lizard",
	npc_noba =         "actors/npc/npc_noba",
	npc_hornet =       "actors/npc/npc_hornet",

	-- enemies
	arum_titan_boss =          "actors/enemies/arum_titan_boss",
	arum_titan_boss_spiked =   "actors/enemies/arum_titan_boss_spiked",
	arum_titan_minion =        "actors/enemies/arum_titan_minion",
	arum_titan_minion_spiked = "actors/enemies/arum_titan_minion_spiked",
	bee_boss_alt =             "actors/enemies/bee_boss_alt",
	bee_boss_shield =          "actors/enemies/bee_boss_shield",
	bee_boss_dead =            "actors/enemies/bee_boss_dead",
	big_bug_1 =                "actors/enemies/big_bug_1",
	big_chipper =              "actors/enemies/big_chipper",
	big_chipper_activated =    "actors/enemies/big_chipper_activated",
	big_punching_glove =       "actors/enemies/big_punching_glove",
	bee =                      "actors/enemies/bee",
	bee_1 =                    "actors/enemies/bee_1",
	bee_2 =                    "actors/enemies/bee_2",
	boomshroom_1 =             "actors/enemies/boomshroom_1",
	boomshroom_2 =             "actors/enemies/boomshroom_2",
	boomshroom_3 =             "actors/enemies/boomshroom_3",
	boomshroom_4 =             "actors/enemies/boomshroom_4",
	boomshroom_5 =             "actors/enemies/boomshroom_5",
	boomshroom_6 =             "actors/enemies/boomshroom_6",
	boomshroom_7 =             "actors/enemies/boomshroom_7",
	boomshroom_8 =             "actors/enemies/boomshroom_8",
	bulb_buddy_1 =             "actors/enemies/bulb_buddy_1",
	bulb_buddy_2 =             "actors/enemies/bulb_buddy_2",
	chipper_1 =                "actors/enemies/chipper_1",
	chipper_2 =                "actors/enemies/chipper_2",
	chipper_3 =                "actors/enemies/chipper_3",
	cloud_enemy_size1 =        "actors/enemies/cloud_enemy_size1",
	cloud_enemy_size2 =        "actors/enemies/cloud_enemy_size2",
	cloud_enemy_size3 =        "actors/enemies/cloud_enemy_size3",
	cloud_storm =              "actors/enemies/cloud_storm",
	cloud_storm_angry =        "actors/enemies/cloud_storm_angry",
	cloud_storm_angry_attack = "actors/enemies/cloud_storm_angry_attack",
	cloud_dropper =            "actors/enemies/cloud_dropper",
	cloud_dropper_shocked =    "actors/enemies/cloud_dropper_shocked",
	cloud_dropper_projectile = "actors/enemies/cloud_dropper_projectile",
	beelet_1 =                 "actors/enemies/beelet_1",
	beelet_activated =         "actors/enemies/beelet_activated",
	centipede_head = 	       "actors/enemies/centipede_head",
	centipede_body = 	       "actors/enemies/centipede_body",
	ceo =                      "actors/enemies/ceo",
	ceo_office_desk =          "actors/enemies/ceo_office_desk",
	ceo_office_legs =          "actors/enemies/ceo_office_legs",
	ceo_office_glass =         "actors/enemies/ceo_office_glass",
	ceo_office_glass_break_1 = "actors/enemies/ceo_office_glass_break_1",
	ceo_office_glass_break_2 = "actors/enemies/ceo_office_glass_break_2",
	ceo_office_glass_break_3 = "actors/enemies/ceo_office_glass_break_3",
	ceo_normal =               "actors/enemies/ceo_normal",
	ceo_telegraph_arrow =      "actors/enemies/ceo_telegraph_arrow",
	ceo_npc_idle =             "actors/enemies/ceo_npc_idle",
	ceo_npc_clap_hand =        "actors/enemies/ceo_npc_clap_hand",
	ceo_npc_shocked =          "actors/enemies/ceo_npc_shocked",
	ceo_npc_airborne =         "actors/enemies/ceo_npc_airborne",
	ceo_npc_jetpack =          "actors/enemies/ceo_npc_jetpack",
	ceo_npc_fainted =          "actors/enemies/ceo_npc_fainted",
	ceo_npc_fainted_single =   "actors/enemies/ceo_npc_fainted_single",
	ceo_npc_angry_idle =       "actors/enemies/ceo_npc_angry_idle",
	ceo_npc_angry_airborne =   "actors/enemies/ceo_npc_angry_airborne",
	ceo_npc_sitting =          "actors/enemies/ceo_npc_sitting",
	ceo_tangled_wires =        "actors/enemies/ceo_tangled_wires",
	ceo_tangled_wires_shocked = "actors/enemies/ceo_tangled_wires_shocked",
	ceo_tangled_wires_fainted = "actors/enemies/ceo_tangled_wires_fainted",
	chipper_attack_1 =         "actors/enemies/chipper_attack_1",
	chipper_attack_2 =         "actors/enemies/chipper_attack_2",
	chipper_attack_3 =         "actors/enemies/chipper_attack_3",
	cocoon =                   "actors/enemies/cocoon",
	dummy_target =             "actors/enemies/dummy_target",
	dung =                     "actors/enemies/dung",
	dung_beetle_idle =         "actors/enemies/dung_beetle_idle",
	dung_beetle_1 =            "actors/enemies/dung_beetle_1",
	dung_beetle_2 =            "actors/enemies/dung_beetle_2",
	dung_beetle_3 =            "actors/enemies/dung_beetle_3",
	dung_beetle_4 =            "actors/enemies/dung_beetle_4",
	dung_beetle_5 =            "actors/enemies/dung_beetle_5",
	dung_beetle_6 =            "actors/enemies/dung_beetle_6",
	dung_beetle_walk_1 =       "actors/enemies/dung_beetle_walk_1",
	dung_beetle_walk_2 =       "actors/enemies/dung_beetle_walk_2",
	dung_beetle_shield =       "actors/enemies/dung_beetle_shield",
	dung_beetle_shield_shine = "actors/enemies/dung_beetle_shield_shine",
	dung_beetle_dead =         "actors/enemies/dung_beetle_dead",
	dung_flying =              "actors/enemies/dung_flying",
	dung_flying_spiked =       "actors/enemies/dung_flying_spiked",
	dung_pile =                "actors/enemies/dung_pile",
	dung_projectile =          "actors/enemies/dung_projectile",
	drill_bee =                "actors/enemies/drill_bee",
	fly1 =                     "actors/enemies/fly1",
	fly2 =                     "actors/enemies/fly2",
	golden_beetle =            "actors/enemies/golden_beetle",
	grasshopper =              "actors/enemies/grasshopper",
	grasshopper_fall =         "actors/enemies/grasshopper_fall",
	honeypot_ant1 =            "actors/enemies/honeypot_ant1",
	honeypot_ant2 =            "actors/enemies/honeypot_ant2",
	honeypot_liquid =          "actors/enemies/honeypot_liquid",
	larva =                    "actors/enemies/larva",
	larva1 =                   "actors/enemies/larva1",
	larva2 =                   "actors/enemies/larva2",
	larva_spawner =            "actors/enemies/larva_spawner",
	larva_projectile_telegraph = "actors/enemies/larva_projectile_telegraph",
	flying_spawner =           "actors/enemies/flying_spawner",
	flying_spawner_big =       "actors/enemies/flying_spawner_big",
	larva_projectile =         "actors/enemies/larva_projectile",
	metal_mosquito_1 =         "actors/enemies/metal_mosquito_1",
	metal_mosquito_2 =         "actors/enemies/metal_mosquito_2",
	mole_digging_1 =           "actors/enemies/mole_digging_1",
	mole_telegraph_1 =         "actors/enemies/mole_telegraph_1",
	mole_outside =             "actors/enemies/mole_outside",
	rollossus_digging_1 =      "actors/enemies/rollossus_digging_1",
	rollossus_telegraph_1 =    "actors/enemies/rollossus_telegraph_1",
	rollossus_telegraph_spiked = "actors/enemies/rollossus_telegraph_spiked",
	rollossus_outside =        "actors/enemies/rollossus_outside",
	rollossus_roll =           "actors/enemies/rollossus_roll",
	rollossus_eyes_closed =    "actors/enemies/rollossus_eyes_closed",
	rollossus_minion =         "actors/enemies/rollossus_minion",
	rollossus_minion_spiked =  "actors/enemies/rollossus_minion_spiked",
	motherboard =              "actors/enemies/motherboard",
	motherboard_button =       "actors/enemies/motherboard_button",
	motherboard_button_front = "actors/enemies/motherboard_button_front",
	mushroom_ant1 =            "actors/enemies/mushroom_ant1",
	mushroom_ant2 =            "actors/enemies/mushroom_ant2",
	shooter_focused =          "actors/enemies/shooter_focused",
	shooter_focused_uncharged = "actors/enemies/shooter_focused_uncharged",
	shooter_normal =           "actors/enemies/shooter_normal",
	stabee =                   "actors/enemies/stabee",
	slug1 =                    "actors/enemies/slug1",
	slug2 =                    "actors/enemies/slug2",
	snail_open =               "actors/enemies/snail_open",
	snail_shell =              "actors/enemies/snail_shell",
	snail_shell_bouncy =       "actors/enemies/snail_shell_bouncy",
	spider1 =                  "actors/enemies/spider1",
	spider2 =                  "actors/enemies/spider2",
	spiked_fly =               "actors/enemies/spiked_fly",
	stink_bug_walk =           "actors/enemies/stink_bug_walk",
	thorn_ball =               "actors/enemies/thorn_ball",
	timed_spikes_base =        "actors/enemies/timed_spikes_base",
	timed_spikes_spikes =      "actors/enemies/timed_spikes_spikes",
	timed_spikes_spikes_stem = "actors/enemies/timed_spikes_spikes_stem",
	walking_slot_machine =     "actors/enemies/walking_slot_machine",
	woodlouse_1 =              "actors/enemies/woodlouse_1",
	woodlouse_2 =              "actors/enemies/woodlouse_2",
	rollopod =                 "actors/enemies/rollopod",
	rollopod_rolled =          "actors/enemies/rollopod_rolled",
	rollopod_dead =            "actors/enemies/rollopod_dead",	

	motherboard_bullet_cannon = "actors/enemies/motherboard_bullet_cannon",
	motherboard_led_on =       "actors/enemies/motherboard_led_on",
	motherboard_led_off =      "actors/enemies/motherboard_led_off",
	motherboard_plug_rays_1 =  "actors/enemies/motherboard_plug_rays_1",
	motherboard_plug_rays_2 =  "actors/enemies/motherboard_plug_rays_2",
	motherboard_plug_bullets = "actors/enemies/motherboard_plug_bullets",
	motherboard_shield =       "actors/enemies/motherboard_shield",
	poison_cloud =             "actors/enemies/poison_cloud_1",

	upgrade_jar =              "actors/enemies/upgrade_jar",
	heart_jar =                "actors/enemies/heart_jar",
	gun_display =              "actors/enemies/gun_display",
	big_red_button_crack0 =    "actors/enemies/big_red_button_crack0",
	big_red_button_crack1 =    "actors/enemies/big_red_button_crack1",
	big_red_button_crack2 =    "actors/enemies/big_red_button_crack2",
	big_red_button_crack3 =    "actors/enemies/big_red_button_crack3",
	big_red_button =           "actors/enemies/big_red_button",
	big_red_button_pressed =   "actors/enemies/big_red_button_pressed",
	small_button_crack0 =      "actors/enemies/small_button_crack0",
	small_button_crack1 =      "actors/enemies/small_button_crack1",
	small_button_crack2 =      "actors/enemies/small_button_crack2",
	small_button =             "actors/enemies/small_button",
	small_button_pressed =     "actors/enemies/small_button_pressed",
	exit_sign =                "actors/enemies/exit_sign",
	exit_sign_front =          "actors/enemies/exit_sign_front",
	punching_glove =           "actors/enemies/punching_glove",
	spring =                   "actors/enemies/spring",
	final_boss_minion_star =   "actors/enemies/final_boss_minion_star",
	final_boss_minion_body =   "actors/enemies/final_boss_minion_body",

	vending_machine =          "actors/enemies/vending_machine",
	water_dispenser =          "actors/enemies/water_dispenser",
	machine_coffee =           "actors/enemies/machine_coffee",
	machine_coffee_pressed =   "actors/enemies/machine_coffee_pressed",
	machine_snacks =           "actors/enemies/machine_snacks",
	machine_toys =             "actors/enemies/machine_toys",

	loot_ammo =                "actors/loot/loot_ammo",
	loot_ammo_big =            "actors/loot/loot_ammo_big",
	loot_life =                "actors/loot/loot_life",
	loot_life_big =            "actors/loot/loot_life_big",
	
	bullet =                   "actors/bullets/bullet",
	bullet_pea =               "actors/bullets/bullet_pea",
	bullet_white =             "actors/bullets/bullet_white",
	bullet_red =               "actors/bullets/bullet_red",
	bullet_blue =              "actors/bullets/bullet_blue",
	bullet_ring =              "actors/bullets/bullet_ring",
	bullet_ring_red =          "actors/bullets/bullet_ring_red",
	mushroom =                 "actors/bullets/mushroom",
	mushroom_yellow =          "actors/bullets/mushroom_yellow",
	mushroom_spike =           "actors/bullets/mushroom_spike",

	birby =           "actors/enemies/birby",

	-----------------------------------------------------
	
	-- guns
	gun_machinegun =      "guns/gun_machinegun",
	gun_triple =          "guns/gun_triple",
	gun_burst =           "guns/gun_burst",
	gun_shotgun =         "guns/gun_shotgun",
	gun_minigun =         "guns/gun_minigun",
	gun_mushroom_cannon = "guns/gun_mushroom_cannon",
	gun_ring =            "guns/gun_ring",
	resignation_letter =  "guns/resignation_letter",
	
	-----------------------------------------------------
	
	-- particles
	cabin_fragment_1 =            "particles/cabin_fragment_1",
	cabin_fragment_2 =            "particles/cabin_fragment_2",
	cabin_fragment_3 =            "particles/cabin_fragment_3",
	cocoon_fragment_1 =           "particles/cocoon_fragment_1",
	cocoon_fragment_2 =           "particles/cocoon_fragment_2",
	honey_fragment_1 =            "particles/honey_fragment_1",
	honey_fragment_2 =            "particles/honey_fragment_2",
	dummy_fragment_1 =            "particles/dummy_fragment_1",
	dummy_fragment_2 =            "particles/dummy_fragment_2",
	explosion_flash =             "particles/explosion_flash",
	glass_shard =                 "particles/glass_shard",
	snail_shell_fragment =        "particles/snail_shell_fragment",
	snail_shell_bouncy_fragment = "particles/snail_shell_bouncy_fragment",
	bullet_casing =               "particles/bullet_casing",
	green_fragment_1 =            "particles/green_fragment_1",
	green_fragment_2 =            "particles/green_fragment_2",
	green_fragment_3 =            "particles/green_fragment_3",
	button_fragment_1 =           "particles/button_fragment_1",
	button_fragment_2 =           "particles/button_fragment_2",
	button_fragment_3 =           "particles/button_fragment_3",
	button_fragment_4 =           "particles/button_fragment_4",
	button_fragment_5 =           "particles/button_fragment_5",
	smash_flash =                 "particles/smash_flash",
	particle_leaf =               "particles/particle_leaf",
	particle_bit_zero =           "particles/particle_bit_zero",
	particle_bit_one =            "particles/particle_bit_one",
	particle_bit_zero_dark =      "particles/particle_bit_zero_dark",
	particle_bit_one_dark =       "particles/particle_bit_one_dark",
	poison_skull =                "particles/poison_skull",
	pomegranate_piece_1 =         "particles/pomegranate_piece_1",
	pomegranate_piece_2 =         "particles/pomegranate_piece_2",
	pomegranate_piece_3 =         "particles/pomegranate_piece_3",
	white_dust =                  "particles/white_dust",
	furious_smoke =               "particles/furious_smoke", 

	bubble_fizz_1 =               "particles/bubble_fizz_1",
	bubble_fizz_2 =               "particles/bubble_fizz_2",

	bullet_vanish_1 =             "particles/bullet_vanish_1",
	bullet_vanish_2 =             "particles/bullet_vanish_2",
	bullet_vanish_3 =             "particles/bullet_vanish_3",
	bullet_vanish_4 =             "particles/bullet_vanish_4",
	bullet_vanish_5 =             "particles/bullet_vanish_5",

	sweat_1 =                     "particles/sweat_1",
	sweat_2 =                     "particles/sweat_2",
	sweat_3 =                     "particles/sweat_3",
	sweat_4 =                     "particles/sweat_4",

	star_splash_1 =               "particles/star_splash_1",
	star_splash_2 =               "particles/star_splash_2",
	star_splash_3 =               "particles/star_splash_3",
	star_splash_4 =               "particles/star_splash_4",
	star_splash_5 =               "particles/star_splash_5",

	star_splash_small_1 =         "particles/star_splash_small_1",
	star_splash_small_2 =         "particles/star_splash_small_2",
	star_splash_small_3 =         "particles/star_splash_small_3",

	star_small_1 =                "particles/star_small_1",
	star_small_2 =                "particles/star_small_2",
	star_small_3 =                "particles/star_small_3",

	star_big =                    "particles/star_big",
	star_pento_1 =                "particles/star_pento_1",
	star_big_5 =                  "particles/star_big_5",

	jump_dust_kick_1 =            "particles/jump_dust_kick_1",
	jump_dust_kick_2 =            "particles/jump_dust_kick_2",
	jump_dust_kick_3 =            "particles/jump_dust_kick_3",
	jump_dust_kick_4 =            "particles/jump_dust_kick_4",
	jump_dust_kick_5 =            "particles/jump_dust_kick_5",
	
	dung_particle_1 =             "particles/dung_particle_1",
	dung_particle_2 =             "particles/dung_particle_2",
	dung_particle_3 =             "particles/dung_particle_3",

	brick_fragment_1 =            "particles/brick_fragment_1",
	brick_fragment_2 =            "particles/brick_fragment_2",
	brick_fragment_3 =            "particles/brick_fragment_3",

	wood_fragment_1 =             "particles/wood_fragment_1",
	wood_fragment_2 =             "particles/wood_fragment_2",
	wood_fragment_3 =             "particles/wood_fragment_3",

	spin_whoosh_sheet =           "particles/spin_whoosh_sheet",
	spin_whoosh_1 =               "particles/spin_whoosh_1",
	spin_whoosh_2 =               "particles/spin_whoosh_2",
	spin_whoosh_3 =               "particles/spin_whoosh_3",
	spin_whoosh_4 =               "particles/spin_whoosh_4",
	spin_whoosh_5 =               "particles/spin_whoosh_5",

	surprise_effect =             "particles/surprise_effect",
	clap_effect =                 "particles/clap_effect",

	-----------------------------------------------------
	
	-- level
	metal =     "level/metal",
	chain =     "level/chain",
	semisolid = "level/semisolid",
	bg_plate =  "level/bg_plate",

	cabin_bg_w1 =                        "level/cabin_bg_w1",
	cabin_bg_w2 =                        "level/cabin_bg_w2",
	cabin_bg_w2_fan =                    "level/cabin_bg_w2_fan",
	cabin_bg_w3 =                        "level/cabin_bg_w3",
	cabin_bg_w3_scanlines =              "level/cabin_bg_w3_scanlines",
	cabin_bg_w3_scanlines_big =          "level/cabin_bg_w3_scanlines_big",
	cabin_bg_w3_tape =                   "level/cabin_bg_w3_tape",
	cabin_bg_w4 =                        "level/cabin_bg_w4",
	cabin_bg_w4_test =                   "level/cabin_bg_w4_test",
	cabin_bg_ambient_occlusion =         "level/cabin_bg_ambient_occlusion",
	cabin_bg_rocket =                    "level/cabin_bg_rocket",
    
	cabin_bg_w1_ventilation_shaft =      "level/cabin_bg_w1_ventilation_shaft",
	cabin_bg_w1_trapdoor =               "level/cabin_bg_w1_trapdoor",
    
	cabin_walls_w1 =                     "level/cabin_walls_w1",
	cabin_walls_w2 =              	     "level/cabin_walls_w2",
	cabin_walls_w3 =                     "level/cabin_walls_w3",
	cabin_walls_w4 =                     "level/cabin_walls_w4",
	cabin_walls_rocket =                 "level/cabin_walls_rocket",
	cabin_walls_no_floor =               "level/cabin_walls_no_floor",
    
	cabin_door_empty =                   "level/cabin_door_empty",
    
	cabin_door_left_far =                "level/cabin_door_left_far", 
	cabin_door_left_center =             "level/cabin_door_left_center",
	cabin_door_right_center =            "level/cabin_door_right_center",
	cabin_door_right_far =               "level/cabin_door_right_far",
	
	cabin_door_light_left_far =          "level/cabin_door_light_left_far", 
	cabin_door_light_left_center =       "level/cabin_door_light_left_center",
	cabin_door_light_right_far =         "level/cabin_door_light_right_far",
	cabin_door_light_right_center =      "level/cabin_door_light_right_center",
    
	cabin_door_bee_left_far =            "level/cabin_door_bee_left_far", 
	cabin_door_bee_left_center =         "level/cabin_door_bee_left_center",
	cabin_door_bee_right_far =           "level/cabin_door_bee_right_far",
	cabin_door_bee_right_center =        "level/cabin_door_bee_right_center",
    
	cabin_door_brown_left_far =          "level/cabin_door_brown_left_far", 
	cabin_door_brown_left_center =       "level/cabin_door_brown_left_center",
	cabin_door_brown_right_far =         "level/cabin_door_brown_right_far",
	cabin_door_brown_right_center =      "level/cabin_door_brown_right_center",
	
	cabin_door_w3_left_center =          "level/cabin_door_w3_left_center",
	cabin_door_w3_right_center =         "level/cabin_door_w3_right_center",
    
	cabin_door_w4_left_far =             "level/cabin_door_w4_left_far", 
	cabin_door_w4_left_center =          "level/cabin_door_w4_left_center",
	cabin_door_w4_right_far =            "level/cabin_door_w4_right_far",
	cabin_door_w4_right_center =         "level/cabin_door_w4_right_center",

	cabin_rubble =                       "level/cabin_rubble",
	cabin_grid =                         "level/cabin_grid",
	cabin_grid_brown =                   "level/cabin_grid_brown",
	cabin_grid_platform =                "level/cabin_grid_platform",

	audience_bee =                       "level/misc/audience_bee",
	audience_bee_big =                   "level/misc/audience_bee_big",

	building =                           "level/building",
	tutorial_house =                     "level/tutorial_house",
	tutorial_level =                     "level/tutorial_level",
	tutorial_level_back =                "level/tutorial_level_back",
	wooden_door =                        "level/wooden_door",

	background_world_transition =        "level/background_world_transition",

	basement =                           "level/basement",
	basement_rocket =                    "level/basement_rocket",
	basement_rocket_small =              "level/basement_rocket_small",
	basement_front =                     "level/basement_front",
	cafeteria =                          "level/cafeteria",
	cafeteria_front =                    "level/cafeteria_front",
	cafeteria_glass_hole =               "level/cafeteria_glass_hole",
	cafeteria_table_head =               "level/cafeteria_table_head",
	cafeteria_table_foot =               "level/cafeteria_table_foot",
	cafeteria_chair_left =               "level/cafeteria_chair_left",
	cafeteria_chair_right =              "level/cafeteria_chair_right",
	elevator_through_door =              "level/elevator_through_door",
	ground_floor =                       "level/ground_floor",
	ground_floor_front =                 "level/ground_floor_front",

	ground_floor_caution_sign =          "level/props/ground_floor_caution_sign",
	ground_floor_warning_sign =          "level/props/ground_floor_warning_sign",
	ground_floor_bucket_1 =              "level/props/ground_floor_bucket_1",
	ground_floor_bucket_2 =              "level/props/ground_floor_bucket_2",
	ground_floor_lamp =                  "level/props/ground_floor_lamp",
	ground_floor_chcolate_mug =          "level/props/ground_floor_chcolate_mug",
	ground_floor_cactus =                "level/props/ground_floor_cactus",
	ground_floor_computer_left =         "level/props/ground_floor_computer_left",
	ground_floor_computer_right =        "level/props/ground_floor_computer_right",
	ground_floor_mug =                   "level/props/ground_floor_mug",
	ground_floor_potted_tree =           "level/props/ground_floor_potted_tree",
	ground_floor_potted_plant =          "level/props/ground_floor_potted_plant",
	ground_floor_stack_papers_big =      "level/props/ground_floor_stack_papers_big",
	ground_floor_stack_papers_medium =   "level/props/ground_floor_stack_papers_medium",
	ground_floor_stack_papers_medium_b = "level/props/ground_floor_stack_papers_medium_b",
	ground_floor_stack_papers_small =    "level/props/ground_floor_stack_papers_small",
	ground_floor_boba =                  "level/props/ground_floor_boba",
	ground_floor_laptop =                "level/props/ground_floor_laptop",
	
	ceo_office_room =   "level/ceo_office_room",
	boss_door =         "level/boss_door",
	boss_door_cracked = "level/boss_door_cracked",
	breakable_wall =    "level/breakable_wall",
	
	tv_slideshow_001 = "level/tv_slideshow/tv_slideshow_001",
	tv_slideshow_002 = "level/tv_slideshow/tv_slideshow_002",
	tv_slideshow_003 = "level/tv_slideshow/tv_slideshow_003",
	tv_slideshow_004 = "level/tv_slideshow/tv_slideshow_004",
	tv_slideshow_005 = "level/tv_slideshow/tv_slideshow_005",
	tv_slideshow_006 = "level/tv_slideshow/tv_slideshow_006",
	tv_slideshow_007 = "level/tv_slideshow/tv_slideshow_007",
	tv_slideshow_008 = "level/tv_slideshow/tv_slideshow_008",
	tv_slideshow_009 = "level/tv_slideshow/tv_slideshow_009",
	tv_slideshow_010 = "level/tv_slideshow/tv_slideshow_010",
	tv_slideshow_011 = "level/tv_slideshow/tv_slideshow_011",
	tv_slideshow_012 = "level/tv_slideshow/tv_slideshow_012",
	tv_slideshow_013 = "level/tv_slideshow/tv_slideshow_013",
	tv_slideshow_014 = "level/tv_slideshow/tv_slideshow_014",
	tv_slideshow_015 = "level/tv_slideshow/tv_slideshow_015",
	tv_slideshow_016 = "level/tv_slideshow/tv_slideshow_016",
	tv_slideshow_017 = "level/tv_slideshow/tv_slideshow_017",
	tv_slideshow_018 = "level/tv_slideshow/tv_slideshow_018",
	tv_slideshow_019 = "level/tv_slideshow/tv_slideshow_019",
	tv_slideshow_020 = "level/tv_slideshow/tv_slideshow_020",
	tv_slideshow_021 = "level/tv_slideshow/tv_slideshow_021",
	tv_slideshow_022 = "level/tv_slideshow/tv_slideshow_022",
	tv_slideshow_999 = "level/tv_slideshow/tv_slideshow_999",
	tv_bluescreen =    "level/tv_slideshow/tv_bluescreen",
	tv_bluescreen_2 =  "level/tv_slideshow/tv_bluescreen_2",

	clock = "actors/enemies/clock",

	ending_building = "level/credits/ending_building",
	credits_building = "level/credits/credits_building",
	credits_removeme_characters = "level/credits/credits_removeme_characters",

	-----------------------------------------------------

	-- hud
	heart =           "ui/hud/heart",
	heart_white =     "ui/hud/heart_white",
	heart_half =      "ui/hud/heart_half",
	heart_empty =     "ui/hud/heart_empty",
	heart_temporary = "ui/hud/heart_temporary",
	ammo =            "ui/hud/ammo",
	ammo_hot_sauce =  "ui/hud/ammo_hot_sauce",
	hud_soda =        "ui/hud/hud_soda",

	-- logo
	logo =        "ui/logo/logo",
	logo_noshad = "ui/logo/logo_noshad",
	logo_shad =   "ui/logo/logo_shad",

	controls_jetpack = "ui/controls_jetpack",

	toast_left =  "ui/toast_left",
	toast_mid =   "ui/toast_mid",
	toast_right = "ui/toast_right",

	selection_left =  "ui/selection_left",
	selection_mid =   "ui/selection_mid",
	selection_right = "ui/selection_right",
	selection_left_small =  "ui/selection_left_small",
	selection_right_small = "ui/selection_right_small",
	bubble_tip =      "ui/bubble_tip",

	-- ui
	rays = "ui/rays",
	rays_big = "ui/rays_big",
	offscreen_indicator = "ui/offscreen_indicator",
	stomp_arrow = "ui/stomp_arrow",

	sawtooth_separator = "ui/sawtooth_separator",
	sawtooth_separator_small = "ui/sawtooth_separator_small",

	boss_intro_dung_layer0 = "ui/boss_intro/dung/boss_intro_dung_layer0",
	boss_intro_dung_layer1 = "ui/boss_intro/dung/boss_intro_dung_layer1",
	boss_intro_dung_layer2 = "ui/boss_intro/dung/boss_intro_dung_layer2",
	boss_intro_dung_layer3 = "ui/boss_intro/dung/boss_intro_dung_layer3",
	boss_intro_dung_layer4 = "ui/boss_intro/dung/boss_intro_dung_layer4",
	boss_intro_dung_layer5 = "ui/boss_intro/dung/boss_intro_dung_layer5",

	boss_intro_bee_layer0 = "ui/boss_intro/bee_boss/boss_intro_bee_layer0",
	boss_intro_bee_layer1 = "ui/boss_intro/bee_boss/boss_intro_bee_layer1",
	boss_intro_bee_layer2 = "ui/boss_intro/bee_boss/boss_intro_bee_layer2",
	boss_intro_bee_layer3 = "ui/boss_intro/bee_boss/boss_intro_bee_layer3",
	boss_intro_bee_layer4 = "ui/boss_intro/bee_boss/boss_intro_bee_layer4",
	boss_intro_bee_layer5 = "ui/boss_intro/bee_boss/boss_intro_bee_layer5",
	boss_intro_bee_layer6 = "ui/boss_intro/bee_boss/boss_intro_bee_layer6",
	boss_intro_bee_layer7 = "ui/boss_intro/bee_boss/boss_intro_bee_layer7",

	boss_intro_motherboard_layer0 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer0",
	boss_intro_motherboard_layer1 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer1",
	boss_intro_motherboard_layer2 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer2",
	boss_intro_motherboard_layer3 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer3",
	boss_intro_motherboard_layer4 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer4",
	boss_intro_motherboard_layer5 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer5",
	boss_intro_motherboard_layer6 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer6",
	boss_intro_motherboard_layer7 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer7",
	boss_intro_motherboard_layer8 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer8",
	boss_intro_motherboard_layer9 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer9",
	boss_intro_motherboard_layer10 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer10",
	boss_intro_motherboard_layer11 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer11",
	boss_intro_motherboard_layer12 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer12",
	boss_intro_motherboard_layer13 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer13",
	boss_intro_motherboard_layer14 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer14",
	boss_intro_motherboard_layer15 = "ui/boss_intro/motherboard/boss_intro_motherboard_layer15",

	boss_intro_ceo_layer0 = "ui/boss_intro/final_boss/boss_intro_ceo_layer0",
	boss_intro_ceo_layer1 = "ui/boss_intro/final_boss/boss_intro_ceo_layer1",
	boss_intro_ceo_layer2 = "ui/boss_intro/final_boss/boss_intro_ceo_layer2",
	boss_intro_ceo_layer3 = "ui/boss_intro/final_boss/boss_intro_ceo_layer3",
	boss_intro_ceo_layer4 = "ui/boss_intro/final_boss/boss_intro_ceo_layer4",
	boss_intro_ceo_layer5 = "ui/boss_intro/final_boss/boss_intro_ceo_layer5",
	boss_intro_ceo_layer6 = "ui/boss_intro/final_boss/boss_intro_ceo_layer6",
	boss_intro_ceo_layer7 = "ui/boss_intro/final_boss/boss_intro_ceo_layer7",
	boss_intro_ceo_layer8 = "ui/boss_intro/final_boss/boss_intro_ceo_layer8",
	boss_intro_ceo_layer9 = "ui/boss_intro/final_boss/boss_intro_ceo_layer9",
	boss_intro_ceo_layer10 = "ui/boss_intro/final_boss/boss_intro_ceo_layer10",

	boss_intro_rollossus_layer0 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer0",
	boss_intro_rollossus_layer1 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer1",
	boss_intro_rollossus_layer2 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer2",
	boss_intro_rollossus_layer3 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer3",
	boss_intro_rollossus_layer4 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer4",
	boss_intro_rollossus_layer5 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer5",
	boss_intro_rollossus_layer6 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer6",
	boss_intro_rollossus_layer7 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer7",
	boss_intro_rollossus_layer8 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer8",
	boss_intro_rollossus_layer9 = "ui/boss_intro/rollossus/boss_intro_rollossus_layer9",

	boss_intro_ceo_slap0 = "ui/boss_intro/ceo_slap/boss_intro_ceo_slap0",

	player_preview_bg = "ui/player_preview/player_preview_bg",
	player_preview_detail = "ui/player_preview/player_preview_detail",
	player_preview_dotted = "ui/player_preview/player_preview_dotted",

	-----------------------------------------------------
	
	-- effects
	honey_blob = "effects/honey_blob",
	skid_effect = "effects/skid_effect",

	-----------------------------------------------------
	
	-- upgrades
	upgrade_espresso =          "upgrades/upgrade_espresso",
	upgrade_tea =               "upgrades/upgrade_tea",
	upgrade_chocolate =         "upgrades/upgrade_chocolate",
	upgrade_milk =              "upgrades/upgrade_milk",
	upgrade_boba =              "upgrades/upgrade_boba",
	upgrade_energy_drink =      "upgrades/upgrade_energy_drink",
	upgrade_soda =              "upgrades/upgrade_soda",
	upgrade_fizzy_lemonade =    "upgrades/upgrade_fizzy_lemonade",
	upgrade_apple_juice =       "upgrades/upgrade_apple_juice",
	upgrade_hot_sauce =         "upgrades/upgrade_hot_sauce",
	upgrade_coconut_water =     "upgrades/upgrade_coconut_water",
	upgrade_hot_chocolate =     "upgrades/upgrade_hot_chocolate",
	upgrade_pomegranate_juice = "upgrades/upgrade_pomegranate_juice",
	upgrade_gazpacho =          "upgrades/upgrade_gazpacho",
	upgrade_guarana =           "upgrades/upgrade_guarana",
	upgrade_water =             "upgrades/upgrade_water",
	
	-----------------------------------------------------

	-- background
	bg_city_0 =     "level/city_0",
	bg_city_1 =     "level/city_1",
	bg_city_2 =     "level/city_2",
	bg_city_3 =     "level/city_3",
	bg_city_shine = "level/city_shine",

	bg_w1_back_bricks = "level/background/w1/bg_w1_back_bricks",
	bg_w1_bricks = "level/background/w1/bg_w1_bricks",
	bg_w1_beams_close = "level/background/w1/bg_w1_beams_close",
	bg_w1_beams_far = "level/background/w1/bg_w1_beams_far",
	bg_w1_lights = "level/background/w1/bg_w1_lights",
	bg_w1_pipe_1 = "level/background/w1/bg_w1_pipe_1",
	bg_w1_pipe_2 = "level/background/w1/bg_w1_pipe_2",
	bg_w1_rope = "level/background/w1/bg_w1_rope",
	bg_w1_pipe_far_1 = "level/background/w1/bg_w1_pipe_far_1",
	bg_w1_pipe_far_2 = "level/background/w1/bg_w1_pipe_far_2",
	bg_w1_pipe_far_3 = "level/background/w1/bg_w1_pipe_far_3",
	
	bg_element_w1_01 = "level/background/bg_element_w1_01",
	bg_element_w1_02 = "level/background/bg_element_w1_02",
	bg_element_w1_03 = "level/background/bg_element_w1_03",
	bg_element_w1_04 = "level/background/bg_element_w1_04",
	bg_element_w1_05 = "level/background/bg_element_w1_05",
	bg_element_w1_06 = "level/background/bg_element_w1_06",
	bg_element_w1_07 = "level/background/bg_element_w1_07",

	bg_w4_platform_1 = "level/background/w4/bg_w4_platform_1",
	bg_w4_platform_1_back = "level/background/w4/bg_w4_platform_1_back",
	bg_w4_base = "level/background/w4/bg_w4_base",

	bg_walls_w4 = "level/background/bg_walls_w4",

	-----------------------------------------------------
	-- Achievements
	ach_complete_w1 =        "achievements/ach_complete_w1",
	ach_complete_w2 =        "achievements/ach_complete_w2",
	ach_complete_w3 =        "achievements/ach_complete_w3",
	ach_complete_w4 =        "achievements/ach_complete_w4",
	ach_complete_end =       "achievements/ach_complete_end",
	
	ach_death =              "achievements/ach_death",
	ach_all_upgrades =       "achievements/ach_all_upgrades",
	ach_all_skins =          "achievements/ach_all_skins",

	ach_max_hearts =         "achievements/ach_max_hearts",
	ach_no_damage_easy =     "achievements/ach_no_damage_easy",
	ach_no_damage_full =     "achievements/ach_no_damage_full",
	ach_no_floor =           "achievements/ach_no_floor",
	ach_big_combo =          "achievements/ach_big_combo",
	ach_smash_easter_egg =   "achievements/ach_smash_easter_egg",

	ach_secret =             "achievements/ach_secret",

	ach_no_upgrades =        "achievements/ach_no_upgrades",

	achievement_lock =       "achievements/achievement_lock",
	
	-----------------------------------------------------
	
	-- misc
	splash = "splash",

	final_boss_intro_building = "level/final_boss_intro/final_boss_intro_building",
	final_boss_intro_house = "level/final_boss_intro/final_boss_intro_house",

	_test_hexagon = "_test_hexagon",
	_test_hexagon_small = "_test_hexagon_small",
}

-----------------------------------------------------
-- Input buttons

local images = {}
local function load_images()
	local start = love.timer.getTime()
	print("Loading images...")

	images = {}

	for id, path in pairs(img_names) do
		if type(path) == "string" then
			images[id] = load_image(path..".png")

		elseif type(path) == "table" then
			if path[1] == "spritesheet" then
				images[id] = load_spritesheet(path[2]..".png", path[3])
			end

		else
			error("Invalid type for image: "..type(path))
		end
	end

	images.button_fragments = {
		images.button_fragment_1,
		images.button_fragment_2,
		images.button_fragment_3,
		images.button_fragment_4,
		images.button_fragment_5,
	}

	-- Keyboard
	for key_constant, button_image_name in pairs(KEY_CONSTANT_TO_IMAGE_NAME) do
		images[button_image_name] = load_image("buttons/keyboard/"..button_image_name..".png")
	end

	-- Controller
	local function get_button_name(brand, button)
		return string.format("btn_c_%s_%s", brand, button)
	end
	local function load_button_icon(brand, button)
		local name = get_button_name(brand, button)
		local path = string.format("buttons/controller/%s/%s.png", brand, name)
		images[name] = load_image(path)
	end

	local brands = copy_table_deep(CONTROLLER_BRANDS)
	local ps5_index = 0
	for i = 1, #brands do 
		if brands[i] == BUTTON_STYLE_PLAYSTATION5 then
			ps5_index = i
			break
		end
	end
	assert(ps5_index ~= 0, "no PS5 button scheme found")
	table.remove(brands, ps5_index)
	for _, brand in pairs(brands) do
		for button, __ in pairs(CONTROLLER_BUTTONS) do
			load_button_icon(brand, button)
		end
	end

	-- Load PS5 buttons from PS4 ones
	local ps5_buttons = {
		["back"] = true,
		["start"] = true,
		["misc1"] = true,
		["touchpad"] = true,
	}
	for button, _ in pairs(CONTROLLER_BUTTONS) do
		if ps5_buttons[button] then
			load_button_icon(BUTTON_STYLE_PLAYSTATION5, button)
		else
			images[get_button_name(BUTTON_STYLE_PLAYSTATION5, button)] = images[get_button_name(BUTTON_STYLE_PLAYSTATION4, button)]
		end
	end
	images.btn_c_unknown = load_image("buttons/controller/btn_c_unknown.png")

	images.load_images = load_images

	print(concatsep({"Finished loading", table_key_count(images), "images. (", (love.timer.getTime() - start) * 1000 ,"ms)"}))

end

-----------------------------------------------------

load_images()

return images