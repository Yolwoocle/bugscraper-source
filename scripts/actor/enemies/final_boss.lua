require "scripts.util"
local Enemy          = require "scripts.actor.enemy"
local sounds         = require "data.sounds"
local images         = require "data.images"
local ElectricRays   = require "scripts.actor.enemies.electric_rays"
local StateMachine   = require "scripts.state_machine"
local Timer          = require "scripts.timer"
local Segment        = require "scripts.math.segment"
local guns           = require "data.guns"
local TimedSpikes    = require "scripts.actor.enemies.timed_spikes"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local CollisionInfo = require "scripts.physics.collision_info"
local FinalBossMinion = require "scripts.actor.enemies.final_boss_minion"

local Larva =              require "scripts.actor.enemies.larva"
local Fly =                require "scripts.actor.enemies.fly"
local SpikedFly =          require "scripts.actor.enemies.spiked_fly"
local Woodlouse =          require "scripts.actor.enemies.woodlouse"
local Slug =               require "scripts.actor.enemies.slug"
local Spider =             require "scripts.actor.enemies.spider"
local StinkBug =           require "scripts.actor.enemies.stink_bug"
local SnailShelled =       require "scripts.actor.enemies.snail_shelled" 
local Boomshroom =         require "scripts.actor.enemies.boomshroom" 
local Dung =               require "scripts.actor.enemies.dung"
local DungBeetle =         require "scripts.actor.enemies.dung_beetle"
local DungProjectile =     require "scripts.actor.enemies.dung_projectile"
local FlyingDung =         require "scripts.actor.enemies.flying_dung"

local FinalBoss      = Enemy:inherit()

local LAYER_CEO = 1
local LAYER_DESK = 2
local LAYER_GLASS = 3
local LAYER_ROBOT_LEGS = 4

function FinalBoss:init(x, y, params)
    params = params or {}
    
    self:init_enemy(x, y, images.ceo, 86, 68)
    self.name = "final_boss"

    self.is_boss = true

    self.spr = AnimatedSprite:new({
        introduction = { images.ceo_npc_idle, 0.2, 4 },
        fight = { images.ceo_npc_idle, 0.2, 4 },

        angry_idle = { images.ceo_npc_angry_idle, 0.1, 4 },
        angry_airborne = { images.ceo_npc_angry_airborne, 0.2, 1 },

        fainted = { images.ceo_npc_fainted, 0.1, 4 },
        shocked = { images.ceo_npc_shocked, 0.2, 1 },
        airborne = { images.ceo_npc_airborne, 0.2, 1 },
        jetpack = { images.ceo_npc_jetpack, 0.2, 1 },
        clap = { images.ceo_npc_clap_hand, 0.02, 3, nil, { looping = false } },
        tangled_wires = {images.ceo_tangled_wires, 0.1, 1},
        tangled_wires_shocked = {images.ceo_tangled_wires_shocked, 0.1, 1},
    }, "introduction")

    self.score = 1000

    self.phase = 1

    self.layers = {
        { 
            spr = self.spr, 
            is_visible = true, 
            offset = {x = 0, y = -16}
        },
        { -- Desk
            spr = AnimatedSprite:new({
                normal = { { images.ceo_office_desk }, 0.1 },
            }, "normal"),
            is_visible = true,
        },
        { -- Glass
            spr = AnimatedSprite:new({
                break_0 = { { images.ceo_office_glass }, 0.1 },
                break_1 = { { images.ceo_office_glass_break_1 }, 0.1 },
                break_2 = { { images.ceo_office_glass_break_2 }, 0.1 },
                break_3 = { { images.ceo_office_glass_break_3 }, 0.1 },
            }, "break_0"),
            is_visible = true
        },
        { -- Legs
            spr = AnimatedSprite:new({
                normal = { { images.ceo_office_legs }, 0.1 },
            }, "normal"),
            is_visible = true
        },
    }

    self.furious_smoke_spr = AnimatedSprite:new({
        normal = { images.furious_smoke, 0.1, 3 },
    }, "normal")

    -- Parameters
    self.def_friction_y = self.friction_y
    self:set_max_life(160)
    self.is_flying = true
    self.gravity = 0
    self.attack_radius = 64

    self.is_stompable = false
    self.is_pushable = false
    self.is_killed_on_negative_life = false
    
    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true
    
    self.can_be_stomped_if_falling_down = false
    self.damage_on_stomp = 5

    self.speed = 10
    self.speed_x = self.speed
    self.speed_y = self.speed * 3
    self.friction_x = 0.8
    self.friction_y = 0.8
    self.thwomp_follow_player_speed = 120
    self.thwomp_telegraph_speed = self.speed * 8
    self.thwomp_attack_speed = self.speed * 400
    self.thwomp_rise_speed = self.speed * 800

    self.follow_player = false
    self.self_knockback_mult = 0
    self.stomps = math.huge
    self.friction_y = self.friction_x
    self.def_target_y = game.level.cabin_rect.ay + BW * 3
    self.telegraph_oy = 16

    self.charge_speed = 600

    -- Timers
    self.telegraph_timer = Timer:new(0.5)

    self.sin_x_value = 0
    self.sin_y_value = 0

    self.speed = 100
    self.state_timer = Timer:new(6)
    self.unstompable_timer = Timer:new(1)

    self.spikes = {}

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.glass_break_state = 0

    -- Spawn minon timer
    self.do_minion_spawning = false
    self.spawn_minion_timer = Timer:new({2.0, 4.0})
    self.minions = {}
    self.max_minions = 6

    -- State machine
    self.state_machine = StateMachine:new({
        introduction = {
            enter = function(state)
                self.spr:set_animation("introduction")
            end,
        },

        start = {
            enter = function(state)
                self.spr:set_animation("fight")
                for _, l in pairs(self.layers) do
                    l.is_visible = true
                end

                self.do_minion_spawning = true
                self.spawn_minion_timer:start()
            end,
            update = function(state, dt)
                self:spawn_spikes(0, 0)
                self:reset_spikes()
                return "charge"
            end,
        },

        random = {
            enter = function(state)
            end,
            update = function(state, dt)
                local possible_states = {
                    "thwomp",
                    "charge",
                    "bunny_hopping_telegraph",
                }
                self.state_machine:set_state(random_sample_no_repeat(possible_states, self.previous_state))
            end,
        },

        waiting = {
            enter = function(state)
                self.state_timer:start(0.5)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "random"
                end
            end
        },

        mid_phase = {
            enter = function(state)
                self.phase = 2
                
                self.vx = 0
                self.vy = 0
                self.speed_x = 0

                self.friction_x = 1
                self.friction_y = self.def_friction_y

                self.gravity = self.default_gravity
                self.damage = 0
                
                state.jumps = 7
                state.y = -16
                state.vy = 0

                self:play_sound("sfx_boss_ceo_phase2")
            end,
            update = function(state, dt)
                self.furious_smoke_spr:update(dt)

                state.vy = state.vy + self.gravity
                state.y = state.y + state.vy * dt
                state.y = min(-16, state.y)

                self.spr:set_animation("angry_airborne")
                if state.y >= -16 and state.vy > 300 then
                    state.vy = -200
                    state.jumps = state.jumps - 1

                    if state.jumps <= 0 then
                        return "waiting"
                    end
                end
                
                self.layers[1].offset.y = state.y
            end, 
            exit = function(state)
                self.damage = 1
                self.layers[1].offset.y = -16

                self.spr:set_animation("angry_idle")
            end,
            draw_bg = function(state)
                local ox, oy = self.layers[1].offset.x, self.layers[1].offset.y

                self.furious_smoke_spr:set_flip_x(true)
                self.furious_smoke_spr:set_anchor(SPRITE_ANCHOR_LEFT_CENTER)
                self.furious_smoke_spr:draw(self.mid_x - 34 + ox, self.y + 42 + oy)

                self.furious_smoke_spr:set_flip_x(false)
                self.furious_smoke_spr:set_anchor(SPRITE_ANCHOR_RIGHT_CENTER)
                self.furious_smoke_spr:draw(self.mid_x + 34 + ox, self.y + 42 + oy)
            end
        },

        -----------------------------------------------------
        --- JUMPING ---
        -----------------------------------------------------
        bunny_hopping_telegraph = {
            enter = function(state)
                self.speed_x = 0
                local time = ternary(self.phase == 1, 1.3, 0.7)
                self.state_timer:start(time)

                self.friction_x = 1
                self.friction_y = self.def_friction_y

                self.gravity = self.default_gravity

                self.bunny_hop_target = self:get_random_player()
                
                self.telegraph_t = 0
                self.telegraph_vx = 0
                self.telegraph_vy = 0

                self:play_sound("sfx_boss_ceo_telegraph_lob_{01-04}")
            end,
            update = function(state, dt)
                local ox = 0
                if self.bunny_hop_target then
                    ox = (self.bunny_hop_target.mid_x - self.mid_x) / 64

                    self.telegraph_vx = (self.bunny_hop_target.mid_x - self.mid_x)
                    self.telegraph_vy = -500
                end
                self.spr:update_offset(ox + random_neighbor_int(3), 5 + random_neighbor_int(3))
                

                if self.state_timer:update(dt) then
                    return "bunny_hopping"
                end

                self.telegraph_t = self.telegraph_t + dt*200
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
            draw_bg = function(state)
                local tx = 0
                local ty = 0
                local tvx, tvy = self.telegraph_vx, self.telegraph_vy
                
                local gap = 24
                local r = self.telegraph_t % gap
                tvy = tvy + self.gravity * self.gravity_mult * 3 * r/gap
                tx = tx + tvx * (1/20) * r/gap
                ty = ty + tvy * (1/20) * r/gap
                for i=1, 12 do
                    local dx, dy = normalise_vect(tvx, tvy)
                    circle_color({1,1,1, clamp((12-i)/6, 0, 0.7)}, "fill", self.mid_x + tx, self.mid_y + ty, 4.5)
                    tvy = tvy + self.gravity * self.gravity_mult * 3
                    
                    tx = tx + tvx * (1/60) * 3
                    ty = ty + tvy * (1/60) * 3
                end
            end
        },
        bunny_hopping = {
            enter = function(state)
                self.vx = self.telegraph_vx
                self.vy = self.telegraph_vy

                if not self.bunny_hop_target then
                    return
                end

            end,
            after_collision = function(state, col)
                if col.normal.y == -1 then
                    self:wait_then_random_wave()
                    self.vx = 0
                    Input:vibrate_all(0.2, 0.5)
                    game:screenshake(6)
                    self:play_sound_var("sfx_boss_ceo_stomp_{01-04}", 0.1, 1.1)
                end
            end
        },

        -----------------------------------------------------
        --- CHARGE ---
        -----------------------------------------------------
        charge = {
            enter = function(state)
                local target = self:get_random_player()
                local dir
                if target then
                    dir = sign(target.mid_x - self.mid_x)
                else
                    dir = random_sample { -1, 1 }
                end

                self.friction_x = 1
                self.friction_y = self.def_friction_y

                self.charge_dir = dir
                self.gravity = self.default_gravity
            end,
            update = function(state, dt)
                return "charge_telegraph"
            end,
        },
        charge_telegraph = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                local charge_time = ternary(self.phase == 1, 1.5, 0.7)
                self.state_timer:start(charge_time)

                self.telegraph_t = 0

                self:play_sound("sfx_boss_ceo_telegraph_dash_{01-04}")
            end,
            update = function(state, dt)
                self.telegraph_t = (self.telegraph_t + dt * 200) % images.ceo_telegraph_arrow:getWidth()

                self.spr:update_offset(random_neighbor_int(3), random_neighbor_int(3))
                if self.state_timer:update(dt) then
                    return "charging"
                end
            end,
            draw_bg = function(state)
                local a, b, step
                if self.charge_dir == 1 then
                    a = self.x + self.telegraph_t
                    b = self.x + 200
                    step = images.ceo_telegraph_arrow:getWidth()
                else
                    a = self.x + self.w - self.telegraph_t
                    b = self.x + self.w - 200
                    step = -images.ceo_telegraph_arrow:getWidth()
                end
                for ix = a, b, step do
                    local alpha = 0.8
                    if math.abs(ix - a) < 32 then
                        alpha = 0.8 * math.abs(ix - a) / 32
                    end
                    if math.abs(ix - b) < 32 then
                        alpha = 0.8 * math.abs(ix - b) / 32
                    end
                    exec_color({ 1, 1, 1, alpha }, function()
                        love.graphics.draw(images.ceo_telegraph_arrow, ix, self.y, 0, self.charge_dir, 1)
                    end)
                end
            end,
        },
        charging = {
            enter = function(state)
                self.vx = self.charge_dir * self.charge_speed
                self.vy = 0
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and math.abs(col.normal.x) == 1 then
                    self:play_sound_var("sfx_boss_ceo_dash_{01-06}", 0.1, 1.1)
                    self:wait_then_random_wave()
                    Input:vibrate_all(0.2, 0.5)
                    game:screenshake(6)
                end
            end
        },

        -----------------------------------------------------
        --- THWOMP ---
        -----------------------------------------------------
        thwomp = {
            enter = function(state)
                self:reset_spikes()

                self.stomps_counter = 2
                self.gravity = 0
            end,
            update = function(state, dt)
                self.state_machine:set_state("thwomp_rise")
            end,
        },
        thwomp_flying = {
            enter = function(state)
                self.friction_y = self.def_friction_y

                self.thwomp_target = self:get_random_player()
                self.vy = 0
            end,
            update = function(state, dt)
                if self.thwomp_target then
                    self.vx = self.thwomp_follow_player_speed * sign(self.thwomp_target.mid_x - self.mid_x) * ternary(self.phase == 1, 1, 1.5)
                end

                for _, player in pairs(game.players) do
                    if math.abs(self.mid_x - player.mid_x) <= self.attack_radius then
                        return "thwomp_telegraph"
                    end
                end

                if self.stomps_counter <= 0 then
                    self:wait_then_random_wave()
                    return
                end
            end
        },
        thwomp_telegraph = {
            enter = function(state)
                self.vx = 0
                self.vy = 0

                self.telegraph_timer:start()
                self:play_sound_var("sfx_boss_ceo_telegraph_stomp_{01-04}", 0.1, 1.1)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_telegraph_speed * ternary(self.phase == 1, 1, 1.5)

                self.vy = -self.speed_y
                if self.telegraph_timer:update(dt) then
                    return "thwomp_attack"
                end
                self.spr:update_offset(random_neighbor_int(3), random_neighbor_int(3))
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
        thwomp_attack = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_attack_speed
                self.friction_y = 1

                self.vy = self.vy + self.speed_y * dt * ternary(self.phase == 1, 1, 1.5)
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and col.normal.x == 0 and col.normal.y == -1 then
                    self.stomps_counter = self.stomps_counter - 1

                    if self.stomps_counter <= 0 then
                        self:wait_then_random_wave()
                    else
                        self.state_machine:set_state("thwomp_rise")
                    end

                    self:play_sound_var("sfx_boss_ceo_stomp_{01-04}", 0.1, 1.1)
                    Input:vibrate_all(0.2, 0.5)
                    game:screenshake(6)
                    self:set_spike_waves()
                end
            end
        },
        thwomp_rise = {
            enter = function(state)
            end,
            update = function(state, dt)
                self.speed_x = 0
                self.speed_y = self.thwomp_rise_speed
                self.friction_y = 1

                self.vy = -self.speed_y * dt
                if self.y < self.def_target_y then
                    self.state_machine:set_state("thwomp_flying")
                end
            end,
        },

        -----------------------------------------------------
        --- FINAL SECTION ---
        -----------------------------------------------------

        death_animation = {
            enter = function(state)
                self:reset_spikes()
                self.vx = 0
                self.vy = 0
                self.friction_x = 0
                self.gravity = self.default_gravity
                self.damage = 0 
                self.life = 0
	            self.fury_damage_multiplier = 0.0

                self.disable_minions = true
                
                self.invincible_timer = math.huge
                self.destroy_bullet_on_impact = false

                Particles:push_layer(PARTICLE_LAYER_BACK)
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 1, {
                    color = COL_WHITE
                })
                Particles:static_image(images.star_big, self.mid_x, self.mid_y, 0, 0.05, 0.9, {
                    color = COL_LIGHT_RED
                })
                Particles:pop_layer()
                
                Particles:image(self.mid_x, self.mid_y, 80, images.glass_shard, self.h)

                self.spr:set_animation("fainted")
                self.layers[LAYER_GLASS].spr:set_visible(false)
                
                self.layers[LAYER_CEO].offset.y = -16

                game:frameskip(60*1.5)
                game:screenshake(15)

                game.actor_manager:remove_actors_with_name("final_boss_minion")
                
                game.music_player:set_disk("off")

                state.f = 2

                game:play_cutscene("final_boss_death")
                self:play_sound("sfx_boss_ceo_death")

                self.do_minion_spawning = false
                for _, m in pairs(self.minions) do
                    m:remove()
                end
            end,

            update = function(state, dt)
                -- state.f = state.f - 1
                -- if state.f == 0 then
                --     self.spr:set_visible(false)
                --     Particles:ejected_player(images.ceo_npc_fainted_single, self.mid_x, self.mid_y)
                -- end
            end
        },     
        
    }, param(params.init_state, "start"))
end

function FinalBoss:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)

    if self.unstompable_timer:update(dt) then
        self.spr:set_color(COL_WHITE)
        self.damage = 1
    end
    if self.unstompable_timer.is_active then
        local freq = ternary(self.unstompable_timer.time < self.unstompable_timer.duration / 2, 0.12, 0.07)
        if self.unstompable_timer.time % freq > freq / 2 then
            self.spr:set_color(COL_WHITE)
        else
            self.spr:set_color({ 0.5, 0.5, 0.5 })
        end
    end

    for _, layer in pairs(self.layers) do
        layer.spr:update_offset(self.spr.ox, self.spr.oy)
        layer.spr:set_flashing_white(self.spr.is_flashing_white)
    end

    local new_glass_break_state = floor(4 * (1 - self.life / self.max_life))
    if new_glass_break_state ~= self.glass_break_state then
        self.glass_break_state = new_glass_break_state
        Particles:image(self.mid_x, self.mid_y, 40, images.glass_shard, self.h)

        self.layers[LAYER_GLASS].spr:set_animation("break_"..tostring(clamp(new_glass_break_state, 0, 3)))
        game:screenshake(4)
        Input:vibrate_all(0.1, 0.3)
        if self.life > 0 then
            self:play_sound_var("sfx_actor_upgrade_display_break_{01-04}", 0.1, 1.1)
        end
    end

    -- minions
    if self.spawn_minion_timer:update(dt) and not self.disable_minions then
        self.spawn_minion_timer:start()

        if #self.minions < self.max_minions then
            local dir = random_sample({false, true})
            local x, dx
            local y = random_range(game.level.cabin_inner_rect.ay + 32, game.level.cabin_inner_rect.by - 32)

            if dir then
                x = -24
                dx = 1
            else
                x = CANVAS_WIDTH
                dx = -1
            end

            local e = FinalBossMinion:new(x, y, {dir_x = dx, dir_y = 0, parent=self})
            game:new_actor(e)

            table.insert(self.minions, e)
        end

        for i=#self.minions, 1, -1 do
            if self.minions[i].is_dead or self.minions[i].is_removed then
                table.remove(self.minions, i)
            end
        end
    end
end

function FinalBoss:on_damage()
    FinalBoss.super.on_damage(self)

    game:screenshake(6)
    game:frameskip(8)

    if self.phase == 1 and self.life <= self.max_life/2 + 0.01 then
        self.state_machine:set_state("mid_phase")
    end
end

function FinalBoss:on_negative_life()
    self.state_machine:set_state("death_animation")
end

function FinalBoss:wait_then_random_wave()
    self.previous_state = ({
        bunny_hopping_telegraph = "bunny_hopping_telegraph",
        bunny_hopping = "bunny_hopping_telegraph",
        charge = "", --it's fine to repeat multiple charges
        charge_telegraph = "",
        charging = "",
        thwomp = "thwomp",
        thwomp_flying = "thwomp",
        thwomp_telegraph = "thwomp",
        thwomp_attack = "thwomp",
        thwomp_rise = "thwomp",
    })[self.state_machine.current_state_name]
    
    self.state_machine:set_state("waiting")
end

function FinalBoss:on_stomped(player)
    self.unstompable_timer:start()
    self.damage = 0

    game:frameskip(10)
    game:screenshake(4)
    Input:vibrate(player.n, 0.1, 0.3)
end

function FinalBoss:reset_spikes()
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spike:force_off()
        spike:freeze()
    end
end

function FinalBoss:after_collision(col, other)
    if col.type ~= "cross" then
        self.state_machine:_call("after_collision", col)
    end
end

function FinalBoss:draw()
    self.state_machine:_call("draw_bg")

    local def_spr = self.spr
    for i, layer in pairs(self.layers) do
        if layer.is_visible then
            self.spr = layer.spr
            
            if layer.offset then
                self.spr:update_offset(self.spr.ox + layer.offset.x, self.spr.oy + layer.offset.y)
            end
            self:draw_enemy()
            if layer.offset then
                self.spr:update_offset(self.spr.ox - layer.offset.x, self.spr.oy - layer.offset.y)
            end
        end
    end
    self.spr = def_spr

    self.state_machine:draw()
end

function FinalBoss:set_spike_waves()
    local function dist_func(source, spike)
        return 3 - 0.01 * dist(source.mid_x, source.mid_y, spike.mid_x, spike.mid_y)
    end

    for _, spike in pairs(self.spikes) do
        if spike.orientation == 0 then
            local t = (dist_func(self, spike))
            if t >= 0 then
                spike:set_time_offset(t)
            end
        end
    end
end

function FinalBoss:set_spikes_pattern_timing()
    for _, spike in pairs(self.spikes) do
        spike.timing_mode = TIMED_SPIKES_TIMING_MODE_TEMPORAL
        spike:force_off()
        spike:freeze()
        spike:set_time_offset(0)
    end
end

function FinalBoss:set_spikes_pattern_spinning(time_offset, number_of_waves)
    local t_total = self.spikes[1]:get_cycle_total_time()
    for _, spike in pairs(self.spikes) do
        -- spike:set_time_offset()
        spike:standby(spike.spike_i * (t_total / 68) * number_of_waves + time_offset, 1.5)
    end
end

function FinalBoss:spawn_spikes(tile_ox, tile_oy)
    self.spikes = {}

    local j = 0

    local t_off, t_tel, t_on = 2.0, 0.75, 0.25
    local t_total = t_off + t_tel + t_on
    local function spawn_spike(x, y, orientation, j)
        local spikes = TimedSpikes:new(x, y, t_off, t_tel, t_on, j * (t_total / 68) * 2, {
            orientation = orientation,
            start_after_standby = false,
            do_circular_timing = false,
        })
        spikes.spike_i = j
        spikes.timing_mode = TIMED_SPIKES_TIMING_MODE_MANUAL
        spikes.z = 2 - j / 100
        -- spikes.debug_values[1] = j
        game:new_actor(spikes)
        table.insert(self.spikes, spikes)
    end
    local spikes

    -- Bottom
    for i = 3, CANVAS_WIDTH / 16 - 4 do
        spawn_spike(tile_ox*16 + i * BW, tile_oy*16 + CANVAS_HEIGHT * 0.85, 0, j)

        if i ~= CANVAS_WIDTH / 16 - 4 then
            j = j + 1
        end
    end
end

return FinalBoss
