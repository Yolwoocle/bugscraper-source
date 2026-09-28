require "scripts.util"
local menu_util             = require "scripts.ui.menu.menu_util"
local Menu                  = require "scripts.ui.menu.menu"
local backgrounds           = require "data.backgrounds"

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local func_set_menu         = menu_util.func_set_menu
local func_url              = menu_util.func_url
local PROMPTS_NORMAL        = menu_util.PROMPTS_NORMAL

local pause_items           = {
    { "" },
    { "▶ {menu.pause.resume}", function() game.menu_manager:unpause() end },
    { "🔄 {menu.pause.return_to_ground_floor}", func_set_menu('confirm_retry') },
    -- { "🔄 {menu.game_over.quick_restart}", function()
    --     game:new_game({ quick_restart = true })
    -- end },
    { "🎚 {menu.pause.options}", func_set_menu('options') },
    { "🏆 {menu.achievements.title}", func_set_menu('achievements') },
    { "⎘ {menu.stats.title}", func_set_menu('stats') },
    -- { "💡 {menu.pause.feedback}", func_set_menu("feedback") },
    { "❤ {menu.pause.credits}", func_set_menu('credits') },
}
if OPERATING_SYSTEM ~= "Web" then
    -- Disable quitting on web
    table.insert(pause_items, { "🔚 {menu.pause.quit}", func_set_menu('quit') })
end

table.insert(pause_items, { "" })

if BUILD_TYPE == "demo" then
    -- Disable wishlist if not demo
    table.insert(pause_items, { "❤ {menu.win.wishlist} 🔗", func_url("steam://advertise/2957130/") })
    -- table.insert(pause_items, { "🌐 {menu.pause.website} 🔗", func_url("https://bugscraper.net/") })
end
-- table.insert(pause_items, { "😈 {menu.pause.discord} 🔗", func_url("https://bugscraper.net/discord") })

local function debug_skipto(wave, background)
    for k, e in pairs(game.actors) do
        if e.is_enemy then
            e:remove()
        end
    end
    game:set_floor(wave)
    for _, p in pairs(game.players) do
        p:set_position(CANVAS_CENTER[1], CANVAS_CENTER[2])
    end
    game.can_start_game = true
    game.camera:reset()
    game:start_game()
    game.menu_manager:unpause()
    if background then
        game.level:set_background(background)
    end
    for k, e in pairs(game.actors) do
        if e.is_enemy then
            e:remove()
        end
    end
end
if DEBUG_MODE and false then
    table.insert(pause_items, { " " })
    table.insert(pause_items, { "[CHEAT] Skip to world 1 boss", function()
        debug_skipto(18)
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 2", function()
        debug_skipto(20)
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 2 boss", function()
        debug_skipto(38, backgrounds.BackgroundBeehive:new())
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 3", function()
        debug_skipto(40)
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 3 boss", function()
        debug_skipto(58, backgrounds.BackgroundBeehive:new())
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 4", function()
        debug_skipto(60)
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 4 wave 70", function()
        debug_skipto(70, backgrounds.BackgroundFinal:new())
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 4 boss", function()
        debug_skipto(78, backgrounds.BackgroundFinal:new())
    end })
    table.insert(pause_items, { "[CHEAT] Skip to world 5", function()
        debug_skipto(80, backgrounds.BackgroundFinal:new())
    end })
end

return Menu:new(game, "{menu.pause.title}", pause_items, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)
