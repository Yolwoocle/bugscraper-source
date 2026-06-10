require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local Timer = require "scripts.timer"
local PongBall = require "scripts.actor.enemies.pong_ball"
local Loot = require "scripts.actor.loot"

local RollossusMinion = PongBall:inherit()

function RollossusMinion:init(x, y, spawner, params)
    params = params or {}
    params = params.speed or 100 
    RollossusMinion.super.init(self, x, y, images.rollossus_minion, 20, 20)
    self.name = "rollossus_minion"
    self.spawner = spawner

    self.life = 4
    self.z = -1

    self.invul = true
    self.invul_timer = Timer:new(0.5)
    self.invul_timer:start()

    self.is_pushable = false
    self.is_bouncy_to_bullets = false
    self.destroy_bullet_on_impact = false
    self.is_immune_to_bullets = true
    self.do_stomp_animation = false
    self.is_stompable = false
    self.damage = 0

    self.sound_pong_bounce = "sfx_boss_rollossus_minion_bump_{01-06}"
    self.sound_pong_bounce_volume = 0.5

    self.score = 10

    self.fury_stomp_multiplier = 3.0

    self.is_spiky = random_range(0, 1) <= 0.2
    if self.is_spiky then
        self:set_image(images.rollossus_minion_spiked)
    end

    Particles:smoke(self.mid_x, self.mid_y)
end

function RollossusMinion:update(dt)
    self:update_pong_ball(dt)

    if self.invul_timer:update(dt) then
        self.invul = false

        self.destroy_bullet_on_impact = true
        self.is_immune_to_bullets = false
        self.is_stompable = not self.is_spiky
        self.damage = 1
    end
end

function RollossusMinion:draw()
    self:draw_pong_ball()
end

function RollossusMinion:after_collision(col, other)
    self:after_collision_pong_ball(col, other)

    if col.type ~= "cross" then
        if not self.is_ponging then
            self:kill()
        end
    end
end

function RollossusMinion:on_death()
end

return RollossusMinion
