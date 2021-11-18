INPUT_STRING.tick();

//Pointer buttons
if (mouse_check_button_released(mb_any) && !INPUT_STRING.async_active())
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
            case 0: INPUT_STRING.set(long_string);          break;
            case 1: INPUT_STRING.set();                     break;
            case 2: INPUT_STRING.async_get("Test Caption"); break;
        }
    }
}  