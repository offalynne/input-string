/// @description Test cycle

if (mouse_check_button_released(mb_any) && !input_string_async_active())
{
    // Pointer buttons
    var _x = device_mouse_x(0);
    if (device_mouse_y(0) < 300)
    {
        if (_x < (room_width/2))
        {
            // Show OSK
            input_string_keyboard_show();
        }
        else
        {
            // Hide OSK
            input_string_keyboard_hide();
        }
    }
    else
    {
        switch((_x <= 0)? 0 : _x div (room_width/3))
        {
            // Primary tests
            case 0: input_string_set(long_string);          break; // Fill String
            case 1: input_string_set();                     break; // Clear String
            case 2: input_string_async_get("Test Caption"); break; // Set Async
        }
    }
}

if (input_string_platform_hint() == "keyboard")
{
    // Secondary tests
    if (keyboard_check_pressed(vk_f1))
    {
        // Append, force tick
        input_string_add(" add test");
        input_string_tick();
    }
    
    if (keyboard_check_pressed(vk_f2))
    {
        // Manual submission
        input_string_submit();
    }
    
    if (keyboard_check_pressed(vk_f3))
    {
        // Toggle tick
        ticking = !ticking;
    }
    
    if (keyboard_check_pressed(vk_f4))
    {
        // Toggle max-length
        input_string_max_length_set(32);
    }
}

if (ticking)
{
    input_string_tick();
}
