//Config
global.__input_string             = "";
global.__input_string_prev        = "";
global.__input_string_predialogue = "";
global.__input_string_max_length  = 1000;
global.__input_string_allow_empty = false;
global.__input_string_async_id    = undefined;
global.__input_string_tick_last   = undefined;
global.__input_string_keyboard_supported = ((os_browser != browser_not_a_browser)
                                         || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                                         || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp));    
function input_string_tick()
{
    //Manage text input
    if ((global.__input_string_keyboard_supported || os_type == os_ios)
    && (!input_string_async_is_active()))
    {
        var _string = keyboard_string;

        //Revert overflow
        if ((_string == "") && (string_length(global.__input_string_prev) > 1))
        {
            _string = "";
        }
        
        input_string_set(_string);
    }
    
    global.__input_string_tick_last = current_time;
}