function input_string_async_get(_prompt, _string = global.__input_string)
{
    //Warn dialog platform suitability
    var _source = input_string_platform_hint();
    if (_source != "async")   show_debug_message("Input String: Async dialog is not suitable for use on the current platform");
    if (_source == "virtual") show_debug_message("Input String: Consider showing the virtual keyboard for non-modal text input instead");
       
    //Issue modal request when not awaiting response
    if (global.__input_string_async_id != undefined)
    {
        show_debug_message("Input String: Dialog prompt refused: awaiting callback ID \"" + string(global.__input_string_async_id) + "\"");
        return false;
    }
    else
    {
        //Enforce Switch character limit
        if (os_type == os_switch)
        {
            _string = string_copy(_string, 1, 500);
        }
        
        global.__input_string_async_id    = get_string_async(_prompt, _string);
        global.__input_string_predialogue = input_string_get();
        return true;
    }
    
    show_error("Input String: Failed to issue async dialog", true);
}
