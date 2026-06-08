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
        { "" },
        { ProgressBarMenuItem,
            {
                -- This is so ridiculously overengineered
                update_value = function(item, dt)
                    item.augment_xp_delay = math.max(0, item.augment_xp_delay - dt)

                    local actual_xp = Metaprogression:get_xp()
                    local actual_level = Metaprogression:get_xp_level()
                    local shown_level_threshold = Metaprogression:get_xp_level_threshold(item.shown_level)

                    -- Compute target value
                    local value_target = actual_xp
                    if actual_level > item.shown_level then
                        value_target = shown_level_threshold
                    end

                    -- New level
                    if math.abs(item.value - shown_level_threshold) < 0.1 and actual_level > item.shown_level then
                        item.value = 0
                        item.overlay_value = nil
                        item.shown_level = item.shown_level + 1
                        item.augment_xp_delay = 0.5

                        local reward_info = Metaprogression:get_xp_level_info(item.shown_level - 1)
                        if reward_info then
                            Metaprogression.old_xp = 0
                            Metaprogression.old_xp_level = item.shown_level
                            game.has_finished_game_over_animation = false

                            game.menu_manager.menus["new_reward"]:set_rewards(reward_info.rewards)
                            game.menu_manager:set_menu("new_reward")
                        end
                    end

                    -- Set the progress bar value
                    local old_value = item.value
                    if item.augment_xp_delay <= 0 then
                        item.value = lerp(item.value, value_target, 0.1)
                    end

                    local sfx_tick = 5
                    if math.floor(item.value / sfx_tick) * sfx_tick > math.floor(old_value / sfx_tick) * sfx_tick then
                        local volume = 0.3
                        if shown_level_threshold == math.huge then
                            Audio:play("sfx_ui_xpbar_tick", volume, 1.0)
                        else
                            Audio:play("sfx_ui_xpbar_tick", volume, clamp(lerp(1 - (item.value / item.max_value), 0.75, 1.25), 0.01, 1))
                        end
                    end

                    -- Shows the text
                    local shown_xp = round(item.value)
                    item.text = concat(shown_xp, "/", shown_level_threshold)
                    if shown_level_threshold == math.huge then
                        item.text = concat(shown_xp)
                    end

                    -- Finish animation
                    if item.augment_xp_delay <= 0 and (
                        shown_level_threshold == math.huge or
                        (actual_level == item.shown_level and math.abs(item.value - Metaprogression:get_xp()) < 0.1)
                    ) then
                        if not game.has_finished_game_over_animation then
                            game.has_finished_game_over_animation = true
                        end 
                    end

                    if game.has_finished_game_over_animation and not game.menu_manager.sel_item then
                        game.menu_manager:set_selection(1, true)
                    end
                end,
                init_value = function(item)
                    local threshold = Metaprogression:get_xp_level_threshold(Metaprogression.old_xp_level)
                    item.value = Metaprogression.old_xp
                    item.overlay_value = item.value
                    item.max_value = threshold
                    item.shown_level = Metaprogression.old_xp_level

                    if threshold == math.huge then
                        item.overlay_value = nil
                        item.max_value = 1
                    end
                    if Metaprogression.old_xp == 0 then
                        item.overlay_value = nil
                    end

                    item.augment_xp_delay = 0.5

                    game.has_finished_game_over_animation = false
                end
            }
        },
        { "" },
    }

    for i, item in pairs(item_order) do
        if item == "quick_restart" then
            table.insert(items, { "🔄 {menu.game_over.quick_restart}",
                function(item)
                    if game.has_finished_game_over_animation then
                        game.has_seen_controller_warning = true
                        game:new_game({ quick_restart = true })
                    end
                end,
                function(item)
                    item.is_selectable = game.has_finished_game_over_animation
                    -- item.is_selectable = not Options:get("convention_mode")
                    item.is_visible = not Options:get("convention_mode")
                end
            })

        elseif item == "return" then
            table.insert(items, { "▶ {menu.pause.return_to_ground_floor}",
                function(item)
                    -- scotch
                    if game.has_finished_game_over_animation then
                        game.has_seen_controller_warning = true
                        game:new_game()
                    end
                end,
                function(item)
                    item.is_selectable = game.has_finished_game_over_animation
                end,
            })

        elseif item == "continue" then
            table.insert(items, { "▶ {menu.game_over.continue}",
            function(item)
                    -- scotch
                    if game.has_finished_game_over_animation then
                        game:new_game()
                    end
                end,
                function(item)
                    item.is_selectable = game.has_finished_game_over_animation
                end,
            })

        elseif item == "wishlist" and BUILD_TYPE == "demo" then
            table.insert(items,
                { "❤ {menu.win.wishlist} 🔗",
                    function(item)
                        if game.has_finished_game_over_animation then
                            game.has_seen_controller_warning = true
                            love.system.openURL("steam://advertise/2957130/")
                        end
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