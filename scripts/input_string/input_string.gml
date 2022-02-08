function ___input_string()
{
    //Self initialize
    static instance = new (function() constructor {
        
    //Config
    auto_closevkb = true;   //Whether the 'Return' key closes the virtual keyboard
    auto_submit   = true;   //Whether the 'Return' key fires a submission callback
    auto_trim     = true;   //Whether submit trims leading and trailing whitespace

    allow_empty   = false;  //Whether a blank field submission is treated as valid
    allow_newline = false;  //Whether to allow newline characters or swap to space
    use_clipboard = false;  //Whether 'Control-V' pastes clipboard text on Windows

    max_length = 1000;      //Maximum text entry string length. Do not exceed 1024

    //Init
    predialogue = "";
    value       = "";

    tick_last = undefined;
    callback  = undefined;
    async_id  = undefined;

    virtual_submit = false;
    async_submit   = false;

    keyboard_supported = ((os_type == os_operagx) || (os_browser != browser_not_a_browser)
                       || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                       || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp)
                       || (os_type == os_tvos) || (os_type == os_ios));

    //Set platform hint
    if ((os_type == os_xboxone) || (os_type == os_xboxseriesxs) 
    ||  (os_type == os_switch)  || (os_type == os_ps4) || (os_type == os_ps5))
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
    else if ((os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos)
    || (uwp_device_touchscreen_available() && (os_type == os_uwp)))
    {
        //Suggest virtual keyboard on mobile
        platform_hint = "virtual";
    }
    else
    {
        platform_hint = "keyboard";
    }

    //Utils
    __trim = function(_string)
    {        
        var _c = "";
        var _l = 1;
        var _r = string_length(_string);

        repeat (_r)
        {
            //Offset left
            _c = ord(string_char_at(_string, _l));
            if ((_c > 8) && (_c < 14) || (_c == 32)) _l++;
            else break;
        }

        repeat (_r - _l)
        {
            //Offset right
            _c = ord(string_char_at(_string, _r));
            if ((_c > 8) && (_c < 14) || (_c == 32)) _r--;
            else break;
        }

        //Trim
        return string_copy(_string, _l, _r - _l + 1);
    };


    __set = function(_string)
    {
        with (___input_string())
        {
            _string = string(_string);

            //Enforce length
            var _max = max_length + ((os_type == os_android) ? 1 : 0);
            _string = string_copy(_string, 1, _max);

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
                if (((os_type == os_ios) || (os_type == os_tvos))
                && (string_length(keyboard_string) > _max))
                {
                    //Close keyboard on overflow (fixes iOS string setting quirk)
                    keyboard_virtual_hide();
                }

                //Set inbuilt value if necessary
                keyboard_string = _string;
            }

            //Set internal string
            value = _string;

            if ((os_type == os_android) && _trim)
            {
                //Trim Android placeholder
                value = string_delete(value, 1, 1);
            }
        }
    };


    __submit = function()
    {
        with (___input_string())
        {
            if (auto_trim)
            {
                //Trim whitespace on submission
                __set(__trim(input_string_get()));
            }

            if (is_method(callback) && (input_string_get() != "" || allow_empty))
            {
                //Issue submission callback
                callback();
            }
        }
    };
        
    })(); return instance;
}

function input_string_virtual_submit() { return (___input_string()).virtual_submit; }
function input_string_platform_hint()  { return (___input_string()).platform_hint;  }
function input_string_submit()         { return (___input_string()).__submit();     }
function input_string_get()            { return (___input_string()).value;          }

function input_string_set(_string = "")
{    
    if ((os_type == os_ios) || (os_type == os_tvos))
    {
        //Close virtual keyboard if string is manually set (fixes iOS setting quirk)
        keyboard_virtual_hide();
    }
    
    (___input_string()).__set(_string);
}


function input_string_add(_string)
{
    return input_string_set((___input_string()).value + string(_string));
}


function input_string_callback_set(_callback = undefined)
{
    (___input_string()).callback = _callback;
}


function input_string_tick()
{
    with (___input_string())
    {
        if (!input_string_async_active() && keyboard_supported)
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

            if (_string != "")
            {
                if ((os_type != os_windows) || !allow_newline)
                {
                    //Filter carriage returns
                    _string = string_replace_all(_string, chr(13), "");
                }
        
                if (!allow_newline)
                {
                    //Cull newlines
                    _string = string_replace_all(_string, chr(10), " ");
                }
            }
      
            //Handle virtual keyboard submission
            virtual_submit = false;
            if ((keyboard_virtual_status() != undefined) && !input_string_async_active())
            {
                if ((os_type == os_ios) || (os_type == os_tvos))
                {
                    //Virtual keyboard submission
                    virtual_submit = ((keyboard_lastkey == 10) 
                                   && (string_length(keyboard_string) > string_length(value)));
                }
                else
                {
                    //Keyboard submission
                    virtual_submit = (keyboard_check_pressed(vk_enter));
                }
                
                if (keyboard_check_pressed(10) && !virtual_submit && (os_type == os_android))
                {
                    //Android alternate key
                    virtual_submit = true;
                }                
            
                if (auto_closevkb && virtual_submit
                && (((os_type == os_uwp) && uwp_device_touchscreen_available()) 
                ||   (os_type == os_ios) || (os_type == os_tvos)))
                {
                    //Close virtual keyboard on submission
                    keyboard_virtual_hide();
                }
            }

            //Set internal string
            __set(_string);
                
            if (auto_submit && !async_submit
            && (virtual_submit || (keyboard_supported && keyboard_check_pressed(vk_enter))))
            {
                //Handle submission
                __submit();
            }

            async_submit = false;
            tick_last = current_time;
        }
    }
}
