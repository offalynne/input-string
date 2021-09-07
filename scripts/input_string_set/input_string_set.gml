function input_string_set(_string = "")
{
    var _trim = false;
    _string = string(_string);
    
    if (global.__input_string_keyboard_supported)
    {
        //Enforce length limit
        _string = string_copy(_string, 1, global.__input_string_max_length);
        
        if ((os_type == os_android) && (string_char_at(_string, 1) != " "))
        {
            //Set leading space
            _string = " " + _string;
            _trim = true;
        }
        
        //Set inbuilt value if necessary
        if (global.__input_string_tick_last != undefined && keyboard_string != _string)
        {
            keyboard_string = _string;
        }
        
        global.__input_string_prev = _string;
    }
    
    //Set internal string
    global.__input_string = _string;
    
    if (_trim)
    {
        //Trim leading space
        global.__input_string = string_delete(global.__input_string, 1, 1);
    }
}
