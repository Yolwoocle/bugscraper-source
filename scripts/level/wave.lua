require "scripts.util"
local Class = require "scripts.meta.class"
local Enemies = require "data.enemies"
local Rect = require "scripts.math.rect"

local Wave = Class:inherit()

function Wave:init(params)
	self.floor_type = param(params.floor_type, FLOOR_TYPE_NORMAL)
	self.roll_type = param(params.roll_type, WAVE_ROLL_TYPE_RANDOM)
	self.music = param(params.music, nil)
	self.fade_out_music = param(params.fade_out_music, true)
	self.push_music_buffer = param(params.push_music_buffer, nil)
	self.pull_music_buffer = param(params.pull_music_buffer, nil)
	self.ambience = param(params.ambience, nil)
	self.bounds = param(params.bounds, Rect:new(unpack(RECT_ELEVATOR_PARAMS)))

	self.min = param(params.min, 1)
	self.max = param(params.max, 1)
	self.enemies = param(params.enemies, {})
	self.fixed_enemies = param(params.fixed_enemies, {})
	self.level_geometry = param(params.level_geometry, nil)
	self.elevator_layers = param(params.elevator_layers, {})
	
	self.over_title = param(params.over_title, nil)
	self.title = param(params.title, nil)
	self.title_x = param(params.title_x, CANVAS_WIDTH/2)
	self.title_y = param(params.title_y, CANVAS_HEIGHT/2)
	self.title_color = param(params.title_color, COL_BLACK_BLUE)
	self.over_title_color = param(params.over_title_color, self.title_color)
	self.title_stay_time = param(params.title_stay_time, 3)
	self.title_scale = param(params.title_scale, 2)
	self.title_outline_color = param(params.title_outline_color, COL_WHITE)
	
	self.run = param(params.run, nil)
	self.floating_text = param(params.floating_text, nil)
	self.cutscene = param(params.cutscene, nil)
	self.backroom = param(params.backroom, nil)
	self.backroom_params = param(params.backroom_params, nil)
	self.elevator = param(params.elevator, nil)
	self.world = param(params.world, nil)

	self.counter_display_func = param(params.counter_display_func, nil)

	self.background = param(params.background, nil)
	self.background_transition = param(params.background_transition, nil)
	self.background_speed_multiplier = param(params.background_speed_multiplier, nil)

	self.override_spawn_cocoons = param(params.override_spawn_cocoons, false)
	self.opened_door_timer_override = param(params.opened_door_timer_override, nil)

	self.achievements = param(params.achievements, {})

	self.entrance_names = self:generate_entrance_names()
end

function Wave:generate_entrance_names()
	local entrances = {}
	for _, entry in pairs(self.enemies) do
		local entry_entrances = entry.entrances or {"main"}
		for _, entrance in pairs(entry_entrances) do
			entrances[entrance] = true
		end 
	end
	if self.floor_type == FLOOR_TYPE_CAFETERIA then
		entrances["main"] = true
	end
	return table_keys(entrances)
end

function Wave:roll()
	local roll = {}
	if self.roll_type == WAVE_ROLL_TYPE_RANDOM then
		roll = self:roll_random()
	elseif self.roll_type == WAVE_ROLL_TYPE_FIXED then
		roll = self:roll_fixed()
	end

	self:add_cocoons(roll)
	return roll
end

function Wave:get_parsed_enemy_table(enemy_table)
	return {
		enemy_class = enemy_table[1],
		args = enemy_table.args or {},
		position = enemy_table.position,
		life = enemy_table.life,
		entrances = enemy_table.entrances or {"main"},
		ignore_position_clamp = enemy_table.ignore_position_clamp,
	}
end

function Wave:roll_random(enemies)
	enemies = param(enemies, self.enemies)
	local number_of_enemies = love.math.random(self.min, self.max)
	if number_of_enemies == 0 then
		return {}
	end

	local output = {}
	for i=1, number_of_enemies do
		local _, enemy_table = random_weighted(enemies)
		table.insert(output, self:get_parsed_enemy_table(enemy_table))
	end
	
	return output
end

function Wave:roll_fixed(enemies)
	enemies = param(enemies, self.enemies)
	local output = {}
	for i=1, #enemies do
		local enemy_table = enemies[i]
		for j=1, enemy_table[2] do
			table.insert(output, self:get_parsed_enemy_table(enemy_table))
		end
	end
	
	return output
end

function Wave:add_cocoons(enemy_classes)
	if game:get_number_of_alive_players() >= Input:get_number_of_users() then
		return 
	end

	for i = 1, MAX_NUMBER_OF_PLAYERS do
		local cond = (game.waves_until_respawn[i][1] == 0 or self.floor_type == FLOOR_TYPE_CAFETERIA or self.override_spawn_cocoons)
		if game.waves_until_respawn[i][1] ~= -1 and cond then
			table.insert(enemy_classes, {
				enemy_class = Enemies.Cocoon,
				args = {game.waves_until_respawn[i][2]},
				entrances = {"main"},
			})
			game.waves_until_respawn[i] = {-1, nil}
		end
	end
end

function Wave:spawn(elevator)
	local spawned_enemies = {}

	self:spawn_roll(elevator, self:roll(), spawned_enemies)
	if self.fixed_enemies then
		self:spawn_roll(elevator, self:roll_fixed(self.fixed_enemies), spawned_enemies)
	end

	return spawned_enemies
end

function Wave:spawn_roll(elevator, roll, spawned_enemies)
	local enemy_classes = roll

	for i=1, #enemy_classes do
		local entrance_names = enemy_classes[i].entrances or elevator.entrance_names
		assert(entrance_names and type(entrance_names) == "table" and #entrance_names > 0, "Invalid entrances table given")
		local entrance_name = random_sample(entrance_names)
		local entrance = elevator.entrances[entrance_name]
		assert(entrance and entrance.rect, "Invalid entrance found (name '"..tostring(entrance_name).."')")
		local rect = entrance.rect

		local x = love.math.random(rect.ax, rect.bx)
		local y = love.math.random(rect.ay, rect.by)

		local enemy_class = enemy_classes[i].enemy_class
		local args = enemy_classes[i].args
		local position = enemy_classes[i].position or {x, y}

		local life = enemy_classes[i].life
		
		local enemy_instance = enemy_class:new(position[1], position[2], unpack(args))

		-- Center enemy & clamp position
		local function clamp_actor(actor)
			if actor.is_removed then
				return
			end
			actor:set_position(
				math.floor(clamp(actor.x, rect.ax, rect.bx - actor.w)), 
				math.floor(clamp(actor.y, rect.ay, rect.by - actor.h))
			)
		end

		if not (enemy_classes[i].position or enemy_classes[i].ignore_position_clamp) then
			clamp_actor(enemy_instance)
		end

		if life then
			enemy_instance.life = life
		end

		game:new_actor(enemy_instance)
		
		-- Passengers / riders
		local cur_rider = enemy_instance
		local limit = 10
		while cur_rider ~= nil and limit >= 0 do
			table.insert(spawned_enemies, cur_rider)
			cur_rider:set_active(false)
			
			cur_rider = cur_rider.rider
			limit = limit - 1
		end
		
		-- Extra spawned enemies
		local function add_spawned_actors(enemy)
			if not enemy.spawned_actors or #enemy.spawned_actors == 0 then
				return
			end

			for _, extra_enemy in pairs(enemy.spawned_actors or {}) do
				table.insert(spawned_enemies, extra_enemy)
				add_spawned_actors(extra_enemy)
				extra_enemy:set_active(false)

				clamp_actor(extra_enemy)
			end
		end
		add_spawned_actors(enemy_instance)
	end

	return spawned_enemies
end

function Wave:get_floor_type()
	return self.floor_type
end

function Wave:show_title()
	if self.title then
		Particles:word(
			self.title_x, self.title_y - 16, 
			self.over_title, self.over_title_color, self.title_stay_time, 1, self.title_outline_color
		)
		Particles:word(
			self.title_x, self.title_y, 
			self.title, self.title_color, self.title_stay_time, self.title_scale, self.title_outline_color
		)
	end
end

function Wave:enable_wave_side_effects(level)
	if self.background then
		level:set_background(self.background)
	end
	if self.background_transition then
		level:start_background_transition(self.background_transition)
	end
	if self.background_speed_multiplier then
		level.level_speed_advancing = level.default_level_speed * self.background_speed_multiplier
	end

	if self.music then
		game.music_player:fade_out(self.music, self.fade_out_music and 1.0 or 0.0, {
			push_playback_position = self.push_music_buffer,
			pull_playback_position = self.pull_music_buffer, 
		})
	end

	if self.ambience then
		game.ambience_player:fade_out(self.ambience, 1.0)
	end

	if self.level_geometry then
		self.level_geometry:apply(level)
	end

	if self.bounds then
		level:set_bounds(self.bounds)
	end

	if self.elevator_layers then
		for layer, value in pairs(self.elevator_layers) do
			level.elevator:set_layer(layer, value)
		end
	end
	
	if self.run then
		self:run(level)
	end

	if self.floating_text then
		game.game_ui:enable_floating_text(self.floating_text)
	else
		game.game_ui:disable_floating_text()
	end

	if self.cutscene then
		game:play_cutscene(self.cutscene)
	end

	if self.backroom then
		game.level:begin_backroom(self.backroom:new(self.backroom_params))
	end
	
	if self.counter_display_func then
		game.level.elevator.counter_display_func = self.counter_display_func
	end
	
	if self.achievements then
		for _, ach in pairs(self.achievements) do
			Achievements:grant(ach)
		end
	end
end

return Wave