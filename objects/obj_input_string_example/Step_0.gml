input_string_tick();

//Pointer buttons
if (mouse_check_button_released(mb_any) && !input_string_async_is_active())
{
    var _x = device_mouse_x(0);
    if (device_mouse_y(0) < 300)
    {
        //Top row
        if (_x < (room_width/2))
        {
            keyboard_virtual_show(kbv_type_default, kbv_returnkey_default, kbv_autocapitalize_none, false);
        }
        else
        {
            keyboard_virtual_hide();
        }
    }
    else
    {
        //Bottom row
        switch(_x == 0 ? 0 : _x div (room_width/3))
        {
            case 0: input_string_set(long_string);          break;
            case 1: input_string_set();                     break;            
            case 2: input_string_async_get("Test Caption"); break;            
        }
    }
}

//Close virtual keyboard on submit
if (!is_undefined(keyboard_virtual_status()) && !input_string_async_is_active())
{
    //On iOS
    if ((os_type == os_ios) || (os_type == os_tvos))
    {
        if ((keyboard_lastkey == 10) && (keyboard_lastkey != keyboard_lastkey_previous))
        {
            keyboard_virtual_hide();
            input_string_set(string_delete(input_string_get(), string_length(input_string_get()), 1));
        }
    }
    else
    {
        //Off iOS
        if (keyboard_check_pressed(vk_enter))
        {
            keyboard_virtual_hide();
        }
    }
}

keyboard_lastkey_previous = keyboard_lastkey;