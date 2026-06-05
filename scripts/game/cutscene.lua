require "scripts.util"
local Timer = require "scripts.timer"

local Class = require "scripts.meta.class"

local Cutscene = Class:inherit()

function Cutscene:init(name, scenes, params)
    params = params or {}

    self.name = name
    self.scenes = scenes
    self.current_scene = nil
    self.current_scene_i = -1
    self.total_duration = 0

    self.data = {} -- Table that can be freely written to by scenes for storing data

    self.unpausable = param(params.unpausable, false)

    for _, scene in pairs(self.scenes) do
        self.total_duration = self.total_duration + scene.duration
    end

    self.timer = Timer:new()
    self.is_playing = false
end

function Cutscene:set_current_scene(scene_i) 
    if self.current_scene then
        self.current_scene:exit(self, self.data)
    end
    self.current_scene_i = scene_i
    self.current_scene = self.scenes[self.current_scene_i]
    self.current_scene:enter(self, self.data)

    self.timer:start(self.current_scene.duration)
end

function Cutscene:play()
    self.data = {}
    self:set_current_scene(1)
    self.is_playing = true
    self.total_time = 0

    if self.unpausable then
        game.menu_manager:set_can_pause(false)
    end
end

function Cutscene:stop()
    self.is_playing = false
    self.current_scene = nil
    self.current_scene_i = -1
    self.timer:stop()

    if self.unpausable then
        game.menu_manager:set_can_pause(true)
    end
end

function Cutscene:update(dt)
    if self.is_playing then
        if game.skip_cutscene_flag then
            for i = self.current_scene_i+1, #self.scenes do
                self:set_current_scene(i)
            end
            self:stop()
            game.skip_cutscene_flag = false
            return
        end
        
        local skip_scene = (self.current_scene:update(self, self.data, dt) == true) or game.skip_scene_flag
        if game.skip_scene_flag then
            game.skip_scene_flag = false
        end
        
        if skip_scene or self.timer:update(dt) then
            local next_i = mod_plus_1(self.current_scene_i + 1, #self.scenes)
            if next_i ~= 1 then
                self:set_current_scene(next_i)
            else
                self:stop()
            end
        end
    end
end

function Cutscene:get_current_scene_elapsed_time()
    return self.timer:get_time_passed()
end

function Cutscene:get_current_scene_time_ratio()
    return self.timer:get_ratio()
end

function Cutscene:get_current_scene_duration()
    return self.timer.duration
end

return Cutscene