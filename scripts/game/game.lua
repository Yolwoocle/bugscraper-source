print("Loading API libraries...")
DiscordPresence   = require "scripts.meta.discord_presence"
Steamworks        = require "scripts.meta.steamworks"
print("")

local TextManager            = require "scripts.text"
local ActorManager           = require "scripts.game.actor_manager"
local cutscenes              = require "data.cutscenes"
local music_disks            = require "data.music_disks"
local ambience_disks         = require "data.ambience_disks"
Text                         = TextManager:new()

local backgrounds            = require "data.backgrounds"
local LightWorld             = require "scripts.graphics.light_world"

local AchievementManager
if DISTRIBUTION_PLATFORM == "steam" then
	AchievementManager = require "scripts.meta.achievement_manager_steam"
else
	AchievementManager = require "scripts.meta.achievement_manager_default"
end

local Class                  = require "scripts.meta.class"
local CollisionManager       = require "scripts.physics.collision"
local Player                 = require "scripts.actor.player"
local Enemies                = require "data.enemies"
local ParticleSystem         = require "scripts.game.particles"
local AudioManager           = require "scripts.audio.audio"
local MenuManager            = require "scripts.ui.menu.menu_manager"
local InputManager           = require "scripts.input.input"
local MusicPlayer            = require "scripts.audio.music_player"
local Level                  = require "scripts.level.level"
local GameUI                 = require "scripts.ui.game_ui"
local Debug                  = require "scripts.game.debug"
local Camera                 = require "scripts.game.camera"
local Layer                  = require "scripts.graphics.layer"
local LightLayer             = require "scripts.graphics.light_layer"
local ScreenshotManager      = require "scripts.screenshot"
local QueuedPlayer           = require "scripts.game.queued_player"
local LifeOrb = require "scripts.actor.enemies.life_orb"
local MetaprogressionManager = require "scripts.game.metaprogression"
local StatsManager           = require "scripts.game.stats_manager"
local BackroomTutorial       = require "scripts.level.backroom.backroom_tutorial"

local measure                = require "lib.batteries.measure"

local guns                   = require "data.guns"
local upgrades               = require "data.upgrades"
local shaders                = require "data.shaders"
local images                 = require "data.images"
local skins, skin_name_to_id = require "data.skins"
local sounds                 = require "data.sounds"
local utf8                   = require "utf8"

require "bugscraper_config"
require "scripts.meta.constants"
require "scripts.util"
require "scripts.meta.post_constants"

local Game = Class:inherit()

function Game:init()
	-- Global singletons
	Input = InputManager:new(self)
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()
	Audio = AudioManager:new()
	Screenshot = ScreenshotManager:new()
	Metaprogression = MetaprogressionManager:new()
	Stats = StatsManager:new()
	Achievements = AchievementManager:new()

	Input:init_users()

	love.keyboard.setTextInput(true)
	SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")

	self:update_screen()

	main_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Load fonts
	FONT_HOPE = love.graphics.newImageFont("fonts/hope_gold.png", FONT_CHARACTERS)
	FONT_SYMBOLS = love.graphics.newImageFont("fonts/font_symbols.png", FONT_SYMBOLS_CHARACTERS)
	FONT_ZH = love.graphics.newImageFont("fonts/font_zh.png", FONT_ZH_CHARACTERS)
	FONT_JA = love.graphics.newImageFont("fonts/font_ja.png", FONT_JA_CHARACTERS..FONT_CHARACTERS..FONT_SYMBOLS_CHARACTERS)
	FONT_7SEG = love.graphics.newImageFont("fonts/7seg_font.png", FONT_7SEG_CHARACTERS)
	FONT_MINI = love.graphics.newImageFont("fonts/font_ant_party.png", FONT_MINI_CHARACTERS)
	FONT_FAT = love.graphics.newImageFont("fonts/font_counting_apples.png", FONT_FAT_CHARACTERS)
	FONT_PAINT = love.graphics.newFont("fonts/NicoPaint-Regular.ttf", 16)
	FONT_HEIGHT_OVERRIDES = {
		FONT_JA = 14
	} 

	if Text.language == "zh_Hans" then
		FONT_REGULAR = FONT_ZH
		FONT_REGULAR:setFallbacks(FONT_HOPE, FONT_SYMBOLS, FONT_ZH, FONT_JA)
		FONT_MINI:setFallbacks(FONT_HOPE, FONT_REGULAR, FONT_ZH, FONT_JA)

	elseif Text.language == "ja" then
		print_debug(":setLineHeight( height ) ", FONT_JA:getHeight())

		FONT_REGULAR = FONT_JA
		FONT_MINI:setFallbacks(FONT_REGULAR, FONT_JA, FONT_HOPE)
		
		FONT_HEIGHT_OVERRIDES[FONT_REGULAR] = 14

	else
		FONT_REGULAR = FONT_HOPE
		FONT_REGULAR:setFallbacks(FONT_SYMBOLS, FONT_JA, FONT_ZH)
	end
	Text:push_font(FONT_REGULAR)

	-- Audio ===> Moved to OptionsManager
	Options:set("volume", Options:get("volume"))

	local backroom
	if not Metaprogression:get("has_played_tutorial") then
		backroom = BackroomTutorial:new()
	end
	self.start_with_splash = true
	self:new_game({ backroom = backroom })

	self.debug = Debug:new(self)
	self.menu_manager = MenuManager:new(self)
	love.mouse.setVisible(Options:get("mouse_visible"))

	self.is_game_ui_visible = true
	self.has_seen_controller_warning = false
	self.ui_visible = true

	self.join_cooldown_frames = 0

	self.stat_total_time = Stats:get("total_time")
	self.stat_ingame_time = Stats:get("ingame_time")

	self.debug_mode = DEBUG_MODE

	self.is_ready = false
end

function Game:new_game(params)
	params = params or {}
	self.start_params = params

	if OPERATING_SYSTEM ~= "Web" then -- scotch
		love.audio.stop()
	end

	Audio.current_effect = nil

	-- Reset global systems
	Collision = CollisionManager:new()
	Particles = ParticleSystem:new()
	Input:mark_all_actions_as_handled()
	if Options:get("convention_mode") then
		for i = 1, MAX_NUMBER_OF_PLAYERS do
			Input:remove_user(i)
		end
	end

	self.t = 0
	self.frame = 0
	self.in_game_frame = 0

	-- Remove old queued players
	self:remove_queued_players()
	self:remove_inactive_joysticks()

	-- Music & ambience
	if self.music_player then self.music_player:stop() end
	self.music_player = MusicPlayer:new(music_disks, "ground_floor_empty", {processes_pause = true, volume = Options:get("music_volume")})
	self:set_music_volume(Options:get("music_volume"))
	self.music_player:set_disk("ground_floor_empty") -- TODO put correct disk depending on nb of players

	if self.ambience_player then self.ambience_player:stop() end
	self.ambience_player = MusicPlayer:new(ambience_disks, "cafeteria", {})
	self.ambience_player:set_disk("lobby")
	self.ambience_player:play()
	self:set_ambience_volume(Options:get("ambience_on") and Options:get("sfx_volume") or 0)

	Options:update_volume()

	-- Players
	self.waves_until_respawn = {}
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		self.waves_until_respawn[i] = { -1, nil }
	end

	-- Camera
	self.camera = Camera:new()

	-- Level
	self.level = Level:new(self, params.backroom)

	if self.level.backroom and self.level.backroom.get_default_camera_position then
		local cx, cy = self.level.backroom:get_default_camera_position()
		self.camera:set_position(cx, cy)
	else
		self.camera:set_position(0, 0)
	end

	-- Actors
	self.actors = {}
	self.actor_manager = ActorManager:new(self, self.actors)
	self.actor_draw_color = nil

	self.boss = nil

	-- Init players
	local px, py
	local spacing = 16
	if params.quick_restart then
		px = self.level.door_rect.ax + 32
		py = self.level.door_rect.by
	end
	self:init_players(px, py, spacing)

	-- Debugging
	self.colview_mode = false
	self.msg_log = {}

	-- Logo
	self.jetpack_tutorial_y = -30
	self.move_jetpack_tutorial = false

	if self.menu_manager then
		self.menu_manager:reset()
		self.menu_manager:set_menu()
	end

	self.stats = {
		floor = 0,
		kills = 0,
		time = 0,
		max_combo = 0,
	}
	self.kills = 0
	self.time = 0
	self.score = 0
	self.deaths = 0

	self.frames_to_skip = 0
	self.slow_mo_rate = 0

	self.light_world = LightWorld:new()

	self.layers = {}
	self.layers_count = LAYER_COUNT
	self:init_layers()

	self.is_light_on = true
	self.draw_shadows = true
	self.shadow_ox = -1
	self.shadow_oy = 2
	self.object_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.front_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.smoke_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.smoke_buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	-- Cutscenes
	self.cutscene = nil

	self.can_join_game = true
	self.can_start_game = false
	self.game_state = GAME_STATE_WAITING
	self.endless_mode = false
	self.timer_before_game_over = 0
	self.max_timer_before_game_over = 3.3

	-- UI
	self.game_ui = GameUI:new(self, self.is_game_ui_visible)
	if params.iris_params then
		self.game_ui:start_iris_transition(unpack(params.iris_params))
	end
	self.game_ui.dark_overlay_alpha = param(params.dark_overlay_alpha, self.game_ui.dark_overlay_alpha)
	self.game_ui.dark_overlay_alpha_target = param(params.dark_overlay_alpha_target,
		self.game_ui.dark_overlay_alpha_target)
	self.menu_blur = 1
	self.max_menu_blur = 3

	self.notif = ""
	self.notif_timer = 0.0

	self.upgrades = {}
	self:update_skin_choices()

	if Text.language == nil then
		self.menu_manager:set_menu("options_language")
	end

	Options:update_volume()

	if params.quick_restart then
		self.level.force_backroom_end_flag = true
		self.camera.x = DEFAULT_CAMERA_X
		self.camera.y = DEFAULT_CAMERA_Y
		self.game_ui.logo_y = -70 -- SCOTCH

		self:start_game(true)
	end

	self.check_achievements_timer = 1.0

	self.ready_run = params.ready_run

	_G_t_test = love.timer.getTime()
end

function Game:ready()
	self.is_ready = true
	
	if self.ready_run then
		self.ready_run()
		self.ready_run = nil
	end
	
	if not Options:get("has_chosen_language") then
		self.game_state = GAME_STATE_LANGUAGE_SETUP
		for _, joy in pairs(love.joystick.getJoysticks()) do
			self:queue_join_game("controller", joy)
		end

		self.music_player:set_disk("off")
		self.menu_manager:set_menu("options_language_basic")
	end

	self:check_achievements()
end

function Game:init_layers()
	self.layers = {}
	for i = 1, self.layers_count do
		local layer
		if i == LAYER_LIGHT then
			layer = LightLayer:new(CANVAS_WIDTH, CANVAS_HEIGHT, self.light_world)
		else
			layer = Layer:new(CANVAS_WIDTH, CANVAS_HEIGHT)
		end
		table.insert(self.layers, layer)
	end
end

function Game:get_window_flags()
	return {
		fullscreen = ternary(OPERATING_SYSTEM == "Web", false, Options:get("is_fullscreen")),
		resizable = true,
		vsync = Options:get("is_vsync"),
		minwidth = CANVAS_WIDTH,
		minheight = CANVAS_HEIGHT,
	}
end

function Game:on_resize(w, h)
	if not Options:get("is_fullscreen") then
		local s = love.graphics.getDPIScale()
		Options:set("windowed_width", w * s)
		Options:set("windowed_height", h * s)
		Options:set("is_window_maximized", love.window.isMaximized())
	end
	self:update_screen()
end

function Game:update_fullscreen(is_fullscreen)
	love.window.setFullscreen(is_fullscreen)

	if not is_fullscreen then
		local window_w = Options:get("windowed_width")
		local window_h = Options:get("windowed_height")
		local maximized = Options:get("is_window_maximized")

		love.window.setMode(window_w, window_h, self:get_window_flags())
		if maximized then
			love.window.maximize()
		end
	end

	self:update_screen()
end

function Game:update_screen()
	WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()

	local pixel_scale_mode = Options:get("pixel_scale")

	local screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	local screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	local auto_scale = math.min(screen_sx, screen_sy)

	local scale = auto_scale

	if pixel_scale_mode == "auto" then
		scale = auto_scale
	elseif pixel_scale_mode == "max_whole" then
		scale = math.max(1, math.floor(auto_scale))
	elseif type(tonumber(pixel_scale_mode)) == "number" then
		scale = math.min(tonumber(pixel_scale_mode), auto_scale)
	else
		print("Game.update_screen: WARNING: pixel scale mode has invalid value: '" .. tostring(pixel_scale_mode) .. "'")
	end

	CANVAS_SCALE = scale

	CANVAS_OX = math.floor(max(0, (WINDOW_WIDTH - CANVAS_WIDTH * CANVAS_SCALE) / 2))
	CANVAS_OY = math.floor(max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * CANVAS_SCALE) / 2))
end

function Game:update(dt)
	if not self.is_ready then
		self:ready()
	end

	self.frame = self.frame + 1

	self.frames_to_skip = max(0, self.frames_to_skip - 1)
	-- BUG: pressing and releasing a button during a frameskip period will not register it
	if self.frames_to_skip <= 0 then
		Input:update(dt)
	end

	self.music_player:update(dt)
	self.ambience_player:update(dt)

	-- Menus
	self.game_ui:update_global(dt)
	self.menu_manager:update(dt)
	if self.debug_mode then
		self.debug:update(dt)
	end

	if not self.menu_manager.cur_menu then
		self:update_main_game(dt)
	end

	for i = 1, #self.layers - 1 do
		self.layers[i].blur = Options:get("menu_blur") and (self.menu_manager.cur_menu ~= nil) and
			(self.menu_manager.cur_menu.blur_enabled)
	end

	DiscordPresence:update(dt)
	Steamworks:update(dt)

	self.join_cooldown_frames = math.max(0, self.join_cooldown_frames - 1)

	local old_total_time = self.stat_total_time
	self.stat_total_time = self.stat_total_time + dt
	Stats:set("total_time", self.stat_total_time, true)
	if (old_total_time % STATS_AUTOSAVE_INTERVAL) > STATS_AUTOSAVE_INTERVAL/2 and (self.stat_total_time % STATS_AUTOSAVE_INTERVAL) < STATS_AUTOSAVE_INTERVAL/2 then
		Stats:save_progress()
	end

	-- THIS SHOULD BE LAST
	Input:update_last_input_state(dt)
end

function Game:update_main_game(dt)
	self.camera:update_screenshake(dt)
	Particles:update(dt)

	if self.frames_to_skip > 0 then
		return
	end

	self.in_game_frame = self.in_game_frame + 1
	self.camera:update(dt)

	if self.game_state == GAME_STATE_PLAYING then
		self.time = self.time + dt
		
		self.stat_ingame_time = self.stat_ingame_time + dt
		Stats:set("ingame_time", self.stat_ingame_time, true)
	end
	self.t = self.t + dt

	self:listen_for_player_join(dt)

	self.level:update(dt)

	self:update_timer_before_game_over(dt)

	self:update_skin_choices()
	self:update_queued_players(dt)
	self.actor_manager:update(dt)
	self:update_logo(dt)
	self:update_debug(dt)
	if self.cutscene then
		self.cutscene:update(dt)
		if self.cutscene and not self.cutscene.is_playing then
			self.cutscene = nil
		end
	end
	self.game_ui:update(dt)
	self.light_world:update(dt)

	self.notif_timer = math.max(self.notif_timer - dt, 0)
end

function Game:quit()
	DiscordPresence:quit()
	Steamworks:quit()
end

function Game:get_enemy_count()
	return self.actor_manager:get_enemy_count()
end

function Game:get_life_ratio_of_weakest_player()
	local min_life_ratio = math.huge
	for _, player in pairs(self.players) do
		min_life_ratio = min(min_life_ratio, clamp(player.life / player.max_life, 0, 1)) 
	end
	return min_life_ratio
end

function Game:update_logo(dt)
	if self.move_jetpack_tutorial then
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, 70, 0.1)
	else
		self.jetpack_tutorial_y = lerp(self.jetpack_tutorial_y, -30, 0.1)
	end
end

function Game:get_camera_position()
	return self.camera:get_position()
end

function Game:update_debug(dt)

end

function Game:get_layer(layer_id)
	return self.layers[layer_id]
end

function Game:draw_on_layer(layer_id, paint_function, params)
	local layer = self.layers[layer_id]
	if layer == nil then return end

	params = param(params, {})
	local apply_camera = param(params.apply_camera, true)

	layer:paint(paint_function, {
		apply_camera = apply_camera,
		camera = self.camera,
	})
end

function Game:draw()
	local tic_gamedraw = love.timer.getTime()

	-- Using a canvas for that sweet, resizable pixel art
	love.graphics.setCanvas(main_canvas)
	love.graphics.clear(0, 0, 0)
	love.graphics.translate(0, 0)

	self:draw_game()

	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.scale(1, 1)

	love.graphics.draw(main_canvas, CANVAS_OX, CANVAS_OY, 0, CANVAS_SCALE, CANVAS_SCALE)

	if self.debug.layer_view then
		self.debug:draw_layers()
	end
	if self.notif_timer > 0 then
		love.graphics.flrprint(self.notif, 0, 0, 0, 3, 3)
	end

	__gamedraw_dur = love.timer.getTime() - tic_gamedraw
end

function Game:draw_game()
	exec_on_canvas(self.smoke_canvas, love.graphics.clear)

	---------------------------------------------

	self:draw_on_layer(LAYER_BACKGROUND, function()
		love.graphics.clear()

		self.level:draw()

		Particles:draw_layer(PARTICLE_LAYER_BACK_SHADOWLESS)
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_OBJECTS, function()
		love.graphics.clear()

		Particles:draw_layer(PARTICLE_LAYER_BACK)

		for _, actor in pairs(self.actors) do
			if actor.is_active and actor.is_visible then
				actor:draw_back()
			end
		end

		-- Draw actors
		for _, actor in pairs(self.actors) do
			if actor.is_active and actor.is_visible then
				actor:draw()
			end
		end

		Particles:draw_layer(PARTICLE_LAYER_NORMAL)
	end)

	self:draw_on_layer(LAYER_OBJECT_SHADOWLESS, function()
		love.graphics.clear()
		Particles:draw_layer(PARTICLE_LAYER_SHADOWLESS)
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_HUD, function()
		love.graphics.clear()
		Particles:draw_layer(PARTICLE_LAYER_HUD)
		for k, actor in pairs(self.actors) do
			if actor.is_active and actor.draw_hud and self.game_ui.is_visible then
				actor:draw_hud()
			end
		end
	end)

	---------------------------------------------

	self:draw_on_layer(LAYER_SHADOW, function()
		love.graphics.clear()

		if not self.draw_shadows then
			return
		end
		exec_color({ 0, 0, 0, 0.5 }, function()
			-- love.graphics.cl
			love.graphics.draw(self:get_layer(LAYER_OBJECTS).canvas, self.shadow_ox, self.shadow_oy)
			love.graphics.draw(self:get_layer(LAYER_HUD).canvas, self.shadow_ox, self.shadow_oy)
		end)
	end, { apply_camera = false })

	-----------------------------------------------------

	self:draw_on_layer(LAYER_FRONT, function()
		love.graphics.clear()

		self:draw_smoke_canvas()
		self.level:draw_front()

		for _, actor in pairs(self.actors) do
			if actor.is_active and actor.is_visible and actor.is_front then
				actor:draw()
			end
		end

		Particles:draw_layer(PARTICLE_LAYER_FRONT)
	end, { apply_camera = true })

	-----------------------------------------------------

	self:draw_on_layer(LAYER_LIGHT, function()
		local c = transparent_color(self.light_world.custom_fill_color or COL_BLACK_BLUE,
			self.light_world.darkness_intensity)
		rect_color(c, "fill", -CANVAS_WIDTH, -CANVAS_HEIGHT, CANVAS_WIDTH * 4, CANVAS_HEIGHT * 3)
	end)

	-----------------------------------------------------

	-- UI
	self:draw_on_layer(LAYER_UI, function()
		love.graphics.clear()

		love.graphics.draw(self.front_canvas, 0, 0)
		self.game_ui:draw()
		self.level:draw_ui()
		self.debug:draw_colview()
		self.debug:draw_actor_info_view()
	end, { apply_camera = false })

	-----------------------------------------------------

	-- Menus
	self:draw_on_layer(LAYER_MENUS, function()
		love.graphics.clear()

		-- Menus
		if self.menu_manager.cur_menu then
			self.menu_manager:draw()
		end
		self.game_ui:draw_front()

		if self.debug_mode then
			self.debug:draw()
		end
	end, { apply_camera = false })

	-----------------------------------------------------

	love.graphics.origin()
	love.graphics.scale(1)
	for i = 1, #self.layers do
		local layer = self.layers[i]
		if (not layer.is_light_layer) or (layer.is_light_layer and not self.is_light_on) then
			self.layers[i]:draw(0, 0)
		end
	end
end

function Game:draw_smoke_canvas()
	self.camera:pop()

	-- Used for effects for the stink bugs
	exec_on_canvas(self.smoke_buffer_canvas, function()
		love.graphics.clear()

		love.graphics.setColor(0.2, 0.2, 0.2)
		love.graphics.draw(self.smoke_canvas, 0, 4)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.smoke_canvas, 0, 0)
	end)
	exec_on_canvas(self.smoke_canvas, function()
		love.graphics.clear()

		love.graphics.setColor(0, 0, 0.1)
		-- Outline
		love.graphics.draw(self.smoke_buffer_canvas, -1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 1, 0)
		love.graphics.draw(self.smoke_buffer_canvas, 0, -1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.smoke_buffer_canvas, 0, 0)
	end)

	love.graphics.setColor(1, 1, 1, 0.5)
	love.graphics.draw(self.smoke_canvas, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)

	self.camera:push()
end

function Game:set_ui_visible(bool)
	self.game_ui:set_visible(bool)
end

function Game:listen_for_player_join(dt)
	if self.game_state ~= GAME_STATE_WAITING then return end

	if Input:action_pressed_global("join_game") and self.can_join_game and self.join_cooldown_frames <= 0 then
		local global_user = Input:get_global_user()
		local last_button = global_user.last_pressed_button
		local input_profile_id = ""
		local joystick = nil

		local can_add_keyboard_user = ternary(
			last_button and last_button.type == INPUT_TYPE_KEYBOARD,
			(Input:get_number_of_users(INPUT_TYPE_KEYBOARD) <= 0),
			true
		)
		if last_button and Input:can_add_user() and can_add_keyboard_user then
			if last_button.type == INPUT_TYPE_KEYBOARD then
				input_profile_id = "keyboard_solo"
			elseif last_button.type == INPUT_TYPE_CONTROLLER then
				input_profile_id = "controller"
				joystick = Input:get_global_user().last_active_joystick
			end
			self:queue_join_game(input_profile_id, joystick)
		end
	end

	if Input:action_pressed_global("split_keyboard") then
		if Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 1 then
			self:queue_join_game("keyboard_solo")
			Input:split_keyboard()

			-- elseif Input:get_number_of_users(INPUT_TYPE_KEYBOARD) == 2 then
			-- 	self:unsplit_keyboard_and_kick_second_player()
		end
	end
end

function Game:remove_queued_player(player_n)
	local queued_player = self.queued_players[player_n]
	if not queued_player then
		return
	end

	Input:remove_user(player_n)
	self.queued_players[player_n]:remove()
	self.queued_players[player_n] = nil
end

function Game:remove_queued_players()
	if self.queued_players then
		for _, queued_player in pairs(self.queued_players) do
			Input:remove_user(queued_player.player_n)
		end
	end
	self.queued_players = {}
end

function Game:remove_inactive_joysticks()
	for n = 1, MAX_NUMBER_OF_PLAYERS do
		local user = Input:get_user(n)

		if user and user.joystick and not user.joystick:isConnected() then
			self:leave_game(n)
		end
	end
end

function Game:unsplit_keyboard_and_kick_second_player()
	local second_user = Input:get_users(INPUT_TYPE_KEYBOARD)[2]
	if second_user == nil then return end

	self:leave_game(second_user.n)
	Input:unsplit_keyboard()
end

function Game:on_menu()
	self.music_player:on_menu()
	self.ambience_player:on_menu()
	self:pause_repeating_sounds()
end

function Game:on_pause()
	Audio:play("ui_menu_pause")
end

function Game:on_unpause()
	Audio:play("ui_menu_unpause")
end

function Game:pause_repeating_sounds()
	for k, a in pairs(self.actors) do
		a:pause_constant_sounds()
	end
end

function Game:on_button_glass_spawn(button)
	self.music_player:stop()
	self.ambience_player:stop()
end

function Game:on_unmenu()
	self.music_player:on_unmenu()
	self.ambience_player:on_unmenu()

	for k, a in pairs(self.actors) do
		a:resume_constant_sounds()
	end
end

function Game:set_music_volume(vol)
	self.music_player:set_volume(vol)
end

function Game:set_ambience_volume(vol)
	self.ambience_player:set_volume(vol)
end

function Game:new_actor(actor, buffer_enemy)
	return self.actor_manager:new_actor(actor, buffer_enemy)
end

function Game:on_new_actor(actor)
	if actor and actor.is_boss then
		self.boss = actor
	end
end

function Game:get_boss()
	return self.boss
end

function Game:on_enemy_damage(enemy, n, damager)
	self.level:on_enemy_damage(enemy, n, damager)
end

function Game:on_player_damage(player, n, source)
	self.level:on_player_damage(player, n, source)
end

function Game:on_kill(actor)
	if actor.counts_as_enemy then
		if actor.play_sfx then --REMOVEME SCOTCH
			Audio:play_var("sfx_enemy_death", 0.2, 1.2)--REMOVEME SCOTCH
		end --REMOVEME SCOTCH

		self.kills = self.kills + 1
		self.score = self.score + (actor.score or 0)
		Stats:add("kills", 1)
		-- Particles:word(actor.x, actor.y, tostring(actor.score or 0))
		self.level:on_enemy_death(actor)
	end

	if actor.is_player then
		self:on_player_death(actor)
	end
end

function Game:on_remove(actor)
	if actor and actor.is_boss then
		self.boss = nil
	end
end

function Game:on_player_death(player)
	self.deaths = self.deaths + 1
	Stats:add("deaths", 1)

	self:unregister_alive_player(player.n)
	self.waves_until_respawn[player.n] = { player.waves_until_respawn, player }

	if self:get_number_of_alive_players() <= 0 then
		self:on_last_player_death(player)
	end
end

function Game:on_player_ghosted(player)
	self:on_player_death(player)
end

function Game:on_last_player_death(player)
	self.menu_manager:set_can_pause(false)
	self.music_player:set_disk("game_over")
	self.music_player:pause()
	self:pause_repeating_sounds()
	self.game_state = GAME_STATE_DYING
	self.timer_before_game_over = self.max_timer_before_game_over
end

function Game:update_timer_before_game_over(dt)
	if self.game_state ~= GAME_STATE_DYING then
		return
	end
	self.timer_before_game_over = self.timer_before_game_over - dt

	if self.timer_before_game_over <= 0 then
		self:game_over()
	end
end

function Game:save_stats()
	self.stats.time = self.time
	self.stats.floor = self.level.floor
	self.stats.kills = self.kills
	self.stats.max_combo = self.level.max_fury_combo
	self.stats.score = self.score
	self.stats.deaths = self.deaths
	
	Stats:check_achievements()
end

function Game:on_end_game()
	self:save_stats()
	
	Metaprogression:add_xp(self.score)
	self.score = 0
end

function Game:game_over()
	self:on_end_game()
	self.menu_manager:set_menu("game_over")
end

function Game:do_win()

end

function Game:get_floor()
	return self.level:get_floor()
end

function Game:set_floor(val)
	self.level:set_floor(val)
end

function Game:init_players(x, y, spacing)
	spacing = spacing or (5 * 16)
	self.all_players = {} -- All players, including dead/ghost ones
	self.players = {}  -- Only alive players

	if Options:get("convention_mode") then
		return
	end

	for i = 1, MAX_NUMBER_OF_PLAYERS do
		if Input:get_user(i) ~= nil then
			local px, py
			if x and y and spacing then
				px = x + spacing * (i - 1)
				py = y
			end

			self:new_player(i, px, py)
		end
	end
end

function Game:queue_join_game(input_profile_id, joystick)
	self.join_cooldown_frames = 2
	
	local player_n = Input:find_free_user_number()
	if player_n == nil then
		return
	end
	-- Is joystick already taken?
	if joystick ~= nil and Input:get_joystick_user(joystick) ~= nil then
		return
	end
	
	Input:new_user(player_n)
	Input:set_last_ui_user_n(player_n)
	if joystick ~= nil then
		Input:assign_joystick(player_n, joystick)
	end
	Input:assign_input_profile(player_n, input_profile_id)
	
	self.queued_players[player_n] = QueuedPlayer:new(player_n, input_profile_id, joystick)

	return player_n
end

function Game:join_game(player_n)
	local player = self:new_player(player_n, nil, nil)

	if player then
		self.skin_choices[player.skin.id] = false
		Particles:smoke_big(player.mid_x, player.mid_y, COL_WHITE)
	end

	self.level:on_player_joined(player)
	self.game_ui:on_player_joined(player)
end

function Game:get_default_player_position(player_n)
	if self.level.backroom and self.level.backroom.get_default_player_position then
		return self.level.backroom:get_default_player_position(player_n)
	end
	return 26 * 16 + (5 * 16) * (player_n - 1), CANVAS_HEIGHT - 3 * 16 + 4
end

--- Registers a player into the table of alive players, and the table of all players
function Game:register_player(player_n, player)
	self.players[player_n] = player
	self.all_players[player_n] = player
end

--- Unregisters a player from the table of alive players, and the table of all players
function Game:unregister_player(player_n)
	self.players[player_n] = nil
	self.all_players[player_n] = nil
end

--- Unregisters a player ONLY from the table of alive players, and keeps the reference in the table of all players
function Game:unregister_alive_player(player_n)
	self.players[player_n] = nil
end

function Game:new_player(player_n, x, y)
	player_n = player_n or self:find_free_player_number()
	if player_n == nil then
		return
	end

	local def_x, def_y = self:get_default_player_position(player_n)
	x = param(x, def_x)
	y = param(y, def_y)

	local player = Player:new(player_n, x, y, Input:get_user(player_n):get_skin() or skins["mio"])
	self:register_player(player_n, player)

	self.waves_until_respawn[player_n] = { -1, nil }
	if self.level.backroom and self.level.backroom.get_default_player_gun then
		local gun = self.level.backroom:get_default_player_gun()
		player:equip_gun(gun)
	end

	self:new_actor(player)

	if self.level.backroom then
		if self.level.backroom.get_x_target_after_join_game then
			player.show_hud = false
			player:set_input_mode(PLAYER_INPUT_MODE_CODE)
			player:set_code_input_mode_target_x(self.level.backroom:get_x_target_after_join_game(), function(p)
				p.show_hud = true
				p:set_input_mode(PLAYER_INPUT_MODE_USER)
			end)
		end
		if self.level.backroom.on_new_player then
			self.level.backroom:on_new_player(player)
		end
	end

	return player
end

function Game:remove_player(player_n)
	if not self.all_players[player_n] then
		return
	end
	self.all_players[player_n]:remove()
	self:unregister_player(player_n)
end

function Game:revive_player(player_n, x, y)
	-- Remove old player (if exists)
	self:remove_player(player_n)

	-- Spawn new player
	local new_player = game:new_player(player_n, x, y)
	self.waves_until_respawn[player_n] = { -1, nil }

	new_player:set_invincibility(new_player.max_invincible_time)
	for _, upgrade in pairs(game.upgrades) do
		new_player:apply_upgrade(upgrade, true)
	end

	new_player:set_life(new_player.max_life)

	return new_player
end

function Game:leave_game(player_n)
	if self.all_players[player_n] == nil then
		return
	end

	local player = self.all_players[player_n]
	local profile_id = Input:get_input_profile_from_player_n(player.n):get_profile_id()

	Particles:smoke(player.mid_x, player.mid_y, 10)
	self:remove_player(player_n)
	Input:remove_user(player_n)
	if profile_id == "keyboard_split_p1" or profile_id == "keyboard_split_p2" then
		Input:unsplit_keyboard()
	end

	if self.level.backroom.on_player_leave then
		self.level.backroom:on_player_leave(player)
	end
	self.level:on_player_leave(player_n)

	self.join_cooldown_frames = 2
end

function Game:update_queued_players(dt)
	for _, queued_player in pairs(self.queued_players) do
		queued_player:update(dt, self.queued_players)
	end

	for key, queued_player in pairs(self.queued_players) do
		if queued_player.is_removed then
			self.queued_players[key] = nil
		end
	end
end

function Game:get_number_of_alive_players()
	local count = 0
	for i, player in pairs(self.players) do
		count = count + 1
	end
	return count
end

function Game:enable_endless_mode()
	self.endless_mode = true
	self.music_player:play()
end

function Game:start_game(is_quickstart)
	self.game_ui.logo_y_target = -70
	self.game_state = GAME_STATE_PLAYING
	self.level:activate_enemy_buffer()
	self.level:begin_next_wave_animation()
	self:remove_queued_players()
	
	if is_quickstart then
		self.music_player:set_disk("w1")
		self.ambience_player:set_disk("w1")
	else
		self.music_player:fade_out("w1", 1.0)
		self.ambience_player:fade_out("w1", 1.0)
	end

	self.menu_manager:set_can_pause(true)
	self.camera:set_target_offset(0, 0)

	Stats:add("runs", 1)
end

function Game:apply_upgrade(upgrade)
	self.level:on_upgrade_applied(upgrade)
	table.insert(self.upgrades, upgrade)
	for i, player in pairs(self.players) do
		player:apply_upgrade(upgrade)
	end
end

function Game:revoke_upgrade(upgrade_index)
	assert(self.upgrades[upgrade_index] ~= nil)

	table.remove(self.upgrades, upgrade_index)
	for i, player in pairs(self.players) do
		player:revoke_upgrade(upgrade_index)
	end
end

function Game:screenshot()
	local filename, filepath, imgdata, imgpng = Screenshot:screenshot()
	self.notif = "screenshot " .. filename
	self.notif_timer = 3.0
	-- Particles:word(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
end

function Game:new_life_orb(x, y, value)
    local vx = random_neighbor(300)
    local vy = random_range(-200, -500)
	return LifeOrb:new(x, y, value or 1.0, vx, vy)
end

function Game:play_cutscene(cutscene_name)
	local cutscene = cutscenes[cutscene_name]
	if not cutscene then
		return
	end
	self.cutscene = cutscene
	self.cutscene:play()
end

function Game:stop_cutscene()
	if not self.cutscene then
		return
	end
	self.cutscene:stop()
	self.cutscene = nil
end

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

function Game:keypressed(key, scancode)
	if scancode == "f12" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rshift")) then
		self.debug_mode = true
		self.debug.notif = "debug mode enabled"
		self.debug.notif_timer = 3.0

		-- self.debug
	end

	if self.menu_manager then
		self.menu_manager:keypressed(key, scancode)
	end
	if self.debug then
		self.debug:keypressed(key, scancode)
	end
end

function Game:keypressedrepeat(key, scancode)
	
	if self.menu_manager then
		self.menu_manager:keypressedrepeat(key, scancode)
	end
	if self.debug then
		self.debug:keypressedrepeat(key, scancode)
	end
end

function Game:keyreleased(key, scancode)
	if self.debug then
		self.debug:keyreleased(key, scancode)
	end
end

function Game:joystickadded(joystick)
	Input:joystickadded(joystick)

	if self.game_state == GAME_STATE_LANGUAGE_SETUP then
		print_debug("ADDED")
		self:queue_join_game("controller", joystick)
	end
end

function Game:joystickremoved(joystick)
	Input:joystickremoved(joystick)

	local player_n = Input:get_joystick_user_n(joystick)
	if player_n ~= -1 then
		if self.game_state == GAME_STATE_WAITING then
			self:leave_game(player_n)
			self.menu_manager:unpause()

		elseif self.game_state == GAME_STATE_LANGUAGE_SETUP then
			
		else
			self.menu_manager:enable_joystick_wait_mode(joystick)
		end

		if self.queued_players and self.queued_players[player_n] then
			self.game_ui.player_previews[player_n]:cancel_character_select()
		end
	end
end

function Game:gamepadpressed(joystick, buttoncode)
	Input:gamepadpressed(joystick, buttoncode)
	if self.menu_manager then self.menu_manager:gamepadpressed(joystick, buttoncode) end
	if self.debug then self.debug:gamepadpressed(joystick, buttoncode) end
end

function Game:gamepadreleased(joystick, buttoncode)
	Input:gamepadreleased(joystick, buttoncode)
	if self.menu_manager then self.menu_manager:gamepadreleased(joystick, buttoncode) end
	if self.debug then self.debug:gamepadreleased(joystick, buttoncode) end
end

function Game:gamepadaxis(joystick, axis, value)
	Input:gamepadaxis(joystick, axis, value)
	if self.menu_manager then self.menu_manager:gamepadaxis(joystick, axis, value) end
	if self.debug then self.debug:gamepadaxis(joystick, axis, value) end
end

function Game:mousepressed(x, y, button, istouch, presses)
	-- Input:mousepressed(joystick, axis, value)
	if self.menu_manager then self.menu_manager:mousepressed(x, y, button, istouch, presses) end
end

function Game:mousereleased(x, y, button, istouch, presses)
	-- Input:mousereleased(joystick, axis, value)
	if self.menu_manager then self.menu_manager:mousereleased(x, y, button, istouch, presses) end
end

function Game:textinput(text)
	if self.menu_manager then self.menu_manager:textinput(text) end
end

function Game:focus(f)
	if f then
	else
		if Options:get("pause_on_unfocus") and self.menu_manager and Input:get_number_of_users() >= 1 then
			self.menu_manager:pause()
		end
	end
end

function Game:reset_screenshake()
	self.camera:reset_screenshake()
end

function Game:screenshake(q)
	self.camera:screenshake(q)
end

function Game:frameskip(q)
	self.frames_to_skip = math.max(self.frames_to_skip, q)
end

function Game:slow_mo(q)
	self.slow_mo_rate = q
end

function Game:reset_slow_mo(q)
	self.slow_mo_rate = 0
end

function Game:update_skin_choices()
	self.skin_choices = {}
	for skin_id, _ in pairs(skins) do
		self.skin_choices[skin_id] = false
	end
	for _, unlocked_skin_id in pairs(Metaprogression:get("skins")) do
		self.skin_choices[unlocked_skin_id] = true
	end
	for i, player in pairs(self.all_players) do
		self.skin_choices[player.skin.id] = false
	end
end

function Game:set_actor_draw_color(col)
	self.layers[LAYER_OBJECTS].draw_color = col
	self.layers[LAYER_OBJECT_SHADOWLESS].draw_color = col
	self.layers[LAYER_FRONT].draw_color = col
end

function Game:check_achievements()
	Stats:check_achievements()
	Metaprogression:check_achievements()
end

return Game
