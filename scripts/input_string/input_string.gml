function __input_string()
{
    // Self initialize
    static instance = new (function() constructor {
        
    #region Configuration
    
    auto_closevkb = true;   // Whether the 'Return' key closes the virtual keyboard
    auto_submit   = true;   // Whether the 'Return' key fires a submission callback
    auto_trim     = true;   // Whether submit trims leading and trailing whitespace
    
    allow_empty   = false;  // Whether a blank field submission is treated as valid
    allow_newline = false;  // Whether to allow newline characters or swap to space
    
    max_length = 1000;  // Maximum text entry string length. Do not exceed 1024
    
    #endregion
    
    #region Initialization
    
    __predialog = "";
    __value     = "";
    
    __backspace_hold_duration  = 0;
    __tick_last                = 0;
    
    __callback  = undefined;
    __async_id  = undefined;
    
    __virtual_submit = false;
    __async_submit   = false;
    __just_ticked    = false;
    __use_steam      = false;
    __just_set       = false;
    
    __keyboard_supported = ((os_type == os_operagx) || (os_browser != browser_not_a_browser)
                         || (os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux)
                         || (os_type == os_android) || (os_type == os_switch) || (os_type == os_uwp)
                         || (os_type == os_tvos) || (os_type == os_ios));
                         
    // Steamworks
    try
    {
        // Try Steam setup
        steam_dismiss_floating_gamepad_text_input();
        __use_steam = true;
        show_debug_message("Input String: Using Steamworks extension")
    }
    catch(_error)
    {
        // In absence of Steam extension
        show_debug_message("Input String: Not using Steamworks extension")
    }
    
    // Set platform hint
    if ((os_type == os_xboxone) || (os_type == os_xboxseriesxs) 
    ||  (os_type == os_switch)  || (os_type == os_ps4) || (os_type == os_ps5))
    {
        // Suggest 'async' (dialog) on console
        __platform_hint = "async";
    }
    else if ((os_browser != browser_not_a_browser)
         &&  ((os_type != os_windows) && (os_type != os_macosx) 
         &&   (os_type != os_operagx) && (os_type != os_linux)))
    {
        // Suggest 'async' (dialog) on non-desktop web
        __platform_hint = "async";
    }
    else if ((os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos)
         ||  (uwp_device_touchscreen_available() && (os_type == os_uwp)))
    {
        // Suggest virtual keyboard on mobile
        __platform_hint = "virtual";
    }
    else
    {
        __platform_hint = "keyboard";
    }
    
    #endregion
    
    #region Utilities
    
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
    
    
    __set = function(_string)
    {
        _string = string(_string);
        
        if (!allow_newline)
        {
            if (os_type != os_windows)
            {
                // Filter carriage returns
                _string = string_replace_all(_string, chr(13), "");
            }
            
            if ((os_type == os_ios) || (os_type == os_tvos))
            {
                // Filter newlines
                _string = string_replace_all(_string, chr(10), " ");
            }
        }
        
        if (string_pos(chr(0x7F), _string) > 0)
        {
            // Filter delete character (fixes Windows and Mac quirk)
            _string = string_replace_all(_string, chr(0x7F), "");
        }
        
        // Enforce length
        var _max = max_length + ((os_type == os_android)? 1 : 0);
        _string = string_copy(_string, 1, _max);
        
        // Left pad one space (fixes Android quirk on first character)
        var _trim = (string_char_at(_string, 1) == " ");
        if ((os_type == os_android) && !_trim)
        {
            // Set leading space
            _string = " " + _string;
            _trim = true;
        }
        
        //Update internal value
        if ((keyboard_string != _string) 
        &&  ((__tick_last > (current_time - (delta_time div 1000) - 2)) || __just_ticked))
        {
            if (((os_type == os_ios) || (os_type == os_tvos))
            &&  (string_length(keyboard_string) > _max))
            {
                // Close keyboard on overflow (fixes iOS string setting quirk)
                keyboard_virtual_hide();
            }
            
            // Set inbuilt value if necessary
            keyboard_string = _string;
        }
        
        __just_ticked = false;
        __value = _string;
        
        if ((os_type == os_android) && _trim)
        {
            //Strip leading space
            __value = string_delete(__value, 1, 1);
        }
    };
    
    
    __submit = function()
    {
        if (auto_trim)
        {
            __set(__trim(input_string_get()));
        }
        
        if ((__callback != undefined) 
        && ((input_string_get() != "") || allow_empty))
        {
            if (is_method(__callback))
            {
                __callback();
            }
            else if (is_numeric(__callback) && script_exists(__callback))
            {
                script_execute(__callback);
            }
            else
            {
                show_error("callback set to an illegal value (typeof=" + typeof(__callback) + ")", false);
            }
        }
    };
    
    
    __tick = function()
    {
        if (__tick_last <= (current_time - (delta_time div 1000) - 2))
        {
            __just_ticked = true;
            __set(__value);
        }
        
        if (__keyboard_supported && !__just_set && (__async_id == undefined))
        {
            // Manage text input
            var _string = keyboard_string;
            if ((_string == "") && (string_length(__value) > 1))
            {
                // Revert internal string when in overflow state
                _string = "";
            }
            
            __virtual_submit = false;
            if (!input_string_async_active())
            {            
                // Handle virtual keyboard submission
                if ((os_type == os_ios) || (os_type == os_tvos))
                {
                    __virtual_submit = ((ord(keyboard_lastchar) == 10) 
                                     && (string_length(keyboard_string) > string_length(value)));
                }
                else if ((os_type == os_android) && keyboard_check_pressed(10))
                {
                    __virtual_submit = true;
                }
                else
                {
                    // Keyboard submission
                    __virtual_submit = keyboard_check_pressed(vk_enter);
                }             
            
                if (auto_closevkb && __virtual_submit)
                {
                    // Close virtual keyboard on submission
                    input_string_keyboard_hide();
                }
            }
            
            if (_string != "")
            {
                // Backspace key repeat (fixes lack-of on native Mac and Linux)
                if ((os_browser == browser_not_a_browser) 
                &&  (os_type == os_macosx) || (os_type == os_linux))
                {
                    if (__backspace_hold_duration > 0)
                    {
                        // Repeat on hold, normalized against Windows. Timed in microseconds
                        var _repeat_rate = 33000;
                        if (!keyboard_check(vk_backspace))
                        {
                            __backspace_hold_duration = 0;
                        }
                        else if ((__backspace_hold_duration > 500000)
                             && ((__backspace_hold_duration mod _repeat_rate) > ((__backspace_hold_duration + delta_time) mod _repeat_rate)))
                        {
                            _string = string_copy(_string, 1, string_length(_string) - 1);
                        }
                    }
                    
                    if (keyboard_check(vk_backspace))
                    {
                        __backspace_hold_duration += delta_time;
                    }
                }
            }
            
            __set(_string);
        }
        __just_set = false;
                
        if (auto_submit && !__async_submit
        && (__virtual_submit || (__keyboard_supported && keyboard_check_pressed(vk_enter))))
        {
            __submit();
        }
        
        __async_submit = false;
        __tick_last = current_time;
    }
    
    #endregion
        
    })(); return instance;
}

function input_string_max_length_set(_max_length)
{
    if (!is_numeric(_max_length) || _max_length < 0
    || (_max_length > (__input_string()).max_length))
    {
        show_error
        (
            "Input String Error: Invalid value provided for max length: \"" 
                + string(_max_length) 
                + "\". Expected a value between 0 and "
                + string((__input_string()).max_length),
            true
        );
    }
    
    with (__input_string())
    {
        max_length = _max_length;
        set(string_copy(__value, 0, _max_length));
    }
}

function input_string_callback_set(_callback = undefined)
{    
    if (!is_undefined(_callback) && !is_method(_callback)
    && (!is_numeric(_callback) || !script_exists(_callback)))
    {
        show_error
        (
            "Input String Error: Invalid value provided as callback: \"" 
                + string(_callback) 
                + "\". Expected a function or method.",
            true
        );
    }
    
    with (__input_string()) __callback = _callback;
}

function input_string_set(_string = "")
{
    if ((os_type == os_ios) || (os_type == os_tvos))
    {
        // Close virtual keyboard if string is manually set (fixes iOS setting quirk)
        keyboard_virtual_hide();
    }
    
    with (__input_string())
    {
        __just_set = true;
        __set(_string);
    }
}

function input_string_add(_string)
{
    input_string_set((__input_string()).value + string(_string));
}

function input_string_keyboard_show(_keyboard_type = kbv_type_default)
{
    var _steam = (__input_string()).__use_steam;
    
    // Note platform suitability
    var _source = input_string_platform_hint();
    if ((_source != "virtual") && !_steam) show_debug_message("Input String Warning: Onscreen keyboard is not suitable for use on the current platform");
    if  (_source == "async")               show_debug_message("Input String Warning: Consider using async dialog for modal text input instead");
    
    if ((keyboard_virtual_show != undefined) && script_exists(keyboard_virtual_show) 
    && ((os_type == os_android) || !keyboard_virtual_status()))
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
   
function input_string_keyboard_hide()
{
    var _steam = (__input_string()).__use_steam;    
    if ((keyboard_virtual_show != undefined)
    && ((os_type == os_android) || keyboard_virtual_status())
    &&   script_exists(keyboard_virtual_show))
    {
        keyboard_virtual_hide();
    }
    else if (_steam)
    {        
        return steam_dismiss_floating_gamepad_text_input();
    }
    
    return undefined;
}

function input_string_virtual_submit() { gml_pragma("forceinline"); return (__input_string()).__virtual_submit; }
function input_string_platform_hint()  { gml_pragma("forceinline"); return (__input_string()).__platform_hint;  }
function input_string_submit()         { gml_pragma("forceinline"); return (__input_string()).__submit();       }
function input_string_tick()           { gml_pragma("forceinline"); return (__input_string()).__tick();         }
function input_string_get()            { gml_pragma("forceinline"); return (__input_string()).__value;          }
