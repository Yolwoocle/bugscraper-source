require "scripts.util"
local Class          = require "scripts.meta.class"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images         = require "data.images"
local Timer          = require "scripts.timer"

local TvPresentation = Class:inherit()

function TvPresentation:init(x, y, params)
    params = params or {}
    self.x = x
    self.y = y
    
    self.canvas_w = TV_WIDTH
    self.canvas_h = TV_HEIGHT

    self.default_slide_duration = param(params.default_slide_duration, 5.0)

    self.slides_data = {
        ["slide_001"] = { images.tv_slideshow_001, 0 },      -- Powerpoint stats         by Sslime7 
        ["slide_002"] = { images.tv_slideshow_002, 0 },      -- Hot dogs                 by Alexis Belmonte
        ["slide_003"] = { images.tv_slideshow_003, 0.04 },   -- Mio rotate               by Corentin Vaillant 
        ["slide_004"] = { images.tv_slideshow_004, 0 },      -- Bug with Guns            by Yolwoocle
        ["slide_005"] = { images.tv_slideshow_005, 0 },      -- "Love, obey"             by ellraiser
        ["slide_006"] = { images.tv_slideshow_006, 0.07 },   -- "Need your duck taped?"  by Joseph
        ["slide_007"] = { images.tv_slideshow_007, 0.11 },   -- Starbugs green tea       by Goyome
        ["slide_008"] = { images.tv_slideshow_008, 0.1 },    -- Binarion                 by Hector SK (Nextop Games)
        ["slide_009"] = { images.tv_slideshow_009, 0.3 },    -- "No quuen?"              by behck
        ["slide_010"] = { images.tv_slideshow_010, 0 },      -- "injured? good"          by Hector SK (Nextop Games) 
        ["slide_011"] = { images.tv_slideshow_011, 0.035 },  -- Splat commercial         by Sarcose
        ["slide_012"] = { images.tv_slideshow_012, 0.03 },   -- End toastal abuse        by clem 
        ["slide_013"] = { images.tv_slideshow_013, 0.03 },   -- A salt rifle             by clem 
        ["slide_014"] = { images.tv_slideshow_014, 0.08 },   -- Beatleblock              by Daphne Sophinos (DPS2004)
        ["slide_015"] = { images.tv_slideshow_015, 0.3 },    -- bugscrapers arent enough by pkhead
        ["slide_016"] = { images.tv_slideshow_016, 0 },      -- optic studio             by pkhead
        ["slide_017"] = { images.tv_slideshow_017, 0.08 },   -- Soon(tm)                 by pixelbath
        ["slide_018"] = { images.tv_slideshow_018, 0.04 },   -- Mio explode              by Corentin Vaillant
        ["slide_019"] = { images.tv_slideshow_019, 0.04 },   -- Snail Ball Run           by Hector SK (Nextop Games)
        ["slide_020"] = { images.tv_slideshow_020, 0.5 },   -- You are a Bug             by kiwisky 
        ["slide_021"] = { images.tv_slideshow_021, 0.075, default_slide_duration = 0 },       -- Roaring Knight            by Linky 
        ["slide_021_b"] = { images.tv_slideshow_021, 0.075/2, default_slide_duration = 0 },   -- Roaring Knight            by Linky 
        ["slide_021_c"] = { images.tv_slideshow_021, 0.075/4, default_slide_duration = 0 },   -- Roaring Knight            by Linky 
        ["slide_022"] = { images.tv_slideshow_022, 0.1 },   -- Buglatro                  by 8lueskii 
        
        ["bluescreen"] = { random_sample {images.tv_bluescreen, images.tv_bluescreen_2}, math.huge } ,
        -- By Hector SK (Nextop Games) & 418cat

        ["bluescreen_1"] = {images.tv_bluescreen, 0.0},
        ["bluescreen_2"] = {images.tv_bluescreen_2, 0.0},
        ["empty"] = {images.empty, 1.0}
    }
    self.slide_names = {}
    for name, slide_info in pairs(self.slides_data) do
        if not is_in_table({"bluescreen", "bluescreen_1", "bluescreen_2", "empty", "slide_021", "slide_021_b", "slide_021_c"}, name) then
            table.insert(self.slide_names, name)
        end

        self.slides_data[name][3] = math.floor(self.slides_data[name][1]:getWidth() / self.canvas_w)
        self.slides_data[name][4] = math.floor(self.slides_data[name][1]:getHeight() / self.canvas_h)
    end
    if param(params.shuffle_table, true) then
        shuffle_table(self.slide_names)
    end

    -- Add RAARRR
    local pos = random_range(2, #self.slide_names)
    table.insert(self.slide_names, pos, "slide_021")
    table.insert(self.slide_names, pos+1, "slide_021_b")
    table.insert(self.slide_names, pos+2, "slide_021_c")

    self.do_slideshow = param(params.do_slideshow, true)
    
    self.bluescreen_probability = TV_BLUESCREEN_PROBABILITY
    self.is_bluescreened = (random_range(0, 1) < self.bluescreen_probability)
    if self.is_bluescreened then
        self.slide_names = {"bluescreen"}
    end

    self.transitions = {
        { -- fade
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0, { 1, 1, 1, 1 - alpha })
                self:draw_frame(new_image, new_frame, 0, 0, { 1, 1, 1, alpha })
            end,
        },
        { -- push vertical
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, self.canvas_h * alpha)
                self:draw_frame(new_image, new_frame, 0, self.canvas_h * (alpha - 1))
            end,
        },
        { -- push horizontal
            draw = function(trans, old_slide, old_frame, new_image, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, self.canvas_w * alpha, 0)
                self:draw_frame(new_image, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- cover
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                self:draw_frame(old_slide, old_frame, 0, 0)
                self:draw_frame(new_slide, new_frame, self.canvas_w * (alpha - 1), 0)
            end,
        },
        { -- growing circle
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                love.graphics.setStencilTest()
                self:draw_frame(old_slide, old_frame, 0, 0)

                love.graphics.stencil(function()
                    love.graphics.circle("fill", self.canvas_w / 2, self.canvas_h / 2, alpha * self.canvas_w * 1.2)
                end, "replace", 1, false)
                
                love.graphics.setStencilTest("greater", 0)
                self:draw_frame(new_slide, new_frame, 0, 0)
                
                love.graphics.setStencilTest()
            end,
        },
        { -- bunch of growing circles
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                love.graphics.setStencilTest()
                self:draw_frame(old_slide, old_frame, 0, 0)

                love.graphics.stencil(function()
                    for ix = 0, self.canvas_w, 10 do
                        for iy = 0, self.canvas_h, 10 do
                            love.graphics.circle("fill", ix, iy, alpha * 15)
                        end
                    end
                end, "replace", 1, false)
                
                love.graphics.setStencilTest("greater", 0)
                self:draw_frame(new_slide, new_frame, 0, 0)

                love.graphics.setStencilTest()
            end,
        },
        { -- "curtains" (idk how to call it)
            draw = function(trans, old_slide, old_frame, new_slide, new_frame, alpha)
                love.graphics.setStencilTest()
                self:draw_frame(old_slide, old_frame, 0, 0)
                
                love.graphics.stencil(function()
                    love.graphics.rectangle("fill", 0, 0, self.canvas_w / 2 * alpha, self.canvas_h)
                    love.graphics.rectangle("fill", self.canvas_w - self.canvas_w / 2 * alpha, 0, self.canvas_w, self.canvas_h)
                end, "replace", 1, false)
                
                love.graphics.setStencilTest("greater", 0)
                self:draw_frame(new_slide, new_frame, 0, 0)

                love.graphics.setStencilTest()
            end,
        },
    }
    self.current_transition = nil
    self.transition_t = 0.0
    self.transition_timer = Timer:new(0.5)
    
    self.slideshow_timer = Timer:new(self.default_slide_duration):start()
    
    self.canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    self.buffer_canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    
    self.current_slide_number = 1
    self.old_slide_frame_i = 1
    self.old_slide = self.slide_names[self.current_slide_number]
    self.current_slide = self.slide_names[self.current_slide_number]

    self.spr = AnimatedSprite:new(copy_table_shallow(self.slides_data), self.current_slide, SPRITE_ANCHOR_LEFT_TOP)
end

function TvPresentation:update(dt)
    if self.is_bluescreened then
        self.spr:update(dt)
        return
    end

    -- Slide end
    if self.do_slideshow and self.slideshow_timer:update(dt) then
        self.transition_timer:start()
        self.current_transition = random_sample(self.transitions)

        self.old_slide = self.current_slide
        self.old_slide_frame_i = self.spr.frame_i
        self:set_current_slide(mod_plus_1(self.current_slide_number + 1, #self.slide_names))
    end

    -- Transition end
    if self.do_slideshow and self.transition_timer:update(dt) then
        local default_slide_duration = self.slides_data[self.current_slide].default_slide_duration
        self.slideshow_timer:start(
            math.max(
                default_slide_duration or self.default_slide_duration, 
                self.spr.animations[self.current_slide].duration - 1/60
            )
        )
        self.current_transition = nil
    end
    
    self.spr:update(dt)
end

function TvPresentation:set_current_slide_from_name(slide_name)
    -- this will NOT update the slide index number
    -- self.current_slide_number = slide_index
    self.current_slide = slide_name 
    if self.current_slide then
        self.spr:set_animation(self.current_slide)
    end
end

function TvPresentation:set_current_slide(slide_index)
    self.current_slide_number = slide_index
    self.current_slide = self.slide_names[self.current_slide_number]
    if self.current_slide then
        self.spr:set_animation(self.current_slide)
    end
end


function TvPresentation:draw_frame(slide, frame, x, y, color)
    color = color or COL_WHITE
    self.spr:set_color(color)
    self.spr:set_animation(slide)
    self.spr:set_frame_index(frame)
    self.spr:draw(x, y)
    self.spr:set_color(COL_WHITE)
end

function TvPresentation:draw()
    exec_on_canvas({ self.canvas, stencil = true }, function()
        game.camera:push_origin()
        
        love.graphics.clear()
        if self.current_transition then
            self.current_transition:draw(self.old_slide, self.old_slide_frame_i, self.current_slide, 1,
            1 - (self.transition_timer.time / self.transition_timer.duration))
        else
            self.spr:draw(0, 0)
        end

        game.camera:pop()
    end)

    love.graphics.draw(self.canvas, self.x, self.y)
end

return TvPresentation
