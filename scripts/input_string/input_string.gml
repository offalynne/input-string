//Config
#macro INPUT_STRING global.___INPUT_STRING
___INPUT_STRING = 
{   
    max_length : 1000,      //Maximum text entry string length. Do not exceed 1024

    autoclose_vkb : true,   //Whether the 'Return' key closes the virtual keyboard
    use_clipboard : false,  //Whether 'Control-V' pastes clipboard text on Windows
    allow_newline : false,  //Whether to allow newline characters or swap to space
    allow_empty   : false,  //Whether a blank field submission is treated as valid
    submit_trim   : true,   //Whether submit trims leading and trailing whitespace

    //Init    
    platform_hint : "keyboard",
    predialogue   : "",
    value         : "",
    
    tick_last : undefined,
    callback  : undefined,
    async_id  : undefined,

    virtual_submit : false,
    async_submit   : false,

    keyboard_supported : ((os_type == os_operagx) || (os_browser != browser_not_a_browser)
	               || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
	               || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp)
	               || (os_type == os_tvos) || (os_type == os_ios)),
    //Utilites
    ___trim: function(_string = "")
    {
        var _c = "";
        var _l = 1;
        var _r = string_length(_string);
        
        repeat (_r)
        {
            //Offset left
            _c = ord(string_char_at(_string, _l));
            if ((_c > 8) && (_c < 14) || (_c == 32)) _l += 1;
            else break;
        }
        
        repeat (_r - _l)
        {
            //Offset right
            _c = ord(string_char_at(_string, _r));
            if ((_c > 8) && (_c < 14) || (_c == 32)) _r -= 1;
            else break;
        }
        
        //Trim
        return string_copy(_string, _l, _r - _l + 1);
    },

    ___set: function(_string = "")
    {
        with INPUT_STRING
        {
            //Stringify
            _string = string(_string);

            //Enforce length
            _string = string_copy(_string, 1, max_length);

            //Left pad one space (fixes Android quirk on first character)
            var _trim = (string_char_at(_string, 1) == " ");
            if ((os_type == os_android) && !_trim)
            {
                //Set leading space
                _string = " " + _string;
                _trim = true;
            }
        
            if ((tick_last != undefined) && (keyboard_string != _string))
            {
                //Set inbuilt value if necessary
                keyboard_string = _string;
            }
    
            //Set internal string
            value = _string;
    
            if ((os_type == os_android) && _trim)
            {
                //Trim leading space
                value = string_delete(value, 1, 1);
            }
        }
    },
    
    ___submit: function()
    {
        with INPUT_STRING
        {
            _string = input_string_get();
            
            if (submit_trim && (_string != ""))
            {
                //Trim whitespace on submission
                ___set(___trim(_string));
            }
            
            if (is_method(callback) && (_string != "" || allow_empty))
            {
                //Issue submission callback
                callback();
            }
        }
    }   
}
        
function input_string_set(_string = "")
{    
    if ((os_type == os_ios) || (os_type == os_tvos))
    {
        //Close virtual keyboard if string is manually set (fixes iOS setting quirk)
        keyboard_virtual_hide();
    }
    
    INPUT_STRING.___set(_string);
}

function input_string_virtual_submit() { return INPUT_STRING.virtual_submit; }
function input_string_platform_hint()  { return INPUT_STRING.platform_hint;  }
function input_string_submit()         { return INPUT_STRING.___submit();    }
function input_string_get()            { return INPUT_STRING.value;          }

function input_string_add(_string) { return input_string_set(INPUT_STRING.value + string(_string)); }

function input_string_callback_set(_callback = undefined) { INPUT_STRING.callback = _callback; }

function input_string_async_active() { return (INPUT_STRING.async_id != undefined); }

    
function input_string_tick()
{
    with INPUT_STRING
    {
        if (!input_string_async_active() && (keyboard_supported))
        {
            //Manage text input
            var _string = keyboard_string;
            if ((_string == "") && (string_length(value) > 1))
            {
                //Revert internal string when in overflow state
                _string = "";
            }
        
            if (use_clipboard && (os_type == os_windows)
                && keyboard_check_pressed(ord("V")) && keyboard_check(vk_control)
                && clipboard_has_text())
            {
                //Paste
                _string += clipboard_get_text();
            }
        
            //Filter carriage returns
            _string = string_replace_all(_string, chr(13), "");
        
            if (_string != "" && !allow_newline)
            {
                //Cull newlines
                _string = string_replace_all(_string, chr(10), " ");
            }
      
            //Handle virtual keyboard submission
            virtual_submit = false;
            if (keyboard_virtual_status() != undefined)
            {
                if ((os_type == os_ios) || (os_type == os_tvos))
                {
                    //iOS virtual keyboard submission
                    virtual_submit = ((keyboard_lastkey == 10) 
                                    && (string_length(keyboard_string) > string_length(value)));
                }
                else
                {
                    //non-iOS keyboard submission
                    virtual_submit = (keyboard_check_pressed(vk_enter));
                }
            
                if (autoclose_vkb && virtual_submit)
                {
                    //Close virtual keyboard on submission
                    keyboard_virtual_hide();
                }
            }

            //Any string submission
            var _submit = (async_submit || virtual_submit
                        || (keyboard_supported && keyboard_check_pressed(vk_enter)));
        
            //Set internal string
            ___set(_string);
                
            //Handle submission
            if (_submit)
            {
                ___submit();
            }
        
            //Delta
            async_submit = false;
            tick_last = current_time;
        }
    }
}

function input_string_async_get(_prompt, _string = INPUT_STRING.value)
{
    with INPUT_STRING
    {
        if (async_id != undefined)
        {
            show_debug_message("Input String Warning: Dialog prompt refused. Awaiting callback ID \"" + string(async_id) + "\"");
            return false;
        }
        else
        {
            var _source = input_string_platform_hint();
            if (_source != "async"  ) show_debug_message("Input String Warning: Async dialog is not suitable for use on the current platform");
            if (_source == "virtual") show_debug_message("Input String Warning: Consider showing the virtual keyboard for non-modal text input instead");
        
            if (os_type == os_switch)
            {
                //Enforce Switch character limit
                _string = string_copy(_string, 1, 500);
            }
        
            predialogue = input_string_get();
            async_id    = get_string_async(_prompt, _string);
        
            return true;
        }
    
        show_error("Input String Error: Failed to issue async dialog", true);
    }
}
    
function input_string_dialog_async_event()
{
    with INPUT_STRING
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
                && (async_load[? "id"] == async_id) && (async_load[? "status"] != undefined))
            {
                var _result = string(async_load[? "result"]);       
                if (!allow_empty && (_result == ""))
                {
                    //Revert empty
                    _result = predialogue;
                }
                else
                {
                    async_submit = true;
                }
            
                ___set(_result);            
                async_id = undefined;
            }
        }
    }
}

//Set platform hint
with INPUT_STRING
{
    if ((os_type == os_xboxone) || (os_type == os_xboxseriesxs) 
     || (os_type == os_switch)  || (os_type == os_ps4) || (os_type == os_ps5))
    {
        //Suggest 'async' (modal) on console
        platform_hint = "async";
    }
    else if ((os_browser != browser_not_a_browser)
     && ((os_type != os_windows) && (os_type != os_macosx) 
     &&  (os_type != os_operagx) && (os_type != os_linux)))
    {
        //Suggest 'async' (modal) on non-desktop web
        platform_hint = "async";
    }
    else if (((os_type == os_uwp) && uwp_device_touchscreen_available()) 
     || (os_type == os_ios) || (os_type == os_tvos))
    {
        //Suggest virtual keyboard on iOS and UWP mobile
        platform_hint = "virtual";
    }
    else if (os_type == os_android)
    {
        var _map = os_get_info();
        if (ds_exists(_map, ds_type_map))
        {
            if (!_map[? "PHYSICAL_KEYBOARD"])
            {
                //Suggest virtual keyboard on Android in absence of physical
                platform_hint = "virtual";
            }
        
            ds_map_destroy(_map);
        }
    }
}