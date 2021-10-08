function input_string_platform_hint()
{
    if ((os_type == os_switch) || (os_type == os_xboxone) || (os_type == os_xboxseriesxs) || (os_type == os_ps4) || (os_type == os_ps5)) 
    || ((os_browser != browser_not_a_browser) && !((os_type == os_macosx) || (os_type == os_windows) || (os_type == os_linux)))
    {
        //On console, or non-desktop web
        return "async";
    }
    else if (((os_type == os_uwp) && uwp_device_touchscreen_available()) || (os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos))
    {
        //Native mobile
        return "virtual";
    }
    else
    {
        return "keyboard";
    }
    
    show_error("Input String Error: Failed to identify platform text source", true);
}
