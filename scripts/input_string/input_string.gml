//Config
#macro INPUT_STRING global.___INPUT_STRING
___INPUT_STRING = 
{
    //Config
	max_length : 1000,      //Maximum text entry string length. Do not exceed 1024

	autoclose_vkb : true,   //Whether the 'Return' key closes the virtual keyboard
	use_clipboard : false,  //Whether 'Control-V' pastes clipboard text on Windows
	allow_newline : false,  //Whether to allow newline characters or swap to space
	allow_empty   : false,  //Whether a blank field submission is treated as valid

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
                       
    set : function(_string = "")
    {
        //Stringify
        _string = string(_string);

        //Enforce max length
        _string = string_copy(_string, 1, INPUT_STRING.max_length);

        //Left pad one space (fixes Android quirk on the first character)
        var _trim = (string_char_at(_string, 1) == " ");
        if ((os_type == os_android) && !_trim)
        {
            //Set leading space
            _string = " " + _string;
            _trim = true;
        }
        
        if ((INPUT_STRING.tick_last != undefined) && (keyboard_string != _string))
        {
            //Set inbuilt value if necessary
            keyboard_string = _string;
        }
    
        //Set internal string
        INPUT_STRING.value = _string;
    
        if ((os_type == os_android) && _trim)
        {
            //Trim leading space
            INPUT_STRING.value = string_delete(INPUT_STRING.value, 1, 1);
        }
    }
}

function input_string_set(_string = "")
{    
    if (keyboard_virtual_status() != undefined)
    {
        //Close virtual keyboard if string is manually set (fixes iOS setting quirk)
        keyboard_virtual_hide();
        
    }
    
    INPUT_STRING.set(_string);
}

function input_string_tick()
{
    if (!input_string_async_active() && (INPUT_STRING.keyboard_supported))
    {
        //Manage text input
        var _string = keyboard_string;
        if ((_string == "") && (string_length(INPUT_STRING.value) > 1))
        {
            //Revert internal string when in overflow state
            _string = "";
        }
        
        if (INPUT_STRING.use_clipboard && (os_type == os_windows)
        && keyboard_check_pressed(ord("V")) && keyboard_check(vk_control)
        && clipboard_has_text())
        {
            //Paste
            _string += clipboard_get_text();
        }
        
        //Filter carriage returns
        _string = string_replace_all(_string, chr(13), "");
        
        if (_string != "" && !INPUT_STRING.allow_newline)
        {
            //Cull newlines
            _string = string_replace_all(_string, chr(10), " ");
        }
      
        //Handle virtual keyboard submission
        INPUT_STRING.virtual_submit = false;
        if (keyboard_virtual_status() != undefined)
        {
            if ((os_type == os_ios) || (os_type == os_tvos))
            {
                //iOS virtual keyboard submission
                INPUT_STRING.virtual_submit = ((keyboard_lastkey == 10) 
                                            && (string_length(keyboard_string) > string_length(INPUT_STRING.value)));
            }
            else
            {
                //non-iOS keyboard submission
                INPUT_STRING.virtual_submit = (keyboard_check_pressed(vk_enter));
            }
            
            if (INPUT_STRING.autoclose_vkb && INPUT_STRING.virtual_submit)
            {
                //Close virtual keyboard on submission
                keyboard_virtual_hide();
            }
        }

        //Any string submission
        var _submit = (INPUT_STRING.async_submit || INPUT_STRING.virtual_submit
                   || (INPUT_STRING.keyboard_supported && keyboard_check_pressed(vk_enter)));

        if (_submit && (string_char_at(_string, string_length(_string)) == chr(10)))
        {
            //Strip trailing newline on submission
            _string = string_copy(_string, 1, string_length(_string) - 1);
        }
        
        //Set internal string
        INPUT_STRING.set(_string);
        
        if (_submit && is_method(INPUT_STRING.callback)
        && (_string != "" || INPUT_STRING.allow_empty))
        {
            //Issue submission callback
            INPUT_STRING.callback();
        }
        
        //Delta
        INPUT_STRING.async_submit = false;
        INPUT_STRING.tick_last = current_time;
    }
}

function input_string_callback_set(_callback = undefined) { INPUT_STRING.callback = _callback; }

function input_string_add(_string = "") { return input_string_set(INPUT_STRING.value + string(_string)); }
function input_string_virtual_submit()  { return INPUT_STRING.virtual_submit; }
function input_string_get()             { return INPUT_STRING.value; }

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
            else
            {
                INPUT_STRING.async_submit = true;
            }
            
            INPUT_STRING.set(_result);
            
            INPUT_STRING.async_id = undefined;
        }
    }
}