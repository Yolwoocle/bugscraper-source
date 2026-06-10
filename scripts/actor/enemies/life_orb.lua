require "scripts.util"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Loot = require "scripts.actor.loot"
local Sprite = require "scripts.graphics.sprite"

local utf8 = require "utf8"

local LifeOrb = Prop:inherit()

function LifeOrb:init(x, y, life)
    LifeOrb.super.init(self, x, y, images.gun_orb, 16, 16)
    self.name = "life_orb"
    
    self.life = life or 1
	self.counts_as_enemy = false

    self.life = 4

    self.dissapear_life = 20
    self.loot = {}

    self.gravity = self.default_gravity
    self.is_flying = false

    self.is_pushable = false
    self.is_knockbackable = true

    self.is_stompable = true
    self.is_killed_on_stomp = false
    self.stomps = 500
    self.damage_on_stomp = 5

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false
    self.can_be_stomped_if_on_head = false

    self.friction_x = 0.9
    self.self_knockback_mult = 0.7
    self.vertical_bounce_multiplier = 0.8
    
    self.rot_mult = 0.06

	-- self.sound_damage = "sfx_weapon_glassjump_{01-06}"
	self.sound_damage = "sfx_actor_button_small_glass_damage_{01-06}"
	self.sound_death = "sfx_actor_button_small_glass_break"

    self.max_dissapear_life = 10
    self.dissapear_life = self.max_dissapear_life

	self.max_blink_timer = 0.1
	self.blink_timer = self.max_blink_timer
	self.blink_is_shown = true

    self.spr.rot = random_range(0, pi*2)
    self.spr:set_scale(0.45, 0.45)

    self.below_spr = Sprite:new(images.loot_life, SPRITE_ANCHOR_CENTER_CENTER)
end

function LifeOrb:assign_upgrade(upgrade)
    self.product = upgrade
end

function LifeOrb:update(dt)
    LifeOrb.super.update(self, dt)

    -- scotch
    if self.buffer_vx then
        self.vx = self.buffer_vx
        self.buffer_vx = nil
    end
    -- scotch
    if self.buffer_vy then
        self.vy = self.buffer_vy
        self.buffer_vy = nil
    end

    local r = (self.spr.rot + self.vx * self.rot_mult * dt)
    self.spr:set_rotation(r)
    self.below_spr:set_rotation(0.0)

    -- Copy pasted from Loot. Is this a bad coding habit? Too bad.
    self.dissapear_life = self.dissapear_life - dt
	if self.dissapear_life < self.max_dissapear_life * 0.5 then
		self.blink_timer = self.blink_timer - dt
		
		if self.blink_timer < 0 then
			local val = self.max_blink_timer
			if self.dissapear_life < self.max_dissapear_life * 0.25 then
				val = self.max_blink_timer * .5
			end
			self.blink_timer = val
			self.blink_is_shown = not self.blink_is_shown
		end
	end 
	self.spr:set_color(ternary(self.blink_is_shown, COL_WHITE, {1,1,1, 0.5}))
	self.below_spr:set_color(ternary(self.blink_is_shown, COL_WHITE, {1,1,1, 0.5}))

    if self.dissapear_life < 0 then
        self:remove()
    end

    self.below_spr:set_flashing_white(self:is_flashing_white())
end

function LifeOrb:draw()
    if self.below_spr and self.blink_is_shown then
        self.below_spr:draw(self.x, self.y - 3, self.w, self.h)
    end
	LifeOrb.super.draw(self) 
end

function LifeOrb:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 10, images.glass_shard, self.h)

    local vx = random_neighbor(300)
    local vy = random_range(-200, -500)
    local instance = Loot.Life:new(self.mid_x, self.mid_y, 1, vx, vy)
    game:new_actor(instance)
end

function LifeOrb:after_collision(col, other)
    if col.type ~= "cross" then
        local s = 0
        if col.normal.y == 0 then
            self.buffer_vx = col.normal.x * math.abs(self.vx)
            s = math.abs(self.buffer_vx)
        end
        if col.normal.x == 0 then
            self.buffer_vy = col.normal.y * math.abs(self.vy) * self.vertical_bounce_multiplier
            s = math.abs(self.buffer_vy)
        end

        if math.abs(s) > 30 then
            self:play_sound(self.sound_damage, clamp(math.abs(s) / 200, 0.3, 0.6), 0.7)
        end
    end
end

function LifeOrb:on_stomped(stomper)
    self:apply_force_from(500 * self.self_knockback_mult, stomper)
end

return LifeOrb