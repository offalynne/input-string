function input_string_dialog_async_event()
{
    if (event_number != (os_browser == browser_not_a_browser ? ev_dialog_async : 0))
    {
        //Use in async dialog event only
        show_error("Input String: Async dialogue used in invalid event (" 
                    + object_get_name(object_index) + ", " 
                    + string(event_type) + ", " 
                    + string(event_number) 
                    + ")", true);
    }
    else
    {
        if (input_string_async_is_active() && (async_load != undefined)
        && (async_load[? "id"] == global.__input_string_async_id) && (async_load[? "status"] != undefined))
        {
            //Report results
            var _result = string(async_load[? "result"]);
            if (!global.__input_string_allow_empty && ((_result == "undefined") || (_result == "")))
            {
                _result = global.__input_string_predialogue;
            }
            
            input_string_set(_result);
            global.__input_string_async_id = undefined;
        }
    }
}
