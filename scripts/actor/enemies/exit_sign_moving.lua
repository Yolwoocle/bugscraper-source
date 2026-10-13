require "scripts.util"
local ExitSign = require "scripts.actor.enemies.exit_sign"
local images = require "data.images"

local ExitSignMoving = ExitSign:inherit()

function ExitSignMoving:init(x, y, player_n)
    ExitSignMoving.super.init(self, x, y)
    self.name = "exit_sign_moving"

    self.z = -5

    self.default_spring_ideal_length = -5
	self.is_interactible = false
    
    self.player_n = player_n
    self.player = nil

    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false

    self.gravity = 0

    self.is_visible = false

    self.hide_time = 4.0
    self.hide_timer = 0.0

    self.smash_padding_left = 80
    self.smash_padding_right = 700
end

function ExitSignMoving:update(dt)
    ExitSignMoving.super.update(self, dt)

    if game.players[self.player_n] then
        self.player = game.players[self.player_n]
    else
        self.player = nil
    end

    self.hide_timer = max(0.0, self.hide_timer - dt) 
    if self.hide_timer <= 0.0 then
        self.is_visible = false
    end
end


function ExitSignMoving:draw()
    self.spr:set_image(images.empty)
    self:draw_enemy()

    if self.is_in_smash_easter_egg then
        self:draw_smash_easter_egg()
    end
    
    local final_spring_y = math.floor(self.y + self.h + 5 - self.spring_y)
    local max_spring_y = math.floor(self.y + self.h + 6) -- Value to clamp the y value to (to prevent intersection w/ floor)
    local spring_height = images.spring:getHeight()

    for iy = final_spring_y, max_spring_y + spring_height, spring_height do
        love.graphics.draw(images.spring, math.floor(self.mid_x - images.spring:getWidth()/2), iy)
    end
    if final_spring_y < max_spring_y then
        draw_centered(images.punching_glove, self.mid_x, final_spring_y)
    end

    self:draw_enemy()
end


function ExitSignMoving:activate(player)
    if not player then 
        return 
    end

    self.is_visible = true
    self.hide_timer = self.hide_time
    self:set_position(player.x-13, 196)

    if random_range(0, 1) < self.smash_easter_egg_probability then
        player:set_position(clamp(player.x, game.level.cabin_inner_rect.ax + self.smash_padding_left, game.level.cabin_inner_rect.bx - self.smash_padding_right), self.y)
        self:set_position(player.x-13, 196)

        self.retracted_spring_ideal_length = 40
        self:activate_smash_easter_egg(player)
    else
        self.retracted_spring_ideal_length = 10 + math.abs(self.y - player.y)
        game:leave_game(player.n)
        game:screenshake(4)
        
		Particles:star_splash(player.mid_x, player.mid_y)
        Particles:ejected_player(player.skin.img_dead, player.x, player.y)
        Particles:floating_image({
            images.star_small_1,
            images.star_small_2,
        }, player.mid_x, player.mid_y, random_range_int(7, 10), 0, 0.25, 1, 120, 0.95)
        self:play_sound("sfx_player_leave_game")
        
        self.spring_active = true
        self.spring_retract_timer = 2.0
        self.spring_ideal_length = self.retracted_spring_ideal_length
    end
end


return ExitSignMoving