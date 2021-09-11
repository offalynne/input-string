input-string

Multiplatform text entry utility for GameMaker Studio 2.3.

A robust alternative to inbuilt `keyboard_string` usage.

input_​string_​get
  function: Serves managed text
  argument: None
  returned: String

input_​string_​set
  function: Sets managed text
  argument: String (Optional)

input_​string_​virtual_​submit
  function: Serves virtual keyboard state
  requires: input_​string_​tick

input_​string_​tick
  function: Manages state and `keyboard_​string`
  in event: Begin Step (Once, Optional)

input_​string_​async_​get
  function: Opens modal dialog
  requires: input_​string_​dialog_​async_​event
  argument: Caption, Default String (Optional)
  returned: Boolean

input_​string_​async_​active
  function: Serves dialog status
  requires: input_​string_​dialog_​async_​event
  returned: Boolean

input_​string_​dialog_​async_​event
  function: Dialog entry manager
  in event: Dialog Async (Once, Optional)

input_​string_​platform_​hint
  function: Serves entry method hint
  returned: String (Hint)
  possible: “keyboard”, “virtual”, “async”

Thanks to: Juju, Elf, Nik
Community: discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
