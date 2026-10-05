require "scripts.util"
local menu_util             = require "scripts.ui.menu.menu_util"
local Menu                  = require "scripts.ui.menu.menu"
local Timer                 = require "scripts.timer"

local StatsMenuItem         = require "scripts.ui.menu.items.menu_item_stats"
local ProgressBarMenuItem   = require "scripts.ui.menu.items.progress_bar_menu_item"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_url              = menu_util.func_url
local PROMPTS_NORMAL     = menu_util.PROMPTS_NORMAL

---------------------------------------------------------

local StatsMenu             = Menu:inherit()

function StatsMenu:init(game)
    StatsMenu.super.init(self, game, "{menu.stats.title}", {
            { StatsMenuItem, Text:parse("🕐 {menu.stats.time_total}"), function(self)
                return time_to_string(Stats:get("total_time"))
            end },
            { StatsMenuItem, Text:parse("🕐 {menu.stats.time_ingame}"), function(self)
                return time_to_string(Stats:get("ingame_time"))
            end },
            { "" },
            { StatsMenuItem, Text:parse("⏰ {menu.stats.runs}"), function(self)
                return Stats:get("runs")
            end },
            { StatsMenuItem, Text:parse("⚔️ {menu.game_over.kills}"), function(self)
                return Stats:get("kills")
            end },
            { StatsMenuItem, Text:parse("💀 {menu.game_over.deaths}"), function(self)
                return Stats:get("deaths")
            end },
            { StatsMenuItem, Text:parse("🔥 {menu.game_over.max_combo}"), function(self) 
                return Stats:get("max_combo") 
            end },
            { StatsMenuItem, Text:parse("⭐ {menu.stats.best_run}"), function(self) 
                return Stats:get("best_run") 
            end },
        }, 
        DEFAULT_MENU_BG_COLOR,
        PROMPTS_NORMAL, 
        nil
    )
end

function StatsMenu:update(dt)
    StatsMenu.super.update(self, dt)
end

function StatsMenu:on_set(is_back)
    StatsMenu.super.on_set(self, is_back)
end

return StatsMenu:new()
