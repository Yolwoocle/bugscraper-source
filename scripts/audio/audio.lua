require "scripts.util"
local Class = require "scripts.meta.class"
local images = require "data.images"
local sounds = require "data.sounds"

local AudioManager = Class:inherit()

function AudioManager:init()
	love.audio.setOrientation( 0, 0, 1, 0, -1, 0 )

	-- Music is managed outside AudioManager so no need to assign it a layer 
	self.layers = {
		"sfx"
	}

	love.audio.setEffect("echo", {
		type = "echo",
		delay = 0.18, -- [0, 0.207]
		tapdelay = 0.35, -- [0, 0.404]
		damping = 0.99, -- [0, 0.99]
		feedback = 0.1, -- [0, 1]   
		spread = 0.7 , -- [-1, 1] 
	})
	self.current_effect = nil

	self.disable_playing = false
end

function AudioManager:update(dt)
end

function AudioManager:play(snd, volume, pitch, params)
	if self.disable_playing then
		return
	end

	params = params or {}
	local layer = params.layer or "sfx"
	
    -- Formalize inputs
    local sndname = snd
	if type(snd) == "table" then
        sndname = random_sample(snd)
    end

    volume = volume or 1
    pitch = pitch or 1
    
    if not Options:get("sound_on") then  return  end
	
    local sound = self:get_sound(sndname)
    if sound == nil then   return   end
	
	local new_sound = sound:clone()
	new_sound:set_volume(volume * sound.volume)
	new_sound:set_pitch(pitch * sound.pitch)

	-- Sound position
	if game and game.camera then
		local x = params.x
		local y = params.y
		local z = params.z
		new_sound:set_position(x, y, z)
	end

	new_sound:play()
	
	if self.current_effect == "echo" then
		local echo_sound = sound:clone()
		echo_sound:set_volume(volume * sound.volume * 0.3)
		echo_sound:set_effect("echo")
		echo_sound:play()
	end
end

function AudioManager:play_var(snd, vol_var, pitch_var, params)
	params = params or {}
	vol_var = vol_var or 0
	pitch_var = pitch_var or 1
	local def_vol = params.volume or 1
	local volume = random_range(def_vol-vol_var, def_vol)
	local pitch = random_range(1/pitch_var, pitch_var) * (params.pitch or 1)
	self:play(snd, volume, pitch, params)
end

function AudioManager:set_music(name)
	-- Unused
	local track = self.music_tracks[name]
	if track then
		self.curmusic_name = name
		self.curmusic = track
	end
end

function AudioManager:play_music()
	if game.music_on then
		self.curmusic:play()
	end
end

function AudioManager:pause_music()
	self.curmusic:pause()
end

function AudioManager:on_leave_start_area()
	self:play_music()
end

function AudioManager:on_pause()
	self:pause_music()
end

function AudioManager:on_unpause()
	self:play_music()
end

function AudioManager:get_sound(name)
    if type(name) == "string" then
		-- Substitute patterns like "sfx_jump_{01-05}" to "sfx_jump_XX" (XX is a random value between 01 and 05)
		name = name:gsub("{(.-)%-(.-)}", function(a_str, b_str)
			assert(type(a_str) == "string", "argument a is not a string (in '"..tostring(name).."')")
			assert(type(b_str) == "string", "argument b is not a string (in '"..tostring(name).."')")
			local len = math.max(#a_str, #b_str)
			local a = tonumber(a_str)
			local b = tonumber(b_str)
			assert(type(a) == "number", "argument a is not a number (in '"..tostring(name).."')")
			assert(type(b) == "number", "argument b is not a number (in '"..tostring(name).."')")
			local n = random_range_int(a, b)
			return string.format("%0"..len.."d", n)
		end)
	end

	return sounds[name]
end

function AudioManager:set_effect(effect_name)
	self.current_effect = effect_name
end

return AudioManager