require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Slug = require "scripts.actor.enemies.slug"

local PongBall = Enemy:inherit()

function PongBall:init(x, y, spr, w, h, params)
    params = params or {}
    self:init_enemy(x,y, spr or images.snail_shell, w or 16, h or 16)
    self.name = "pong_ball"
    self.is_flying = true
    self.follow_player = false
    self.do_stomp_animation = false

    self.rot_speed = 3

    self.gravity = 0
    self.friction_x = 1.0 
    self.friction_y = self.friction_x 

    self:init_pong(params)

    self.sound_pong_bounce = "sfx_enemy_snail_bounce_{01-06}"
    self.sound_pong_bounce_volume = 0.7
    
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
end

function PongBall:init_pong(params)
    params = params or {}
    
    self.pong_direction = params.start_angle or (pi/4 + pi/2 * love.math.random(0,3)) % pi2
    self.is_ponging = true
    self.pong_speed = params.speed or 100
    self.pong_vx = cos(self.pong_direction) * self.pong_speed
    self.pong_vy = sin(self.pong_direction) * self.pong_speed
end

function PongBall:update(dt)
    self:update_pong_ball(dt)
end

function PongBall:update_pong_ball(dt)
    self:update_enemy(dt)
    self.spr:set_rotation(self.spr.rot + self.rot_speed * dt)

    if self.is_ponging then
        self.pong_vx = math.cos(self.pong_direction) * self.pong_speed
        self.pong_vy = math.sin(self.pong_direction) * self.pong_speed
        
        self.vx = (self.pong_vx or 0)
        self.vy = (self.pong_vy or 0)
    end
end

function PongBall:after_collision(col, other)
    self:after_collision_pong_ball(col, other)
end

function PongBall:after_collision_pong_ball(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        if self.is_ponging then
            local s = self.sound_pong_bounce
            self:play_sound_var(s, 0.3, 1.1, {pitch=1.0, volume=self.sound_pong_bounce_volume})
            Particles:smoke(col.touch.x, col.touch.y)

            local dx, dy = bounce_vector_cardinal(math.cos(self.pong_direction), math.sin(self.pong_direction), col.normal.x, col.normal.y)
            self.pong_direction = math.atan2(dy, dx)
        end
    end
end

function PongBall:draw()
    self:draw_pong_ball()
end

function PongBall:draw_pong_ball()
    self:draw_enemy()
end

return PongBall