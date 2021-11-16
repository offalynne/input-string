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
