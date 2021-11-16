//Set platform hint
if ((os_type == os_xboxone) || (os_type == os_xboxseriesxs) || (os_type == os_switch) || (os_type == os_ps4) || (os_type == os_ps5))
{
    //Suggest 'async' (modal) on console
    INPUT_STRING.platform_hint = "async";
}
else if ((os_browser != browser_not_a_browser)
     && ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux) && (os_type != os_operagx)))
{
    //Suggest 'async' (modal) on non-desktop web
    INPUT_STRING.platform_hint = "async";
}
else if (((os_type == os_uwp) && uwp_device_touchscreen_available()) || (os_type == os_ios) || (os_type == os_tvos))
{
    //Suggest virtual keyboard on iOS and UWP mobile
    INPUT_STRING.platform_hint = "virtual";
}
else if (os_type == os_android)
{
    var _map = os_get_info();
    if (ds_exists(_map, ds_type_map))
    {
        if (!_map[? "PHYSICAL_KEYBOARD"])
        {
            //Suggest virtual keyboard on Android in absence of physical
            INPUT_STRING.platform_hint = "virtual";
        }
        
        ds_map_destroy(_map);
    }
}

function input_string_platform_hint() { return  INPUT_STRING.platform_hint; }
function input_string_async_active()  { return (INPUT_STRING.async_id != undefined); }

function input_string_async_get(_prompt, _string = INPUT_STRING.value)
{
    if (INPUT_STRING.async_id != undefined)
    {
        show_debug_message("Input String Warning: Dialog prompt refused. Awaiting callback ID \"" + string(INPUT_STRING.async_id) + "\"");
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
        
        INPUT_STRING.predialogue = input_string_get();
        INPUT_STRING.async_id    = get_string_async(_prompt, _string);
        
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
        && (async_load[? "id"] == INPUT_STRING.async_id) && (async_load[? "status"] != undefined))
        {
            //Report results            
            var _result = string(async_load[? "result"]);            
            if (!INPUT_STRING.allow_empty && (_result == ""))
            {
                //Revert empty
                _result = INPUT_STRING.predialogue;
            }
            
            INPUT_STRING.set(_result);
            
            INPUT_STRING.async_submit = true;
            INPUT_STRING.async_id = undefined;
        }
    }
}
