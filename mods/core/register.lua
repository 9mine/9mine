class 'register'

register.form_handlers = {}

function register.add_form_handler(formname, f)
    register.form_handlers[formname] = f
end

function register.call_form_handlers(player, formname, fields)
    for index, handler in pairs(register.form_handlers) do
        handler(player, formname, fields)
    end
end
