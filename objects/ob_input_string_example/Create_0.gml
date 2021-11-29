tick = true;
submission_test = "";
long_string = "";

repeat(INPUT_STRING.max_length) long_string += chr(ord("A") + irandom(25));

input_string_callback_set
(
    function()
    {
        var _string = input_string_get();
        self.submission_test = "Callback test @" + string(current_time) + ": " + _string;
        //input_string_set();
    }
);