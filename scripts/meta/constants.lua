local function rgb(r,g,b)
	return {r/255, g/255, b/255, 1}
end

local function color(hex)
    -- thanks to chatgpt
	if not hex then  return {1, 1, 1}  end
	assert(type(hex) == "number", "incorrect type for 'hex' ("..type(hex).."), argument given should be number")

	local r = math.floor(hex / 65536) % 256
	local g = math.floor(hex / 256) % 256
	local b = hex % 256
	return {r/255, g/255, b/255, 1.0}
end

---------------------------------------------

-- Saves
STATS_AUTOSAVE_INTERVAL = 15

---------------------------------------------

-- Graphics
CANVAS_WIDTH = 480
CANVAS_HEIGHT = 270
CANVAS_CENTER = {CANVAS_WIDTH/2, CANVAS_HEIGHT/2}
SCREENSHOT_SCALE = 4

LAYER_COUNT = 9

LAYER_BACKGROUND = 1
LAYER_SHADOW = 2
LAYER_OBJECTS = 3
LAYER_OBJECT_SHADOWLESS = 4
LAYER_FRONT = 5
LAYER_LIGHT = 6
LAYER_HUD = 7
LAYER_UI = 8
LAYER_MENUS = 9

LAYER_NAMES = {
	[1] = "LAYER_BACKGROUND",
	[2] = "LAYER_SHADOW",
	[3] = "LAYER_OBJECTS",
	[4] = "LAYER_OBJECT_SHADOWLESS",
	[5] = "LAYER_FRONT",
    [6] = "LAYER_LIGHT",
	[7] = "LAYER_HUD",
	[8] = "LAYER_UI",
	[9] = "LAYER_MENUS",
}

SPRITE_ANCHOR_AXIS_START = "s"
SPRITE_ANCHOR_AXIS_CENTER = "c"
SPRITE_ANCHOR_AXIS_END = "e"

SPRITE_ANCHOR_LEFT_TOP = "ss"
SPRITE_ANCHOR_LEFT_CENTER = "sc"
SPRITE_ANCHOR_LEFT_BOTTOM = "se"
SPRITE_ANCHOR_CENTER_TOP = "cs"
SPRITE_ANCHOR_CENTER_CENTER = "cc"
SPRITE_ANCHOR_CENTER_BOTTOM = "ce"
SPRITE_ANCHOR_RIGHT_TOP = "es"
SPRITE_ANCHOR_RIGHT_CENTER = "ec"
SPRITE_ANCHOR_RIGHT_BOTTOM = "ee"

PARTICLE_LAYER_CAFETERIA_BACKGROUND = 1
PARTICLE_LAYER_BACKGROUND = 2
PARTICLE_LAYER_BACK = 3
PARTICLE_LAYER_BACK_SHADOWLESS = 4
PARTICLE_LAYER_NORMAL = 5
PARTICLE_LAYER_SHADOWLESS = 6
PARTICLE_LAYER_HUD = 7
PARTICLE_LAYER_FRONT = 8

PARTICLE_LAYER_COUNT = 8 -- CHANGE THIS AFTER ADDING A PARTICLE LAYER

-- Enemy flipping mode
ENEMY_FLIP_MODE_MANUAL = "manual" -- only manual flipping
ENEMY_FLIP_MODE_XVELOCITY = "xvelocity" -- flipping based on x velocity
ENEMY_FLIP_MODE_TARGET = "target" -- flipping based on location of the target

---------------------------------------------

-- Physics & map
BLOCK_WIDTH = 16
BW = BLOCK_WIDTH

COLLISION_TYPE_SOLID = "solid"
COLLISION_TYPE_SEMISOLID = "semisolid"
COLLISION_TYPE_NONSOLID = "nonsolid"
COLLISION_TYPE_PLAYER_NONSOLID = "player_nonsolid" -- not slid to players only

TILE_AIR = 0
TILE_METAL = 1
TILE_METAL_SEMISOLID = 2
TILE_RUBBLE = 3
TILE_CHAIN = 4
TILE_BORDER = 5
TILE_FLIP_ON = 6
TILE_FLIP_OFF = 7
TILE_CARPET = 8
TILE_SAND = 9
TILE_STONE = 10
TILE_WOOD = 11
TILE_WOOD_SEMISOLID = 12
TILE_GLASS = 13

BULLET_BOUNCE_MODE_RADIAL = "radial"
BULLET_BOUNCE_MODE_NORMAL = "normal"

RECT_ELEVATOR_PARAMS = {2, 2, 28, 16}
RECT_CAFETERIA_PARAMS = {2, 2, 59, 16}
RECT_CEO_OFFICE_PARAMS = {2, 2, 104, 24}
RECT_BASEMENT = {2, -4, 104, 16}
-- RECT_GROUND_FLOOR_PARAMS = {2, 2, 58, 16}
-- RECT_GROUND_FLOOR_PARAMS = {2, 2, 100, 16}
RECT_GROUND_FLOOR_PARAMS = {2, 3, 111, 16}
RECT_TUTORIAL_PARAMS = {2, 0, 96, 16}
RECT_CREDITS_PARAMS = {-1, 0, 31, 16}

---------------------------------------------

-- Enemies
TIMED_SPIKES_TIMING_MODE_TEMPORAL = "temporal" -- Spikes timing depend on time
TIMED_SPIKES_TIMING_MODE_MANUAL = "manual" -- Spikes timing are manual

---------------------------------------------

-- Font
FONT_CHARACTERS =
    " !\"#$%&'()*+,-·./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz"..
    "{|}~ ¡¢£©®°¿ÀÁÂÃÄÅĄÆÇĆÈÉÊËĘÌÍÎÏŁÐÑŃÒÓÔÕÖØÙÚÛÜŚÝŹŻŒÞßàáâãäåąæçćèéêëęìíîïłðñńòóôõöøùúûüśýźżœþÿŸЁАБВГДЕЖЗИЙКЛМНО"..
    "ПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяё€"
FONT_SYMBOLS_CHARACTERS =
    "🔊🔉🔈🎵🎼🔳🔲📺🕐↖🛜▶⏸✓❌🔄🔘⬅➡⬆⬇⏏🔫🔚📥👆🔙🗄⌨🎮🎚❤"..
    "✅❎🔗💡⚠🕹🫨💧🐜🐛🐝🪲🈶🌄🛅😎😈🐦𝕏🦋🐰🐞🌐⏭🥚🥦🐧🎓🔺🦂💀⏰🔥⭐🍊🏆⎘⚔️"
FONT_7SEG_CHARACTERS = " 0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
FONT_MINI_CHARACTERS = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~ÀÁÂÃÄÅĄÆÇĆÈÉÊËĘÌÍÎÏŁÐÑŃÒÓÔÕÖØÙÚÛÜŚÝŹŻÞßàáâãäåąæçćèéêëęìíîïłðñńòóôõöøùúûüśýþÿźżŒœ⁍🦋𝕏❤"
FONT_FAT_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!,.:;'\"@#$%^&*()[]{}_-=+<>/\\|~"
FONT_ZH_CHARACTERS = require "fonts.font_zh_characters"
FONT_JA_CHARACTERS = require "fonts.font_ja_characters"

---------------------------------------------

-- Colors
COL_WHITE = {1, 1, 1, 1}
COL_BLACK = {0, 0, 0, 1}
COL_RED = {1, 0, 0, 1}
COL_YELLOW = {1, 1, 0, 1}
COL_GREEN = {0, 1, 0, 1}
COL_CYAN = {0, 1, 1, 1}
COL_BLUE = {0, 0, 1, 1}
COL_MAGENTA = {1, 0, 1, 1}
COL_TRANSPARENT = {1, 1, 1, 0}

-- Reference is EDG32 palette
COL_DARKEST_GRAY = color(0x202035) -- This is not in the palette but is used in the basement
COL_VERY_DARK_GRAY = color(0x262b44)
COL_DARK_GRAY = color(0x3a4466)
COL_MID_GRAY = color(0x5a6988)
COL_LIGHT_GRAY = color(0x8b9bb4)
COL_LIGHTEST_GRAY = color(0xc0cbdc)

COL_DARK_RED = color(0x9e2835)
COL_LIGHT_RED = color(0xe43b44)
COL_PINK = color(0xf6757a)

COL_YELLOW_ORANGE = color(0xfeae34)
COL_ORANGE = color(0xf77622)

COL_DARK_BRICK = color(0xbe4a2f)
COL_LIGHT_BRICK = color(0xd87644)

COL_LIGHT_BEIGE = color(0xead4aa)
COL_MID_BEIGE = color(0xe4a672)
COL_LIGHT_BROWN = color(0xb86f50)
COL_MID_BROWN = color(0x743f39)
COL_DARK_BROWN = color(0x3f2832)

COL_LIGHT_YELLOW = color(0xfee761)

COL_LIGHT_GREEN = color(0x63c74d)
COL_MID_GREEN = color(0x3e8948)
COL_MID_DARK_GREEN = color(0x265c42)
COL_DARK_GREEN = color(0x193c3e)

COL_BLACK_BLUE = color(0x181425)
COL_DARK_BLUE = color(0x124e89)
COL_MID_BLUE = color(0x0095e9)
COL_LIGHT_BLUE = color(0x2ce8f5)

COL_PURPLE = color(0xb55088)
COL_DARK_PURPLE = color(0x68386c)

SELECTED_HIGHLIGHT_COLOR = COL_LIGHT_RED
LOGO_COLS = {COL_LIGHT_YELLOW, COL_LIGHT_BLUE, COL_LIGHT_RED}

---------------------------------------------

-- Ui
DEFAULT_MENU_PADDING = 0.17

---------------------------------------------

-- Game
MAX_NUMBER_OF_PLAYERS = 4

GAME_STATE_WAITING = "waiting"
GAME_STATE_PLAYING = "playing"
GAME_STATE_DYING = "dying"
GAME_STATE_ELEVATOR_BURNING = "elevator_burning"
GAME_STATE_WIN = "win"
GAME_STATE_LANGUAGE_SETUP = "language_setup"

-- Ajusts probability of dropping loot:
-- For non-empty fields in enemies' loot tables, new_probablity = probablity * (1 + this_value * (number_of_players - 1))
MULTIPLAYER_LOOT_PROBABILITY_MULTIPLIER = 1.0

LIGHTNING_STYLE_NORMAL = "normal"
LIGHTNING_STYLE_BITS = "bits"
LIGHTNING_STYLE_THORNS = "thorns"

LIGHTNING_ANIMATION_JITTER = "jitter"

DEFAULT_CAMERA_X = 0
DEFAULT_CAMERA_Y = 8

DEFAULT_CAMERA_FOLLOW_SPEED = 5
DEFAULT_CAMERA_MAX_SPEED = 300

MAX_DISPLAY_FLOOR = 80 -- Maximum floor of the bugscraper (and not the maximum number of waves)

---------------------------------------------

-- Input
MAX_ASSIGNABLE_BUTTONS = 8

PLAYER_INPUT_MODE_USER = "user" -- The player is controlled by the user (with a keyboard, controller, etc)
PLAYER_INPUT_MODE_CODE = "code" -- The player is controlled via code (for example, for cutscenes)

INPUT_TYPE_KEYBOARD = "k"
INPUT_TYPE_CONTROLLER = "c"

BUTTON_STYLE_SWITCH = "switch"
BUTTON_STYLE_PLAYSTATION4 = "playstation4"
BUTTON_STYLE_PLAYSTATION5 = "playstation5"
BUTTON_STYLE_XBOX = "xbox"
BUTTON_STYLE_DETECT = "detect"
BUTTON_STYLES = {
	BUTTON_STYLE_SWITCH,
	BUTTON_STYLE_PLAYSTATION4,
	BUTTON_STYLE_PLAYSTATION5,
	BUTTON_STYLE_XBOX,
	BUTTON_STYLE_DETECT,
}
CONTROLLER_BRANDS = {
    BUTTON_STYLE_SWITCH,
    BUTTON_STYLE_PLAYSTATION4,
    BUTTON_STYLE_PLAYSTATION5,
    BUTTON_STYLE_XBOX,
}

BUTTON_HOLD_REPEAT_TIME = 0.35
BUTTON_HOLD_REPEAT_INTERVAL = 0.07

RAW_INPUT_MAP_DEFAULT_EMPTY = {
    left =      {},
    right =     {},
    up =        {},
    down =      {},
    jump =      {},
    shoot =     {},
    interact =  {},

    pause =     {},
    ui_select = {},
    ui_back =   {},
    ui_left =   {},
    ui_right =  {},
    ui_up =     {},
    ui_down =   {},
    split_keyboard = {},
    join_game = {},

    debug = {}
}

RAW_INPUT_MAP_DEFAULT_GLOBAL = {
    left =      {},
    right =     {},
    up =        {},
    down =      {},
    jump =      {},
    shoot =     {},
    interact =  {},

    pause =     {"k_escape", "k_p"},
    ui_select = {"k_c", "k_z", "k_j", "k_l", "k_return"},
    ui_back =   {"k_x", "k_k", "k_escape", "k_backspace"},
    ui_left =   {"k_left",  "k_a"},
    ui_right =  {"k_right", "k_d"},
    ui_up =     {"k_up",    "k_w"},
    ui_down =   {"k_down",  "k_s"},
    split_keyboard = {"k_y"},
    join_game = {"k_c", "k_z", "k_j", "k_l", "k_return", "c_a", "c_b"},

    debug = {"k_f1", "c_back"},
}

RAW_INPUT_MAP_DEFAULT_CONTROLLER = {
    left =      {"c_leftxneg", "c_dpleft"},
    right =     {"c_leftxpos", "c_dpright"},
    up =        {"c_leftyneg", "c_dpup"},
    down =      {"c_leftypos", "c_dpdown"},
    jump =      {"c_a", "c_triggerleft", "c_leftshoulder"},
    shoot =     {"c_x", "c_triggerright", "c_rightshoulder"},
    interact =  {"c_y"},

    pause =     {"c_start"},
    ui_select = {"c_a", "c_y"},
    ui_back =   {"c_b"},
    ui_left =   {"c_leftxneg", "c_dpleft"},
    ui_right =  {"c_leftxpos", "c_dpright"},
    ui_up =     {"c_leftyneg", "c_dpup"},
    ui_down =   {"c_leftypos", "c_dpdown"},
    split_keyboard = {},
    join_game = {},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_KEYBOARD_SOLO = {
    left =      {"k_left",  "k_a"},
    right =     {"k_right", "k_d"},
    up =        {"k_up",    "k_w"},
    down =      {"k_down",  "k_s"},
    jump =      {"k_c", "k_j"},
    shoot =     {"k_x", "k_k"},
    interact =  {"k_z", "k_l"},

    pause =     {"k_escape", "k_p"},
    ui_select = {"k_c", "k_z", "k_j", "k_l", "k_return"},
    ui_back =   {"k_x", "k_k", "k_escape", "k_backspace"},
    ui_left =   {"k_left",  "k_a"},
    ui_right =  {"k_right", "k_d"},
    ui_up =     {"k_up",    "k_w"},
    ui_down =   {"k_down",  "k_s"},
    split_keyboard = {},
    join_game = {},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_SPLIT_KEYBOARD_P1 = {
    left =      {"k_a"},
    right =     {"k_d"},
    up =        {"k_w"},
    down =      {"k_s"},
    jump =      {"k_f"},
    shoot =     {"k_g"},
    interact =  {"k_h"},

    pause =     {"k_escape", "k_p"},
    ui_select = {"k_f", "k_h"},
    ui_back =   {"k_g", "k_escape"},
    ui_left =   {"k_a"},
    ui_right =  {"k_d"},
    ui_up =     {"k_w"},
    ui_down =   {"k_s"},
    split_keyboard = {},
    join_game = {},

    debug = {},
}

RAW_INPUT_MAP_DEFAULT_SPLIT_KEYBOARD_P2 = {
    left =      {"k_left"},
    right =     {"k_right"},
    up =        {"k_up"},
    down =      {"k_down"},
    jump =      {"k_l"},
    shoot =     {"k_k"},
    interact =  {"k_j"},

    pause =     {"k_escape", "k_p"},
    ui_select = {"k_l", "k_j", "k_return"},
    ui_back =   {"k_k", "k_backspace"},
    ui_left =   {"k_left"},
    ui_right =  {"k_right"},
    ui_up =     {"k_up"},
    ui_down =   {"k_down"},
    split_keyboard = {},
    join_game = {},

    debug = {},
}

UI_ACTIONS = {"ui_up", "ui_down", "ui_left", "ui_right", "ui_select", "ui_back", "pause", "join_game"}

AXIS_TABLE = {
    leftxpos =  true,
    leftxneg =  true,
    leftypos =  true,
    leftyneg =  true,

    rightxpos = true,
    rightxneg = true,
    rightypos = true,
    rightyneg = true,

    triggerleft =    true,
    triggerright =   true,
}

AXIS_DEADZONE = 0.4
TRIGGER_DEADZONE = 0.15
AXIS_ANGLE_MARGIN = 3 * math.pi/8
UI_AXIS_ANGLE_MARGIN = 2 * math.pi/8

GLOBAL_INPUT_USER_PLAYER_N = -1

KEY_CONSTANT_TO_IMAGE_NAME = {
	["unknown"] = "btn_k_unknown",

	["a"] = "btn_k_a",
	["b"] = "btn_k_b",
	["c"] = "btn_k_c",
	["d"] = "btn_k_d",
	["e"] = "btn_k_e",
	["f"] = "btn_k_f",
	["g"] = "btn_k_g",
	["h"] = "btn_k_h",
	["i"] = "btn_k_i",
	["j"] = "btn_k_j",
	["k"] = "btn_k_k",
	["l"] = "btn_k_l",
	["m"] = "btn_k_m",
	["n"] = "btn_k_n",
	["o"] = "btn_k_o",
	["p"] = "btn_k_p",
	["q"] = "btn_k_q",
	["r"] = "btn_k_r",
	["s"] = "btn_k_s",
	["t"] = "btn_k_t",
	["u"] = "btn_k_u",
	["v"] = "btn_k_v",
	["w"] = "btn_k_w",
	["x"] = "btn_k_x",
	["y"] = "btn_k_y",
	["z"] = "btn_k_z",
	["0"] = "btn_k_0",
	["1"] = "btn_k_1",
	["2"] = "btn_k_2",
	["3"] = "btn_k_3",
	["4"] = "btn_k_4",
	["5"] = "btn_k_5",
	["6"] = "btn_k_6",
	["7"] = "btn_k_7",
	["8"] = "btn_k_8",
	["9"] = "btn_k_9",
	["space"] = "btn_k_space",
	["!"] = "btn_k_exclamationmark",
	["\""] = "btn_k_doublequote",
	["#"] = "btn_k_hash",
	["$"] = "btn_k_dollar",
	["&"] = "btn_k_ampersand",
	["'"] = "btn_k_singlequote",
	["("] = "btn_k_leftparenthesis",
	[")"] = "btn_k_rightparenthesis",
	["*"] = "btn_k_asterisk",
	["+"] = "btn_k_plus",
	[","] = "btn_k_comma",
	["-"] = "btn_k_minus",
	["."] = "btn_k_period",
	["/"] = "btn_k_slash",
	[":"] = "btn_k_colon",
	[";"] = "btn_k_semicolon",
	["<"] = "btn_k_lessthan",
	[">"] = "btn_k_greaterthan",
	["="] = "btn_k_equal",
	["?"] = "btn_k_questionmark",
	["@"] = "btn_k_at",
	["["] = "btn_k_leftsquarebracket",
	["]"] = "btn_k_rightsquarebracket",
	["\\"] = "btn_k_backslash",
	["^"] = "btn_k_caret",
	["_"] = "btn_k_underscore",
	["`"] = "btn_k_backtick",
	["right"] = "btn_k_right",
	["left"] = "btn_k_left",
	["down"] = "btn_k_down",
	["up"] = "btn_k_up",
	["insert"] = "btn_k_insert",
	["backspace"] = "btn_k_backspace",
	["tab"] = "btn_k_tab",
	["return"] = "btn_k_enter",
	["delete"] = "btn_k_delete",
	["f1"] = "btn_k_f1",
	["f2"] = "btn_k_f2",
	["f3"] = "btn_k_f3",
	["f4"] = "btn_k_f4",
	["f5"] = "btn_k_f5",
	["f6"] = "btn_k_f6",
	["f7"] = "btn_k_f7",
	["f8"] = "btn_k_f8",
	["f9"] = "btn_k_f9",
	["f10"] = "btn_k_f10",
	["f11"] = "btn_k_f11",
	["f12"] = "btn_k_f12",
	["capslock"] = "btn_k_capslock",
	["rshift"] = "btn_k_rshift",
	["lshift"] = "btn_k_lshift",
	["lctrl"] = "btn_k_lctrl",
	["rctrl"] = "btn_k_rctrl",
	["lalt"] = "btn_k_lalt",
	["ralt"] = "btn_k_ralt",
	["kp0"] = "btn_k_kp0",
	["kp1"] = "btn_k_kp1",
	["kp2"] = "btn_k_kp2",
	["kp3"] = "btn_k_kp3",
	["kp4"] = "btn_k_kp4",
	["kp5"] = "btn_k_kp5",
	["kp6"] = "btn_k_kp6",
	["kp7"] = "btn_k_kp7",
	["kp8"] = "btn_k_kp8",
	["kp9"] = "btn_k_kp9",
	["kp."] = "btn_k_kpdot",
	["kp,"] = "btn_k_kpcomma",
	["kp/"] = "btn_k_kpslash",
	["kp*"] = "btn_k_kpasterisk",
	["kp-"] = "btn_k_kpminus",
	["kp+"] = "btn_k_kpplus",
	["kpenter"] = "btn_k_kpenter",
	["kp="] = "btn_k_kpequals",
	["escape"] = "btn_k_escape",

	["mouse1"] = "btn_k_mouse1",
	["mouse2"] = "btn_k_mouse2",
	["mouse3"] = "btn_k_mouse3",
	["mouse4"] = "btn_k_mouse4",
	["mouse5"] = "btn_k_mouse5",
	["mouse6"] = "btn_k_mouse6",
	["mouse7"] = "btn_k_mouse7",
	["mouse8"] = "btn_k_mouse8",
	["mouse9"] = "btn_k_mouse9",
	["mouse10"] = "btn_k_mouse10",
	["mouse11"] = "btn_k_mouse11",
	["mouse12"] = "btn_k_mouse12",
}

CONTROLLER_BUTTONS = {
    ["a"] = true,
    ["b"] = true,
    ["x"] = true,
    ["y"] = true,
    ["back"] = true,
    ["start"] = true,
    ["leftstick"] = true,
    ["rightstick"] = true,
    ["leftshoulder"] = true,
    ["rightshoulder"] = true,
    ["dpup"] = true,
    ["dpdown"] = true,
    ["dpleft"] = true,
    ["dpright"] = true,
    -- Only for love 12.0
    -- ["misc1"] = true,
    -- ["paddle1"] = true,
    -- ["paddle2"] = true,
    -- ["paddle3"] = true,
    -- ["paddle4"] = true,
    -- ["touchpad"] = true,
    ["leftxpos"] = true,
    ["leftxneg"] = true,
    ["leftypos"] = true,
    ["leftyneg"] = true,
    ["rightxpos"] = true,
    ["rightxneg"] = true,
    ["rightypos"] = true,
    ["rightyneg"] = true,
    ["triggerleft"] = true,
    ["triggerright"] = true,
}

---------------------------------------------

-- Music
MUSIC_MODE_OFF = "off"
MUSIC_MODE_INGAME = "ingame"
MUSIC_MODE_PAUSE = "pause"

---------------------------------------------

-- Audio
AUDIO_3D_RANGE = 0.2

---------------------------------------------

-- Upgrade
UPGRADE_TYPE_TEMPORARY = "temporary"
UPGRADE_TYPE_INSTANT = "instant"
UPGRADE_TYPE_PERMANENT = "permanent"

UPGRADE_TARGET_SINGLE = "single"
UPGRADE_TARGET_ALL = "all"

---------------------------------------------

-- Wave
FLOOR_TYPE_NORMAL = "normal"
FLOOR_TYPE_CAFETERIA = "cafeteria"

WAVE_ROLL_TYPE_RANDOM = "random"
WAVE_ROLL_TYPE_FIXED = "fixed"

---------------------------------------------

-- Misc
LIGHNING_COORDINATE_MODE_CARTESIAN = "cartesian" -- x, y
LIGHNING_COORDINATE_MODE_POLAR = "polar" -- radius, angle

TV_WIDTH = 55
TV_HEIGHT = 31

TV_CREDITS = {
    ["slide_001"] = "Sslime7",
    ["slide_002"] = "Alexis Belmonte",
    ["slide_003"] = "Corentin Vaillant",
    ["slide_004"] = "Yolwoocle",
    ["slide_005"] = "ellraiser",
    ["slide_006"] = "Joseph",
    ["slide_007"] = "Guillaume Tran",
    ["slide_008"] = "Hector SK (Nextop Games)",
    ["slide_009"] = "behck",
    ["slide_010"] = "Hector SK (Nextop Games)",
    ["slide_011"] = "Sarcose",
    ["slide_012"] = "clem",
    ["slide_013"] = "clem",
    ["slide_014"] = "Daphne Sophinos (DPS2004)",
    ["slide_015"] = "pkhead",
    ["slide_016"] = "pkhead",
    ["slide_017"] = "pixelbath",
    ["slide_018"] = "Corentin Vaillant",
    ["slide_019"] = "Hector SK (Nextop Games)",
    ["slide_020"] = "kiwisky",
    ["slide_021"] = "LinkyLorelei",
    ["slide_022"] = "8lueskii",

    ["bluescreen_1"] = "Hector SK (Nextop Games)",
    ["bluescreen_2"] = "418cat",
}

---------------------------------------------

-- Super secret easter egg stuff :)
SMASH_EASTER_EGG_PROBABILITY = 0.05
TV_BLUESCREEN_PROBABILITY = 0.05
HORNET_EASTER_EGG_PROBABILITY = 0.05
