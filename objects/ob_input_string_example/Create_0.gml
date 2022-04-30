tick = true;
submission_test = "";
long_string = "";

repeat((__input_string()).max_length) long_string += chr(ord("A") + irandom(25));

input_string_trigger_set
(
    function()
    {
        var _string = input_string_get();
        self.submission_test = "Trigger test @" + string(current_time) + ": " + _string;
        //input_string_set(); // Clear on return
    }
);
