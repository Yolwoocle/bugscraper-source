require "scripts.util"
local Class = require "scripts.meta.class"
local generate_menus = require "data.menus"

local MenuManager = Class:inherit()

local MENU_SCROLL_DEADZONE = 32

function MenuManager:init(game)
	self.game = game
	
	self:reset()
end
function MenuManager:reset()
	self.menus = generate_menus()
	
	self.cur_menu = nil
	self.cur_menu_name = ""
	self.is_paused = false
	self.can_pause = true
	self.buffer_unpause = false

	self.sel_n = 1
	self.sel_item = nil

	self.menu_stack = {}
	self.last_menu = "title"

	self.joystick_wait_cooldown = 0.0
	self.joystick_wait_mode = false
	self.joystick_wait_set = {}

	self.sawtooth_scroll = 0
	self.border_scroll_speed = -14
end

function MenuManager:update(dt)
	self:update_menu_unpausing()
	if self.cur_menu then
		self:update_current_menu(dt)
	end
	if self.joystick_wait_mode then
		self:update_joystick_wait_mode(dt)
	end

	local pause_button = Input:action_pressed("pause")
	local back_button = Input:action_pressed("ui_back")
	if pause_button then 
		if self.cur_menu == nil then
			self:pause()
		elseif self.is_paused then
			self:unpause()
		end
	elseif back_button and ((not self.cur_menu) or (self.cur_menu and self.cur_menu.is_backable)) then
		self:back()
	end

	self.joystick_wait_cooldown = math.max(self.joystick_wait_cooldown - dt, 0.0)
	self.sawtooth_scroll = self.sawtooth_scroll + self.border_scroll_speed*dt
end

function MenuManager:update_current_menu(dt)
	-- Navigate up and down
	if Input:action_pressed("ui_up") then
		self:incr_selection(-1)
	end
	if Input:action_pressed("ui_down") then
		self:incr_selection(1)
	end
	
	self.cur_menu:update(dt)

	-- Update current selection
	if self.cur_menu and self.sel_n and self.sel_item then
		self.sel_n = mod_plus_1(self.sel_n, #self.cur_menu.items)
		self.sel_item = self.cur_menu.items[self.sel_n]
	end
	if self.sel_item then
		self.sel_item.is_selected = true
	end

	-- On pressed
	local btn = Input:action_pressed("ui_select")
	if btn and self.sel_item and self.sel_item.on_click then
		if not self.sel_item.is_waiting_for_input then
			self.sel_item:on_click()
			if self.sel_item then self.sel_item:after_click() end
		end
	end

	-- Scroll
	if self.cur_menu and self.sel_item and self.cur_menu.is_scrollable then
		if self.sel_item.y > CANVAS_HEIGHT/2 + MENU_SCROLL_DEADZONE then
			self.cur_menu:set_target_scroll_position(self.sel_item.def_y - (CANVAS_HEIGHT/2 + MENU_SCROLL_DEADZONE))
		elseif self.sel_item.y < CANVAS_HEIGHT/2 - MENU_SCROLL_DEADZONE then
			self.cur_menu:set_target_scroll_position(self.sel_item.def_y - (CANVAS_HEIGHT/2 - MENU_SCROLL_DEADZONE))
		end
	end
end

function MenuManager:draw()
	if self.cur_menu.bg_color then
		rect_color(self.cur_menu.bg_color, "fill", -1, -1, CANVAS_WIDTH+2, CANVAS_HEIGHT+2)
	end
	self.cur_menu:draw()
end

function MenuManager:set_menu(menu, params)
	params = params or {}
	self.last_menu = self.cur_menu

	-- nil menu
	if menu == nil then
		self.buffer_unpause = true
		return true
	else
		if not params.is_back then
			table.insert(self.menu_stack, {
				menu = self.cur_menu,
				sel_n = self.sel_n,
			})
		end
	end

	local m = self.menus[menu]
	if type(menu) ~= "string" and menu.is_menu then
		m = menu
	end

	if not m then 
		return false, "Menu '" .. tostring(menu) .. "' does not exist"
	end
	if self.cur_menu and not params.skip_on_unset_call then
		self.cur_menu:on_unset()
	end
	self.cur_menu = m
	self.cur_menu_name = menu

	-- Update selection to first selectable
	if not params.skip_on_set_call then
		self.cur_menu:on_set(params.is_back)
	end
	self.cur_menu:update(0)
	
	self:remove_selection()
	local sel = self:find_selectable_from(1, 1)
	self:set_selection(sel)
	
	-- Reset game screenshake
	-- if game and game.camera then
		-- game.camera:reset()
	-- end

	game:on_menu()
	return true
end

function MenuManager:update_menu_unpausing()
	if self.buffer_unpause then
		self.buffer_unpause = false
		self.cur_menu = nil
		self.cur_menu_name = nil
		self.menu_stack = {}
		game:on_unmenu()
	end
end

function MenuManager:set_can_pause(value)
    self.can_pause = value
end

function MenuManager:pause(force_pause)
	-- Retry if game ended
	if not force_pause then
		if self.is_paused then return end
		if not self.can_pause then return end
	end

	if self.cur_menu == nil then
		self.is_paused = true
		self:set_menu("pause")
		game:on_pause()
	end
end

function MenuManager:unpause()
	if not self.cur_menu then return end
	
	self.is_paused = false
	self:set_menu()
	game:on_unmenu()
	game:on_unpause()
end

function MenuManager:incr_selection(delta)
	if not self.cur_menu then return false, "no current menu" end

	if not self.sel_n then
		self.sel_n = 1
	end
	
	-- Increment selection until valid item
	local sel = self:find_selectable_from(mod_plus_1(self.sel_n + delta, #self.cur_menu.items), delta)

	if not sel then
		return false, concat("no selectable item found")
	end

	-- Update new selection
	if self.sel_item then
		self.sel_item:set_selected(false, delta)
	end
	self.sel_n = sel
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item:set_selected(true, delta)
	
	Audio:play_var("ui_menu_hover_{01-04}", 0.2, 1.1, {pitch = 2.0})

	return true
end

function MenuManager:find_selectable_from(n, diff)
	if not n then 
		return
	end
	diff = diff or 1

	local len = #self.cur_menu.items
	local sel = n

	local limit = len
	local found = self.cur_menu.items[sel].is_selectable
	while not found and limit > 0 do
		sel = mod_plus_1(sel + diff, len)
		if self.cur_menu.items[sel].is_selectable then 
			found = true 
		end
		limit = limit - 1
	end

	if not found then
		return nil
	end
	return sel
end

function MenuManager:remove_selection()
	if not self.cur_menu then
		return
	end
	for _, item in pairs(self.cur_menu.items) do
		if item.set_selected then
			item:set_selected(false)
		end 
	end
	self.sel_n = nil
	self.sel_item = nil
end

function MenuManager:set_selection(n, find_first_valid_selectable)
	if not self.cur_menu then 
		return false
	end	
	if not n then
		return false
	end

	if find_first_valid_selectable then
		n = self:find_selectable_from(n, 1)
	end 
	if not n then
		return false
	end

	if not self.cur_menu.items[n] or not self.cur_menu.items[n].is_selectable then 
		return false 
	end	

	if self.sel_item then 
		self.sel_item:set_selected(false)
	end
	self.sel_n = n
	self.sel_item = self.cur_menu.items[n]
	self.sel_item:set_selected(true)
	
	return true
end

function MenuManager:back(params)
	params = params or {}
	local item = table.remove(self.menu_stack)
	if item and item.menu then
		local _params = copy_table_shallow(params)
		_params.is_back = true
		self:set_menu(item.menu, _params)
		self:set_selection(item.sel_n)
	end
	
	if #self.menu_stack == 0 then
		self:unpause()
		return
	end

end

function MenuManager:keypressed(key, scancode)
	if self.sel_item and self.sel_item.keypressed then
		self.sel_item:keypressed(key, scancode)
	end
	if self.cur_menu and self.cur_menu.keypressed then
		self.cur_menu:keypressed(key, scancode)
	end
end

function MenuManager:keypressedrepeat(key, scancode)
	if self.sel_item and self.sel_item.keypressedrepeat then
		self.sel_item:keypressedrepeat(key, scancode)
	end
	if self.cur_menu and self.cur_menu.keypressedrepeat then
		self.cur_menu:keypressedrepeat(key, scancode)
	end
end

function MenuManager:gamepadpressed(joystick, buttoncode)
	if self.sel_item and self.sel_item.gamepadpressed then
		self.sel_item:gamepadpressed(joystick, buttoncode)
	end
	if self.cur_menu and self.cur_menu.gamepadpressed then
		self.cur_menu:gamepadpressed(joystick, buttoncode)
	end
end

function MenuManager:gamepadreleased(joystick, buttoncode)
	if self.sel_item and self.sel_item.gamepadreleased then
		self.sel_item:gamepadreleased(joystick, buttoncode)
	end
	if self.cur_menu and self.cur_menu.gamepadreleased then
		self.cur_menu:gamepadreleased(joystick, buttoncode)
	end
end

function MenuManager:gamepadaxis(joystick, axis, value)
	if self.sel_item and self.sel_item.gamepadaxis then
		self.sel_item:gamepadaxis(joystick, axis, value)
	end
	if self.cur_menu and self.cur_menu.gamepadaxis then
		self.cur_menu:gamepadaxis(joystick, axis, value)
	end
end

function MenuManager:mousepressed(x, y, button, istouch, presses)
	if self.sel_item and self.sel_item.mousepressed then
		self.sel_item:mousepressed(x, y, button, istouch, presses)
	end
	if self.cur_menu and self.cur_menu.mousepressed then
		self.cur_menu:mousepressed(x, y, button, istouch, presses)
	end
end

function MenuManager:mousereleased(x, y, button, istouch, presses)
	if self.sel_item and self.sel_item.mousereleased then
		self.sel_item:mousereleased(x, y, button, istouch, presses)
	end
	if self.cur_menu and self.cur_menu.mousereleased then
		self.cur_menu:mousereleased(x, y, button, istouch, presses)
	end
end

function MenuManager:textinput(text)
	if self.sel_item and self.sel_item.textinput then
		self.sel_item:textinput(text)
	end
	if self.cur_menu and self.cur_menu.textinput then
		self.cur_menu:textinput(text)
	end
end

---------------------------------------------

function MenuManager:enable_joystick_wait_mode(joystick)
	self:set_menu("joystick_removed")
	self.joystick_wait_cooldown = 1.0
	self.joystick_wait_mode = true
	self.joystick_wait_set[joystick] = true
end

function MenuManager:disable_joystick_wait_mode()
	self:back()
	self.joystick_wait_mode = false
	self.joystick_wait_set = {}
end

function MenuManager:update_joystick_wait_mode(dt)
	local count = 0
	for controller, _ in pairs(self.joystick_wait_set) do
		if controller:isConnected() then
			self.joystick_wait_set[controller] = nil
		else
			count = count + 1
		end
	end

	if count == 0 and self.joystick_wait_mode then
		self:disable_joystick_wait_mode()
	end
end

function MenuManager:get_menu_padding()
	return CANVAS_WIDTH * (Text:get_meta().menu_padding or DEFAULT_MENU_PADDING)
end

return MenuManager