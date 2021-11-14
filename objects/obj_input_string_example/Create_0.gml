long_string = string_repeat("A", global.__input_string_max_length) + "Z";

callback_test = function()
{
    _string = input_string_get();
    show_message_async("Callback test @" + string(current_time) + ": " + _string);
    input_string_set();
}

input_string_callback_set(callback_test);
