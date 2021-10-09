//Config
global.__input_string_max_length    = 1000;   //Maximum text entry string length. Do not exceed 1024
global.__input_string_autoclose_vkb = true;   //Whether the 'Return' key closes the virtual keyboard
global.__input_string_use_clipboard = false;  //Whether 'Control-V' pastes clipboard text on Windows
global.__input_string_allow_newline = true;   //Whether to allow newline characters or swap to space
global.__input_string_allow_empty   = false;  //Whether a blank field submission is treated as valid

//Init
global.__input_string_tick_last   = undefined;
global.__input_string_async_id    = undefined;
global.__input_string_callback    = undefined;
global.__input_string_lastkey     = undefined;

global.__input_string             = "";
global.__input_string_prev        = "";
global.__input_string_predialogue = "";

global.__input_string_async_submit   = false;
global.__input_string_virtual_submit = false;

global.__input_string_keyboard_supported = ((os_browser != browser_not_a_browser)
                                         || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                                         || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp));    
function input_string_tick()
{
    if (!input_string_async_active()
    && (global.__input_string_keyboard_supported || os_type == os_ios || os_type == os_tvos))
    {
        //Manage text input
        var _string = keyboard_string;
        if ((_string == "") && (string_length(global.__input_string_prev) > 1))
        {
            //Revert internal string overflow
            _string = "";
        }
        
        if (global.__input_string_use_clipboard && (os_type == os_windows)
        && keyboard_check_pressed(ord("V")) && keyboard_check(vk_control)
        && clipboard_has_text())
        {
            //Paste
            _string += clipboard_get_text();
        }
        
        if (!global.__input_string_allow_newline && (_string != ""))
        {
            //Cull newlines
            _string = string_replace_all(_string, chr(13), "");
            _string = string_replace_all(_string, chr(10), " ");
        }
        
        //Set internal string
        input_string_set(_string);

        global.__input_string_virtual_submit = false;
        if (keyboard_virtual_status() != undefined)
        {
            //Catch virtual keyboard submission
            if ((os_type == os_ios) || (os_type == os_tvos))
            {
                global.__input_string_virtual_submit = ((keyboard_lastkey == 10) 
                                                     && (keyboard_lastkey != global.__input_string_lastkey));
            }
            else
            {
                global.__input_string_virtual_submit = (keyboard_check_pressed(vk_enter));
            }
            
            global.__input_string_lastkey = keyboard_lastkey;
            if (global.__input_string_autoclose_vkb && global.__input_string_virtual_submit)
            {
                //Close virtual keyboard on submission
                keyboard_virtual_hide();
            }
        }
        
        if (is_method(global.__input_string_callback)
        && (global.__input_string_allow_empty  || global.__input_string != "")
        && (global.__input_string_async_submit || global.__input_string_virtual_submit
        || (global.__input_string_keyboard_supported && keyboard_check_pressed(vk_enter))))
        {
            //Issue string submission callback
            global.__input_string_callback();
        }
        
        //Delta
        global.__input_string_async_submit = false;
        global.__input_string_tick_last = current_time;
    }
}

function input_string_get(){ return global.__input_string; }
function input_string_virtual_submit(){ return global.__input_string_virtual_submit; }
function input_string_callback_set(_callback = undefined){ global.__input_string_callback = _callback; }
