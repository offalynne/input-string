draw_set_halign(fa_right);
draw_text(room_width - 10, 10, "\"" + input_string_platform_hint() + "\" source hint");
draw_text(room_width - 10, 30, string(string_length(keyboard_string))     +" string length");

draw_text(room_width - 10, 50, "\"" + keyboard_string    + "\" keyboard_string   ");
draw_text(room_width - 10, 70, "\"" + input_string_get() + "\" input_string_get()");

draw_text(room_width - 10, 90, "\"" + string(keyboard_virtual_status()) + "\" keyboard_virtual_status()");
draw_text(room_width - 10, 110,"\"" + string(keyboard_virtual_height()) + "\" keyboard_virtual_height()");

//Test button labels
draw_set_halign(fa_center);
draw_text(room_width*.33, 200, "Show OSK"  );
draw_text(room_width*.66, 200, "Hide OSK"  );

draw_text(room_width*.25, 400, "Fill String" );
draw_text(room_width*.50, 400, "Clear String");
draw_text(room_width*.75, 400, "Set Async"   );