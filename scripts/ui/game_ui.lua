require "scripts.util"
local images = require "data.images"
local Class = require "scripts.meta.class"
local PlayerPreview = require "scripts.ui.player_preview"
local Toast = require "scripts.ui.toast"
local shaders = require "data.shaders"
local Ui = require "scripts.ui.ui"
local Timer = require "scripts.timer"
local TvPresentation = require "scripts.level.background.tv_presentation"
local achievements   = require "data.achievements"

local GameUI = Class:inherit()

function GameUI:init(game, is_visible)
	self.game = game

    self.is_visible = param(is_visible, true)

	self.logo_y = 0
	self.logo_y_target = 0

	self.floating_text = ""
	self.floating_text_y = -50
	self.floating_text_target_y = -100

	self.player_previews = {}
	local w = 108
	local spacing = 10
	local x = CANVAS_WIDTH/2 - ((w + spacing) * (MAX_NUMBER_OF_PLAYERS-1) + w)/2
	local y = 200
	for i = 1, MAX_NUMBER_OF_PLAYERS do
		table.insert(self.player_previews, PlayerPreview:new(i, x, y, w, 64))
		x = x + w + spacing	
	end

	self.splash_x = 0
	self.splash_vx = 0
	self.show_splash = true
	if not game.start_with_splash then
		self.show_splash = false
	end

	self.show_upgrades = true

	self.cinematic_bar_loop_threshold = 14
	self.cinematic_bar_scroll = 0
	self.cinematic_bar_scroll_speed = -14
	self.cinematic_bar_current_height = 0
	self.cinematic_bar_height = 24
	self.cinematic_bar_color = nil

	self.show_fury = true
	self.fury_previous_value = 0
	self.fury_visual_width = 0
	self.fury_flash_timer = 0
	self.fury_flash_max_timer = 0.2
	self.fury_text_oy = 32
	self.fury_text_oy_target = 32
	self.fury_text_wave_height = 2.0
	self.displayed_combo = 0 
	self.time_since_fury_end = math.huge
	self.max_time_since_fury_end = 5.0

	self.offscreen_indicators_enabled = true
	
	self.title_buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.titles = {"Léo Bernard"}
	self.subtitle = "Yolwoocle"
	self.overtitle = "A game by"
	self.title_alpha = 0.0
	self.title_alpha_target = 1.0
	
	self.title_intro_duration = 0.5
	self.title_stay_duration = 1.0
	self.title_outro_duration = 0.5
	
	self.title_state = "intro"
	self.title_state_timer = Timer:new(0.0)
	self.current_title_state_duration = "intro"

	self.title_image = nil
	self.title_image_x = 0
	self.title_image_y = 0
	
	self.title_tvs_on = false
	self.title_tv_grid = nil
	self.title_tvs = {}
	self.tv_grid_rows = 2
	self.tv_grid_columns = 4
	self.tv_grid_x_spacing = 82
	self.tv_grid_y_spacing = 64
	self:init_tv_grid()

	self.dark_overlay_color_override = nil
	self.dark_overlay_alpha = 0.0
	self.dark_overlay_alpha_target = 0.0

	self.boss_bar_value = 1.0
	self.boss_bar_buffer_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)

	self.iris_transition_canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
	self.iris_transition_on = false
	self.iris_transition_x = CANVAS_WIDTH/2
	self.iris_transition_y = CANVAS_HEIGHT/2
	self.iris_transition_radius = 50
	self.iris_transition_original_radius = 0
	self.iris_transition_target_radius = 0
	self.iris_transition_t = 0
	self.iris_transition_target_t = 0

	self.toasts = {}
	self.frames_since_toast_sfx = 0

	self.ending_counter_text = nil

	self.show_boss_bar = true

	self.show_timer = true

	self.t = 0
end

function GameUI:update(dt)
	self:update_floating_text(dt)
	for i, preview in pairs(self.player_previews) do
		preview:update(dt)
		preview.y = preview.base_y - self.logo_y
	end

	self.logo_y = lerp(self.logo_y, self.logo_y_target, 0.1)
	self.logo_y = clamp(self.logo_y, -70, 0)

	self:update_cinematic_bars(dt)
	self:update_splash(dt)
	self:update_fury(dt)
	self:update_convention_video(dt)
	self:update_title(dt)
	self:update_boss_bar(dt)
	self:update_iris_transition(dt)
	self.dark_overlay_alpha = move_toward(self.dark_overlay_alpha, self.dark_overlay_alpha_target, dt)
	
	self.t = self.t + dt
end

function GameUI:update_global(dt)
	self:update_toast(dt)
end

function GameUI:draw()
	if not self.is_visible then return end
	self:draw_version()
	self:draw_offscreen_indicators()
	self:draw_floating_text()
	self:draw_upgrades()

	self:draw_convention_video()
	self:draw_player_previews()
	self:draw_cinematic_bars()
	self:draw_fury()
	self:draw_boss_bar()
	
	self:draw_titles()
	self:draw_iris_transition()
	
	if self.dark_overlay_alpha > 0 then
		rect_color(transparent_color(self.dark_overlay_color_override or COL_BLACK_BLUE, self.dark_overlay_alpha), "fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	end
	self:draw_splash_animation()
	-- local r
    -- r = game.level.cabin_inner_rect
    -- rect_color(COL_GREEN, "line", r.ax, r.ay, r.w, r.h)
	-- r = game.level.cabin_rect
    -- rect_color(COL_RED, "line", r.ax, r.ay, r.w, r.h)
end

function GameUI:draw_front()
	if not self.is_visible then return end
	
	self:draw_FPS()
	self:draw_timer()
	self:draw_toast()
end

function GameUI:set_gameplay_hud_visible(bool)
	self.show_fury = bool
	self.offscreen_indicators_enabled = bool
	self.show_upgrades = bool
	self.show_boss_bar = bool

	for _, player in pairs(game.players) do
		player.show_hud = bool
	end	
end

function GameUI:start_title(title, subtitle, overtitle, intro_dur, stay_dur, outro_dur, params)
	params = params or {}

	local titles = {}
	if type(title) == "string" then
		titles = {title}
	elseif type(title) == "table" then
		titles = copy_table_shallow(title)
	end

	for i = 1, #titles do
		titles[i] = Text:parse(titles[i])
	end
	self.titles = titles
	self.subtitle = Text:parse(subtitle)
	self.overtitle = Text:parse(overtitle)

	self.title_intro_duration = intro_dur
	self.title_stay_duration = stay_dur
	self.title_outro_duration = outro_dur
	self.title_tvs_on = false

	if params.image then
		self.title_image = params.image
		self.title_image_x = params.image_x or 0
		self.title_image_y = params.image_y or 0
	else
		self.title_image = nil
	end

	self.title_state = "intro"

	self.title_state_timer:start(self.title_intro_duration)
end

function GameUI:init_tv_grid()
	local sx = CANVAS_WIDTH/2 - (self.tv_grid_columns-1) * self.tv_grid_x_spacing * 0.5
	local sy = CANVAS_HEIGHT/2 - (self.tv_grid_rows-1) * self.tv_grid_y_spacing * 0.5
	for ix = 1, self.tv_grid_columns do
		for iy = 1, self.tv_grid_rows do
			table.insert(self.title_tvs, {
				tv = TvPresentation:new(
					math.floor(sx + (ix-1) * self.tv_grid_x_spacing - TV_WIDTH/2),
					math.floor(sy + (iy-1) * self.tv_grid_y_spacing - TV_HEIGHT/2),
					{
						shuffle_table = false,
						default_slide_duration = 50.0,
						do_slideshow = false
					}
				),
				enabled = false,
				subtext = "",
			})
		end
	end
end

function GameUI:start_title_tv(tvs, intro_dur, stay_dur, outro_dur)
	self:start_title("", "", "", intro_dur, stay_dur, outro_dur)
	self.title_tvs_on = true
	
	for i=1, #tvs do
		self.title_tvs[i].tv:set_current_slide_from_name(tvs[i][1])
		self.title_tvs[i].subtext = TV_CREDITS[tvs[i][1]]
	end
end

function GameUI:update_title(dt)
	if self.title_state_timer:update(dt) then
		if self.title_state == "intro" then
			self.title_state = "stay"
			self.title_state_timer:start(self.title_stay_duration)
			
		elseif self.title_state == "stay" then
			self.title_state = "outro"
			self.title_state_timer:start(self.title_outro_duration)

		elseif self.title_state == "outro" then
			self.title_state = "off"
			self.titles = nil
			self.subtitle = nil
			self.overtitle = nil
			self.title_tvs_on = false
			self.title_image = nil
			self.title_image_x = 0
			self.title_image_y = 0
		end
	end

	if self.title_state == "off" then
		self.title_alpha = 0
	end 
	if self.title_state == "stay" then
		self.title_alpha = 1
	end 
	if self.title_state == "intro" or self.title_state == "outro" then
		local a, b = 0, 1
		if self.title_state == "outro" then
			a, b = 1, 0
		end
		self.title_alpha = lerp(a, b, self.title_state_timer:get_ratio())
	end

	for _, tv in pairs(self.title_tvs) do
		tv.tv:update(dt)
	end
end

function GameUI:update_boss_bar(dt)
	if not game:get_boss() then
		self.boss_bar_value = 1
		return
	end

	local old_val = self.boss_bar_value
	self.boss_bar_value = lerp(self.boss_bar_value, game:get_boss().life / game:get_boss().max_life, 0.3)

	self.boss_bar_is_changing = (math.abs(self.boss_bar_value - old_val) > 0.001)
end

function GameUI:update_floating_text(dt)
	self.floating_text_y = lerp(self.floating_text_y, self.floating_text_target_y, 0.05)
end

function GameUI:enable_floating_text(text)
	self.floating_text = text
	self.floating_text_target_y = 80
end

function GameUI:disable_floating_text()
	self.floating_text_target_y = -50
end

function GameUI:set_visible(bool)
    self.is_visible = bool
end

function GameUI:draw_titles()
	exec_on_canvas(self.title_buffer_canvas, function()
		love.graphics.clear()

		local title_line_height = get_text_height()
		local titles_height = 0
		if self.titles then 
			titles_height = #self.titles * title_line_height
		end

		Text:push_font(FONT_REGULAR)
		if self.titles then
			for i=1, #self.titles do
				print_centered_outline(nil, nil, 
					self.titles[i], 
					CANVAS_CENTER[1], 
					CANVAS_CENTER[2] - (title_line_height*(#self.titles - 1))/2 + title_line_height*(i-1)
				)
			end
		end
		Text:pop_font()
	
		Text:push_font(FONT_MINI)
		if self.subtitle then
			print_centered_outline(nil, nil, self.subtitle, CANVAS_CENTER[1], CANVAS_CENTER[2] + titles_height/2 + 5)
		end
		if self.overtitle then
			print_centered_outline(COL_LIGHTEST_GRAY, nil, self.overtitle, CANVAS_CENTER[1], CANVAS_CENTER[2] - titles_height/2 - 9)
		end
		Text:pop_font()

		if self.title_image then
			love.graphics.draw(self.title_image or images.empty, self.title_image_x or 0, self.title_image_y or 0)
		end
		
		self:draw_title_tv_grid()
		
	end)
	
	exec_color({1, 1, 1, self.title_alpha}, function()		
		love.graphics.draw(self.title_buffer_canvas, 0, 0)
	end)

	if self.ending_counter_text then
		Text:push_font(FONT_7SEG)
		print_centered_outline(COL_WHITE, nil, self.ending_counter_text, CANVAS_CENTER[1], 70, 2, 0, 2)
		Text:pop_font()
	end
end

function GameUI:draw_title_tv_grid()	
	if not self.title_tvs_on then
		return
	end
	
	Text:push_font(FONT_MINI)
	for i = 1, #self.title_tvs do
		self.title_tvs[i].tv:draw()	
		print_centered_outline(COL_WHITE, COL_BLACK_BLUE, self.title_tvs[i].subtext, self.title_tvs[i].tv.x + TV_WIDTH/2, self.title_tvs[i].tv.y + TV_HEIGHT/2 + 24)
	end
	Text:pop_font()
end

function GameUI:draw_logo()
	for i=1, #LOGO_COLS + 1 do
		local ox, oy = cos(game.logo_a + i*.4)*8, sin(game.logo_a + i*.4)*8
		local logo_x = floor((CANVAS_WIDTH - images.logo_noshad:getWidth())/2)
		
		local col = LOGO_COLS[i]
		local img = images.logo_shad
		if col == nil then
			col = COL_WHITE
			img = images.logo_noshad
		end
		love.graphics.setColor(col)
		love.graphics.draw(img, math.floor(logo_x + ox), math.floor(self.logo_y + oy))
		if BUILD_TYPE == "demo" then
			if i == 4 then
				print_outline(COL_WHITE, COL_BLACK_BLUE, Text:text("game.demo"), logo_x + ox + 90, self.logo_y + oy + 19)
			else
				print_outline(col, col, Text:text("game.demo"), logo_x + ox + 90, self.logo_y + oy + 19)
			end
		end
	end
end

function GameUI:draw_version()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(FONT_MINI)

	local text = concat("v", BUGSCRAPER_VERSION)
	if BETA_BUILD then
		text = "Beta build: game might be unstable and change in the future - "..text
	end
	local x = math.floor(CANVAS_WIDTH - get_text_width(text) - 2)
	local y = self.logo_y
	print_color(COL_DARK_GRAY, text, x, y)
	love.graphics.setFont(old_font)

	-- if OPERATING_SYSTEM == "Web" and not game.has_seen_controller_warning then
	-- 	print_centered_outline(COL_MID_GRAY, COL_BLACK_BLUE, "⚠️ "..Text:text("game.warning_web_controller"), CANVAS_WIDTH/2, y+6)
	-- end
end

function GameUI:draw_timer()
	if not Options:get("timer_on") or not self.show_timer then 
		return
	end

	local text = concat(time_to_string(game.time), " · ⏰ ", game.level.floor)
	rect_color({0,0,0,0.5}, "fill", 0, 8, get_text_width(text) + 16, 12)
	love.graphics.flrprint(text, 8, 6)
end

function GameUI:draw_FPS()
	if not Options:get("show_fps_warning") then
		return
	end
	
	local t = "⚠ "..Text:text("game.fps", love.timer.getFPS())
	
	if game.t > 2 and love.timer.getFPS() <= 55 then
		print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3)
		-- if game.menu_manager.cur_menu ~= nil then
		-- 	t = "⚠ "..Text:text("game.fps_warning")
		-- 	print_outline(nil, nil, t, CANVAS_WIDTH - get_text_width(t) - 3, 3+get_text_height())
		-- end
	end
end

function GameUI:draw_offscreen_indicators()
	if not self.offscreen_indicators_enabled then
		return
	end
	local cam_x, cam_y = self.game.camera:get_position()
	for i, player in pairs(self.game.all_players) do
		if (player.x + player.w < cam_x) or (cam_x + CANVAS_WIDTH < player.x) then
			-- or (player.y + player.h < cam_y) or (cam_y + CANVAS_HEIGHT < player.y) then 
			self:draw_offscreen_indicator_for(player)
		end
	end
end

function GameUI:draw_offscreen_indicator_for(player)
	-- local padding = 17
	local padding = 24
	local radius = 10
	
	local cam_x, cam_y = self.game.camera:get_position()
	local x = math.floor(clamp(player.mid_x - cam_x, padding, CANVAS_WIDTH - padding))
	local y = math.floor(clamp(player.mid_y - cam_y, padding, CANVAS_HEIGHT - padding))
	local rot = math.atan2(player.mid_y - (y + cam_y), player.mid_x - (x + cam_x))
	
	local scale = 0.5
	exec_color(player.skin.color_palette[2], function()
		draw_centered(images.offscreen_indicator, x+1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x-1, y, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y+1, rot, scale, scale)
		draw_centered(images.offscreen_indicator, x, y-1, rot, scale, scale)
	end)
	exec_color(player.skin.color_palette[1], function()
		draw_centered(images.offscreen_indicator, x, y, rot, scale, scale)
	end)
	
	shaders.draw_in_color:sendColor("fillColor", player.skin.color_palette[2])
	exec_color(player.skin.color_palette[2], function()
		print_centered(player.skin.icon, x, y)
	end)
	print_centered_outline(player.skin.color_palette[1], player.skin.color_palette[2], Text:text("player.abbreviation", player.n), x, y - 16)
end

function GameUI:draw_floating_text()
	if #self.floating_text > 0 then
		print_centered_outline(nil, nil, Text:parse(self.floating_text), CANVAS_WIDTH/2, self.floating_text_y)
	end
end

function GameUI:get_upgrade_preview_position(i)
	local padding = 4
	local item_size = 20
	return (CANVAS_WIDTH - 4 - item_size/2), (padding + item_size/2 + item_size * (i-1))
end

function GameUI:draw_upgrades()
	if not self.show_upgrades then
		return
	end

	local item_size = 20
	local i = 1
	for _, upgrade in pairs(game.upgrades) do
		local x, y = self:get_upgrade_preview_position(i)
		draw_centered(upgrade.sprite, x, y)
		i = i + 1
	end
end

function GameUI:update_convention_video(dt)
	-- Exit if not in convention_mode
	if not Options:get("convention_mode") then
		if self.convention_video and self.convention_video:isPlaying() then
			self.convention_video:pause()
		end
		return
	end

	-- Load convention video if needed
	if not self.convention_video then
		-- Uncomment when videos are ready
		-- self.convention_video = love.graphics.newVideo("videos/testvideo.ogv")
		-- self.convention_video:play()
	end
		
	-- Rewind video if reached end
	if self.convention_video and not self.convention_video:isPlaying() then
		self.convention_video:rewind()
	end
end

function GameUI:draw_convention_video()
	if Options:get("convention_mode") and self.convention_video then
		love.graphics.draw(self.convention_video, 0, 0)
	end
end

function GameUI:draw_player_previews()
	for i, preview in pairs(self.player_previews) do
		preview:draw()
	end
end

function GameUI:on_player_joined(player)
	for i, preview in pairs(self.player_previews) do
		preview:on_player_joined(player)
	end
end

-- CINEMATIC BARS

function GameUI:update_cinematic_bars(dt)
	local target_height = 0
	if self.cinematic_bars_enabled then
		target_height = self.cinematic_bar_height
	end
	self.cinematic_bar_current_height = lerp(self.cinematic_bar_current_height, target_height, 0.08)

	self.cinematic_bar_scroll = (self.cinematic_bar_scroll + self.cinematic_bar_scroll_speed * dt) % self.cinematic_bar_loop_threshold
end


function GameUI:draw_cinematic_bars()
	Ui:draw_sawtooth_border(
		self.cinematic_bar_current_height, 
		self.cinematic_bar_current_height, 
		self.cinematic_bar_scroll, 
		{
			color = self.cinematic_bar_color or COL_BLACK_BLUE, 
			image_top = images.sawtooth_separator_small, 
			image_bottom = images.sawtooth_separator_small
		}
	)	
end


--- IRIS TRANSITION 

function GameUI:set_iris(value)
	self.iris_transition_on = value
end

function GameUI:start_iris_transition(x, y, duration, original, target)
	self.iris_transition_on = true

	self.iris_transition_x = x or self.iris_transition_x
	self.iris_transition_y = y or self.iris_transition_y

	self.iris_transition_t = 0
	self.iris_transition_target_t = duration

	self.iris_transition_original_radius = original or self.iris_transition_radius
	self.iris_transition_target_radius = target
end

function GameUI:update_iris_transition(dt)
	self.iris_transition_t = math.min(self.iris_transition_t + dt, self.iris_transition_target_t)

	local t = self.iris_transition_t / self.iris_transition_target_t
	self.iris_transition_radius = easeinoutquart(self.iris_transition_original_radius, self.iris_transition_target_radius, t)
end

function GameUI:draw_iris_transition()
    if not self.iris_transition_on then 
        return
    end
    
    exec_on_canvas({self.iris_transition_canvas, stencil=true}, function()
        love.graphics.clear()

        love.graphics.stencil(function()
            love.graphics.circle("fill", self.iris_transition_x, self.iris_transition_y, self.iris_transition_radius)
        end, "replace", 1, false)

        love.graphics.setStencilTest("less", 1)
        
        rect_color(COL_BLACK_BLUE, "fill", 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
        love.graphics.setStencilTest()
    end)

    love.graphics.draw(self.iris_transition_canvas, 0, 0)
end

--- SPLASH

function GameUI:update_splash(dt)
	if self.splash_x < -1 then
		game.start_with_splash = false
	end
	if self.splash_x < -CANVAS_WIDTH*2 then
		self.show_splash = false
	end
	self.splash_vx = self.splash_vx - dt*500 
	self.splash_x = self.splash_x + self.splash_vx * dt
end

function GameUI:draw_splash_animation()
	if not self.show_splash then 
		return
	end
	love.graphics.draw(images.splash, self.splash_x, 0)
end

--- FURY

function GameUI:update_fury(dt)
	local ratio = (game.level.fury_bar - game.level.fury_threshold) / (game.level.fury_max - game.level.fury_threshold)
	local w = 64
	local target = math.max(ratio * w, 0)
	local old_fury_visual_width = self.fury_visual_width
	self.fury_visual_width = lerp(self.fury_visual_width, target, 0.3)
	if math.abs(self.fury_visual_width) <= 1 then
		self.fury_visual_width = 0
	end
	self.is_fury_bar_increasing = self.fury_visual_width - old_fury_visual_width > 0.1 

	self.fury_flash_timer = self.fury_flash_timer - dt
	if self.fury_flash_timer < 0.0 then
		self.fury_flash_timer = self.fury_flash_timer + self.fury_flash_max_timer 
	end

	-- if fury ended
	local old_is_in_combo = self.is_in_combo
	if game.level.fury_bar < game.level.fury_threshold then
		self.is_in_combo = false
		if self.time_since_fury_end > self.max_time_since_fury_end then
			self.fury_text_oy_target = 32
		else
			self.fury_text_oy_target = -4
		end
		self.displayed_combo = game.level.last_fury_combo
		self.time_since_fury_end = self.time_since_fury_end + dt
	else
		self.is_in_combo = true
		self.fury_text_oy = 0
		self.fury_text_oy_target = 0
		self.displayed_combo = game.level.fury_combo
		self.time_since_fury_end = 0
	end
	self.fury_text_oy = lerp(self.fury_text_oy, self.fury_text_oy_target, 0.1)

	if old_is_in_combo and not self.is_in_combo then
		self.fury_text_oy = 32
	end
end


function GameUI:draw_fury()
	-- print_centered_outline(nil, nil, concat(round(game.level.fury_bar, 1), " / ", game.level.fury_max, " (", game.level.fury_threshold, ")"), CANVAS_WIDTH/2, 24)
	if not self.show_fury then
		return
	end
	
	-- local y = 12
	local y = CANVAS_HEIGHT - 12
	local w = math.min(self.fury_visual_width, math.huge)
	local h = 8

	local light_col, col, shad_col = COL_LIGHT_YELLOW, COL_YELLOW_ORANGE, COL_ORANGE
	if game.level.has_energy_drink then
		light_col, col, shad_col = COL_PINK, COL_PURPLE, COL_DARK_PURPLE
	end
	
	exec_on_canvas(self.boss_bar_buffer_canvas, function()
		-- This is horrendous.
		love.graphics.clear()
		rect_color(self.is_fury_bar_increasing and COL_WHITE or shad_col,  "fill", CANVAS_WIDTH/2 - w*1.35,  y-h*0.5/2,  w*2*1.35,  h*0.5)

		rect_color(self.is_fury_bar_increasing and COL_WHITE or col,       "fill", CANVAS_WIDTH/2 - w*1.25, y-h*0.75/2, w*2*1.25, h*0.75)
		exec_using_shader(shaders.dither, function()
			rect_color(self.is_fury_bar_increasing and COL_WHITE or shad_col, "fill", CANVAS_WIDTH/2 - w*1.25, y+h*0.75/2-2, w*2*1.25, 2)
		end)

		rect_color(self.is_fury_bar_increasing and COL_WHITE or light_col, "fill", CANVAS_WIDTH/2 - w,    y-h/2,        w*2,      h)
		exec_using_shader(shaders.dither, function()
			rect_color(self.is_fury_bar_increasing and COL_WHITE or col, "fill", CANVAS_WIDTH/2 - w,      y+h/2-2,      w*2,      2)
		end)
	end)

	draw_with_outline(COL_BLACK_BLUE, "square", self.boss_bar_buffer_canvas, 0, 0)

	exec_on_canvas(self.boss_bar_buffer_canvas, function()
		local text = Text:text("game.combo", self.displayed_combo)
		if self.is_in_combo then
			text = tostring(self.displayed_combo)
		end

		love.graphics.clear()
		print_wavy_centered_outline_text(
			col, col, 
			text, 
			CANVAS_WIDTH/2, y-h/2+self.fury_text_oy, nil, self.t+0.14, self.fury_text_wave_height, 9, 0.8
		)
		print_wavy_centered_outline_text(
			shad_col, shad_col, 
			text, 
			CANVAS_WIDTH/2, y-h/2+self.fury_text_oy, nil, self.t+0.07, self.fury_text_wave_height, 9, 0.8
		)
		print_wavy_centered_outline_text(
			COL_WHITE, COL_TRANSPARENT, 
			text, 
			CANVAS_WIDTH/2, y-h/2+self.fury_text_oy, nil, self.t, self.fury_text_wave_height, 9, 0.8
		)
	end)

	draw_with_outline(COL_BLACK_BLUE, "square", self.boss_bar_buffer_canvas, 0, 0)
end

function GameUI:draw_boss_bar()
	local boss = game:get_boss()
	if not boss then
		return
	end
	if not self.show_boss_bar then
		return
	end

	local w = 256
	local col = nil
	if self.boss_bar_is_changing then
		col = COL_WHITE
	end
	Ui:draw_progress_bar(CANVAS_CENTER[1] - w/2, 8, w, 4, 
						self.boss_bar_value, 1, 
						col or COL_LIGHT_RED, COL_BLACK_BLUE, col or COL_DARK_RED, "")
end



function GameUI:new_toast(image, title, description, params)
	params = params or {}
	if param(params.play_sfx, true) and self.frames_since_toast_sfx > 1 then
		Audio:play("sfx_ui_achievement")
		self.frames_since_toast_sfx = 0
	end
	table.insert(self.toasts, Toast:new(#self.toasts + 1, image, title, description, params))
end

function GameUI:update_toast(dt)
	for _, toast in pairs(self.toasts) do
		toast:update(dt)
	end

	self.frames_since_toast_sfx = self.frames_since_toast_sfx + 1

	for i=#self.toasts, 1, -1 do
		if self.toasts[i].to_delete then
			table.remove(self.toasts, i)
		end
	end

	for i=1, #self.toasts do
		self.toasts[i].i = i
	end
end

function GameUI:draw_toast()
	local x = 2
	local y = 2
	
	local sep = 2

	for i, toast in pairs(self.toasts) do
		toast:draw()

		y = y + toast.h + sep
	end
end

return GameUI