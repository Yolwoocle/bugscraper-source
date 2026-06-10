require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local Explosion = require "scripts.actor.enemies.explosion"
local Timer     = require "scripts.timer"

local GoldenBeetle = Enemy:inherit()

function GoldenBeetle:init(x, y, spr)
    GoldenBeetle.super.init(self, x,y, spr or images.golden_beetle)
    self.name = "golden_beetle"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    
    self.speed = 5
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x

    self.spr = AnimatedSprite:new({
        walk = {images.golden_beetle, 0.2, 1},
    }, "walk")
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    self:set_ai_template("random_rotate")
    self.direction = 0
    
    self.do_stomp_animation = false
    -- self.destroy_bullet_on_impact = false
    -- self.is_bouncy_to_bullets = true
    -- self.is_immune_to_bullets = true

    self.is_killed_on_negative_life = false
    self.is_killed_on_stomp = false

    self.sound_death = "sfx_enemy_kill_general_stomp_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_stomp_{01-10}"

    self.exploding = false
    self.exploding_timer = Timer:new(2.0)

    self.explosion_radius = 42

    self.is_exploding = false

    self.score = 10
end

function GoldenBeetle:update(dt)
    GoldenBeetle.super.update(self, dt)

    self.direction = self.direction + random_sample({-1, 1}) * dt * 3
    
	self.vx = self.vx + math.cos(self.direction) * self.speed
	self.vy = self.vy + math.sin(self.direction) * self.speed

    self.spr:set_rotation(self.direction)

    if self.exploding then
        Particles:push_layer(PARTICLE_LAYER_BACK)
        Particles:dust(self.mid_x, self.mid_y)
        Particles:pop_layer()

        if self.exploding_timer:get_ratio() > 0.5 then
            self.spr:set_flashing_white(self.exploding_timer.time % 0.1 < 0.05)
        else
            self.spr:set_flashing_white(self.exploding_timer.time % 0.2 < 0.1)
        end 

        if self.exploding_timer:update(dt) then
            local explosion = Explosion:new(self.mid_x, self.mid_y, {radius = self.explosion_radius, sound="sfx_enemy_goldenbeetle_explode_{01-03}"})
            game:new_actor(explosion)
            self:kill()
        end
    end
end

function GoldenBeetle:draw()
	GoldenBeetle.super.draw(self)
end

function GoldenBeetle:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function GoldenBeetle:on_stomped()
    self:activate()
end

function GoldenBeetle:on_negative_life()
    self:activate()
end

function GoldenBeetle:activate()
    if self.is_exploding then
        return
    end
    self.is_exploding = true
    self.counts_for_enemy_count = false
    
    self.random_rotate_speed = 0
    self.speed = 30

    self.is_stompable = false
    self.damage = 0

    self.exploding = true
    self.exploding_timer:start()

    self:play_sound_var("sfx_enemy_goldenbeetle_trigger", 0.2, 1.2)
	Particles:star_splash(self.mid_x, self.mid_y)

    self:set_constant_sound("beep", "sfx_enemy_goldenbeetle_beep", false)
    self:set_constant_sound_volume("beep", 1.0 + random_neighbor(0.1))
    self:play_constant_sound("beep")
end

return GoldenBeetle