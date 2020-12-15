class 'register'

register.form_handlers = {}
register.texture_handlers = {}
register.craft_handlers = {}
register.on_join_funcs = {}

-- form handler
function register.add_form_handler(formname, f)
    register.form_handlers[formname] = f
end

function register.delete_form_handler(formname)
    register.form_handlers[formname] = nil
end

function register.call_form_handlers(player, formname, fields)
    for index, handler in pairs(register.form_handlers) do
        handler(player, formname, fields)
    end
end


-- texture handler
function register.add_texture_handler(handler_name, f)
    register.texture_handlers[handler_name] = f
end

function register.delete_texture_handler(handler_name)
    register.texture_handlers[handler_name] = nil
end

function register.call_texture_handlers(directory_entry, entity)
    for index, handler in pairs(register.texture_handlers) do
        handler(directory_entry, entity)
    end
end


-- craft handlers
function register.add_craft_handler(handler_name, f)
    register.craft_handlers[handler_name] = f
end

function register.delete_craft_handler(handler_name) 
    register.craft_handlers[handler_name] = nil
end

function register.call_craft_handlers(itemstack, player, old_craft_grid, craft_inv)
    for index, handler in pairs(register.craft_handlers) do 
        handler(itemstack, player, old_craft_grid, craft_inv)
    end
end

-- on_join funcs 
-- craft handlers
function register.add_onjoin_func(func_name, f)
    register.on_join_funcs[func_name] = f
end

function register.delete_onjoin_func(func_name) 
    register.on_join_funcs[func_name] = nil
end

function register.call_onjoin_funcs(player, last_login)
    for index, func in pairs(register.on_join_funcs) do 
        func(player, last_login)
    end
end
