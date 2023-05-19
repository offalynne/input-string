// input-string library feather disable all

function __input_string()
{
    // Self initialize
    static instance = new (function() constructor {
    
    
    #region Configuration
    
    auto_closevkb  = true;   // Whether the 'Return' key closes the virtual keyboard
    auto_submit    = true;   // Whether the 'Return' key fires a submission callback
    auto_trim      = true;   // Whether submit trims leading and trailing whitespace
    
    allow_case     = false;  // Whether searches are performed with case sensitivity
    allow_empty    = false;  // Whether a blank field submission is treated as valid
    allow_newline  = false;  // Whether to allow newline characters or swap to space
    
    max_length     = 1000;   // Maximum text entry string length. Do not exceed 1024
    search_timeout = 200;    // Minimum milliseconds between doing consecutive search
    
    #endregion
    
    
    #region Initialization
    
    __value     = "";
    __predialog = "";

    __search_list = [];
    __result_list = [];
    
    __delete_duration = 0;
    __tick_last       = 0;
    __search_last     = 0;
    
    __callback  = undefined;
    __async_id  = undefined;
    
    __async_submit = false;
    __just_ticked  = false;
    __just_set     = false;
    __search_queue = false;
    
    __on_windows     =  (os_type == os_windows);
    __on_android     =  (os_type == os_android);
    __on_ios         = ((os_type == os_ios) || (os_type == os_tvos));
    __on_mobile      = (__on_android || __on_ios);
    __on_xbox        = ((os_type == os_xboxone) || (os_type == os_xboxseriesxs));
    __on_playstation = ((os_type == os_ps4) || (os_type == os_ps5));
    __on_console     = ((os_type == os_switch) || __on_playstation || __on_xbox);
    __on_unix_native = ((os_browser == browser_not_a_browser) && ((os_type == os_macosx) || (os_type == os_linux)));
    __on_mobile_web  = ((os_browser != browser_not_a_browser) && ((os_type != os_macosx) && (os_type != os_linux) && (os_type != os_windows) && (os_type != os_operagx)));
    
    if (__on_xbox) max_length = max(max_length, 256);
    
    #endregion
    
    
    #region Detect features
    
    var _feature_report = "";
    
    __use_steam = extension_exists("Steamworks");    
    if (__use_steam) _feature_report += " Using Steamworks extension.";
    
    __use_trim = false;
    try
    {
        var _z = string_trim(" z ");
        __use_trim = (_z == "z");
    }
    catch(_error)
    {
        // No `string_trim` support
        _feature_report += " Not using native string trim.";
    }
    
    // Set platform hint
    if (__on_console)
    {
        // 'async' (dialog) on console
        __platform_hint = "async";
    }
    else if (__on_mobile_web)
    {
        // 'async' (dialog) on mobile web
        __platform_hint = "async";
    }
    else if (__on_mobile)
    {
        // 'virtual' (OSK) on mobile native
        __platform_hint = "virtual";
        
        if (__on_android)
        {
            var _map = os_get_info();
            if (ds_exists(_map, ds_type_map))
            {
                // Android on Chromebook form factor (ARC) test via Google
                // matches(".+_cheets|cheets_.+")
                var _device = string(_map[? "DEVICE"]);
                if ((string_pos("_cheets", _device) > 1) || ((string_pos("cheets_", _device) > 0) && (string_pos("cheets_", _device) < (string_length(_device) - 6))))
                {
                    // 'keyboard' (hardware) on Android Chromebook
                    __platform_hint = "keyboard";
                }

                ds_map_destroy(_map)
            }
        }
    }
    else 
    {
        __platform_hint = "keyboard";
        if (__use_steam)
        {
            if (steam_utils_is_steam_running_on_steam_deck())
            {
                // 'virtual' (OSK) on Steam Deck
                __platform_hint = "virtual";
            }
        }
    }
    
    _feature_report += " Suggesting input method \"" + __platform_hint + "\".";
    
    show_debug_message("Input String:" + _feature_report);
    
    #endregion
    
    
    #region Utilities    
        
    if (__use_trim)
    {
        __trim = function(_string){ return string_trim(_string); };
    }
    else
    {
        __trim = function(_string)
        {
            var _char  = 0;
            var _right = string_length(_string);
            var _left  = 1;
            
            repeat (_right)
            {
                // Offset left
                _char = ord(string_char_at(_string, _left));
                if ((_char > 8) && (_char < 14) || (_char == 32)) _left++; else break;
            }
            
            repeat (_right - _left)
            {
                // Offset right
                _char = ord(string_char_at(_string, _right));
                if ((_char > 8) && (_char < 14) || (_char == 32)) _right--; else break;
            }
            
            return string_copy(_string, _left, _right - _left + 1);
       };
    }    
    
    __set = function(_string)
    {
        _string = string(_string);
        
        if (!allow_newline)
        {
            if (!__on_windows)
            {
                // Filter carriage returns
                _string = string_replace_all(_string, chr(13), "");
            }
            
            if (__on_ios)
            {
                // Filter newlines
                _string = string_replace_all(_string, chr(10), " ");
            }
        }
        
        // Filter delete character (fixes Windows and Mac quirk)
        _string = string_replace_all(_string, chr(127), "");
        
        // Enforce length
        var _max = max_length + (__on_android? 1 : 0);
        _string = string_copy(_string, 1, _max);
        
        // Left pad one space (fixes Android quirk on first character)
        var _trim = (string_char_at(_string, 1) == " ");
        if (__on_android && !_trim)
        {
            // Set leading space
            _string = " " + _string;
            _trim = true;
        }
        
        // Update internal value
        if ((keyboard_string != _string) && ((__tick_last > (current_time - (delta_time div 1000) - 2)) || __just_ticked))
        {
            // Close keyboard on overflow (fixes iOS string setting quirk)
            if (__on_ios && (string_length(keyboard_string) > _max)) keyboard_virtual_hide();
            
            // Set inbuilt value if necessary
            keyboard_string = _string;
        }
 
        // Strip leading space
        if (__on_android && _trim) _string = string_delete(_string, 1, 1);
        
        // Search on change
        if (!__search_queue && (__value != _string) && (array_length(__search_list) != 0)) __search_queue = true;
        
        // Set internal value
        __value = _string;
        
        __just_ticked = false;
    };
    
    __submit = function()
    {
        if (auto_trim) __set(__trim(__value));
        
        if ((__callback != undefined) && ((__value != "") || allow_empty))
        {
            if (is_method(__callback))
            {
                // Execute method
                __callback();
            }
            else if (is_numeric(__callback) && script_exists(__callback))
            {
                // Execute script
                script_execute(__callback);
            }
            else
            {
                // Invalid callback
                show_error("Input String Error: Callback set to an illegal value (typeof=" + typeof(__callback) + ")", false);
            }
        }
    };
    
    __search_set = function(_array)
    {
        // Clear
        var _was_empty = (array_length(__search_list) == 0);
        array_delete(__search_list, 0, array_length(__search_list));
        
        // Stringify
        var _i = 0;
        repeat(array_length(_array))
        {
            __search_list[_i] = string(_array[_i]);
            ++_i;
        }
        
        // Search
        if (!__search_queue && !(_was_empty && (array_length(__search_list) == 0))) __search_queue = true;
    };
    
    __search = function()
    {
        if (__search_queue && (__search_last < (current_time - search_timeout)))
        {
            __search_queue = false;
            __search_last  = current_time;
            
            array_delete(__result_list, 0, array_length(__result_list));        
            if (__trim(__value) == "") return __result_list;
        
            var _find = __value;
            var _i = 0;
            if (!allow_case) 
            {
                // Any case
                _find = string_lower(_find);
                repeat(array_length(__search_list))
                {
                    if (string_pos(_find, string_lower(__search_list[_i])) > 0) array_push(__result_list, __search_list[_i]);
                    ++_i;
                }
            }
            else
            {
                // Match case
                repeat(array_length(__search_list))
                {
                    if (string_pos(_find, __search_list[_i]) > 0) array_push(__result_list, __search_list[_i]);
                    ++_i;
                }
            }
        }
        
        return __result_list;        
    };
    
    __submit_get = function()
    {
        var _virtual_submit = false;
        if (__async_id == undefined)
        {
            // Handle virtual keyboard submission
            if (__on_ios)
            {
                // iOS virtual keyboard submission
                _virtual_submit = ((ord(keyboard_lastchar) == 10) && (string_length(keyboard_string) > string_length(__value)));
            }
            else if (__on_xbox && !__just_set)
            {
                // Xbox virtual keyboard submission
                _virtual_submit = (keyboard_string != __value);
            }
            else if (__on_android && keyboard_check_pressed(10))
            {
                // Android virtual keyboard submission
                _virtual_submit = true;
            }
            else
            {
                // Virtual or hardware keyboard submission
                _virtual_submit = keyboard_check_pressed(vk_enter);
            }
        }
                
        return _virtual_submit;
    };
    
    __keyboard_hide = function()
    {
        if (__on_android || keyboard_virtual_status())
        {
            keyboard_virtual_hide();
        }
        else if (__use_steam)
        {        
            return steam_dismiss_floating_gamepad_text_input();
        }
    
        return undefined;
    };
    
    __tick = function()
    {
        if (__tick_last <= (current_time - (delta_time div 1000) - 2))
        {
            __just_ticked = true;
            __set(__value);
        }
        
        _virtual_submit = false;
        if (!__on_playstation && !__just_set && (__async_id == undefined))
        {
            // Manage text input
            var _string = keyboard_string;
            if ((_string == "") && (string_length(__value) > 1))
            {
                // Revert internal string when in overflow state
                _string = "";
            }
            
            _virtual_submit = __submit_get();          
            if (auto_closevkb && _virtual_submit)
            {
                // Close virtual keyboard on submission
                __keyboard_hide();
            }
            
            if (_string != "")
            {
                // Backspace key repeat (fixes lack-of on native Mac and Linux)
                if (__on_unix_native)
                {
                    if (__delete_duration > 0)
                    {
                        if (keyboard_check_pressed(vk_control) || keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_alt))
                        {
                            keyboard_clear(vk_backspace);
                        }
                        
                        // Repeat on hold, normalized against Windows. Timed in microseconds
                        var _repeat_rate = 33000;
                        if (!keyboard_check(vk_backspace))
                        {
                            __delete_duration = 0;
                        }
                        else if ((__delete_duration > 500000) && ((__delete_duration mod _repeat_rate) > ((__delete_duration + delta_time) mod _repeat_rate)))
                        {
                            _string = string_copy(_string, 1, string_length(_string) - 1);
                        }
                    }
                    
                    if (keyboard_check(vk_backspace)) __delete_duration += delta_time;
                }
            }
            
            __set(_string);
        }
                
        if (auto_submit && !__async_submit && (_virtual_submit || (!__on_playstation && keyboard_check_pressed(vk_enter)))) __submit();
        
        __async_submit = false;
        __just_set     = false;
        __tick_last    = current_time;
    };
    
    #endregion
    
        
    })(); return instance;
}

function input_string_max_length_set(_max_length)
{
    if (!is_numeric(_max_length) || (_max_length < 0) || (_max_length > 1024))
    {
        show_error
        (
            "Input String Error: Invalid value provided for max length: \"" 
                + string(_max_length) 
                + "\". Expected a value between 0 and 1024",
            true
        );

        return;
    }
    
    with (__input_string())
    {
        max_length = _max_length;
        
        // Respect hard-limit on Xbox GDK
        if (__on_xbox) max_length = max(max_length, 256);
        
        __set(string_copy(__value, 0, _max_length));
    }
}

function input_string_callback_set(_callback)
{
    if not (is_undefined(_callback) || is_method(_callback) || (is_numeric(_callback) && !script_exists(_callback)))
    {
        show_error
        (
            "Input String Error: Invalid value provided as callback: \"" 
                + string(_callback) 
                + "\". Expected a function or method.",
            true
        );
        
        return;
    }
    
    (__input_string()).__callback = _callback;
}

function input_string_set(_string = "")
{
    with (__input_string())
    {
        if (__on_ios)
        {
            // Close virtual keyboard if string is manually set (fixes iOS setting quirk)
            keyboard_virtual_hide();
        }
        
        __just_set = true;
        __set(_string);
    }
}

function input_string_add(_string)
{
    input_string_set((__input_string()).__value + string(_string));
}

function input_string_keyboard_show(_keyboard_type = kbv_type_default)
{
    var _steam = (__input_string()).__use_steam;
    
    // Note platform suitability
    var _source = input_string_platform_hint();
    if ((_source != "virtual") && !_steam) show_debug_message("Input String Warning: Onscreen keyboard is not suitable for use on the current platform");
    if  (_source == "async")               show_debug_message("Input String Warning: Consider using async dialog for modal text input instead");
    
    if ((__input_string()).__on_android || (!keyboard_virtual_status() && !(__input_string()).__on_xbox))
    {
        keyboard_virtual_show(_keyboard_type, kbv_returnkey_default, kbv_autocapitalize_sentences, false);
    }
    else if (_steam)
    {
        switch (_keyboard_type)
        {
            case kbv_type_email:   _keyboard_type = steam_floating_gamepad_text_input_mode_email;       break;
            case kbv_type_numbers: _keyboard_type = steam_floating_gamepad_text_input_mode_numeric;     break;
            default:               _keyboard_type = steam_floating_gamepad_text_input_mode_single_line; break;
        }
        
        return steam_show_floating_gamepad_text_input(_keyboard_type, display_get_width(), 0, 0, 0);
    }
    else
    {
         show_debug_message("Input String Warning: Onscreen keyboard not supported on the current platform");
    }
    
    return undefined;
}

function input_string_search_set(_array)
{
     // Coallesce
    _array = _array ?? [];
        
    if (!is_array(_array))
    {
        // Stringify
        _array = string(_array);
            
        // Wrap
        _array = [_array];
    }
        
    (__input_string()).__search_set(_array);
}

function input_string_tick()           { return (__input_string()).__tick();          }
function input_string_submit_get()     { return (__input_string()).__submit_get();    }
function input_string_force_submit()   { return (__input_string()).__submit();        }
function input_string_keyboard_hide()  { return (__input_string()).__keyboard_hide(); }
function input_string_search_results() { return (__input_string()).__search();        }
function input_string_platform_hint()  { return (__input_string()).__platform_hint;   }
function input_string_get()            { return (__input_string()).__value;           }