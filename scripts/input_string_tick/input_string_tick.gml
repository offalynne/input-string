//Config
global.__input_string_max_length  = 1000;
global.__input_string_allow_empty = false;

//Init
global.__input_string             = "";
global.__input_string_prev        = "";
global.__input_string_predialogue = "";
global.__input_string_async_id    = undefined;
global.__input_string_tick_last   = undefined;
global.__input_string_lastkey     = undefined;

global.__input_string_virtual_submit     = false;
global.__input_string_keyboard_supported = ((os_browser != browser_not_a_browser)
                                         || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                                         || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp));    
function input_string_tick()
{
    //Manage text input
    if (!input_string_async_active()
    && (global.__input_string_keyboard_supported || os_type == os_ios || os_type == os_tvos))
    {
        var _string = keyboard_string;

        //Revert overflow
        if ((_string == "") && (string_length(global.__input_string_prev) > 1))
        {
            _string = "";
        }
        
        //Set internal string
        input_string_set(_string);

        //Catch virtual keyboard submission        
        global.__input_string_virtual_submit = false;
        if (!is_undefined(keyboard_virtual_status()))
        {
            if ((os_type == os_ios) || (os_type == os_tvos))
            {
                global.__input_string_virtual_submit = ((keyboard_lastkey == 10) && (keyboard_lastkey != global.__input_string_lastkey));
            }
            else
            {
                global.__input_string_virtual_submit = (keyboard_check_pressed(vk_enter));
            }
            
            global.__input_string_lastkey = keyboard_lastkey;
        }
        
        global.__input_string_tick_last = current_time;
    }
}