require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local CloudDropperProjectile = require "scripts.actor.enemies.cloud_dropper_projectile"
local sounds = require "data.sounds"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images = require "data.images"

local CloudDropper = Fly:inherit()
	
function CloudDropper:init(x, y)
    CloudDropper.super.init(self, x,y, images["cloud_enemy_size3"], 16, 16, false)
    self.name = "cloud_dropper"
    self.max_life = 4
    self.life = self.max_life
    self.score = 10

    self.ai_template = "random_rotate"
    
    self.do_stomp_animation = false
    self.counts_as_enemy = true
    self.follow_player = false
    self.is_killed_on_stomp = false
    self.is_stompable = false
    
    self.spr = AnimatedSprite:new({
		normal = {images.cloud_dropper},
        fall = {images.cloud_dropper_shocked},
	}, "normal", SPRITE_ANCHOR_CENTER_CENTER)
    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.anim_frames = nil
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.state_machine = StateMachine:new({
        flying = {
            enter = function(state)
                self.ai_template = "random_rotate"
                self.spr:set_animation("normal")
            end,
            update = function(state, dt)
                Particles:push_layer(PARTICLE_LAYER_BACK)
                -- for i=-1, 1, 2 do
                --     Particles:smoke_big(self.mid_x + i*14, self.mid_y + 8, 
                --         {
                --             COL_WHITE, COL_LIGHTEST_GRAY, COL_LIGHT_GRAY
                --         }, 
                --         8, -- rad
                --         3, -- quantity
                --         {
                --             size = 4,
                --             vx = 0, 
                --             vx_variation = 10, 
                --             vy = 40, 
                --             vy_variation = 20,
                --             min_spawn_delay = 0,
                --             max_spawn_delay = 0.2,
                --         }
                --     )
                -- end
                Particles:pop_layer()
            end,
            after_collision = function(state, col, other)
                if col.type ~= "cross" and self.direction then
                    local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
                    self.direction = math.atan2(new_vy, new_vx)
                end
            end
        },
        shake = {
            enter = function(state)
                self.spr:set_animation("fall")

                self.timer = Timer:new(0.5):start()
                self.spr:set_shake(1.0)

                self.ai_template = 0
                self.gravity = 0
                self.vx = 0
                self.vy = 0
                self:play_sound_var("sfx_ennemy_dropper_trigger_{01-04}", 0.1, 1.1)
            end,
            update = function(state, dt)
                if self.t % 0.2 < 0.1 then
                    self.spr:set_flashing_white(true)
                else
                    self.spr:set_flashing_white(false)
                end
                if self.timer:update(dt) then
                    return "falling"
                end
            end,
            exit = function(state)
                self.spr:set_flashing_white(false)
            end
        },
        falling = {
            enter = function(state)
                self.ai_template = nil
                self.gravity = self.default_gravity

                self.friction_y = 1
                self.spr:set_animation("fall")

                self:play_sound_var("sfx_enemy_honeypot_liquid_falling_{01-04}", 0.2, 1.2)
                -- self:set_constant_sound_volume("drop", 1.0 + random_neighbor(0.2))
                -- self:play_constant_sound("drop")
            end,
            after_collision = function(state, col, other)
                if col.type ~= "cross" and col.normal.y == -1 then
                    self:kill()
                    return
                end
            end
        }
    }, "flying")
end

function CloudDropper:after_collision(col, other)
    CloudDropper.super.after_collision(self, col, other)
    self.state_machine:_call("after_collision", col, other)
end

function CloudDropper:update(dt)
    CloudDropper.super.update(self, dt)
    self.state_machine:update(dt)
end

function CloudDropper:draw()
    CloudDropper.super.draw(self)
end

function CloudDropper:on_death()
    for i = 1, 4 do
        local cloud = CloudDropperProjectile:new(self.mid_x - 4, self.y, 2)
        cloud.vx = 1.5 * ({-150, 150, -60, 60})[i]
        cloud.vy = 1.5 * ({-150, -150, -200, -200})[i]
        cloud.harmless_timer = 0.5
        cloud.invincible_timer = 0.1
        game:new_actor(cloud)
    end
end

function CloudDropper:on_damage(amount)
    if self.state_machine.current_state_name == "flying" then
        self.state_machine:set_state("shake")
    end
end

function CloudDropper:on_stomped()
    if self.state_machine.current_state_name == "flying" then
        self.state_machine:set_state("shake")
    end
end

return CloudDropper