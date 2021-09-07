```
input-string

Multiplatform text entry utility for GameMaker Studio 2.3 with 
physical, virtual keyboard and modal support. Different platform
cases call for different text entry affordances, and input-string
provides a suggested source and unified handling for each.

input_string_tick
  function: Manages state (optional)
  usage: Once in Begin Step

input_string_get
   returns: String
   function: Serves managed text

input_string_set
  argument: String
  function: Sets managed text

input_string_platform_hint
   returns: String
   function: Serves entry method hint
   eg: “keyboard”, “virtual”, “async”
   
input_string_virtual_submit
   return: Boolean (Confirm)
   function: Serves virtual keyboard status
   requires: input_string_tick

input_string_async_get
  arguments: Dialog caption, Initial string (optional)
  returns: Boolean (Success)
  function: Opens modal dialog
  requires: input_string_dialog_async_event

input_string_dialog_async_event
   function: Managed dialog entry
   usage: Once in Dialog Async

input_string_async_active
   returns: Boolean
   function: Serves dialog status

Thanks: Juju, Elf, Nik
Discord: https://discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
```
