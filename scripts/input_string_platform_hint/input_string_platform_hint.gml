function input_string_platform_hint()
{
    if (((os_type == os_switch) || (os_type == os_xboxone) || (os_type == os_xboxseriesxs) || (os_type == os_ps4) || (os_type == os_ps5)) 
    || !((os_type == os_macosx) || (os_type == os_windows) || (os_type == os_linux)) && ((os_browser != browser_not_a_browser))
    {
        //On console, or non-desktop web
        return "async";
    }
    else if ((uwp_device_touchscreen_available() && (os_type == os_uwp)) || (os_type == os_android) || (os_type == os_ios) || (os_type == os_tvos))
    {
        //Native mobile
        return "virtual";
    }
    else
    {
        return "keyboard";
    }
    
    show_error("Input String: Failed to identify platform text source", true);
}
