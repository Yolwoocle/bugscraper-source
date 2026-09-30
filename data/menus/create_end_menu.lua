require "scripts.util"
local menu_util             = require "scripts.ui.menu.menu_util"
local BackroomCredits      = require "scripts.level.backroom.backroom_credits"
local func_url              = menu_util.func_url

local StatsMenuItem         = require "scripts.ui.menu.items.menu_item_stats"
local ProgressBarMenuItem   = require "scripts.ui.menu.items.progress_bar_menu_item"

local function create_items(item_order)
    local items = {
        { StatsMenuItem, Text:parse("⚔️ {menu.game_over.kills}"), function(self)
            return game.stats.kills
        end },
        { StatsMenuItem, Text:parse("💀 {menu.game_over.deaths}"), function(self)
            return game.stats.deaths
        end },
        { StatsMenuItem, Text:parse("🕐 {menu.game_over.time}"), function(self)
            return time_to_string(game.stats.time)
        end },
        { StatsMenuItem, Text:parse("⏰ {menu.game_over.floor}"), function(self)
            return concat(game.stats.floor)
        end },
        { StatsMenuItem, Text:parse("🔥 {menu.game_over.max_combo}"), function(self) return concat(game.stats.max_combo) end },
        { StatsMenuItem, Text:parse("⭐ {menu.game_over.score}"), function(self)
            return concat(game.stats.score)
        end },
        {""},
    }

    for i, item in pairs(item_order) do
        if item == "quick_restart" then
            table.insert(items, { "🔄 {menu.game_over.quick_restart}",
                function(item)
                    game.has_seen_controller_warning = true
                    game:new_game({ quick_restart = true })
                end,
                function(item)
                    item.is_visible = not Options:get("convention_mode")
                end
            })

        elseif item == "return" then
            table.insert(items, { "▶ {menu.pause.return_to_ground_floor}",
                function(item)
                    -- scotch
                    game:new_game()
                end,
                function(item)
                end,
            })

        elseif item == "continue" then
            table.insert(items, { "▶ {menu.game_over.continue}",
            function(item)
                    -- scotch
                    game:new_game()
                end,
                function(item)
                end,
            })

        elseif item == "wishlist" and BUILD_TYPE == "demo" then
            table.insert(items,
                { "❤ {menu.win.wishlist} 🔗",
                    function(item)
                        game.has_seen_controller_warning = true
                        love.system.openURL("steam://advertise/2957130/")
                    end,
                    function(item)
                        item.is_selectable = game.has_finished_game_over_animation
                        item.is_visible = not Options:get("convention_mode")
                    end
                }
            )

        end
    end

    return items
end

return create_items