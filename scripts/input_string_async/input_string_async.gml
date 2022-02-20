function input_string_async_active(){ return ((___input_string()).async_id != undefined); }

function input_string_async_get(_prompt, _string = (___input_string()).value)
{
    with (___input_string())
    {
        if (async_id != undefined)
        {
            show_debug_message("Input String Warning: Dialog prompt refused. Awaiting callback ID \"" + string(async_id) + "\"");
            return false;
        }
        else
        {
            //Note platform suitability
            var _source = input_string_platform_hint();
            if (_source != "async")   show_debug_message("Input String Warning: Async dialog is not suitable for use on the current platform");
            if (_source == "virtual") show_debug_message("Input String Warning: Consider showing the virtual keyboard for non-modal text input instead");
            
            if ((os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos))
            {
                //Hide lingering overlay on dialogue prompt open (Fixes mobile keyboard focus quirk)
                keyboard_virtual_hide();
            }
            
            if (_string != "")
            {
                if ((os_type == os_switch) && (string_length(_string) > 500))
                {
                    //Enforce Switch dialog character limit
                    show_debug_message("Input String Warning: Switch dialog has a limit of 500 characters");
                    _string = string_copy(_string, 1, 500);
                }
                
                if (((os_type == os_ps4) || (os_type == os_ps5)) && (string_length(_string) > 1024))
                {
                    //Enforce PlayStation dialog character limit
                    show_debug_message("Input String Warning: PlayStation dialog has a limit of 1024 characters");
                    _string = string_copy(_string, 1, 1024);
                }

                if (string_length(_string) > max_length)
                {
                    //Enforce configured character limit
                    _string = string_copy(_string, 1, max_length);
                }
            }
        
            predialogue = input_string_get();
            async_id = get_string_async(_prompt, _string);
        
            return true;
        }
    
        show_error("Input String Error: Failed to issue async dialog", true);
    }
}
    
function input_string_dialog_async_event()
{
    with (___input_string())
    {
        if (event_number != ((os_browser == browser_not_a_browser) ? ev_dialog_async : 0))
        {
            //Use in async dialog event only
            show_error
            (
                "Input String Error: Async dialogue used in invalid event " 
                 + object_get_name(object_index) + ", " 
                 + "Event " + string(event_type) + ", " 
                 + "no. " + string(event_number) + ") ",
                true
            );
        }
        else
        {
            if (input_string_async_active() && (async_load != -1)
            && (async_load[? "id"] == async_id) && (async_load[? "status"] == true))
            {
                //Confirm Async
                var _result = async_load[? "result"];   
                _result = (is_undefined(_result) ? "" : string(_result));
                
                if (!allow_empty && (_result == ""))
                {
                    //Revert empty
                    _result = predialogue;
                }
                else
                {
                    async_submit = true;
                }
            
                __set(_result);
                async_id = undefined;
                
                if (async_submit)
                {
                    __submit();
                }
            }
        }
    }
}
