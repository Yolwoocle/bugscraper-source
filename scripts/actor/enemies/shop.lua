require "scripts.util"
local StaticProp = require "scripts.actor.enemies.static_prop"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local images = require "data.images"

local UpgradeEspresso = require "scripts.upgrade.upgrade_espresso"
local UpgradeMoreLife = require "scripts.upgrade.upgrade_milk"
local UpgradeTea = require "scripts.upgrade.upgrade_tea"

local utf8 = require "utf8"

local Shop = StaticProp:inherit()

function Shop:init(x, y, w, h, params)
    params = params or {}
    Shop.super.init(self, x, y, params.spr or images.empty, w or 1, h or 1)
    self.name = "shop"
    self.is_shop = true

    self.ui_oy = 85

    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false

    self.is_interactible = true
    self.show_interaction_prompt = true
	self.interact_label = "{input.prompts.open}"
    self.interaction_margin = 32
    self.interaction_delay = 1.0
    self.interact_prompt_oy = -64

    self.selected_player = nil

    self.products = {
        UpgradeEspresso:new(),
        UpgradeMoreLife:new(),
        UpgradeTea:new(),
    }
    self.selected_product_index = 1
    self.selected_product = self.products[1]

    self.star_pattern_ox = 0.0
    self.left_prompt_ox = 0.0
    self.right_prompt_ox = 0.0

    self.animation_t = 0.0

    if param(params.assign_random_upgrades, false) then
        self:assign_random_upgrades()
    end

    self.state_machine = StateMachine:new({
        normal = {
            enter = function (state)
                self.show_interaction_prompt = true
            end
        },
        opening = {
            enter = function(state)
                state.timer = Timer:new(0.2):start()
                self.show_interaction_prompt = false
            end,
            update = function(state, dt)
                self.animation_t = state.timer:get_ratio()
                if state.timer:update(dt) then
                    return "selected" 
                end
            end,
            draw = function(state)
                self:draw_products()
            end,
            exit = function(state, dt)
                self.animation_t = 1.0
            end
        },
        selected = {
            enter = function(state)
                self.show_interaction_prompt = false
            end,
            update = function(state, dt)
                if not self.selected_player then
                    return
                end

                if self.selected_player:action_pressed("ui_left", true) then
                    self:increment_selection(-1)
                    self.left_prompt_ox = -5
                end
                if self.selected_player:action_pressed("ui_right", true) then
                    self:increment_selection(1)
                    self.right_prompt_ox = 5
                end

                if self.selected_player:action_pressed("ui_select", true) then
                    self:apply_current_product()
                    return "deopening"
                end
                
                if self.selected_player:action_pressed("ui_back", true) then
                    return "deopening"
                end

                self.star_pattern_ox = lerp(self.star_pattern_ox, 0, 0.5)
                self.left_prompt_ox = lerp(self.left_prompt_ox, 0, 0.3)
                self.right_prompt_ox = lerp(self.right_prompt_ox, 0, 0.3)
            end,
            draw = function(state)
                self:draw_products()
            end,
        },
        
        deopening = {
            enter = function(state)
                state.timer = Timer:new(0.2):start()
                
                if self.selected_player then
                    self.selected_player:set_input_mode(PLAYER_INPUT_MODE_USER)
                end
                self.show_interaction_prompt = false
            end,
            update = function(state, dt)
                self.animation_t = state.timer:get_inverse_ratio()
                if state.timer:update(dt) then
                    return "normal" 
                end
            end,
            draw = function(state)
                self:draw_products()
            end,
            exit = function(state, dt)
                self.animation_t = 0.0
                if not self.selected_player then
                    return
                end

                self.selected_player:set_in_menu(false)
                self.selected_player = nil
            end
        },
    }, 'normal')
end

function Shop:assign_random_upgrades()
    local bag = copy_table_shallow(game.level.upgrade_bag)
    local bag_overrides = copy_table_shallow(game.level.upgrade_bag_overrides or {})

	local number_of_upgrades = game.level.number_of_upgrades_per_roll
	local roll = {}
    if #bag_overrides > 0 then
        roll = bag_overrides
    end
	for i_roll=1, number_of_upgrades - #roll do
		local upgrade, _, i = random_weighted(bag)
		if upgrade then
			table.remove(bag, i)
			table.insert(roll, upgrade)
		end
	end
	
    self:assign_products(roll)

    game.level:reset_upgrade_bag_overrides()
end

function Shop:update(dt)
    Shop.super.update(self, dt)

    self.state_machine:update(dt)
end

function Shop:assign_products(products)
    self.products = products
    self:set_selection(self.selected_product_index)
end

function Shop:on_interact(player)
    if self.state_machine.current_state_name == "normal" then
        self:start_interaction(player)
    end
end

function Shop:draw()
    Shop.super.draw(self)
    
    self.state_machine:draw()
end

function Shop:set_selection(n)
    self.selected_product_index = n
    self.selected_product = self.products[n]
end

function Shop:increment_selection(diff)
    self:set_selection(mod_plus_1(self.selected_product_index + diff, #self.products))

    self.star_pattern_ox = diff*20

    local r = (self.selected_product_index - 1)/(#self.products - 1)
    self:play_sound_var("ui_menu_hover_{01-04}", 0.2, 1.0, {pitch = lerp(1.8, 2.2, r)})
end

function Shop:start_interaction(player)
    player:set_in_menu(true)
    self.selected_player = player

    self.state_machine:set_state("opening")
end

function Shop:end_interaction(instantly_give_back_control)
    if instantly_give_back_control and self.selected_player then
        self.selected_player:set_in_menu(false)

        self.selected_player = nil
    end
    if self.state_machine.current_state_name ~= "normal" then
        self.state_machine:set_state("deopening")
    end
end

function Shop:apply_current_product()
    if self.selected_player then
        self.selected_player:set_in_menu(false)
    end

    game:apply_upgrade(self.selected_product)
    self.is_interactible = false
end

function Shop:draw_products()
    local sep = 32
    local x = self.mid_x - ((#self.products - 1)*sep)/2
    local sel_x = x + (self.selected_product_index-1)*sep
    local y = self.mid_y - self.ui_oy + 16
    local s = ease_out_elastic(clamp(self.animation_t, 0, 1))

    if self.selected_product then
        love.graphics.setColor(self.selected_product.palette[3])
        draw_centered(images.rays_big, sel_x - self.star_pattern_ox * 1.4, y, 0.6*game.t, s*0.2)

        love.graphics.setColor(self.selected_product.palette[2])
        draw_centered(images.rays_big, sel_x - self.star_pattern_ox * 1.6, y, -0.8*game.t, s*0.18)

        love.graphics.setColor(self.selected_product.palette[1])
        draw_centered(images.rays_big, sel_x - self.star_pattern_ox * 1.8, y, game.t, s*0.15)

        love.graphics.setColor(COL_WHITE)
        
        self:draw_text(self.mid_x + self.star_pattern_ox * 5, y - 71, self.selected_product:get_title(), self.selected_product.color, 2)
        self:draw_text(self.mid_x + self.star_pattern_ox * 2.5, y - 46, self.selected_product:get_description())
    end

    for i=1, #self.products do
        self.products[i]:draw(x + (i-1)*sep, y, s)
    end

    if self.selected_player then
        local icon_left = Input:get_action_primary_icon(self.selected_player.n, "ui_left")
        local icon_right = Input:get_action_primary_icon(self.selected_player.n, "ui_right")
        -- draw_centered(icon_left,  self.mid_x - sep * (#self.products + 1)/2 - 8 + self.left_prompt_ox,  y, 0, s)
        -- draw_centered(icon_right, self.mid_x + sep * (#self.products + 1)/2 + 8 + self.right_prompt_ox, y, 0, s)
    
        if self.animation_t >= 0.5 then
            local prompt_x = math.floor(x - 38)
            local prompt_y = y + 36 - self.animation_t * 10
            local new_x = Input:draw_input_prompt(self.selected_player.n, {"ui_select"}, "{input.prompts.ui_select}", COL_WHITE, prompt_x, prompt_y)
            prompt_x = new_x + 8
            new_x = Input:draw_input_prompt(self.selected_player.n, {"ui_back"}, "{input.prompts.ui_back}", COL_WHITE, prompt_x, prompt_y)
        end
    end
end


function Shop:draw_text(x, y, text, col, s, params)
    params = params or {}
    col = param(col, COL_WHITE)
    s = param(s, 1)
    local wrap = param(params.wrap, true)
    local wrap_limit = param(params.wrap_limit, 16*16)

    local width
    local wrapped_text = {}
    if wrap then
        local font = love.graphics.getFont()
        width, wrapped_text = font:getWrap(text, wrap_limit)
    else
        width, wrapped_text = get_text_width(text), {text}
    end

    local iy = y
    for _, line in pairs(wrapped_text) do
        local total_w = get_text_width(line) * s
        local text_x = x - total_w/2
        for i=1, #line do
            local t = (#line - i)/#line + self.animation_t*2 - 1
            local c = utf8.sub(line, i, i)
            local w = get_text_width(c) * s
            if t > 0 then
                local oy = ease_out_cubic(clamp(t, 0, 1)) * (-4) 
                print_outline(col, COL_BLACK_BLUE, c, text_x, iy + oy, nil, nil, s)
            end
            text_x = text_x + w
        end
        iy = iy + get_text_height()
    end
end

return Shop