submission_test = "";
long_string = "";

repeat(INPUT_STRING.max_length) long_string += chr(ord("A") + irandom(25));

INPUT_STRING.callback_set
(
    function()
    {
        var _string = INPUT_STRING.get();
        self.submission_test = "Callback test @" + string(current_time) + ": " + _string;
        //input_string_set();
    }
);