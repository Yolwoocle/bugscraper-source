require "scripts.util"

local enemies = {
	-- W1
	Larva =              require "scripts.actor.enemies.larva",
	Fly =                require "scripts.actor.enemies.fly",
	SpikedFly =          require "scripts.actor.enemies.spiked_fly",
	Woodlouse =          require "scripts.actor.enemies.woodlouse",
	Slug =               require "scripts.actor.enemies.slug",
	Spider =             require "scripts.actor.enemies.spider",
	StinkBug =           require "scripts.actor.enemies.stink_bug",
	SnailShelled =       require "scripts.actor.enemies.snail_shelled", 
	Boomshroom =         require "scripts.actor.enemies.boomshroom", 
	Dung =               require "scripts.actor.enemies.dung",
	DungBeetle =         require "scripts.actor.enemies.dung_beetle",
	DungProjectile =     require "scripts.actor.enemies.dung_projectile",
	FlyingDung =         require "scripts.actor.enemies.flying_dung",
	
	-- W2
	Bee =                require "scripts.actor.enemies.bee",
	Beelet =             require "scripts.actor.enemies.beelet", 
	Stabee =             require "scripts.actor.enemies.stabee", 
	DrillBee =           require "scripts.actor.enemies.drill_bee", 
	DrillBeeMinion =     require "scripts.actor.enemies.drill_bee_minion", 
	Comball =            require "scripts.actor.enemies.comball", 
	HoneypotAnt =        require "scripts.actor.enemies.honeypot_ant",
	TimedSpikes =        require "scripts.actor.enemies.timed_spikes",
	FlyingSpawner =      require "scripts.actor.enemies.flying_spawner",
	LarvaSpawner =       require "scripts.actor.enemies.larva_spawner", --*
	BeeBoss =            require "scripts.actor.enemies.bee_boss",
	BeeBossRework =      require "scripts.actor.enemies.bee_boss_rework",
	HerMajesty =         require "scripts.actor.enemies.her_majesty",
	HoneyPatch =         require "scripts.actor.enemies.honey_patch",

	-- W3
	ElectricArc =        require "scripts.actor.enemies.electric_arc", 
	ElectricRays =       require "scripts.actor.enemies.electric_rays", 
	ElectricBullet =     require "scripts.actor.enemies.electric_bullet", 
	SnailShelledBouncy = require "scripts.actor.enemies.snail_shelled_bouncy", 
	Grasshopper =        require "scripts.actor.enemies.grasshopper", 
	Chipper =            require "scripts.actor.enemies.chipper",  
	ChipperMinion =      require "scripts.actor.enemies.chipper_minion",  
	MetalFly =           require "scripts.actor.enemies.metal_fly",
	BulbBuddy =          require "scripts.actor.enemies.bulb_buddy", 
	Motherboard =        require "scripts.actor.enemies.motherboard",
	Pendulum =           require "scripts.actor.enemies.pendulum",  
	MotherboardButton =  require "scripts.actor.enemies.motherboard_button",
	BigBeelet =          require "scripts.actor.enemies.big_beelet",

	-- W4
	WallWalker =         require "scripts.actor.enemies.wall_walker", 
	MushroomAnt =        require "scripts.actor.enemies.mushroom_ant", 
	CloudEnemy =         require "scripts.actor.enemies.cloud_enemy",
	CloudDropper =       require "scripts.actor.enemies.cloud_dropper",
	CloudDropperParticle = require "scripts.actor.enemies.cloud_dropper_projectile",
	CloudStorm =         require "scripts.actor.enemies.cloud_storm",
	CloudStormZone =     require "scripts.actor.enemies.cloud_storm_zone",
	Rollopod =           require "scripts.actor.enemies.rollopod", --*
	Centipede =          require "scripts.actor.enemies.centipede", 
	Shooter =            require "scripts.actor.enemies.shooter", 
	GoldenBeetle =       require "scripts.actor.enemies.golden_beetle", --*
	ArumTitanBoss =      require "scripts.actor.enemies.arum_titan_boss", 
	ArumTitanMinion =    require "scripts.actor.enemies.arum_titan_minion", 
	CentipedeBoss =      require "scripts.actor.enemies.centipede_boss", 
	Mole =               require "scripts.actor.enemies.mole", 
	Rollossus =           require "scripts.actor.enemies.rollossus", 
	RollossusMinion =     require "scripts.actor.enemies.rollossus_minion", 
	MoleMinion =         require "scripts.actor.enemies.mole_minion", 

	-- W5 	
	FinalBoss =          require "scripts.actor.enemies.final_boss",
	FinalBossMinion =    require "scripts.actor.enemies.final_boss_minion",
	
	-- Unused
	ProgressingArc =     require "scripts.actor.enemies.progressing_arc", 
	FloorHoleSpawner =   require "scripts.actor.enemies.floor_hole_spawner", 
	BigBug =             require "scripts.actor.enemies.big_bug", --*
	Slime =              require "scripts.actor.enemies.slime", --*
	Frog =               require "scripts.actor.enemies.frog", --*
	SwitchBug =          require "scripts.actor.enemies.switch_bug", --*
	W2boss =             require "scripts.actor.enemies.w2boss", --*
	RainbowButterfly =   require "scripts.actor.enemies.rainbow_butterfly", --*
	SquidMother =        require "scripts.actor.enemies.squid_mother", --*
	SquidChild =         require "scripts.actor.enemies.squid_child", --*
	WalkingSlotMachine = require "scripts.actor.enemies.walking_slot_machine", --*
	
	-- Misc
	StaticProp =         require "scripts.actor.enemies.static_prop",
	JumpingProp =        require "scripts.actor.enemies.jumping_prop",
	Dummy =              require "scripts.actor.enemies.dummy",
	InvisibleDummy =     require "scripts.actor.enemies.invisible_dummy",
	NPC =                require "scripts.actor.enemies.npc",

	BossDoor =           require "scripts.actor.enemies.boss_door",
	BreakableWall =      require "scripts.actor.enemies.breakable_wall",
	ButtonBigPressed =   require "scripts.actor.enemies.button_big_pressed",
	ButtonBig =          require "scripts.actor.enemies.button_big",
	ButtonBigGlass =     require "scripts.actor.enemies.button_big_glass",
	ButtonSmallGlass =   require "scripts.actor.enemies.button_small_glass",
	ButtonSmall =        require "scripts.actor.enemies.button_small",
	ButtonSmallRocket =  require "scripts.actor.enemies.button_small_rocket",
	ExitSign =           require "scripts.actor.enemies.exit_sign",
	UpgradeDisplay =     require "scripts.actor.enemies.upgrade_display",
	HeartJar =           require "scripts.actor.enemies.heart_jar",
	GunDisplay =         require "scripts.actor.enemies.gun_display",
	VendingMachine =     require "scripts.actor.enemies.vending_machine.vending_machine",
	WaterDispenser =     require "scripts.actor.enemies.vending_machine.water_dispenser",
	Clock =              require "scripts.actor.enemies.clock",
	PlayerTrigger =      require "scripts.actor.enemies.player_trigger",
	Shop =               require "scripts.actor.enemies.shop",
	ShopCafeteria =      require "scripts.actor.enemies.shop_cafeteria",
	ShopVendingMachine = require "scripts.actor.enemies.shop_vending_machine",
	
	Cocoon =             require "scripts.actor.enemies.cocoon",

	PoisonCloud =        require "scripts.actor.enemies.poison_cloud",
	PongBall =           require "scripts.actor.enemies.pong_ball",
	Explosion =          require "scripts.actor.enemies.explosion",
}

return enemies