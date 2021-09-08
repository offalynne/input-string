input-string

Multiplatform text entry utility for GameMaker Studio 2.3.
A robust alternative for using inbuilt `keyboard_string`.

input_string_get
   function: Serves managed text
   argument: None
   returned: String

input_string_set
  function: Sets managed text
  argument: String (Optional)

input_string_tick
  function: Manages state and `keyboard_string`
  in event: Begin Step (Once, Optional)

input_string_dialog_async_event
   function: Dialog entry manager
   in event: Dialog Async (Once, Optional)

input_string_async_get
  function: Opens modal dialog
  argument: Caption, Default String (Optional)
  returned: Boolean
  requires: input_string_dialog_async_event

input_string_async_active
   function: Serves dialog status
   returned: Boolean

input_string_platform_hint
   function: Serves entry method hint
   returned: String (Hint)
   possible: “keyboard”, “virtual”, “async”

Thanks: Juju, Elf, Nik
Discord: https://discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
