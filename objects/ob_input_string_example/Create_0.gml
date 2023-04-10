/// @description Test setup

long_string = "";
repeat((__input_string()).max_length)
{
    // Fill with garbage
    long_string += chr(ord("A") + irandom(25));
}

callback = function()
{
    var _string = input_string_get();
    self.submission_test = "Callback test @" + string(current_time) + ": " + _string;        
    //input_string_set(); // Clear on submission
};

submission_test = "";
input_string_callback_set(callback);

// Initial ticking state. Set to true for user ease,
// but suggest testing at false to be comprehensive.
ticking = true;
