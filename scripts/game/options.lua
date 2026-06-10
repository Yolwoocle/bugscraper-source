require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"

local OptionsManager = Class:inherit()

function OptionsManager:init()
	self.default_options = {
		["$version"] = OPTIONS_FILE_FORMAT_VERSION,
		language = "default",

		volume = 1.0,
		music_volume = 0.75,
		sfx_volume = 1.0,
		screenshake = 1.0,
		sound_on = true,
		ambience_on = true,
		disable_background_noise = false,
		play_music_on_pause_menu = true,

		is_vsync = true,
		is_fullscreen = true,
		pixel_scale = "auto",
		windowed_width = CANVAS_WIDTH,
		windowed_height = CANVAS_HEIGHT,
		is_window_maximized = true,
		menu_blur = true,
		background_speed = 1.0,
		bullet_lightness = 1.0,

		timer_on = false,
		mouse_visible = false,
		pause_on_unfocus = ternary(love.system.getOS() == "Web", false, true),
		screenshake_on = true,
		skip_boss_intros = false,
		show_fps_warning = true,
		convention_mode = false,

		button_style_p1 = BUTTON_STYLE_DETECT,
		button_style_p2 = BUTTON_STYLE_DETECT,
		button_style_p3 = BUTTON_STYLE_DETECT,
		button_style_p4 = BUTTON_STYLE_DETECT,

		axis_deadzone_p1 = AXIS_DEADZONE,
		axis_deadzone_p2 = AXIS_DEADZONE,
		axis_deadzone_p3 = AXIS_DEADZONE,
		axis_deadzone_p4 = AXIS_DEADZONE,

		vibration_p1 = 1.0,
		vibration_p2 = 1.0,
		vibration_p3 = 1.0,
		vibration_p4 = 1.0,

		-- Save data (because who needs a separate file for that)
		xp = 0,
		xp_level = 0,
		
        has_chosen_language = false,
	}
	self.setters = {
		sound_on = function(value) 
			if value then
				love.audio.setVolume(self:get("volume"))
			else
				love.audio.setVolume(0)
			end
		end,
		volume = function(value) 
			love.audio.setVolume(value)
		end,
		sfx_volume = function(value)
			game:set_ambience_volume(ternary(self:get("ambience_on"), value, 0.0))
		end,
		music_volume = function(value)
			game:set_music_volume(value)
		end,
		play_music_on_pause_menu = function(value)
			if value then
                game.music_player:play() --TODO test this
            end
		end,
		ambience_on = function(value)
			game:set_ambience_volume(ternary(value, self:get("sfx_volume"), 0.0))
		end,

		is_fullscreen = function(value)
			game:update_fullscreen(value)
		end,
		pixel_scale = function(value)		
			if not game then 
				return	
			end
			game:update_screen()
		end,
		is_vsync = function(value)
			love.window.setVSync(value)
		end,
		mouse_visible = function(value)
            love.mouse.setVisible(value)
		end,
	}

	self:load_options()
end

function OptionsManager:load_options()
	print("Loading options...")
	self.options = Files:read_config_file("options.txt", self.default_options)
	print("Finished loading options.")
end

function OptionsManager:update_options_file()
	Files:write_config_file("options.txt", self.options)
end

function OptionsManager:get(name)
	return self.options[name]
end

function OptionsManager:set(name, val)
	self.options[name] = val
	if self.setters[name] then
		self.setters[name](val)
	end
	self:update_options_file()
end

function OptionsManager:toggle(name)
	self:set(name, not self.options[name])
end

function OptionsManager:update_volume()
	love.audio.setVolume(self:get("sound_on") and self:get("volume") or 0.0)
end


-----------------------------------------------------

-- DEPRACATED

function OptionsManager:toggle_screenshake()
	self:toggle("screenshake_on")
end

function OptionsManager:toggle_background_noise()
	self:toggle("disable_background_noise")
end

function OptionsManager:on_quit()
	self:update_options_file()
end

function OptionsManager:set_button_style(player_n, style)
	self:set("button_style_p"..tostring(player_n), style)
end

function OptionsManager:set_axis_deadzone(player_n, style)
	self:set("axis_deadzone_p"..tostring(player_n), style)
end

return OptionsManager