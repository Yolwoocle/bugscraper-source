require "scripts.util"
local Class = require "scripts.meta.class"
local upgrades = require "data.upgrades"
local skins = require "data.skins"
local skin_name_to_id = require "data.skin_name_to_id"

local StatsManager = Class:inherit()

function StatsManager:init()
    local floors_stat = {}
    for i=1, 100 do floors_stat[i] = random_range(0, 10) end

    self.default_data = {
        ["$version"] = STATS_FILE_FORMAT_VERSION,

        total_time = 0,
        ingame_time = 0,

        runs = 0,
        deaths = 0,
        kills = 0,
        max_combo = 0,
        best_run = 0,

        floors_ended = floors_stat,

        runs_floor = { -1 },
        runs_time = { -1 },
        runs_kills = { -1 },
        runs_max_combo = { -1 },
    }

    self:read_progress()
end

function StatsManager:get(name)
    return self.data[name]
end

function StatsManager:set(name, value, do_not_save)
    self.data[name] = value
    if not do_not_save then
        self:save_progress()
    end
end

function StatsManager:add(name, value, do_not_save)
    self:set(name, self:get(name) + value, do_not_save)
end

function StatsManager:reset()
    self.data = copy_table_shallow(self.default_data)
    self:save_progress()
end

function StatsManager:read_progress()
    self.data = Files:read_config_file("stats.txt", self.default_data)
end

function StatsManager:save_progress()
    Files:write_config_file("stats.txt", self.data)
end

function StatsManager:check_achievements()
    if self:get("deaths") >= 50 then
		-- Achievements:grant("ach_death")
	end
    
    -- if self:get("best_run") >= 20 then
	-- 	Achievements:grant("ach_complete_w1")
	-- end
    -- if self:get("best_run") >= 40 then
	-- 	Achievements:grant("ach_complete_w2")
	-- end
    -- if self:get("best_run") >= 60 then
	-- 	Achievements:grant("ach_complete_w3")
	-- end
    -- if self:get("best_run") >= 80 then
	-- 	Achievements:grant("ach_complete_w4")
	-- end
    
    -- if self:get("max_combo") >= 100 then
    if game and game.level and game.level.max_fury_combo >= 100 then
		Achievements:grant("ach_big_combo")
	end
end

return StatsManager
