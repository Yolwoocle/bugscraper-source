require "scripts.util"
local images = require "data.images"
local CollisionInfo = require "scripts.physics.collision_info"

local BreakableActor = require "scripts.actor.enemies.breakable_actor"
local Button = require "scripts.actor.enemies.button_big"
local Loot = require "scripts.actor.loot"

local HeartJar = BreakableActor:inherit()

function HeartJar:init(x, y, params)
    params = params or {}

    HeartJar.super.init(self, x, y, images.heart_jar, 28, 28)
    self.name = "heart_jar"

    self.images_cracked = {images.heart_jar}
    self.life = 10

    self.sounds_impact = "sfx_actor_button_small_glass_damage_{01-06}"
    self.sound_fracture = ""
    self.sound_break = "sfx_actor_button_small_glass_break"

    self.break_screenshake = 8
    self.break_num_particles = 50
    self.heart_count_per_player = param(params.heart_count_per_player, 1)

    self.counts_as_enemy = true

    self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_SEMISOLID,
        is_slidable = true,

        walk_sound = "sfx_player_footstep_metal_{01-10}",
        slide_sound = "sfx_player_wall_slide_metal_{01-02}",
        land_sound = "sfx_player_footstep_land_metal_{01-04}",
    }
end

function HeartJar:on_death()
    HeartJar.super.on_death(self)

    for _, player in pairs(game.players) do
        for i=1, self.heart_count_per_player do
            local vx = random_neighbor(300)
            local vy = random_range(-200, -500)
            local instance = Loot.Life:new(self.mid_x, self.mid_y, 1, vx, vy, {
                target_player = player,
                only_collect_by_target = true,
                ignore_collisions = true,
            })
            
            game:new_actor(instance)
        end
    end
end

return HeartJar