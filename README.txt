input-string

Multiplatform text entry utility for GameMaker Studio 2.3 with 
physical, virtual keyboard and modal support. Different 
platform cases call for different text entry affordances; 
input-string provides a suggested source and unified handling
for each.

input_string_get
   function: Serves managed text
   returns: String

input_string_set
  function: Sets managed text
  arguments: String

input_string_tick
  function: Manages state, `keyboard_string`
  usage: Once in Begin Step (Optional)

input_string_platform_hint
   function: Serves entry method hint
   returns: String (Hint)
   eg: “keyboard”, “virtual”, “async”
   
input_string_virtual_submit
   function: Serves virtual keyboard status
   returns: Boolean (State)
   requires: input_string_tick

input_string_async_get
  function: Opens modal dialog
  arguments: Caption, String (Optional)
  returns: Boolean
  requires: input_string_dialog_async_event

input_string_async_active
   function: Serves dialog status
   returns: Boolean

input_string_dialog_async_event
   function: Dialog entry manager
   usage: Once in Dialog Async (Optional)

Thanks: Juju, Elf, Nik
Discord: https://discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
