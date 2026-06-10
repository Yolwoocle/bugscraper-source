local Actor = require "scripts.actor.actor"
local guns = require "data.guns"
local Enemies = require "data.enemies"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images = require "data.images"
local ui = require "scripts.ui.ui"
require "scripts.util"
require "scripts.meta.constants"
local Loot = require "scripts.actor.loot"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local guns         = require "data.guns"
local Timer = require "scripts.timer"
local shaders      = require "data.shaders"

local Player = Actor:inherit()

function Player:init(n, x, y, skin)
	n = n or 1
	x = x or 0
	y = y or 0
	self:init_actor(x, y, 14, 14, images.ant1)

	self:set_constant_sound("sfx_wall_slide", "sfx_player_wall_slide_metal_{01-02}")

	self:reset(n, skin)
	self.wall_collision_box = { --Move this to a seperate class if needed
		x = self.x,
		y = self.y,
		w = self.w + self.wall_jump_margin*2,
		h = self.h,
	}
	Collision:add(self.wall_collision_box)


	local old_filter = self.collision_filter
	self.collision_filter = function(item, other)
		if self.is_ghost and other.is_actor then
			return false
		end
		return old_filter(item, other)
	end

	self.state_machine = self:get_state_machine()
end

function Player:reset(n, skin)
	n = self.n or n
	skin = self.skin or skin

	self.is_player = true
	self.is_being = true
	self.name = concat("player", n)

	self.z = -100

	-- Meta
	self.n = n
	self.is_enemy = false

	-- Life
	self.max_life = 4
	self.life = self.max_life
	self.temporary_life = 0
	
	-- Death
	self.is_dead = false

	-- Input
	self.input_mode = PLAYER_INPUT_MODE_USER
	self.virtual_controller = {
		actions = {}
	}
	local mappings = Input:get_input_profile_from_player_n(self.n).mappings
	for action, _ in pairs(mappings) do
		self.virtual_controller.actions[action] = false
	end
	self.code_input_mode_target_x = nil
	self.input_mode_code_target_x_margin = 8
	self.do_chaotic_inputs = false
	
	-- Animation
	self.color_palette = skin.color_palette
	self.skin = skin
	self.spr = AnimatedSprite:new({
		idle = skin.anim_idle,
		walk_down = {skin.img_walk_down},
		airborne = {skin.img_airborne},
		wall_slide = skin.anim_wall_slide,
		dead = {skin.img_dead},
	}, "idle", SPRITE_ANCHOR_CENTER_BOTTOM)

	self.can_move_360 = false
	self.is_grounded = true
	self.is_walking = false
	self.squash = 1
	self.jump_squash = 1
	self.walkbounce_oy = 0
	self.walkbounce_t = 0
	self.walkbounce_squash = 0
	self.bounce_vy = 0
	self.old_bounce_vy = 0

	self.walk_timer = 0

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.dir_x = 1
	self.dir_y = 0
	
	-- Speed 
	self.speed = 50 --This is acceleration not speed but I'm too lazy to change now
	self.speed_mult = 1.0

	self.is_visible = true
	self.gravity_cap = self.default_gravity_cap

	-- Jump
	self.default_gravity = 40
	self.gravity_mult = 1.0

	self.can_do_midair_jump = false
	self.max_jumps = 1
	self.jumps = self.max_jumps
	self.jump_speed = 455 -- NE PAS TOUCHER CA FAIT 5 BLOCS EXACTMEENT MERCI GASPARD DELPIANO--MANFRINI POUR CET AJOUT NECESSAIRE
	self.jump_speed_mult = 1.0
	self.buffer_jump_timer = 0
	self.max_buffer_jump_timer = 8
	self.coyote_time = 0
	self.default_coyote_time = 6
	self.stomp_jump_speed = 500

	self.can_hold_jump_to_float = false
	self.is_floating = false
	self.float_speed = 60
	self.float_max_duration = 3
	self.float_timer = 0

	-- Air time
	self.air_time = 0
	self.jump_air_time = 0.3
	self.air_jump_force = 22

	self.frames_since_land = 0

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 30
	self.is_wall_sliding = false
	self.wall_slide_particle_timer = 0
	self.wall_slide_max_stamina = 7.0
	self.wall_slide_stamina = 0
	self.wall_slide_stamina_use_slide = 1.0
	self.wall_slide_stamina_use_jump = 1.0
	self.wall_slide_sweat_timer = Timer:new(0.7, {loopback = true}):start()

	self.old_stamina_blinking_state = 1 -- 1: off, 2: low, 3: very_low
	self.stamina_blinking_state = 1

	self.wall_jump_margin = 8

	-- Visuals
	self.color = ({COL_RED, COL_GREEN, COL_DARK_RED, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED

	-- Invicibility
	self.is_invincible = false
	self.invincible_time = 0
	self.def_max_invincible_time = 3
	self.max_invincible_time = self.def_max_invincible_time

	self.blink_default_freq = 0.2
	self.blink_freq = 0.2
	self.blink_timer = 0
	self.blink_color = nil

	-- Shooting & guns (keep it or ditch for family friendliness?)	
	self.is_shooting = false
	self.shoot_dir_x = 1
	self.shoot_dir_y = 0
	self.shoot_ang = 0
	self.gun_cooldown_multiplier = 1.0
	self.max_ammo_multiplier = 1.0
	self.ammo_usage_multiplier = 1.0
	self.gun_damage_multiplier = 1.0
	self.gun_reload_speed_multiplier = 1.0
	self.gun_natural_recharge_speed_multiplier = 1.0
	self.ammo_bar_icon = images.ammo
	self.ammo_bar_fill_color = COL_MID_BLUE
	self.ammo_bar_shad_color = COL_DARK_BLUE
	self.ammo_percent_gain_on_stomp = 0
	
	self:equip_gun(guns.unlootable.Machinegun:new())
	-- FOR DEBUGGING
	self.guns = {
		guns.unlootable.Machinegun:new(self),
		guns.unlootable.DebugGun:new(self),
		guns.unlootable.EmptyGun:new(self),
		guns.unlootable.ResignationLetter:new(self),
		guns.Triple:new(self),
		guns.Burst:new(self),
		guns.Shotgun:new(self),
		guns.Minigun:new(self),
		guns.MushroomCannon:new(self),
		guns.Ring:new(self),
	}
	self.gun_number = 1

	self.is_dead = false

	-- UI
	self.show_hud = true
	self.ui_x = self.x
	self.ui_y = self.y
	self.ui_col_gradient = 0
	self.controls_oy = 0

	self.is_in_menu = false

	-- SFX
	self:stop_constant_sounds()

	self.sfx_wall_slide_volume = 0.0
	self.sfx_wall_slide_max_volume = 1.0
	self.walk_sfx_volume = 1.0
	self:set_constant_sound_volume("sfx_wall_slide", 0)

	-- Combo / fury
	self.fury_stomp_value = 0.8 -- How much is added to the fury bar when stomping an enemy
	self.fury_bullet_damage_value_multiplier = 0.18  -- Percentage of the bullet damage that is added to the fury bar when hitting an enemy 
	self.fury_gun_cooldown_multiplier = 0.8
	self.fury_gun_cooldown_multiplier_extra = {}
	self.fury_gun_damage_multiplier = 1.5
	self.fury_speed_mult = 1.3

	self.do_fury_trail = true

	-- Upgrades
	self.upgrades = {}

	-- Misc
	self.is_affected_by_bounds = true
	self.is_affected_by_walls = true
	self.is_vulnerable_to_kill_zone = true

	-- Bloodthirst
	-- After taking damage, kill some enemies to regain HP
	self.bloodthirst_enabled = false
	self.bloodthirst_active = false
	self.bloodthirst_timer = Timer:new(5.0)
	self.bloodthirst_blood = 0.0
	self.bloodthirst_blood_threshold = 5.0

	-- Effects
	self.effects = {}
	self.poison_cloud = nil
	self.poison_timer = 0.0
	self.poison_damage_time = 0.6

	self.spawn_explosion_on_damage = false

	-- Multiplayer 
	self.is_ghost = false
	self.ghost_opacity = 0.7
	self.waves_until_respawn = 3
	
	self.friction_x = self.default_friction
	self.speed_mult = 1

	-- Debug 
	self.debug_god_mode = false
	self.dt = 1
	self.frame = 0
end

function Player:get_state_machine()
	local m = StateMachine:new({
		normal = {
			enter = function(state)
				self:reset()
				
				self.is_ghost = false
				self.show_gun = true
				self.show_hud = true

				self.gravity = self:get_total_gravity()
				self.can_move_360 = false

				self.friction_x = self.default_friction
				self.friction_y = 1
				self.speed_mult = 1

				self.is_invincible = false
			end,
			update = function(state, dt)
				self:update_upgrades(dt)
				self:update_effects(dt)
				local dir = self:get_movement_dir()
				self:move(dir, dt)
				self.is_affected_by_semisolids = not self:action_pressed("down")
				self:do_wall_sliding(dt)
				self:update_jumping(dt)
				self:do_floating(dt)
				Player.super.update(self, dt)

				self:do_aiming(dt)
				self:update_mid_position()
				self.is_walking = self.is_grounded and abs(self.vx) > 50
				self:do_invincibility(dt)
				self:update_poison(dt)

				self.gun:update(dt)
				self:shoot(dt, false)
				self:update_gun_pos(dt)
			end,
			on_grounded = function(state)
				self:on_grounded_normal()
				self:stop_constant_sounds()
			end
		},
		dying = {
			enter = function(state)
				self:reset()
				self:stop_constant_sounds()

				self.is_ghost = true

				self.show_hud = false
				self.show_gun = false

				self.gravity = 0
				self.can_move_360 = true
				self.speed_mult = 0
				
				self.speed_mult = 0
				self.ghost_opacity = 1

				state.death_y = self.y
				state.death_oy = 0

				Input:vibrate(self.n, 0.6, 0.4)
				game:screenshake(10)
				game:frameskip(30)

				self.timer_before_death = self.max_timer_before_death
				self:play_sound("sfx_player_death_intro")
			end,
			update = function(state, dt)
				local goal_r = 5*sign(self.dir_x)*pi2
				self.spr:set_rotation(lerp(self.spr.rot, goal_r, 0.06))
				self.spr:set_animation("dead")

				state.death_oy = lerp(state.death_oy, 40, 0.05)
				self:set_position(self.x, state.death_y - state.death_oy)

				if abs(self.spr.rot - goal_r) < 0.1 then
					game:screenshake(10)
					Input:vibrate_all(0.3, 0.5)
					
					self:play_sound("sfx_player_death_punch")

					Particles:splash(self.mid_x, state.death_y - state.death_oy + self.h/2, 40, {COL_LIGHT_YELLOW, COL_ORANGE, COL_LIGHT_RED, COL_WHITE})
					Particles:star_splash(self.mid_x, state.death_y-state.death_oy + self.h/2)
					
					return "ghost"
				end
			end,
		},
		ghost = { 
			enter = function(state)
				self:reset()

				self.is_ghost = true
				self.show_gun = false
				self.show_hud = false
				self.speed_mult = 1
				self.ghost_opacity = 0.7
				
				self.gravity = 0
				self.can_move_360 = true
				self.is_affected_by_semisolids = false

				self.is_invincible = true
				self:equip_gun(guns.unlootable.GhostGun:new(self))

				self.spr:set_color({1,1,1,0.7})
				self.spr:set_rotation(0)
				self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

				state.is_spinning = false
				state.goal_r = nil
				state.spin_effect_spr = AnimatedSprite:new({normal = {images.spin_whoosh_sheet, 5, 0.05}}, "normal") 
			end,
			update = function(state, dt)
				self.friction_x = self.default_friction
				self.friction_y = self.default_friction
				
				if game.game_state ~= GAME_STATE_DYING then
					self.gun:update(dt)
					self:shoot(dt, false)
				end
				
				local dir = self:get_movement_dir()
				self:move(dir, dt)
				Player.super.update(self, dt)

				if self:action_pressed("jump") and not state.is_spinning then
					state.is_spinning = true
					state.goal_r = pi2 * self.dir_x
					Particles:spin_whoosh(self.mid_x, self.mid_y, self.dir_x > 0, self)
				end

				if state.is_spinning then
					self.spr:set_rotation(lerpmax(self.spr.rot, state.goal_r, 0.1, 0.3))
					if abs(self.spr.rot - state.goal_r) < 0.15 then
						state.is_spinning = false
						state.goal_r = nil
						self.spr:set_rotation(0)
					end
				end
			end,
		}
	}, "normal")

	return m
end

function Player:update(dt)
	self.dt = dt
	self.frame = self.frame + 1
	
	self:update_virtual_inputs(dt)
	self.state_machine:update(dt)
	
	self:animate_walk(dt)
	self:update_color(dt)
	self:update_sprite(dt)
	self:do_particles(dt)
	self:update_visuals()
	self:update_achievements(dt)
	self:update_bloodthirst(dt)

	if self.life <= 0 and not (self.is_killed or self.is_ghost) then
		self:start_ghost()
	end
	
	if self.is_grounded then
		self.frames_since_land = self.frames_since_land + 1
	else
		self.frames_since_land = 0
	end

	self.ui_x = lerp(self.ui_x, floor(self.mid_x), 0.2)
	self.ui_y = lerp(self.ui_y, floor(self.y), 0.2)

	-- MISC
	self.flag_has_jumped_on_current_frame = false
end

------------------------------------------
--- Input ---

function Player:set_input_mode(mode)
	self.input_mode = mode
	if mode == PLAYER_INPUT_MODE_USER then
		self:reset_virtual_controller()
	end
end

function Player:set_code_input_mode_target_x(x, target_x_reached_callback)
	self.code_input_mode_target_x = x
	self.target_x_reached_callback = target_x_reached_callback
end

function Player:is_near_code_input_mode_target_x()
	return math.abs(self.x - self.code_input_mode_target_x) <= self.input_mode_code_target_x_margin
end

function Player:update_chaotic_inputs(dt)
	if not self.do_chaotic_inputs then
		return
	end

	self.input_mode = PLAYER_INPUT_MODE_CODE
	if random_range(0, 1) < 0.05 then
		self.virtual_controller.actions["left"] = not self.virtual_controller.actions["left"]
	end
	if random_range(0, 1) < 0.05 then
		self.virtual_controller.actions["right"] = not self.virtual_controller.actions["right"]
	end
	if random_range(0, 1) < 0.05 then
		self.virtual_controller.actions["jump"] = not self.virtual_controller.actions["jump"]
	end
	if random_range(0, 1) < 0.05 then
		self.virtual_controller.actions["shoot"] = not self.virtual_controller.actions["shoot"]
	end
	if self.gun.is_reloading then
		self.virtual_controller.actions["shoot"] = false
	end
end

function Player:update_virtual_inputs(dt)
	self:update_chaotic_inputs(dt)

	if self.code_input_mode_target_x then
		self.virtual_controller.actions["left"] = false
		self.virtual_controller.actions["right"] = false
		if self.x < self.code_input_mode_target_x - self.input_mode_code_target_x_margin then
			self.virtual_controller.actions["right"] = true
		elseif self.code_input_mode_target_x + self.input_mode_code_target_x_margin < self.x then
			self.virtual_controller.actions["left"] = true
		else 
			self.dir_x = 1
		end

		if self:is_near_code_input_mode_target_x() and self.target_x_reached_callback then
			self.target_x_reached_callback(self)
			self:set_code_input_mode_target_x(nil)
		end
	end
end

function Player:reset_virtual_controller()
	for action, _ in pairs(self.virtual_controller.actions) do
		self.virtual_controller.actions[action] = false
	end
end

function Player:action_down(action, force_test_for_user_input_mode)
	if self.input_mode == PLAYER_INPUT_MODE_USER or force_test_for_user_input_mode then
		return Input:action_down(self.n, action)

	elseif self.input_mode == PLAYER_INPUT_MODE_CODE then
		return self.virtual_controller.actions[action]

	end
end

function Player:action_pressed(action, force_test_for_user_input_mode)
	if self.input_mode == PLAYER_INPUT_MODE_USER or force_test_for_user_input_mode then
		return Input:action_pressed(self.n, action)

	elseif self.input_mode == PLAYER_INPUT_MODE_CODE then
		-- I haven't implemented this feature yet (using action_pressed via code), so this is good enough for now.  
		return self:action_down(action)

	end
end


------------------------------------------
--- Life ---

function Player:set_player_n(n)
	self.n = n
end

function Player:get_total_life()
	return self.life + self.temporary_life
end

function Player:set_life(val)
	self.life = clamp(val, 0, self.max_life)
end

function Player:heal(val)
	local overflow = self.max_life - (self.life + val)
	if overflow >= 0 then
		self.life = self.life + val
		return true
	else
		self.life = self.max_life
		return false, -overflow
	end
end

function Player:add_max_life(val)
	self.max_life = self.max_life + val
end

function Player:add_temporary_life(val)
	self.temporary_life = self.temporary_life + val
end

function Player:do_invincibility(dt)
	self.invincible_time = max(0, self.invincible_time - dt)

	self.is_invincible = false
	if self.invincible_time > 0 and game.frames_to_skip <= 0 then
		self.is_invincible = true

		self.blink_freq = (self.invincible_time > 1) and self.blink_default_freq or self.blink_default_freq/2
	end
end

function Player:set_invincibility(n)
	self.invincible_time = math.max(n, self.invincible_time)
end

function Player:start_ghost()
	self.state_machine:set_state("dying")
	game:on_player_ghosted(self)
end

function Player:kill()
	if self.is_dead then return end
	if self.debug_god_mode then
		return 
	end
	
	Input:vibrate(self.n, 0.6, 0.4)
	game:screenshake(10)
	game:frameskip(30)

	local ox, oy = self.spr:get_total_centered_offset_position(self.x, self.y, self.w, self.h)
	Particles:dead_player(ox, oy, self.skin.img_dead, self.color_palette, self.dir_x)

	self:on_death()
	game:on_kill(self)
	
	self.timer_before_death = self.max_timer_before_death
	self:play_sound("sfx_player_death")

	self.is_dead = true
	self:remove()
end

function Player:on_death()
	
end

function Player:on_removed()
	Collision:remove(self.wall_collision_box)
end

function Player:do_damage(n, source)
	if self.debug_god_mode then
		return false
	end
	if self.state_machine.current_state_name ~= "normal" then
		return false
	end
	if self.invincible_time > 0 then
		return false
	end
	if n <= 0 then
		return false
	end

	game:frameskip(12)
	game:screenshake(7)
	Input:vibrate(self.n, 0.3, 0.45)

	local damage_sfx = "sfx_player_damage_normal"
	if source then
		if source.name == "poison_cloud" then
			damage_sfx = "sfx_player_damage_poison"
		elseif source.name == "timed_spikes" then
			damage_sfx = "sfx_enemy_timed_spikes_hit_{01-05}"	
			self:play_sound("sfx_player_damage_normal")
		end
	end
	self:play_sound(damage_sfx)
	-- Particles:word(self.mid_x, self.y, concat("-",n), COL_LIGHT_RED)
	
	if self.is_knockbackable and source then
		self.vx = self.vx + sign(self.mid_x - source.mid_x)*source.knockback
		self.vy = self.vy - 50
	end

	local old_life = self.life
	local old_temporary_life = self.temporary_life
	self:subtract_life(n)
	local temporary_life_diff = old_temporary_life - self.temporary_life
	if temporary_life_diff > 0 then
		Particles:image(self.ui_x, self.ui_y - 16, temporary_life_diff, images.particle_leaf, 5, 1.5, 0.6, 0.5)
	end
	
	self:set_invincibility(self.max_invincible_time)
	game:on_player_damage(self, n, source)

	local died = false
	if self.life <= 0 then
		self.life = 0 
		self:start_ghost()
		died = true
	end

	self.spr:set_animation("dead")

	-- Star effect
	Particles:push_layer(PARTICLE_LAYER_BACK)
	local a = (source ~= nil) and 
		(get_angle_between_vectors(self.mid_x, self.mid_y, (source.mid_x or source.x), (source.mid_y or source.y))) or
		(random_range(0, pi2))
	local scale = ternary(died, 0.8, 0.5)
	local color = self.color_palette[1]
	if source and source.name == "poison_cloud" then
		color = COL_LIGHT_YELLOW
	end
	Particles:static_image(images.star_big, self.mid_x, self.mid_y, a, 0.05, scale*1.3, {
		color = COL_WHITE
	})
	Particles:static_image(images.star_big, self.mid_x, self.mid_y, a, 0.05, scale, {
		color = color
	})
	Particles:pop_layer()

	Particles:floating_image({
		images.star_small_1,
		images.star_small_2,
	}, self.mid_x, self.mid_y, random_range_int(5, 7), 0, 0.5, 1, 120, 0.95, {ignore_frameskip = true})
	-- x, y, amount, rot, life, scale, vel, friction, params

	self:apply_effect_on_damage()
	
	if source then
		self.last_damage_source_name = source.name
	end
	
	return true
end

function Player:apply_effect_on_damage()
	self:remove_water_upgrade()

	if self.spawn_explosion_on_damage then
		local explosion = Explosion:new(self.mid_x, self.mid_y, {
			explosion_damage = 0,
			color_gradient = {COL_PURPLE, COL_LIGHT_RED, COL_DARK_RED, COL_DARK_PURPLE},
			safe_margin = 0,
			radius = 42,
		})
		game:new_actor(explosion)

		Particles:image(self.mid_x, self.mid_y, 30, {images.pomegranate_piece_1, images.pomegranate_piece_2, images.pomegranate_piece_3}, 4, nil, nil, nil, {
			vx1 = -150,
			vx2 = 150,
	
			vy1 = 80,
			vy2 = -200,
		})
	end

	if self.bloodthirst_enabled then
		self:start_bloodthirst()
	end
end

function Player:remove_water_upgrade()
	for i, upgrade in pairs(self.upgrades) do 
		if upgrade.name == "water" then
			game:revoke_upgrade(i)
			return
		end
	end
end

function Player:subtract_life(n)
	if self.temporary_life > 0 then
		self.temporary_life = self.temporary_life - n
		n = math.max(0, -self.temporary_life)
		self.temporary_life = math.max(0, self.temporary_life)
	end

	self.life = self.life - n
	self.life = math.max(0, self.life)
end


------------------------------------------
--- Physics ---

function Player:get_total_gravity()
	return self.default_gravity * self.gravity_mult
end

function Player:get_movement_dir(blocked)
	if blocked then
		return {x=0, y=0}
	end
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:action_down('left') then       dir.x = dir.x - 1   end
	if self:action_down('right') then      dir.x = dir.x + 1   end
	if self.debug_god_mode or self.can_move_360 then
		if self:action_down('up') then     dir.y = dir.y - 1   end
		if self:action_down('down') then   dir.y = dir.y + 1   end
	end
	if dir.x == 0 and dir.y == 0 then
		return dir
	end

	dir.x, dir.y = normalize_vect(dir.x, dir.y)

	if dir.x ~= 0 then
		self.dir_x = dir.x
	end

	return dir
end

function Player:move(dir, dt)
	-- Apply velocity 
	self.vx = self.vx + dir.x * self:get_speed()
	self.vy = self.vy + dir.y * self:get_speed()
end

function Player:get_speed()
	local v = self.speed
	v = v * self.speed_mult
	if game.level.fury_active then
		v = v * self.fury_speed_mult
	end

	return v
end

function Player:do_wall_sliding(dt)
	-- Check if wall sliding
	local old_is_wall_sliding = self.is_wall_sliding
	local old_is_walled = self.is_walled
	self.is_wall_sliding = false
	self.is_walled = false

	-- Reset wall sliding stamina if grounded
	if self.is_grounded then
		self.wall_slide_stamina = self.wall_slide_max_stamina
	end

	-- Update wall variables
	if self.wall_col then
		local col_normal = self.wall_col.normal
		local is_walled = (col_normal.y == 0)
		local is_falling = (self.vy > 0)
		local holding_left = self:action_down('left') and col_normal.x == 1
		local holding_right = self:action_down('right') and col_normal.x == -1
		
		local is_wall_sliding = 
			is_walled and is_falling 
			and (holding_left or holding_right) 
			and self.wall_col.other.collision_info 
			and self.wall_col.other.collision_info.is_slidable
			and self.wall_slide_stamina > 0
		self.is_wall_sliding = is_wall_sliding
		self.is_walled = is_walled
	end

	-- Reduce jumps if leave wall 
	if old_is_walled and not self.is_walled then
		self.jumps = math.max(0, self.jumps-1)
		self:remove_constant_sound("sfx_wall_slide")
	end

	-- If just started wall sliding 
	if not old_is_wall_sliding and self.is_wall_sliding and self.wall_col and self.wall_col.other.collision_info then
		self:set_constant_sound("sfx_wall_slide", self.wall_col.other.collision_info.slide_sound)
	end
	self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, 0, 0.3)
	self:set_constant_sound_volume("sfx_wall_slide", self.sfx_wall_slide_volume)

	-- Perform wall sliding
	if self.is_wall_sliding then
		-- Orient player opposite if wall sliding
		self.dir_x = self.wall_col.normal.x
		self.shoot_dir_x = self.wall_col.normal.x
	
		-- Slow down descent
		self.gravity = 0
		self.vy = self.wall_slide_speed

		-- Particles
		self.wall_slide_particle_timer = self.wall_slide_particle_timer + 1
		if self.wall_slide_particle_timer % 1 == 0 then
			Particles:dust(self.mid_x + (self.w/2) * -self.dir_x, self.y)
		end

		-- SFX
		self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, self.sfx_wall_slide_max_volume, 0.3)
		self:set_constant_sound_volume("sfx_wall_slide", self.sfx_wall_slide_volume)

		-- Stamina
		local old_stamina = self.wall_slide_stamina
		self.wall_slide_stamina = self.wall_slide_stamina - dt*self.wall_slide_stamina_use_slide

		-- Effects
		if self.wall_slide_stamina >= self.wall_slide_max_stamina/2 and self.wall_slide_sweat_timer.duration ~= 0.6 then
			self.wall_slide_sweat_timer:start(0.6)
		end
		if self.wall_slide_stamina < self.wall_slide_max_stamina/2 and self.wall_slide_sweat_timer.duration ~= 0.2 then
			self.wall_slide_sweat_timer:start(0.2)
		end
		if self.wall_slide_sweat_timer:update(dt) then
			Particles:sweat(self.mid_x + self.dir_x * 12, self.y, self.dir_x < 0)
		end
	else
		self.gravity = self:get_total_gravity()
	end
end


local removeme_n = 0
function Player:update_jumping(dt)
	-- self.debug_values[1] = concat(self.jumps, "/", self.max_jumps)
	-- Update number of jumps
	if self.is_grounded or self.is_wall_sliding then
		self.jumps = self.max_jumps
	end 

	-- This buffer is so that you still jump even if you're a few frames behind
	self.buffer_jump_timer = self.buffer_jump_timer - 1
	if self:action_pressed("jump") then
		removeme_n = removeme_n + 1

		self.buffer_jump_timer = self.max_buffer_jump_timer
	end

	-- Update air time (I think that is used to make you jump higher when holding jump)
	self.air_time = self.air_time + dt
	if self.is_grounded then self.air_time = 0 end
	if self.air_time < self.jump_air_time and not self.is_grounded then
		if self:action_down("jump") then
			self.vy = self.vy - self.air_jump_force
		end
	end

	-- Coyote time
	self.coyote_time = self.coyote_time - 1

	if self.buffer_jump_timer > 0 then
		-- Detect nearby walls using a collision box
		local wall_normal = self:get_nearby_wall()

		if self.is_grounded or self.coyote_time > 0 then 
			-- Regular jump
			self:jump(dt)
			self:on_jump()
		
		elseif wall_normal then
			-- Conditions for a wall jump ("wall kick")
			local left_jump  = (wall_normal.x == 1) and self:action_down("right")
			local right_jump = (wall_normal.x == -1) and self:action_down("left")
			
			-- Conditions for a wall jump used for climbing, while sliding ("wall climb")
			local wall_climb = self.is_wall_sliding

			if (self.wall_slide_stamina > 0) and (left_jump or right_jump or wall_climb) then
				self:wall_jump(wall_normal)
				self:on_jump()

				self.wall_slide_stamina = self.wall_slide_stamina - self.wall_slide_stamina_use_jump
			end
				
		elseif not self.is_grounded and (self.jumps > 0) then 
			-- Midair jump
			self:jump(dt, 1.2)
			self.jumps = math.max(0, self.jumps - 1)
			self:on_jump()
			
			Particles:smoke(self.mid_x, self.y+self.h, 15, {COL_MID_BROWN, COL_DARK_BROWN})
			Particles:bubble_fizz_cloud(self.mid_x, self.y+self.h, 8, 10)
		end
	end
end

function Player:do_floating(dt)
	self.is_floating = false
	if not self.can_hold_jump_to_float then
		return
	end
	if self.is_grounded or self.is_wall_sliding then
		self.float_timer = self.float_max_duration
		return
	end

	if self.float_timer > 0 then
		self.float_timer = math.max(0, self.float_timer - dt)
		if self.vy > 0 and self:action_down("jump") then
			self.is_floating = true

			self.gravity = 0
			self.vy = self.float_speed
			Particles:smoke(self.mid_x, self.y+self.h, 1, transparent_color(COL_LIGHT_YELLOW, 1))
			Particles:bubble_fizz_cloud(self.mid_x, self.y+self.h, 8, 1)
		end
	end
end

function Player:on_grounded_state_change(new_state)
	-- When player has just left the grounded 
	if not new_state then
		self.jumps = math.max(0, self.jumps - 1)
	end
end

function Player:get_nearby_wall()
	-- Returns whether the player is near a wall on its side
	-- This does not count floor and ceilings
	local null_filter = function()
		return "cross"
	end
	
	local box = self.wall_collision_box
	box.x = self.x - self.wall_jump_margin
	box.y = self.y - self.wall_jump_margin
	box.w = self.w + self.wall_jump_margin*2
	box.h = self.h + self.wall_jump_margin*2
	Collision:update(box)
	
	local x,y, cols, len = Collision:move(box, box.x, box.y, null_filter)
	for _,col in pairs(cols) do
		if col.normal.y == 0 and col.other.collision_info and col.other.collision_info.type == COLLISION_TYPE_SOLID then 
			return col.normal	
		end
	end

	return false
end

function Player:jump(dt, multiplier)
	self.vy = -self.jump_speed * self.jump_speed_mult * (multiplier or 1)
	
	Particles:smoke(self.mid_x, self.y+self.h)
	-- Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, 0)
	Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, math.atan2(self.vy, self.vx) + pi/2)
	self:play_sound_var("sfx_player_jumplong", 0, 1.2)
	self.jump_squash = 1/3
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed * self.jump_speed_mult
	
	Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, math.atan2(self.vy, self.vx) + pi/2)
	self:play_sound_var("sfx_player_jumplong", 0, 1.2)
	self.jump_squash = 1/3
end

function Player:on_jump()
	self.buffer_jump_timer = 0
	self.coyote_time = 0

	self.flag_has_jumped_on_current_frame = true
end

function Player:add_max_jumps(val)
	self.max_jumps = self.max_jumps + val
end

function Player:on_leaving_ground()
	if not self.flag_has_jumped_on_current_frame then
		self.coyote_time = self.default_coyote_time
	end
end

function Player:on_leaving_collision()
	self.coyote_time = self.default_coyote_time
end

function Player:on_collision(col, other)
	if col.type ~= "cross" and col.normal.y == -1 then
		-- self.jumps = self.max_jumps
	end
end

function Player:on_grounded()
	self.state_machine:_call("on_grounded")
end

function Player:on_grounded_normal()
	-- On land
	local s = nil
	if self.grounded_col and self.grounded_col.other.collision_info then
		s = self.grounded_col.other.collision_info.land_sound
	end
	self:play_sound_var(s, 0.2, 1.2, {pitch=1.0, volume=1.0})

	self.jump_squash = 1.5
	self.spr:set_animation("idle")
	Particles:smoke(self.mid_x, self.y+self.h, 10, COL_WHITE, 8, 4, 2)

	self.air_time = 0
end

------------------------------------------
--- Guns ---

function Player:shoot(dt, is_burst)
	is_burst = param(is_burst, false)
	
	-- Update aiming direction
	local dx, dy = self.dir_x, self.dir_y
	local aim_horizontal = (self:action_down("left") or self:action_down("right"))
	-- Allow aiming upwards 
	if self.dir_y ~= 0 and not aim_horizontal then    dx = 0    end

	-- Update shoot dir
	self.shoot_ang = atan2(dy, dx)
	self.shoot_dir_x = cos(self.shoot_ang)
	self.shoot_dir_y = sin(self.shoot_ang)

	local btn_auto = (self.gun.is_auto and self:action_down("shoot"))
	local btn_manu = (not self.gun.is_auto and self:action_pressed("shoot"))
	if btn_auto or btn_manu or is_burst then
		self.is_shooting = true

		local ox = dx * self.gun.bul_w
		local oy = dy * self.gun.bul_h
		local success, failure_reason = self.gun:shoot(dt, self, self.mid_x + ox, self.y + oy, dx, dy, is_burst)

		if success then
			-- screenshake
			game:screenshake(self.gun.screenshake)
			if dx ~= 0 then
				self.vx = self.vx - self.dir_x * self.gun.recoil_force
			end
		else
			if failure_reason == "no_ammo" and self:action_pressed("shoot") then
				local ang = math.atan2(dy, dx)
				local tip_x, tip_y = self.gun:get_gun_tip_position(self.mid_x + ox, self.y + oy, ang)
				-- TODO Play "empty gun" sound
				self:play_sound_var("sfx_weapon_dry_shoot_{01-06}", 0.1, 1.1)
				Particles:smoke(tip_x, tip_y, 3, COL_WHITE, 6, 4, 2)
			end
		end

		if self.is_flying then
			-- (When elevator is going down)
			if success then
				self.vx = (self.vx - dx*self.gun.jetpack_force) * self.friction_x
				self.vy = (self.vy - dy*self.gun.jetpack_force) * self.friction_x
			end
		else
			-- If shooting downwards, then go up like a jetpack
			if self:action_down("down") and success then
				self.vy = self.vy - self.gun.jetpack_force
				self.vy = self.vy * self.friction_x
			end
		end
	else
		self.is_shooting = false
	end
end

function Player:get_gun_pos()
	local gunw = self.gun.spr:getWidth()
	local gunh = self.gun.spr:getHeight()
	local top_y = self.y + self.h - self.spr.h
	local hand_oy = 15

	-- x pos is player sprite width minus a bit, plus gun width 
	local w = (self.spr.w/2-5 + gunw/2)
	local hand_y = top_y + hand_oy - self.walkbounce_oy
	local x = self.mid_x 
	local y = hand_y - gunh/2 
	return x, y, self.shoot_dir_x * w, self.shoot_dir_y * gunh
end

function Player:update_gun_pos(dt, lerpval)
	-- Why do I keep overcomplicating these things
	-- TODO: move to Gun?
	-- Gun is drawn at its center
	lerpval = lerpval or 0.5

	local tar_x, tar_y, ox, oy = self:get_gun_pos()
	local ang = self.shoot_ang
	
	self.gun.ox = lerp(self.gun.ox, ox, lerpval)
	self.gun.oy = lerp(self.gun.oy, oy, lerpval)
	self.gun.x = tar_x + self.gun.ox
	self.gun.y = tar_y + self.gun.oy
	self.gun.rot = lerp_angle(self.gun.rot, ang, 0.3)
end

function Player:do_aiming(dt)
	self.dir_y = 0
	if self:action_down("up") then      self.dir_y = -1    end
	if self:action_down("down") then    self.dir_y = 1     end
end

function Player:equip_gun(gun)
	self.gun = gun
	self.gun.user = self

	self:get_gun_pos()
	self:update_gun_pos(1)
end

function Player:set_ammo_usage_multiplier(val)
	self.ammo_usage_multiplier = val
end

function Player:get_max_ammo_multiplier()
	return self.max_ammo_multiplier
end
function Player:set_max_ammo_multiplier(val)
	self.max_ammo_multiplier = val
end
function Player:multiply_max_ammo_multiplier(val)
	self.max_ammo_multiplier = self.max_ammo_multiplier * val
end

function Player:set_gun_cooldown_multiplier(val)
	self.gun_cooldown_multiplier = val
end
function Player:multiply_gun_cooldown_multiplier(val)
	self.gun_cooldown_multiplier = self.gun_cooldown_multiplier * val
end
function Player:get_gun_cooldown_multiplier()
	local value = self.gun_cooldown_multiplier
	if game.level.fury_active then 
		value = value * self.fury_gun_cooldown_multiplier
		for _, m in pairs(self.fury_gun_cooldown_multiplier_extra) do
			value = value * m
		end 
	end
	return value
end

function Player:set_gun_damage_multiplier(val)
	self.gun_damage_multiplier = val
end
function Player:get_total_gun_damage_multiplier()
	local value = 1.0
	if game.level.fury_active then 
		value = value * self.fury_gun_damage_multiplier
	end
	value = value * self.gun_damage_multiplier
	return value
end

function Player:next_gun()
	self.gun_number = mod_plus_1(self.gun_number + 1, #self.guns)
	self:equip_gun(self.guns[self.gun_number])
end

------------------------------------------
--- Combat ---
------------------------------------------

function Player:on_stomp(enemy)
	local spd = -self.stomp_jump_speed
	if (self:action_down("jump") or self.buffer_jump_timer > 0) and not self.is_grounded then
		spd = spd * 1.3
	end
	self.vy = spd
	self:set_invincibility(0.15) --0.1
	self.jumps = math.max(0, self.max_jumps - 1)
	self.wall_slide_stamina = self.wall_slide_max_stamina

	self.float_timer = self.float_max_duration
	if self.gun.is_reloading then
		self.gun:advance_reload_timer_percentage(self.ammo_percent_gain_on_stomp)
	else
		self.gun:add_ammo(math.floor(self.ammo_percent_gain_on_stomp * self.gun:get_max_ammo()))
	end

	self:add_fury(self.fury_stomp_value * enemy.fury_stomp_multiplier, enemy)
end

--- When an enemy bullet hits the player
function Player:on_hit_bullet(bullet, col)
	if bullet.player == self then      return false   end
	if self.invincible_time > 0 then   return false   end

	local damage_success = self:do_damage(bullet.damage, bullet)
	if not damage_success then
		return false
	end
	self.vx = self.vx + sign(bullet.vx) * bullet.knockback
	return true
end

--- When a bullet the player shot hits an enemy
function Player:on_my_bullet_hit(bullet, victim, col)
	-- Why tf would this happen
	if bullet.player ~= self then   return   end

	self:add_fury(bullet.damage * victim.fury_bullet_damage_multiplier * self.fury_bullet_damage_value_multiplier, victim)
end

--- When the player kills an enemy
function Player:on_kill_other(enemy, reason)
end

--- 
function Player:on_reload(gun)
	for _, upgrade in pairs(self.upgrades) do
		upgrade:on_player_reload_gun(self)
	end
end

------------------------------------------
--- Upgrades & effects ---
------------------------------------------

function Player:apply_upgrade(upgrade, is_revive)
	is_revive = param(is_revive, false)
	
	upgrade:apply(self, is_revive)
	table.insert(self.upgrades, upgrade)
end

function Player:revoke_upgrade(upgrade_index)
	assert(self.upgrades[upgrade_index] ~= nil)

	self.upgrades[upgrade_index]:finish(self)
	table.remove(self.upgrades, upgrade_index)
end

function Player:update_upgrades(dt)
	for i, upgrade in pairs(self.upgrades) do
		upgrade:update(self, dt)
	end
end

function Player:apply_effect(effect, duration, params) 
	effect:apply(self, duration, params)
	table.insert(self.effects, effect)
end

function Player:update_effects(dt)
	for i=1, #self.effects do 
		local effect = self.effects[i]
		effect:update(dt, self)
	end
	
	for i=#self.effects, 1, -1 do 
		local effect = self.effects[i]
		if not effect.is_active then
			table.remove(self.effects, i)
		end
	end
end


------------------------------------------
--- Misc ---
------------------------------------------

function Player:add_fury(amount, victim)
	game.level:add_fury(amount)
	if self.bloodthirst_enabled and victim.is_mean then
		self:add_bloodthirst_blood(amount)
	end
end

function Player:is_in_poison_cloud()
	local is_touching, col = self:is_touching_collider(function(col) return col.other.is_poisonous end)
	if col then
		self.poison_cloud = col.other
	else
		self.poison_cloud = nil
	end
	return is_touching
end

function Player:update_poison(dt)
	if self:is_in_poison_cloud() and not self.is_invincible then
		self.poison_timer = self.poison_timer + dt
		
		if self.poison_timer >= self.poison_damage_time then
			self:do_damage(1, self.poison_cloud)
			self.poison_timer = 0.0	
			Particles:rising_image(self.mid_x, self.y - 8, images.poison_skull, nil, nil, nil, {rising_squish_x = true})
		end
	else
		self.poison_timer = math.max(0.0, self.poison_timer - dt)	
	end
end

function Player:set_in_menu(val)
	self.is_in_menu = val
	
	if val then
		self.is_in_menu_old_show_hud = self.show_hud
		self.show_hud = false
		self:set_input_mode(PLAYER_INPUT_MODE_CODE)
	else
		self.show_hud = param(self.is_in_menu_old_show_hud, true)
		self.is_in_menu_old_show_hud = nil
		self:set_input_mode(PLAYER_INPUT_MODE_USER)
	end
	self:reset_virtual_controller()
end

-----------------------------------------------------
--- Visuals ---
-----------------------------------------------------

function Player:update_visuals()
	self.jump_squash       = lerp(self.jump_squash,       1, 0.15)
	self.walkbounce_squash = lerp(self.walkbounce_squash, 1, 0.2)
	self.squash = self.jump_squash * self.walkbounce_squash

	self.spr:set_scale(self.squash, 1/self.squash)

	if self:is_in_poison_cloud() then
		Particles:dust(self.mid_x + random_neighbor(7), self.mid_y + random_neighbor(7), random_sample{COL_LIGHT_YELLOW, COL_YELLOW_ORANGE, COL_ORANGE})
	end

	if (game.level.fury_active) and self.frame % 2 == 0 and not self.is_ghost and self.do_fury_trail then
		Particles:push_layer(PARTICLE_LAYER_BACK_SHADOWLESS)
		
		local x, y = self.spr:get_total_centered_offset_position(self.x, self.y, self.w, self.h)
		Particles:static_image(self.skin.img_walk_down, x, y, 0, 0.12, 1, {
			color = transparent_color(self.skin.color_palette[1], 0.5),
			alpha = 0.3,
			sx = self.spr.sx * ternary(self.dir_x > 0, -1, 1),
			sy = self.spr.sy,
		})
		
		Particles:pop_layer()
	end
end

function Player:draw()
	if self.is_removed then   return   end
	if self.is_dead then    return    end

	-- Draw gun
	if self.show_gun then
		self.gun:draw(1, self.dir_x)
	end

	-- Draw self
	self:draw_player()
	love.graphics.setColor(COL_WHITE)
end

function Player:draw_hud()
	Player.super.draw_hud(self)

	if self.is_removed or self.is_dead then    return    end
	if not self.show_hud then    return    end

	local ui_x = floor(self.ui_x)
	local ui_y = floor(self.ui_y) - self.spr.h - 12

	if self.gun and self.gun.show_hud then
		self:draw_ammo_bar(ui_x, ui_y)
		self:draw_life_bar(ui_x, ui_y)
	else
		ui_y = ui_y + 20
	end

	if game.game_state == GAME_STATE_WAITING then
		local controls_y = self.ui_y + self.controls_oy - 10
		if Input:get_number_of_users() > 1 then
			print_centered_outline(self.color_palette[1], nil, Text:text("player.abbreviation", self.n), ui_x, ui_y- 8)
			controls_y = controls_y - 16
		end

		if self.gun.show_hud then
			controls_y = controls_y - 25 -- SCOTCCHHHHHHH
		end
		self:draw_controls(controls_y)
	end	
end

function Player:draw_life_bar(ui_x, ui_y)
	ui:draw_icon_bar_stacked(ui_x, ui_y, {
		{value = self.life, img = images.heart},
		{value = ternary(self.bloodthirst_active, 1, 0), img = ternary(self.t % 0.1 < 0.05, images.heart_white, images.heart_empty)},
		{value = self.temporary_life, img = images.heart_temporary, extra = true},
	}, self.max_life, images.heart_empty, _margin)

	if self.max_jumps > 1 then
		local j = clamp(0, self.jumps, 1)
		ui:draw_icon_bar(ui_x, ui_y - 12, j, j, 0, images.hud_soda, images.hud_soda, images.hud_soda)
	end
end

function Player:draw_ammo_bar(ui_x, ui_y)
	-- Please make an ui library and stop doing this shit
	local ammo_icon_w = self.ammo_bar_icon:getWidth()
	local slider_w = 23 * (1 + (self:get_max_ammo_multiplier() - 1)/2)
	local bar_w = slider_w + ammo_icon_w + 2

	local x = floor(ui_x) - floor(bar_w/2)
	local y = floor(ui_y) + 8
	love.graphics.draw(self.ammo_bar_icon, x, y)

	local text = self.gun.ammo
	local col_fill = self.ammo_bar_fill_color
	local col_shad = self.ammo_bar_shad_color
	local val, maxval = self.gun.ammo, self.gun:get_max_ammo()
	if val <= maxval * 0.35 then
		col_fill = COL_ORANGE
		col_shad = COL_LIGHT_RED
	end

	if self.gun.is_reloading then
		text = ""
		col_fill = COL_WHITE
		col_shad = COL_LIGHTEST_GRAY
		val, maxval = self.gun.max_reload_timer - self.gun.reload_timer, self.gun.max_reload_timer
	end

	self.ui_col_gradient = self.ui_col_gradient * 0.9
	if self.ui_col_gradient >= 0.02 then
		col_fill = lerp_color(col_fill, COL_WHITE, self.ui_col_gradient)
		col_shad = lerp_color(col_fill, COL_LIGHTEST_GRAY, self.ui_col_gradient)
	end

	-- (x, y, w, h, val, max_val, col_fill, col_out, col_fill_shadow, text, text_col, font);
	local bar_x = x--+ammo_icon_w+2
	-- ui:draw_progress_bar(bar_x, y, slider_w, ammo_icon_w, val, maxval, 
						-- col_fill, COL_BLACK_BLUE, col_shad, text)
	ui:draw_progress_bar(bar_x, y, bar_w, ammo_icon_w, val, maxval, 
						col_fill, COL_BLACK_BLUE, col_shad, text)
end

function Player:get_controls_tutorial_values()
	-- Example : {{"interact"}, "{input.prompts.leave_game}"},
	return {}
end

function Player:get_controls_text_color(i)
	local color
	if Input:get_number_of_users() == 1 then
		color = LOGO_COLS[i]
	else
		color = self.color_palette[1] 
	end 
	return color or COL_WHITE
end

function Player:draw_controls(y)
	if game.debug and not game.debug.title_junk then
		return 
	end

	local tutorials = self:get_controls_tutorial_values()

	local x = self.ui_x
	for i, tuto in ipairs(tutorials) do
		y = y - 16
		Input:draw_input_prompt(self.n, tuto[1], tuto[2], self:get_controls_text_color(i), x, y, {
			alignment = "center",
			background_color = transparent_color(COL_BLACK_BLUE, 0.5),
		})
	end
end

function Player:draw_player()
	self.spr:draw(self.x, self.y - self.walkbounce_oy, self.w, self.h)
	if self.blink_color then
		local s = self.spr.is_solid_color
		local c = self.spr.color
		self.spr:set_solid(true)
		self.spr:set_color(self.blink_color)
		
		self.spr:draw(self.x, self.y - self.walkbounce_oy, self.w, self.h)

		self.spr:set_solid(s)
		self.spr:set_color(c)
	end

	local post_x, post_y = self.spr:get_total_offset_position(self.x, self.y, self.w, self.h)
	self:post_draw(post_x, post_y)

	self.state_machine:draw()

	if game.debug_mode then
		local i = 0
		local th = get_text_height()
		for _, val in pairs(self.debug_values) do
			local txt = tostring(val)
			print_outline(nil, nil, txt, self.x - get_text_width(txt)/2 + self.w/2, self.y - i*th)
			i = i + 1
		end
	end

	if self.debug_god_mode then
		Text:push_font(FONT_MINI)
		print_outline(nil, nil, "godmode", self.x, self.y - 16)
		Text:pop_font()
	end
end

function Player:post_draw(x, y)
	self:draw_effect_overlays(x, y)
end

function Player:draw_effect_overlays(x, y)
	for i, effect in pairs(self.effects) do
		effect:draw_overlay(x, y)
	end 
end

function Player:animate_walk(dt)
	-- Ridiculously overengineered bounce + squash & stretch while walking
	local old_bounce = self.walkbounce_oy

	local t_speed = 15
	local bounce_height = 5
	local squash_amount = 0.17
	
	self.walkbounce_t = self.walkbounce_t + dt * t_speed

	if self.is_walking then
		self.walkbounce_t = self.walkbounce_t % pi
	end

	if self.walkbounce_t < pi + 0.001 then
		self.is_doing_walksquash = true

		--- Compute bounce height
		local sin_a = sin(self.walkbounce_t)
		self.walkbounce_y = abs(sin_a) * bounce_height
		self.walkbounce_oy = self.walkbounce_y
		
		--- Bounce squash
		--cos is the derivative, aka rate of change ("speed") of sin
		local speed_t = math.cos(self.walkbounce_t)
		self.walkbounce_squash = speed_t*squash_amount + 1
	else
		-- If not walking and close enough to ground, reset
		self.walkbounce_squash = 1
		self.walkbounce_oy = 0
		self.walkbounce_t = pi
	end

	self.old_bounce_vy = self.bounce_vy
	self.bounce_vy = old_bounce - self.walkbounce_y
	
	-- Walk SFX
	if self.is_grounded and sign(self.old_bounce_vy) == 1 and sign(self.bounce_vy) == -1 then
		local s = nil
		if self.grounded_col and self.grounded_col.other.collision_info then
			s = self.grounded_col.other.collision_info.walk_sound
		end
		self:play_sound_var(s, 0.2*self.walk_sfx_volume, 1.2, {pitch=1.0, volume=1.0*self.walk_sfx_volume})
	end
end

function Player:update_color(dt)
	self.blink_timer = (self.blink_timer + dt) % self.blink_freq

	self.spr:set_color{1, 1, 1, 1}
	self.spr:set_solid(false)
	self.blink_color = nil

	-- Poison
	if self.poison_timer > 0 then
		self.blink_freq = 0.1
		self.blink_color = transparent_color(COL_LIGHT_YELLOW, 0.8)
	end
	
	-- Wall slide stamina blink
	if self.state_machine.current_state_name == "normal" and self.wall_slide_stamina < self.wall_slide_max_stamina/2 then
		self.stamina_blinking_state = 2
		self.blink_freq = 0.2

		if self.wall_slide_stamina < self.wall_slide_max_stamina/4 then
			self.stamina_blinking_state = 3
			self.blink_freq = self.blink_freq / 2 
		end
		
		self.blink_color = transparent_color(COL_LIGHT_RED, 0.8)
		
		-- Sound
		if self.old_stamina_blinking_state ~= self.stamina_blinking_state then
			self:set_constant_sound("stamina_low", "sfx_player_wall_slide_stamina_low", true)
			if self.stamina_blinking_state == 3 then
				self:set_constant_sound("stamina_low", "sfx_player_wall_slide_stamina_very_low", true)
			end
		end
	else
		self.stamina_blinking_state = 1
		self:remove_constant_sound("stamina_low")
	end
	self.old_stamina_blinking_state = self.stamina_blinking_state
	
	-- Fizzy lemonade running out blink
	if self.is_floating and self.float_timer < 1.5 then
		self.blink_freq = 0.13
		if self.float_timer < 0.7 then
			self.blink_freq = self.blink_freq / 2 
		end

		self.blink_color = transparent_color(COL_LIGHT_YELLOW, 0.8)	
	end
	
	-- Invincibility blink
	if self.is_invincible and self.invincible_time > 0.1 then
		local a = clamp((self.invincible_time / self.max_invincible_time)*0.5 + 0.3, 0.0, 0.8)
		self.blink_color = transparent_color(COL_WHITE, a)
	end
	
	-- Apply blink
	if self.blink_timer <= self.blink_freq/2 then
		self.blink_color = nil
	end
	
	if self.state_machine.current_state_name ~= "normal" then
		self.blink_color = nil
	end

	if self.is_ghost then
		self.spr:set_color{1, 1, 1, self.ghost_opacity}
	end
end

function Player:update_sprite(dt)
	-- Outline color
	if Input:get_number_of_users() > 1 and not self.is_ghost then
		self.spr:set_outline(self.outline_color_override or self.color_palette[1], "round")
	else
		self.spr:set_outline(nil)
	end

	-- Flipping
	self.spr:set_flip_x(self.dir_x < 0)

	-- Ghost float effect 
	if self.is_ghost then
		self.spr:update_offset(nil, math.sin(self.t*3) * 3.0)
	end

	-- Set sprite 
	self.spr:set_animation("idle")
	if not self.is_grounded then
		self.spr:set_animation("airborne")
	end
	if self.is_wall_sliding then
		self.spr:set_animation("wall_slide")
	end
	if self.is_walking then
		if self.walkbounce_y < 4 then
			self.spr:set_animation("walk_down")
		else
			self.spr:set_animation("airborne")
		end
	end
	if self.is_ghost then
		self.spr:set_animation("dead")
	end
end

function Player:do_particles(dt)
	local flr_y = self.y + self.h
	if self.is_walking then
		self.walk_timer = self.walk_timer + 1
		if self.walk_timer % 7 == 0 then
			Particles:dust(self.mid_x, flr_y)
		end
	end
end

function Player:update_debug_god_mode(dt)
	if self.debug_god_mode then
		self.is_affected_by_bounds = false
		self.is_affected_by_walls = false
		self.gravity_mult = 0.0
		self.speed_mult = 2.0
		
		self.friction_x = self.default_friction
		self.friction_y = self.default_friction
	else
		self.is_affected_by_bounds = true
		self.is_affected_by_walls = true
		self.gravity_mult = 1.0
		self.speed_mult = 1.0
		
		self.friction_x = self.default_friction
		self.friction_y = 1
	end
end

function Player:update_achievements(dt)
	if self:get_total_life() >= 7 then
		Achievements:grant("ach_max_hearts")
	end
end

-----------------------------
--- Bloodthirst
-----------------------------

function Player:start_bloodthirst()
	if not self.bloodthirst_enabled then
		return
	end
	self.bloodthirst_timer:start()
	self.bloodthirst_active = true
	self.bloodthirst_blood = 0.0
end

function Player:stop_bloodthirst()
	if not self.bloodthirst_enabled then
		return
	end

	self.bloodthirst_active = false
	self.bloodthirst_timer:stop()
	self.bloodthirst_blood = 0.0
end

function Player:update_bloodthirst(dt)
	if not self.bloodthirst_enabled then
		return
	end

	-- self.debug_values[1] = round(self.bloodthirst_timer.time,2)
	-- self.debug_values[2] = "b"..tostring(round(self.bloodthirst_blood, 2))

	if game.level:is_fury_unfrozen() then
		if self.bloodthirst_timer:update(dt) then
			self:stop_bloodthirst()
		end
	end

	if self.life >= self.max_life then
		self:stop_bloodthirst()
	end

	if self.bloodthirst_active then
		-- Particles:push_layer(PARTICLE_LAYER_BACK)
		-- Particles:smoke(self.mid_x, self.mid_y, 2, random_sample{COL_DARK_BRICK, COL_LIGHT_BRICK, COL_MID_DARK_GREEN}, 16)
		-- Particles:pop_layer()

		if self.bloodthirst_blood > self.bloodthirst_blood_threshold then
			self:stop_bloodthirst()

			local success, overflow = self:heal(1)
			Particles:smoke(self.mid_x, self.mid_y, nil, {COL_DARK_BRICK, COL_LIGHT_BRICK, COL_MID_DARK_GREEN})
			self:play_sound("sfx_loot_health_collect")
			Particles:word(self.mid_x, self.y, concat(1,"❤"), {COL_LIGHT_BRICK, COL_DARK_BRICK, COL_MID_DARK_GREEN, stacked=true}, 1.0)
			Particles:word(self.mid_x, self.y+16, concat("(", Text:text("upgrade.gazpacho.title"), ")"), {COL_LIGHT_BRICK, COL_DARK_BRICK, COL_MID_DARK_GREEN, stacked=true, font=FONT_MINI}, 1.0)
			
		end
	end
end

function Player:add_bloodthirst_blood(amount)
	if not (self.bloodthirst_enabled and self.bloodthirst_active) then
		return
	end
	self.bloodthirst_blood = self.bloodthirst_blood + amount
end

return Player