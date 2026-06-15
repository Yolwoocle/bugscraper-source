require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local WallWalker = require "scripts.actor.enemies.wall_walker"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local RollossusMinion = require "scripts.actor.enemies.rollossus_minion"

local Rollossus = WallWalker:inherit()

function Rollossus:init(x, y) 
    Rollossus.super.init(self, x, y, images.rollossus_digging_1, 80, 80)
    self.name = "rollossus"
    self.is_pushable = false
    self.is_boss = true

    self.spr = AnimatedSprite:new({
        digging = {
            {images.rollossus_digging_1}, 0.1
        },
        telegraph = {
            {images.rollossus_telegraph_1}, 0.1
        },
        telegraph_spiked = {
            {images.rollossus_telegraph_spiked}, 0.1
        },
        flying = {
            {images.rollossus_outside}, 0.1
        },
        rolling = {
            {images.rollossus_roll}, 0.1
        },
        jump_telegraph = {
            {images.rollossus_eyes_closed}, 0.1
        },
    }, "digging")
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self:set_max_life(100)

    self.fly_speed = 500
    self.def_walk_speed = 250
    self.def_roll_speed = 300

    self.is_killed_on_stomp = false
    self.is_stompable = true
    self.damage_on_stomp = 10
    self.can_be_stomped_if_falling_down = false
    self.is_killed_on_negative_life = false
    self.head_ratio = 0.5
    self.do_stomp_animation = false
    
    self.score = 500

    self.sound_death = ""
    self.sound_stomp = ""
    self.sound_damage = "sfx_boss_rollossus_damage_{01-06}"

    self.is_immune_to_bullets = true
    self.destroy_bullet_on_impact = false

    self.damaged_player_throw_speed_x = 2000
    self.damaged_player_throw_speed_y = -500
    self.damaged_player_invincibility = 1.0

    self.dig_phase_player_see_range = 16*2

    self.reburrow_when_possible = false

    self.state_timer = Timer:new()
    self.state_machine = StateMachine:new({
        init = {
            update = function(state, dt)
                return "dig"
            end
        },
        dig_linger = {
            enter = function(state)
                self.walk_speed = 0
                self.damage = 0
                self.state_timer:start(1.0)

                self.gravity = 0
                self.is_stompable = false
                self.is_wall_walking = true

                self.can_burrow_back = false
                self.reburrow_when_possible = false

                self.is_bouncy_to_bullets = false

                self.spr:set_rotation(self.target_rot)
                self.spr:set_shake(3)
                self.spr:set_shake_decrease_speed(6)
                
                local ptc_x = self.mid_x - self.up_vect.x * self.w/2
                local ptc_y = self.mid_y - self.up_vect.y * self.w/2
                Particles:image(ptc_x, ptc_y, 30, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
                
                local ptc_x = self.mid_x - self.up_vect.x * self.w/4
                local ptc_y = self.mid_y - self.up_vect.y * self.w/4
                Particles:smoke(ptc_x, ptc_y, 40, {COL_WHITE, COL_LIGHTEST_GRAY, COL_LIGHT_GRAY}, --[[spw_rad]] self.w/2, --[[size]] 8, --[[sizevar]] 5)
                
                self:play_sound_var("sfx_boss_rollossus_dig_in_{01-03}")
            end,
            update = function(state, dt)
                if self.state_timer:get_time_passed() < 0.1 then
                    self.spr:set_scale(lerp(1.0, 0.7, self.state_timer:get_time_passed()/0.1))    
                else
                    self.spr:set_scale(1.0)
                    self.spr:set_animation("digging")
                end

                if self.state_timer:update(dt) then
                    return "dig"
                end
            end,
            exit = function(state)
                self.spr:set_shake(0)
                self.spr:set_shake_decrease_speed(0)
            end,
        },
        dig = {
            enter = function(state)
                self.walk_speed = self.def_walk_speed
                self.damage = 0
                self.walk_dir = state.override_walk_dir or random_sample{-1, 1}
                self.state_timer:start(random_range(0.2, 1.5))
                state.attack_player_minimum_burrow_time = 0.5 -- how much time the boss needs to have burrowed before attacking a player
                
                self.is_stompable = false
                self.is_wall_walking = true
                self.is_on_wall = true
                self.is_bouncy_to_bullets = false
                self.can_burrow_back = false
                
                self.spr:set_animation("digging")

                state.override_walk_dir = nil          
                
                self:set_constant_sound("dig", "sfx_boss_rollossus_digging_lp_{01-02}")
                self:set_constant_sound_volume("dig", 1.0)
            end,
            update = function(state, dt)
                local ox, oy = get_orthogonal(self.up_vect.x, self.up_vect.y, self.walk_dir)
                local x = self.mid_x - self.up_vect.x * self.h * 0.5 + ox * random_neighbor(self.w * 0.5) 
                local y = self.mid_y - self.up_vect.y * self.h * 0.5 + oy * random_neighbor(self.w * 0.5)
                Particles:image(x, y, 1, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8, nil, nil, nil, {
                    vx1 = -100,
                    vx2 = 100,
                    vy1 = -100,
                    vy2 = 100,
                })

                if self.state_timer:update(dt) or (self.state_timer:get_time_passed() > state.attack_player_minimum_burrow_time and self:find_player_in_dig_phase()) then
                    return "telegraph"
                end
            end,
            exit = function(state)
                self:set_constant_sound_volume("dig", 0.0)
            end
        },

        telegraph = {
            enter = function(state)
                self.walk_speed = 0
                self.damage = 0
                self.spr:update_offset(0, 0)
                self.gravity = 0

                self.is_stompable = false
                self.is_bouncy_to_bullets = false
                self.can_burrow_back = false

                self.state_timer:start(1.0)
                self.spr:set_shake(3)

                -- Set spiky
                if self.prevent_spiky_next_jump then
                    self.is_spiked_on_exit = false
                    self.prevent_spiky_next_jump = false
                else
                    self.is_spiked_on_exit = (random_range() < 1/2)
                end

                if self.is_spiked_on_exit then
                    self.prevent_spiky_next_jump = true
                end
                self.spr:set_animation(self.is_spiked_on_exit and "telegraph_spiked" or "telegraph")

                self:play_sound("sfx_boss_rollossus_telegraph_dig_out_{01-04}")
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "jump"
                end

                if random_range(0, 1) < 0.2 then
                    Particles:image(self.mid_x, self.mid_y, 1, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
                end
            end,
            draw = function(state)
                self.spr:update_offset(0, 0)
            end,
            exit = function(state)
                self.spr:set_shake(0)
            end,
        },

        jump = {
            enter = function(state)
                self.is_wall_walking = false
                self.damage = 1
                self.vx = self.up_vect.x * self.fly_speed
                self.vy = self.up_vect.y * self.fly_speed

                self.is_stompable = not self.is_spiked_on_exit
                self.is_bouncy_to_bullets = true
                self.can_burrow_back = false

                self.gravity = self.default_gravity
                self.spr:set_animation(self.is_spiked_on_exit and "rolling" or "flying")

                -- Visual effects
                local ptc_x = self.mid_x - self.up_vect.x * self.w/2
                local ptc_y = self.mid_y - self.up_vect.y * self.w/2
                Particles:image(ptc_x, ptc_y, 20, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
            	Particles:jump_dust_kick(ptc_x, ptc_y, math.atan2(self.vy, self.vx) + pi/2)

                local ptc_x = self.mid_x - self.up_vect.x * self.w/4
                local ptc_y = self.mid_y - self.up_vect.y * self.w/4
                local side_x, side_y = get_orthogonal(self.up_vect.x, self.up_vect.y)
                local params = {
                    vx = self.up_vect.x * 100,
                    vy = self.up_vect.y * 100,
                    vx_variation = math.abs(self.up_vect.x) * 50 + math.abs(side_x) * 20,
                    vy_variation = math.abs(self.up_vect.y) * 50 + math.abs(side_y) * 20,
                }
                Particles:smoke(ptc_x, ptc_y, 40, {COL_WHITE, COL_LIGHTEST_GRAY, COL_LIGHT_GRAY}, --[[spw_rad]] self.w/2, --[[size]] 8, --[[sizevar]] 5, params)
                self:play_sound("sfx_boss_rollossus_dig_out_{01-04}")

                self.spr:set_scale(0.5)

                -- Spawn obstacles
                local a = atan2(self.up_vect.y, self.up_vect.x)
                local flying_dung = create_actor_centered(RollossusMinion, self.mid_x, self.mid_y, self, {
                    start_angle = a - pi/4,
                })
                game:new_actor(flying_dung)
            end,
            
            update = function(state, dt)
                self.spr:set_scale(lerp(self.spr.sx, 1.0, 0.3))
            end,

            on_collision = function(state, col, other)
                if col.type ~= "cross" and not (col.normal.x == 0 and col.normal.y == 1) then
                    self.is_on_wall = true
                    self.is_wall_walking = true
                    self.up_vect.x = col.normal.x
                    self.up_vect.y = col.normal.y

                    Input:vibrate_all(0.3, 0.7)
                    game:screenshake(7)

                    self.state_machine:set_state("linger")
                end
            end,
        },

        linger = {
            enter = function(state)
                self.walk_speed = 0
                self.state_timer:start(1.0)
                self.spr:set_animation(self.is_spiked_on_exit and "rolling" or "flying")
                
                self.is_wall_walking = true
                self.is_stompable = not self.is_spiked_on_exit
                self.is_bouncy_to_bullets = true
                self.can_burrow_back = true

                self.spr.squash = 1.5
                self.spr:set_rotation(0)
                self.spr:set_scale(1)

                self:play_sound_var("sfx_boss_mrdung_jump_{01-06}", 0.1, 1.1) 
            end,

            update = function(state, dt)
                local r = 4 * clamp((self.state_timer.time-1) / (self.state_timer.duration-1), 0, 1)
                self.spr:update_offset(random_neighbor(r), random_neighbor(r))
                
                if self.state_timer:update(dt) then
                    if random_range(0, 1) < 0.5 then
                        return "bunny_hopping_telegraph"
                    end
                    return "telegraph_walk_to_wall"
                end 
            end,

            exit = function (state)
                self.spr:update_offset(0, 0)
            end
        },

        telegraph_walk_to_wall = {
            enter = function(state)
                self.walk_to_wall_dir = ternary(self.mid_x < CANVAS_WIDTH/2, 1, -1)

                self.is_stompable = not self.is_spiked_on_exit
                self.is_wall_walking = false
                self.is_bouncy_to_bullets = true
                self.can_burrow_back = true

                self.state_timer:start(0.5)
                self.spr:set_animation(self.is_spiked_on_exit and "rolling" or "flying")

                self.spr:animate_scale(1.3, 1.0, 1.5)
                self:play_sound("sfx_boss_rollossus_telegraph_rolling_{01-03}")
            end,
            update = function(state, dt)
                self.vx = 0
                self.spr:set_rotation(self.spr.rot + (1000 * self.walk_to_wall_dir * dt) / (self.h * 0.5))
                
                if self.state_timer:update(dt) then
                    return "walk_to_wall"
                end
            end,
        },

        walk_to_wall = {
            enter = function(state)
                self.is_stompable = not self.is_spiked_on_exit
                self.is_wall_walking = false
                self.is_bouncy_to_bullets = true
                self.can_burrow_back = true

                self.walk_speed = self.def_roll_speed
                self.state_timer:start(2.0)
                self.spr:set_animation("rolling")

                self.spr:animate_scale(1.3, 1.0, 1.5)

                self.unstompable_timer = Timer:new(0.05):start()

                self:set_constant_sound("roll", "sfx_boss_rollossus_rolling_lp")
                self:set_constant_sound_volume("roll", 1.0)
            end,
            update = function(state, dt)
                self.vx = self.walk_to_wall_dir * self.walk_speed
                self.spr:set_rotation(self.spr.rot + (self.vx * dt) / (self.h * 0.5))

                if self.unstompable_timer:update(dt) then
                    self.is_stompable = false
                end
            end,
            on_collision = function(state, col, other)
                self.spr:set_scale(1.0)
                if col.type ~= "cross" and col.normal.y == 0 then
                    if col.normal.x == 1 then
                        state.override_walk_dir = -1 
                    else
                        state.override_walk_dir = 1 
                    end

                    self.up_vect.x = col.normal.x
                    self.up_vect.y = col.normal.y
                    self.state_machine:set_state("dig_linger")
                end
            end,
            exit = function(state)
                self:set_constant_sound_volume("roll", 0.0)
            end,
        },
        
        --------------------------------------------------------
        
        bunny_hopping_telegraph = {
            enter = function(state)
                self.state_timer:start(1.2)

                self.is_wall_walking = false
                self.is_stompable = true

                self.gravity = self.default_gravity
                self.spr:set_animation("jump_telegraph")

                self:play_sound("sfx_boss_rollossus_telegraph_jumping_{01-04}")
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(3), random_neighbor(3))

                if self.state_timer:update(dt) then
                    return "bunny_hopping"
                end
            end
        },

        bunny_hopping = {
            enter = function(state)
                self.is_wall_walking = false
                self.is_stompable = true
                self.spr:set_animation("rolling")
                
                self.friction_x = 1
                
                self.jump_speed = 500
                self.gravity = self.default_gravity

                self.max_bounces = 4
                self.bounces = self.max_bounces

                self.burrow_back_on_grounded = false

                self.vx = random_sample{-1, 1} * 250
                
                self.unstompable_timer = Timer:new(0.1):start()
            end,

            update = function(state, dt)
                if self.unstompable_timer:update(dt) then
                    self.is_stompable = false
                end

                if self.is_grounded and self.bounces > 0 then
                    self.bounces = self.bounces - 1
                    self.jump_flag = true
                end

                if not self.state_timer.is_active then
                    self.spr:set_rotation(self.spr.rot + dt*3)
                end

                if self.state_timer:update(dt) then
                    return "dig_linger"
                end
            end,

            exit = function(state)
                self.spr:update_offset(0, 0)
                
                self.gravity = 0
                self.friction_x = 1
                self.friction_y = 1
            end,

            after_collision = function(state, col)
                if col.type ~= "cross" then
                    if self.bounces < self.max_bounces and not self.state_timer.is_active then
                        -- self:play_sound_var("sfx_boss_mrdung_jump_{01-06}", 0.1, 1.1) 
                        self:play_sound_var("sfx_boss_rollossus_jumping_impact_{01-05}", 0.1, 1.1) 

                        game:screenshake(4)
                        Input:vibrate_all(0.1, 0.3)
                    
                        if self.bounces <= 0 then
                            self.burrow_back_on_grounded = "wait"
                        end
                    end
                    if col.normal.y == 0 then
                        -- scotch scotch scotch
                        self.buffer_vx = math.abs(self.vx) * col.normal.x
                    end
                    if col.normal.y == -1 and self.burrow_back_on_grounded == "wait" then
                        self.burrow_back_on_grounded = "burrow"
                        self.vx = 0
                        self.state_timer:start(1.0)

                        self.is_stompable = true
                        self.spr:set_animation("flying")
                        self.damage = 1

                        self.spr:set_shake(5)
                        self.spr:set_shake_decrease_speed(15)
                    end
                end
            end
        },

        dying = {
            enter = function(state)
                game.music_player:set_disk("off")

                self.damage = 0
                self.is_stompable = false
                self.vx = 0
                self.vy = 0
                self.can_burrow_back = false
                self.gravity = self.default_gravity

                self.state_timer:start(1.0)
                
                game:screenshake(8)
                game:frameskip(20)

                Particles:push_layer(PARTICLE_LAYER_BACK)
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 2.3, {
                    color = COL_WHITE
                })
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 2, {
                    color = COL_LIGHT_RED
                })
                Particles:pop_layer()

                game.actor_manager:kill_actors_with_name("rollossus_minion")
                self.spr:set_animation("flying")

                self:play_sound("sfx_boss_rollossus_death")
            end,
            
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "exploding"
                end
            end
        },
        exploding = {
            enter = function(state)
                self.damage = 0
                self.is_stompable = false
                self.vx = 0
                self.vy = 0
                self.can_burrow_back = false

                self.state_timer:start(1.5)
                
                self.spr:set_shake(6)
                self.spr:set_shake_decrease_speed(0)                
            end,

            update = function(state, dt)
                local s = 1 + self.state_timer:get_ratio()*0.5
                self.spr:set_scale(s)
                self.spr:set_rotation(self.spr.rot + dt * 4)

                if self.state_timer:update(dt) then
                    self:kill()

                    game:screenshake(14)
                    game:frameskip(20)
                    Input:vibrate_all(0.3, 0.5)
                    -- number, spr, spw_rad, life, vs, g, params
                    Particles:image(
                        self.mid_x, self.mid_y, 
                        100, --numner
                        {images.green_fragment_1, images.green_fragment_2, images.green_fragment_3}, 
                        40, -- spwn_rad 
                        1, --life 
                        1.5, 
                        nil, 
                        {
                            vx1 = -150 * 1.5,
                            vx2 = 150 * 1.5,
                            vy1 = 80 * 1.5,
                            vy2 = -200 * 1.5,

                            scale = 1.5,
                        }
                    )
                    Particles:explosion(self.mid_x, self.mid_y, 80)
            
                end
            end,

            exit = function(state)
            end
        }
    }, "init")
end

function Rollossus:ready()
end

function Rollossus:update(dt)
    self.state_machine:update(dt)
    if self.reburrow_when_possible and self.can_burrow_back then
        self.state_machine:set_state("dig_linger")
    end

    if self.buffer_vx then
        self.vx = self.buffer_vx
        self.buffer_vx = nil
    end

    -- scotch
    if self.jump_flag then
        self.vy = -self.jump_speed
        self.jump_flag = false
    end

    Rollossus.super.update(self, dt)


    -- self.debug_values[1] = self.is_stompable
    -- self.debug_values[1] = self.state_machine.current_state_name
    -- self.debug_values[2] = "self.walk_dir "..tostring(self.walk_dir)
    -- self.debug_values[3] = "self.walk_speed "..tostring(self.walk_speed)
    -- self.debug_values[4] = "self.up.x "..tostring(self.up_vect.x).." self.up.y "..tostring(self.up_vect.y)

end

function Rollossus:on_collision(col, other)
    Rollossus.super.on_collision(self, col, other)
    self.state_machine:_call("on_collision", col, other)
end

function Rollossus:after_collision(col, other)
    Rollossus.super.after_collision(self, col, other)
    self.state_machine:_call("after_collision", col, other)
end

function Rollossus:draw()
    Rollossus.super.draw(self)
end

function Rollossus:find_player_in_dig_phase()
    if self.up_vect.x ~= 0 then
        return false
    end

    for _, player in pairs(game.players) do
        if math.abs(player.mid_x - self.mid_x) <= self.dig_phase_player_see_range then
            return true 
        end
    end
    return false
end

function Rollossus:on_stomped(player)
    Rollossus.super.on_stomped(self, player)
    
    game:frameskip(10)
    game:screenshake(8) 
    game.level:add_fury(2.5)

    self:set_invincibility(0.5)
    self:set_harmless(0.5)
    
    self.reburrow_when_possible = true

    player:set_invincibility(self.damaged_player_invincibility)
    player.vy = self.damaged_player_throw_speed_y
    if player.mid_x < CANVAS_WIDTH/2 then
        player.vx = -self.damaged_player_throw_speed_x
    else
        player.vx = self.damaged_player_throw_speed_x
    end
end

function Rollossus:on_negative_life()
    self.state_machine:set_state("dying")
end

return Rollossus