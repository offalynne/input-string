submission_test = "";
long_string = string_repeat("A", INPUT_STRING.max_length) + "Z";

input_string_callback_set
(
    function()
    {
        var _string = input_string_get();
        self.submission_test = "Callback test @" + string(current_time) + ": " + _string;
        //input_string_set();
    }
);