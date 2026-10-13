require "errorhandler"
require "scripts.meta.constants"
require "bugscraper_config"

local function init()
    print("====================[ Launched Bugscraper".." (v"..tostring(BUGSCRAPER_VERSION)..") ]====================")
    print("LOVE version: "..string.format("%d.%d.%d - %s", love.getVersion()))
    print("Distribution platform: "..tostring(DISTRIBUTION_PLATFORM))
    print("Build type: "..tostring(BUILD_TYPE))
    print("")
    
    local ext = package.config:sub(1, 1) == '\\' and 'dll' or 'so'
    package.cpath = string.format("%s;%s/?.%s", package.cpath, love.filesystem.getSourceBaseDirectory(), ext)

    if PROFILER_INIT then
        love.profiler = require "lib.profiler.profile"
        love.profiler.start()
    end

    local FileManager = require "scripts.file.files"
    Files = FileManager:new()

    local OptionsManager = require "scripts.game.options"
    Options = OptionsManager:new()

    OPERATING_SYSTEM = love.system.getOS()
    USE_CANVAS_RESIZING = true
    SCREEN_WIDTH, SCREEN_HEIGHT = 0, 0

    if OPERATING_SYSTEM == "Web" then
        USE_CANVAS_RESIZING = false
        CANVAS_SCALE = 2
        love.window.setMode(CANVAS_WIDTH * CANVAS_SCALE, CANVAS_HEIGHT * CANVAS_SCALE, {
            fullscreen = false,
            resizable = true,
            vsync = Options:get("is_vsync"),
            minwidth = CANVAS_WIDTH,
            minheight = CANVAS_HEIGHT,
        })
    else
        love.window.setMode(Options:get("windowed_width"), Options:get("windowed_height"), {
            fullscreen = Options:get("is_fullscreen"),
            resizable = true,
            vsync = Options:get("is_vsync"),
            minwidth = CANVAS_WIDTH,
            minheight = CANVAS_HEIGHT,
        })
        if Options:get("is_window_maximized") then
            love.window.maximize()
        end
    end
    
    WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
	local screen_sx = WINDOW_WIDTH / CANVAS_WIDTH
	local screen_sy = WINDOW_HEIGHT / CANVAS_HEIGHT
	local scale = math.min(screen_sx, screen_sy)
	CANVAS_OX = math.floor(max(0, (WINDOW_WIDTH - CANVAS_WIDTH * scale) / 2))
	CANVAS_OY = math.floor(max(0, (WINDOW_HEIGHT - CANVAS_HEIGHT * scale) / 2))
    
    -- Splash screen
    love.graphics.clear()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setScissor(CANVAS_OX, CANVAS_OY, CANVAS_WIDTH*scale, CANVAS_HEIGHT*scale)
    love.graphics.draw(love.graphics.newImage('images/splash.png'), CANVAS_OX, CANVAS_OY, 0, scale)
    love.graphics.setScissor()
    love.graphics.present()
    love.graphics.origin()

    if PROFILER_INIT then
        print("")
        print("---[[ LOAD PROFILER REPORT ]]---")
        print(love.profiler.report(20))
        print("")
    
        love.profiler.stop()
    end

    love.keyboard.setKeyRepeat(true)
end

return init
