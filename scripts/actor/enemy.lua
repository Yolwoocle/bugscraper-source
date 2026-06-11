require "scripts.util"
local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
local Loot = require "scripts.actor.loot"
local images = require "data.images"
local sounds = require "data.sounds"
local shaders= require "data.shaders"
local guns = require "data.guns"

local Enemy = Actor:inherit()

function Enemy:init(x,y, img, w,h)
	self:init_enemy(x,y, img, w,h)
end

function Enemy:init_enemy(x,y, img, w,h)
	-- TODO: abstract enemies and players into a single "being" class
	-- "Being" means players, enemies, etc, but not bullets, etc
	-- They have life, can take or deal damage, and inherit Actor:
	-- so they have velocity and collision. 
	w,h = w or 12, h or 12
	self:init_actor(x, y, w, h, img or images.duck)
	self.name = "enemy"

	self.invincible_timer = 0.0
	
	self.counts_as_enemy = true -- don't count in the enemy counter
	self.counts_for_enemy_count = true
	self.is_being = true 
	self.is_enemy = true
    self.is_mean = true
	self.is_flying = false
	self.is_active = true
	self.follow_player = true

	self.random_rotate_speed = 3
	self.random_rotate_probability = 1.0

	self.direction = 0
	self.ai_template = nil
	self.ai_templates = {
		["rotate"] = {
			ready = function(ai)
				self.direction = 0
			end,
			update = function(ai, dt)
                self.vx = self.vx + math.cos(self.direction) * self.speed
                self.vy = self.vy + math.sin(self.direction) * self.speed
			end
		},
		["random_rotate"] = {
			ready = function(ai)
				self.direction = random_range(0, pi2)
			end,
			update = function(ai, dt)
				self.direction = self.direction or random_range(0, pi2)
				
				if random_range(0, 1) < self.random_rotate_probability then
					self.direction = self.direction + random_sample({-1, 1}) * dt * self.random_rotate_speed
				end
                self.vx = self.vx + math.cos(self.direction) * self.speed
                self.vy = self.vy + math.sin(self.direction) * self.speed
			end
		},
	}

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false
	self.is_immune_to_electricity = false
	self.is_bouncy_to_bullets = false
	self.bullet_bounce_mode = BULLET_BOUNCE_MODE_RADIAL

	self.max_frames_since_land_for_stomping = 7
	
	self.harmless_timer = 0

	self.is_killed_on_negative_life = true
	self.max_life = 10
	self.life = self.max_life
	self.is_dead = false

	self.color = COL_BLUE
	self.speed = 20
	self.speed_x = self.speed
	self.speed_y = 0

	self.loot = {
		{nil, 180},
		{Loot.Life, 7, loot_type="life", value=1},
		{Loot.Gun, 3, loot_type="gun"},
	}

	self.is_stompable = true
	self.is_killed_on_stomp = true
	self.do_stomp_animation = true
	self.stomp_height = self.h/2
	self.stomps = 1
	self.damage_on_stomp = 0
	self.head_ratio = 0.25
	self.can_be_stomped_if_on_head = true
	self.can_be_stomped_if_falling_down = true

	self.is_pushable = true
	self.is_knockbackable = true -- Multiplicator when knockback is applied to

    self.is_boss = false
	self.do_boss_gun_damage = true

	self.damage = 1
	self.knockback = 1200
	self.self_knockback_mult = 1 -- Basically weight (?)

	self.damaged_flash_timer = 0
	self.damaged_flash_max = 0.07
	self.flash_white = false

	self.do_squash = false
	self.squash = 1
	self.squash_target = 1
	
	self.play_sfx = true
	self.sound_damage = "sfx_enemy_damage"
	self.sound_death = "stomp2"
	self.sound_stomp = "stomp2"

	self.target = nil

	self.harmless_timer = 0.0

	self.flip_mode = ENEMY_FLIP_MODE_XVELOCITY
	self.do_death_effects = true

	self.gun = nil
	-- self.sound_stomp = {"enemy_stomp_2", "enemy_stomp_3"}
	--{"crush_bug_1", "crush_bug_2", "crush_bug_3", "crush_bug_4"}

	self.fury_damage_multiplier = 1.0
	self.fury_stomp_multiplier = 1.0
	self.death_counts_for_fury_combo = true

	self.has_run_ready = false

	self.score = 0
	self.fury_bullet_damage_multiplier = 1
end

function Enemy:ready()
	if self.ai_template and self.ai_templates[self.ai_template] and self.ai_templates[self.ai_template].ready then
		self.ai_templates[self.ai_template]:ready()
	end
end

function Enemy:update_enemy(dt)
	-- if not self.is_active then    return    end
	Enemy.super.update(self, dt)
	
	if self.follow_player then
		self:assign_target_as_nearest_player(dt)
	end
	if self.ai_template and self.ai_templates[self.ai_template] then
		self.ai_templates[self.ai_template]:update(dt)
	end
	self:follow_target(dt)
	self.invincible_timer = max(self.invincible_timer - dt, 0)
	self.harmless_timer = max(self.harmless_timer - dt, 0)

	if self.flip_mode == ENEMY_FLIP_MODE_TARGET then
		if self.target and math.abs(self.x - self.target.x) >= 20 then
			self.spr:set_flip_x(self.target.x < self.x)
		end
		
	elseif self.flip_mode == ENEMY_FLIP_MODE_XVELOCITY then
		if math.abs(self.vx) > 30 then
			self.spr:set_flip_x(self.vx < 0)
		end

	end

	self:update_flash(dt)
	
	if self.do_squash then
		self.squash = lerp(self.squash, 1, 0.2)
		self.spr:set_scale(self.squash, 1/self.squash)
	end
end
function Enemy:update(dt)
	self:update_enemy(dt)
end

function Enemy:set_ai_template(ai_name)
	self.ai_template = ai_name
	if not self.ai_template then
		return
	end
	assert(self.ai_templates[self.ai_template] ~= nil, "AI template "..tostring(ai_name).." doesn't exist")
	self.ai_templates[self.ai_template]:ready()
end

function Enemy:update_flash(dt)
	self.damaged_flash_timer = max(self.damaged_flash_timer - dt, 0)

	self.spr:set_flashing_white(self:is_flashing_white())
end

function Enemy:get_nearest_player()
	local shortest_dist = math.huge
	local nearest_player 
	for _, ply in pairs(game.players) do
		local dist = distsqr(self.x, self.y, ply.x, ply.y)
		if dist < shortest_dist then
			shortest_dist = dist
			nearest_player = ply
		end
	end
	return nearest_player
end

function Enemy:assign_target_as_nearest_player(dt)
	if not self.follow_player then
		return
	end
	
	-- Find closest player
	self.target = nil
	local nearest_player = self:get_nearest_player()
	if not nearest_player then
		return
	end
	self.target = nearest_player
end

function Enemy:follow_target(dt)
	self.speed_x = self.speed_x or self.speed
	if self.is_flying then
		self.speed_y = self.speed_y or self.speed 
	else
		self.speed_y = self.speed_y or 0
	end 

	if self.target then
		self.vx = self.vx + sign0(self.target.x - self.x) * self.speed_x
		self.vy = self.vy + sign0(self.target.y - self.y) * self.speed_y
	end
end

function Enemy:is_flashing_white()
	return (self.flash_white or self.damaged_flash_timer > 0)
end

function Enemy:draw_enemy()
	Enemy.super.draw(self)
end

function Enemy:draw()
	self:draw_enemy()
end

--- Called when bump.lua collides with an object.
function Enemy:on_collision(col, other)
	if self.is_removed then return end

	-- If hit wall, reverse x vel (why is this here?????) TODO: wtf
	if col.type ~= "cross" and col.normal.y == 0 then 
		self.vx = -self.vx
	end

	-- Player
	if col.other.is_player and not col.other.is_ghost then
		local player = col.other
		
		-- Being stomped
		-- if player.vy > epsilon and self.is_stompable then
		local feet_y = player.y + player.h

		local is_on_head      = (feet_y <= self.y + self.h * self.head_ratio) and self.can_be_stomped_if_on_head
		local is_falling_down = (player.vy > 0.0001) and self.can_be_stomped_if_falling_down
		local recently_landed = (0 < player.frames_since_land) and (player.frames_since_land <= self.max_frames_since_land_for_stomping)
		local stomp_condition = (is_on_head or is_falling_down or recently_landed)
		
		if self.invincible_timer <= 0 and self.is_stompable and stomp_condition then
			self:react_to_stomp(player)

		else
			-- Damage player
			if self.harmless_timer <= 0 then
				local success = player:do_damage(self.damage, self)
				if success then
					self:on_damage_player(player, self.damage)
				end
			end
		end
	end
	
	-- Being collider push force
	if col.other.is_being and self.is_pushable and other.is_pushable then
		self:do_knockback_from(10, col.other)
		col.other:do_knockback_from(10, self)
	end

	if self.ai_template and self.ai_templates[self.ai_template] and self.ai_templates[self.ai_template].after_collision then
		self.ai_templates[self.ai_template]:after_collision(col, other)
	end

	self:after_collision(col, col.other)
end

--- React to a player stomping on the enemy.
function Enemy:react_to_stomp(player)
	player.vy = 0
	player:on_stomp(self)
	
	self.stomps = self.stomps - 1
	if self.damage_on_stomp > 0 then
		self:do_damage(self.damage_on_stomp, player)
	end
	self:on_stomped(player)
	if self.stomps <= 0 then
		if self.do_stomp_animation and self.is_grounded then
			local ox, oy = self.spr:get_total_centered_offset_position(self.x, self.y, self.w, self.h)
			Particles:stomped_enemy(self.mid_x, self.y+self.h, self.stomp_animation_image or self.spr.image)
		end
		self:on_stomp_killed(player)
		if self.is_killed_on_stomp then
			self:kill(player, "stomped")
		end
	end
end

--- Makes the enemy invincible for `duration`.  
function Enemy:set_invincibility(duration)
	self.invincible_timer = math.max(self.invincible_timer, duration)
end

--- Makes the enemy harmless for `duration`.  
function Enemy:set_harmless(duration)
	self.harmless_timer = math.max(self.harmless_timer, duration)
end

--- Set the life and max life of the enemy
function Enemy:set_max_life(val)
	self.max_life = val
	self.life = val
end

--- Deal damage to the enemy.
function Enemy:do_damage(n, damager)
	if not self.is_active or self.invincible_timer > 0 then
		return false
	end
	self.damaged_flash_timer = self.damaged_flash_max
	
	if self.play_sfx then   self:play_sound_var(self.sound_damage, 0.3, 1.1)   end
	self.life = self.life - n
	self:on_damage(n)

	if self.life <= 0 then
		if self.is_killed_on_negative_life then
			self:kill(damager)
		end 
		self:on_negative_life()
	end
	game:on_enemy_damage(self, n, damager)
	return true
end


--- Kills the enemy
function Enemy:kill(damager, reason)
	if self.is_removed then
		return
	end
	self.death_reason = reason or ""

	local player 
	if damager and damager.is_player then player = damager end
	if damager and damager.is_bullet and damager.player.is_player then player = damager.player end

	if self.do_death_effects then
		self:play_death_effects(player)
	end
	if self.play_sfx then
		if reason == "stomped" then
			self:play_sound_var(self.sound_stomp, 0.3, 1.1)
		else
			self:play_sound_var(self.sound_death, 0.3, 1.1)
		end
	end

	self.is_dead = true
	game:on_kill(self)
	self:remove()
	
	self:drop_random_loot()
	self:on_death(damager, reason)

	if damager then
		if damager.is_bullet and damager.player.on_kill_other then
			damager.player:on_kill_other(self, reason)
		elseif damager.on_kill_other then
			damager:on_kill_other(self, reason)
		end
	end
end

function Enemy:play_death_effects(player)
	game:screenshake(2)
	Particles:smoke(self.mid_x, self.mid_y)
	Particles:star_splash(self.mid_x, self.mid_y)

	if player then
		Input:vibrate(player.n, 0.05, 0.3)

		Particles:floating_image({
			images.star_small_1,
			images.star_small_2,
		}, self.mid_x, self.mid_y, random_range_int(5, 7), 0, 0.25, 1, 120, 0.95)
	end
end

--- Ajusts loot table according to the number of players
function Enemy:ajust_loot_probabilities()
	local new_loot_table = copy_table_shallow(self.loot)

	if #game.players == 0 then
		return new_loot_table
	end
	
	-- Ajust for multiplayer
	if Input:get_number_of_users() > 1 then
		for _, item in pairs(new_loot_table) do
			if item[1] ~= nil then
				local p = item[2] * (1 + MULTIPLAYER_LOOT_PROBABILITY_MULTIPLIER * (Input:get_number_of_users() - 1))
				item[2] = p 
			end
		end
	end

	-- Probability biases
	local min_life_ratio = game:get_life_ratio_of_weakest_player()
	for _, item in pairs(new_loot_table) do
		if item.loot_type == "life" then
			local p = item[2] 

			-- Depending on health of player with the least health: 
			-- * 100%: x0 drop probability 
			-- * 50%:  x1 drop probability 
			-- * 0%:   x2 drop probability 
			p = p * map_range(clamp(min_life_ratio, 0.0, 1.0), 0.0, 1.0, 2.0, 0.0)

			-- Ajust for loot bias
			p = p * game.level.loot_bias
			item[2] = p
		end
	end

	return new_loot_table
end

--- Drops random loot from the enemy
function Enemy:drop_random_loot()
	local ajusted_loot_table = self:ajust_loot_probabilities()
	local loot, params = random_weighted(ajusted_loot_table)

	if not loot then
		game.level:on_loot_not_dropped(self, params)
		return		
	end
	self:drop_loot(loot, params)
end

--- Drops the given loot, with the given parameters (format: look at self.loot) from the enemy
function Enemy:drop_loot(loot, params)
	params = params or {}

	local instance
	local vx = random_neighbor(300)
	local vy = random_range(-200, -500)
	local loot_type = params.loot_type
	if loot_type == "gun" then
		local gun = guns:get_random_gun()
		instance = loot:new(self.mid_x, self.mid_y, params.value, vx, vy, gun)

	elseif loot_type == "life" then
		instance = game:new_life_orb(self.mid_x, self.mid_y)

	end 

	game:new_actor(instance)
	game.level:on_loot_dropped(self, params)
end


function Enemy:get_bullet_damage(bul)
	if bul.override_enemy_damage then
		return bul.override_enemy_damage 
	end
	if (self.is_boss and self.do_boss_gun_damage) and bul.boss_damage then
		return bul.boss_damage
	end
	return bul.damage
end

--- Function called when a bullet hits the enemy 
function Enemy:on_hit_bullet(bul, col)
	if self.is_immune_to_bullets then
		return false
	end
	local dmg = self:get_bullet_damage(bul)
	
	self:do_damage(dmg, bul)
	
	if self.is_knockbackable then
		local ang = atan2(bul.vy, bul.vx)
		self.vx = self.vx + cos(ang) * bul.knockback * self.self_knockback_mult
		self.vy = self.vy + sin(ang) * bul.knockback * self.self_knockback_mult
	end
	return true
end

--- Returns a random alive player
function Enemy:get_random_player()
    local players = {}
    for _, player in pairs(game.players) do
        table.insert(players, player)
    end

    if #players == 0 then
        return nil
    end
    return random_sample(players)
end

--- Sets the enemy's property defining whether it is bouncy or not
function Enemy:set_bouncy(bool)
    self.destroy_bullet_on_impact = not bool
    self.is_bouncy_to_bullets = bool
    self.is_immune_to_bullets = bool
end

--- (Abstract) Called when the enemy touches an electric ray
function Enemy:on_hit_electrictiy()
end

--- (Abstract) Called when a bullet bounces off the enemy
function Enemy:on_bullet_bounced(bullet, col)
end

--- (Abstract) Called when the enemy dies
function Enemy:on_death(damager, reason)
end

--- (Abstract) Called when the enemy's life is less than, or equal to 0 
function Enemy:on_negative_life()
end

--- (Abstract) Called when the enemy is damaged
function Enemy:on_damage(amount)
end

--- (Abstract) Called when the enemy is stomped, but not necessarily stomp-killed
function Enemy:on_stomped(damager)
end

--- (Abstract) Called when the enemy is killed by stomping it
function Enemy:on_stomp_killed(damager)
end


--- (Abstract) Called when the enemy damages a player.
function Enemy:on_damage_player(player, damage)
end

--- (Abstract) Called after a collision.  
--- `col`: information about the collision, specified by bump.lua,  
--- `other`: the collision object that was collided with. 
function Enemy:after_collision(col, other)
end

return Enemy