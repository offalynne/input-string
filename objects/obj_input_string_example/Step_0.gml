if (tick)
{
    input_string_tick();
}

//Pointer buttons
if (mouse_check_button_released(mb_any) && !input_string_async_active())
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

//Secondary tests
if (input_string_platform_hint() == "keyboard")
{
    if (keyboard_check_pressed(vk_f1))
    {
        //Append
        input_string_add(" add test");
    }
    
    if (keyboard_check_pressed(vk_f2))
    {
        //Manual submission
        input_string_submit();
    }    
    
    if (keyboard_check_pressed(vk_f3))
    {
        //Toggle tick
        tick = !tick;
    }
}