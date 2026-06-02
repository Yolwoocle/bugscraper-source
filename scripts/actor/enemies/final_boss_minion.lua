require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local StateMachine = require "scripts.state_machine"

local FinalBossMinion = Enemy:inherit()
	
function FinalBossMinion:init(x, y, params)
    params = params or {}
    FinalBossMinion.super.init(self, x,y, images.final_boss_minion_body, 20, 20)

    self.name = "final_boss_minion"
    self.life = 10

    self.spr = AnimatedSprite:new({
        normal = {images.final_boss_minion_body, 0.2, 2},
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER)

    self.damage = 1

    self.parent = params.parent
    
    self.speed = 40 + random_neighbor(10)
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.aim_speed = 300

    self.gravity = 0
    self.friction_x = 1
    self.friction_y = self.friction_x

    self.dir_x = param(params.dir_x, 1)
    self.dir_y = param(params.dir_y, 0)
    self.dir_x, self.dir_y = normalize_vect(self.dir_x, self.dir_y)

    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false

    self.is_stompable = true

    self.star_rot = 0
    self.is_front = true

    self.sound_death = ""
    self.sound_stomp = ""

	self.score = 10

    self.is_killed_on_negative_life = false
    self.is_killed_on_stomp = false

    self.state_machine = StateMachine:new({
        normal = {
            update = function(state, dt)
                self.vx = self.dir_x * self.speed
                self.vy = self.dir_y * self.speed

                if random_range(0, 1) < 0.05 then
                    Particles:floating_image({
                        images.star_small_2,
                        
                    }, self.mid_x, self.mid_y, 1, 0,  1.0,  1, 40, 0.95, {life_rand= 0.5})
                    --function ParticleSystem:floating_image(img, x, y, amount, rot, life, scale, vel, friction, params)

                end

                self.star_rot = self.star_rot + dt*3
            end,
        },
        aim = {
            enter = function(state)
                self.damage = 0

                self:play_sound_var("sfx_boss_ceo_fish_stomp_{01-06}", 0.1, 1.1)

	            self:set_constant_sound("star", "sfx_boss_ceo_fish_starring_lp", true)
            end,
            update = function(state, dt)
                self.star_rot = self.star_rot + dt*8

                if self.parent then
                    local dx, dy = get_direction_vector_between_actors(self, self.parent, true)
                    self.vx = dx * self.aim_speed
                    self.vy = dy * self.aim_speed

                    Particles:floating_image({
                        images.star_small_2,
                        
                    }, self.mid_x, self.mid_y, 1, 0,  1.0,  1, 40, 0.95, {life_rand= 0.5})

                    if actor_distance(self, self.parent, true) < 32 then 
                        self.parent:do_damage(10)
                        self:kill()

                        Particles:floating_image({
                            images.star_small_1,
                            images.star_small_2,
                        }, self.mid_x, self.mid_y, random_range_int(16, 20), 0,  1.0,  1, 200, 0.95, {life_rand= 0.5})
                    end
                end
            end,
        },
    }, "normal")
end

function FinalBossMinion:update(dt)
    FinalBossMinion.super.update(self, dt)

    self.state_machine:update(dt)

    if self.mid_x < -64 or self.mid_x > CANVAS_WIDTH + 64 then
        self:remove()
    end
end

function FinalBossMinion:on_negative_life()
    self:activate_aim()
end

function FinalBossMinion:on_stomped()
    self:activate_aim()
end

function FinalBossMinion:activate_aim()
    if self.state_machine.current_state_name == "normal" then        
        if self.parent and self.parent.is_active and not self.parent.is_dead then
            self:play_death_effects()
            self.state_machine:set_state("aim")
        else
            self:kill()    
        end
    end
end

function FinalBossMinion:draw()
    draw_centered(images.star_big_5, self.mid_x, self.mid_y, self.star_rot, 0.1, 0.1)

    if self.state_machine.current_state_name == "normal" then
        FinalBossMinion.super.draw(self)
    end
end

return FinalBossMinion