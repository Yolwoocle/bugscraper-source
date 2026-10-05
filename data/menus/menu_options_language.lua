require "scripts.util"
local menu_util = require "scripts.ui.menu.menu_util"
local Menu = require "scripts.ui.menu.menu"
local func_set_menu         = menu_util.func_set_menu

local DEFAULT_MENU_BG_COLOR = menu_util.DEFAULT_MENU_BG_COLOR
local PROMPTS_NORMAL    = menu_util.PROMPTS_NORMAL

local function func_language_menu(lang)
    return function()
        game.buffered_language = lang
        game.menu_manager:set_menu("options_confirm_language")
    end
end

local options = {}
for _, lang in pairs(Text.supported_languages) do
    table.insert(options, {"{language."..lang.."}", func_language_menu(lang)})
end

return Menu:new(game, "{menu.options.language.title}", options, DEFAULT_MENU_BG_COLOR, PROMPTS_NORMAL)