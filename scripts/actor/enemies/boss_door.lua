require "scripts.util"
local images = require "data.images"

local BreakableActor = require "scripts.actor.enemies.breakable_actor"

local BossDoor = BreakableActor:inherit()

function BossDoor:init(x, y, params)
    params = params or {}
    BossDoor.super.init(self, x,y, images.boss_door, 16, 16*5)
    self.name = "button_big_glass"

    self.images_cracked = {
        images.boss_door_cracked,
        images.boss_door,
    }

    self.max_life = 30
    self.life = self.max_life

    self.cutscene = params.cutscene
    
    self.change_break_state_particle_image = {images.wood_fragment_1, images.wood_fragment_2, images.wood_fragment_3}
    self.break_particle_image = {images.wood_fragment_1, images.wood_fragment_2, images.wood_fragment_3}

    self.sound_fracture = {"sfx_cutscene_door_cracked"}
    self.sound_break = {"sfx_cutscene_door_break"}
    self.sounds_impact = "sfx_cutscene_door_impact_{01-04}"
end

function BossDoor:on_death()
    BossDoor.super.on_death(self)

    game.camera:set_target_offset(1000, 0)
    game.camera.max_x = 76*16

    for _, actor in pairs(game.actors) do
        if actor.name == "cocoon" then
            actor:revive(nil)
        end
    end

    if self.cutscene then
        game:play_cutscene(self.cutscene)
    end
end

return BossDoor