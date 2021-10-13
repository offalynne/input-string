function input_string_async_get(_prompt, _string = global.__input_string)
{
    if (global.__input_string_async_id != undefined)
    {
        show_debug_message("Input String Warning: Dialog prompt refused. Awaiting callback ID \"" + string(global.__input_string_async_id) + "\"");
        return false;
    }
    else
    {
        //Warn dialog platform suitability
        var _source = input_string_platform_hint();
        if (_source != "async")   show_debug_message("Input String Warning: Async dialog is not suitable for use on the current platform");
        if (_source == "virtual") show_debug_message("Input String Warning: Consider showing the virtual keyboard for non-modal text input instead");
        
        if (os_type == os_switch)
        {
            //Enforce Switch character limit
            _string = string_copy(_string, 1, 500);
        }
        
        global.__input_string_async_id    = get_string_async(_prompt, _string);
        global.__input_string_predialogue = input_string_get();
        
        return true;
    }
    
    show_error("Input String Error: Failed to issue async dialog", true);
}


function input_string_dialog_async_event()
{
    if (event_number != (os_browser == browser_not_a_browser ? ev_dialog_async : 0))
    {
        //Use in async dialog event only
        show_error("Input String Error: Async dialogue used in invalid event (" 
                    + object_get_name(object_index) + ", " 
                    + string(event_type) + ", " 
                    + string(event_number) 
                    + ")", true);
    }
    else
    {
        if (input_string_async_active() && (async_load != undefined)
        && (async_load[? "id"] == global.__input_string_async_id) && (async_load[? "status"] != undefined))
        {
            //Report results            
            var _result = string(async_load[? "result"]);            
            if (!global.__input_string_allow_empty && (_result == ""))
            {
                //Revert empty
                _result = global.__input_string_predialogue;
            }
            
            input_string_set(_result);
            
            global.__input_string_async_submit = true;
            global.__input_string_async_id = undefined;
        }
    }
}

function input_string_async_active(){ return (global.__input_string_async_id != undefined); }
