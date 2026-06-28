require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"
local TimedSpikes = require "scripts.actor.enemies.timed_spikes"
local BeeletMinion = require "scripts.actor.enemies.beelet_minion"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local BeeBoss = Enemy:inherit()

function BeeBoss:init(x, y)
    BeeBoss.super.init(self, x,y, images.bee_boss_alt_1, 32, 32)
    self.name = "bee_boss"

    self.is_boss = true
    self.score = 500

    self:set_max_life(150)
    self.is_killed_on_negative_life = false

    self.stomps = math.huge
    self.is_stompable = true
    self.damage_on_stomp = 10

    self.self_knockback_mult = 0.0

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.spr = AnimatedSprite:new({
        normal = {images.bee_boss_alt, 0.05, 2},
        dead = {images.bee_boss_dead, 0.05, 1},
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER) 

    self.def_friction_x = self.friction_x
    self.def_friction_y = self.friction_y
    self.friction_x = 1
    self.friction_y = 1

    self.attack_radius = 16
    self.thwomp_speed = 100

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.gravity = 0
    self.follow_player = false

    self.def_target_y = game.level.cabin_rect.ay + BW*6
    self.thwomp_telegraph_timer = Timer:new(0.3)

    self.spikes = {}
    self.minions = {}
    self.max_minions = 10

    self.damaged_player_throw_speed_x = 2000
    self.damaged_player_throw_speed_y = -300
    self.damaged_player_invincibility = 1.0

    self.ai_templates["bounce"] = {
        ready = function(ai)
            self.pong_direction = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
            self.pong_speed = 400
        end,
        update = function(ai, dt)
            self.pong_vx = math.cos(self.pong_direction) * self.pong_speed
            self.pong_vy = math.sin(self.pong_direction) * self.pong_speed
            
            self.vx = (self.pong_vx or 0)
            self.vy = (self.pong_vy or 0)
        end,
        after_collision = function(ai, col, other)
            if col.type ~= "cross" then
                local s = "metalfootstep_0"..tostring(love.math.random(0,4))
    
                local dx, dy = bounce_vector_cardinal(math.cos(self.pong_direction), math.sin(self.pong_direction), col.normal.x, col.normal.y)
                self.pong_direction = math.atan2(dy, dx)
            end
        end
    }

    self.state_timer = Timer:new(0.0)
    self.state_machine = StateMachine:new({
        random = {
            enter = function(state)
            end,
            update = function(state, dt)
                local possible_states = {
                    "pong",
                    "thwomp",
                    "spawn_minions",
                    "big_wave",
                }
                return random_sample_no_repeat(possible_states, self.previous_state_name)
            end,
        },

        -----------------------------------------------------
        
        pong = {
            enter = function(state)
                self.pong_telegraph_timer = Timer:new(1.0)
                self.pong_telegraph_timer:start()

                self.vx = 0
                self.vy = 0

                self.future_pong_dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
	            self.flip_mode = ENEMY_FLIP_MODE_MANUAL
                self.spr:set_flip_x(false)
                self.spr.rot = self.future_pong_dir - pi/2

                self:play_sound_var("sfx_boss_majesty_pong_telegraph_{01-04}", 0.1, 1.1)
            end,
            update = function(state, dt)
                local r = 3 * self.pong_telegraph_timer:get_ratio()
                self.spr:update_offset(random_neighbor(r), random_neighbor(r))

                if self.pong_telegraph_timer:update(dt) then
                    self:set_state("pong_attack")
                end
            end,
        },

        pong_attack = {
            enter = function(state)
                self:set_ai_template("bounce")
                self.pong_direction = self.future_pong_dir

                self.friction_x = 1
                self.friction_y = 1

                self.attack_bounces = random_range_int(5, 8)

                for _, spike in pairs(self.spikes) do
                    spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
                    spike:force_off()
                    spike:freeze()
                end
            end,
            update = function(state, dt)
                self.spr.rot = (self.pong_direction or 0) - pi/2

                if self.attack_bounces <= 0 then
                    self:set_state("pong_linger")
                end
            end,
            exit = function(state)
                self:set_ai_template()
            end,
            after_collision = function(state, col, other)
                if col.type ~= "cross" then
                    self.attack_bounces = self.attack_bounces - 1
                    
                    game:screenshake(4)
                    Input:vibrate_all(0.1, 0.45)
                    self:play_sound_var("sfx_boss_mrdung_bump_{01-02}", 0.2, 1.2)
                    self:play_sound_var("sfx_boss_majesty_pong_bounce_{01-10}", 0.1, 1.1)
                end
            end,
        },

        pong_linger = {
            enter = function(state)
                self.pong_telegraph_timer = Timer:new(1.0)
                self.pong_telegraph_timer:start()

                self.vx = 0
                self.vy = 0
            end,
            update = function(state, dt)
                local r = 3 * self.pong_telegraph_timer:get_inverse_ratio()
                self.spr:update_offset(random_neighbor(r), random_neighbor(r))

                if self.pong_telegraph_timer:update(dt) then
                    self:set_state("random")
                end
            end,
            exit = function (state)
                self.spr.rot = 0
            	self.flip_mode = ENEMY_FLIP_MODE_XVELOCITY
            end
        },

        -----------------------------------------------------
        
        thwomp = {
            enter = function(state)
                self:set_spikes_pattern_times(2, 0.75, 0.25)

                for _, spike in pairs(self.spikes) do
                    spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
                    spike:force_off()
                    spike:freeze()
                end
                self.friction_x = 1
                self.friction_y = 1

                self.stomps_counter = 1
            end,
            update = function(state, dt)
                self:set_state("thwomp_rise")
            end,
        },
        thwomp_flying = {
            enter = function(state)
                self.friction_y = self.def_friction_y
                
                self.thwomp_target = self:get_random_player()
                self.thwomp_target_x = {
                    mid_x = random_range(game.level.cabin_inner_rect.ax + 16, game.level.cabin_inner_rect.bx - 16)
                }
                self.vy = 0

            end,
            update = function(state, dt)
                if self.thwomp_target then
                    self.vx = self.thwomp_speed * sign(self.thwomp_target.mid_x - self.mid_x)
                end

                for _, player in pairs(game.players) do
                    if math.abs(self.mid_x - player.mid_x) <= self.attack_radius then
                        self:set_state("thwomp_telegraph")
                    end
                end

                if self.stomps_counter <= 0 then
                    self:set_state("random")
                end
            end
        }, 
        thwomp_telegraph = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                self.thwomp_telegraph_timer:start()
                
                self:play_sound_var("sfx_boss_majesty_thwomp_attack_{01-07}", 0.1, 1.1)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_speed * 0.5

                self.vy = -self.speed_y
                if self.thwomp_telegraph_timer:update(dt) then 
                    self:set_state("thwomp_attack")
                end
            end,
        },
        thwomp_attack = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_speed * 64
                self.friction_y = 1

                self.vy = self.vy + self.speed_y*dt
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and col.normal.x == 0 and col.normal.y == -1 then
                    game:screenshake(6)
                    self:set_spike_waves(0)
                    self:play_sound_var("sfx_boss_majesty_thwomp_impact_{01-03}", 0.1, 1.1)
                    self.stomps_counter = self.stomps_counter - 1

                    self:set_state("thwomp_rise")
                end
            end
        },
        thwomp_rise = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_speed * 64
                self.friction_y = 1

                self.vy = sign(self.def_target_y - self.y) * self.speed_y * dt
                if math.abs(self.y - self.def_target_y) < 6 then
                    self:set_state("thwomp_flying")
                end
            end,
        },        

        -----------------------------------------------------
        
        spawn_minions = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                self.state_timer:start(3.5)
                self.spawn_timer = Timer:new(1.0)
                self.spawn_timer:start()
                self.speed = 30

                self:set_ai_template("random_rotate")
                self.direction = random_range(0, pi2)
                self.friction_x = 0.8
                self.friction_y = 0.8

				self.direction = random_range(0, pi2)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(2), random_neighbor(2))
                self.spr.rot = self.spr.rot + dt*10

                if self.spawn_timer:update(dt) then
                    local amount = random_range_int(0, 2)
                    for i = 1, amount do
                        if #self.minions < self.max_minions then
                            local a = BeeletMinion:new(self.mid_x, self.mid_y)
                            a.z = self.z + 1
                            table.insert(self.minions, a)
                            game:new_actor(a)

                            self:play_sound_var("sfx_boss_majesty_minions_spawn_{01-08}", 0.2, 1.2)
                        end
                    end
                    self.spawn_timer:start()
                end
                if self.state_timer:update(dt) then
                    self:set_state("random")
                end
            end,
            after_collision = function(state, col)             
                local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
                self.direction = math.atan2(new_vy, new_vx)
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
                self.spr.rot = 0
                self.ai_template = nil

                self.follow_player = false
            end,
        },

        -----------------------------------------------------

        big_wave = {
            enter = function(state)
                self.vx = 0
                self.vy = 0
                self:set_spikes_pattern_big_wave()

                local spike = self.spikes[1]
                local t = 5
                if spike then
                    t = spike:get_cycle_total_time() + 0.9
                end
                self.state_timer:start(t)
                state.t = 0
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(2), random_neighbor(2))

                if self.state_timer:get_time_passed() > 1.0 then
                    self.is_stompable = false
                end
                
                if self.state_timer:update(dt) then
                    self.is_stompable = true
                    self:set_state("random")
                end
                state.t = state.t + dt
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)

                self.is_stompable = true
            end,
            draw = function(state)
                if self.is_stompable then
                    exec_color(ternary((state.t % 0.1) < 0.05, {1,1,1,1}, {1,1,1,0}), function()
                        draw_centered(images.bee_boss_shield, self.mid_x, self.mid_y)    
                    end)
                end
            end
        },

        dying = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                self.state_timer:start(2.0)

                self.is_stompable = false
                self.damage = 0

                Particles:push_layer(PARTICLE_LAYER_BACK)
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 1, {
                    color = COL_WHITE
                })
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 0.8, {
                    color = COL_LIGHT_RED
                })
                Particles:pop_layer()

                game:frameskip(30)
                game:screenshake(8)
                Input:vibrate_all(0.3, 0.7)

                self.spr:set_animation("dead")
                self.spr:set_shake(4)

                game.music_player:set_disk("off")
                self:play_sound("sfx_boss_majesty_death")
                state.t = 0.0

                state.sfx_t = 0.0
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:play_sound("sfx_boss_majesty_death")
                    Particles:ejected_player(images.bee_boss_dead, self.mid_x, self.mid_y)
                    
                    self:kill()
                end

                state.sfx_t = state.sfx_t - dt
                if state.sfx_t < 0.0 then
                    state.sfx_t = state.sfx_t + 0.3
                    self:play_sound("sfx_boss_majesty_hit_{01-06}")
                end

                state.t = state.t + dt
                self.spr:set_flashing_white(state.t % 0.2 < 0.1)
                self.spr:set_rotation(self.spr.rot + dt * 5)
            end,
        }

    }, "thwomp")

end

function BeeBoss:ready()
    BeeBoss.super.ready(self)
    self:spawn_spikes()
end

function BeeBoss:set_state(state_name)
    self.previous_state_name = self.state_machine.current_state_name
    self.state_machine:set_state(state_name)
end


function BeeBoss:update(dt)
    BeeBoss.super.update(self, dt)

    self.state_machine:update(dt)

    for i = #self.minions, 1, -1 do
        local m = self.minions[i]
        if m.is_removed then
            table.remove(self.minions, i)
        end
    end
end

function BeeBoss:draw()
    BeeBoss.super.draw(self)

    self.state_machine:draw()

    if not self.is_stompable and self.damage > 0 then
        draw_centered(images.bee_boss_shield, self.mid_x, self.mid_y)    
    end
end

function BeeBoss:on_stomped(player)
    game:frameskip(10)
    game:screenshake(8)

    self:set_invincibility(0.5)
    self:set_harmless(0.5)

    Audio:play_var("sfx_boss_majesty_crowd_happy_{01-04}", 0.1, 1.1)
    self:play_sound_var("sfx_boss_majesty_hit_{01-06}", 0.1, 1.1)
    game.level:add_fury(1.5)

    if game.level.elevator and game.level.elevator.cheer_audience then
        game.level.elevator:cheer_audience(2.0)
    end

    player:set_invincibility(self.damaged_player_invincibility)
    player.vy = self.damaged_player_throw_speed_y
    if player.mid_x < CANVAS_WIDTH/2 then
        player.vx = self.damaged_player_throw_speed_x
    else
        player.vx = -self.damaged_player_throw_speed_x
    end
end

function BeeBoss:on_negative_life()
    for _, actor in pairs(self.minions) do
        actor:kill()
    end

    for _, actor in pairs(self.spikes) do
        actor:remove()
    end

    game.ambience_player:fade_out("bee_boss_crowd_cheer", 0.4)
    game.level.elevator:cheer_audience_intense(200000000.0)

    self.state_machine:set_state("dying")
end

function BeeBoss:on_death()
end

function BeeBoss:on_damage_player(player, damage)
end

-----------------------------------------------------

function BeeBoss:set_spikes_pattern_times(t_off, t_telegraph, t_on)
    for _, spike in pairs(self.spikes) do
        spike:set_pattern_times(t_off, t_telegraph, t_on)
    end
end

function BeeBoss:set_spikes_length(length)
    for _, spike in pairs(self.spikes) do
        spike:set_length(length)
    end
end

function BeeBoss:set_spike_waves(direction)
    self:set_spikes_length(16)

    local function dist_func(source, spike)
        return 3 - 0.01 * dist(source.mid_x, source.mid_y, spike.mid_x, spike.mid_y)
    end

    for _, spike in pairs(self.spikes) do
        if spike.orientation == (direction or 0) then
            local t = (dist_func(self, spike))
            if t >= 0 then
                spike.do_circular_timing = false
                spike:force_off()
                spike:set_time_offset(t)
            end
        end
    end
end

function BeeBoss:set_spikes_pattern_big_wave()
    self:set_spikes_length(64)
    self:set_spikes_pattern_times(2, 0.6, 0.25)

    local wave_pos = random_sample{0, CANVAS_WIDTH}

    for _, spike in pairs(self.spikes) do
        if spike.orientation == 0 then
            local t = math.abs(spike.mid_x - wave_pos) / 200
            spike:force_off()
            spike:freeze()
            spike:standby(t, 0.5)
        else
            spike:force_off()
            spike:freeze()
        end
    end
end


-----------------------------------------------------

function BeeBoss:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col)
    end
end

function BeeBoss:spawn_spikes()
    self.spikes = {}

    local j = 0

    local t_off, t_tel, t_on = 2, 0.75, 0.25
    local t_total = t_off + t_tel + t_on
    local function spawn_spike(x, y, orientation, j)
        local spikes = TimedSpikes:new(x, y, t_off, t_tel, t_on, j*(t_total/68)*2, {
            orientation = orientation,
            start_after_standby = false,
            do_circular_timing = false,
        })
        spikes.spike_i = j
        spikes.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spikes.z = 2 - j/100
        
        spikes:force_off()
        -- spikes.debug_values[1] = j
        game:new_actor(spikes)
        table.insert(self.spikes, spikes)
    end
    local spikes

    -- Bottom
    for i = 3, CANVAS_WIDTH/16 - 4 do
        spawn_spike(i * BW, CANVAS_HEIGHT*0.85, 0, j)
    
        if i ~= CANVAS_WIDTH/16 - 4 then
            j = j + 1
        end
    end
end


return BeeBoss