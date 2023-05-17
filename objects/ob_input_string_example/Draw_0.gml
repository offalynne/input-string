/// @description Test readout

draw_set_halign(fa_left);
draw_text(10, 30, "GM version " + GM_runtime_version);
draw_text(10, 10, "Last built " + date_time_string(GM_build_date));

draw_set_halign(fa_right);
draw_text(room_width - 10,  10, input_string_platform_hint()           +   "  source hint              ");
draw_text(room_width - 10,  30, string(string_length(keyboard_string)) +   "  string length            ");
draw_text(room_width - 10,  50, "\"" + keyboard_string                 + "\"  keyboard_string          ");
draw_text(room_width - 10,  70, "\"" + input_string_get()              + "\"  input_string_get()       ");
draw_text(room_width - 10,  90, string(keyboard_virtual_status())      +   "  keyboard_virtual_status()");
draw_text(room_width - 10, 110, string(keyboard_virtual_height())      +   "  keyboard_virtual_height()");
draw_text(room_width - 10, 130, string(input_string_submit_get())      +   "  input_string_submit_get()");

draw_set_halign(fa_center);
draw_text(room_width * .50, 10, "Tick " + (ticking? "On" : "Off"));
draw_text(room_width * .50, 30, submission_test);

// Search results
if (search_test_index >= 0) 
{
    var _search = input_string_search_results();
    draw_text(room_width / 2, room_height - 50, "Found " + string(array_length(_search)) + " of " + string(array_length(search_test_list[search_test_index])));
    
    var _a = [];
    var _i = 0;
    repeat(array_length(_search))
    {
        array_push(_a, search_test_list[search_test_index][_search[_i]]);
        ++_i;
    }
    
    _a = string(_a);
    _a = string_copy(_a, 2, string_length(_a) - 3);
    
    draw_text(room_width / 2, room_height - 30, _a);
}

// Test button labels
if (keyboard_virtual_status() == undefined) draw_set_color(c_gray);
draw_text(room_width * .33, 200, "Show OSK");
draw_text(room_width * .66, 200, "Hide OSK");

draw_set_color(c_white);
draw_text(room_width * .25, 400, "Fill String" );
draw_text(room_width * .50, 400, "Clear String");
draw_text(room_width * .75, 400, "Set Async"   );


