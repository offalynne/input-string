input-string

Multiplatform text entry utility for GameMaker Studio 2

A robust alternative to inbuilt `keyboard_string` usage.

input_string_get
  function: Serves managed text
  returned: String

input_string_set
  function: Sets managed text
  argument: String (Optional)

input_string_add
  function: Adds to managed text
  argument: String
  
input_string_callback_set
  function: Sets submission callback
  argument: Function (Optional)

input_string_submit
  function: Performs string submission

input_string_platform_hint
  function: Serves entry method hint
  returned: String (Hint)
  possible: "keyboard", "virtual", "async"

input_string_virtual_submit
  function: Serves virtual keyboard submission
  requires: input_​string_​tick
  returned: Boolean

input_string_tick
  function: Manages state and `keyboard_string`
  in event: Step (Once, Optional)

input_string_async_get
  function: Opens modal dialog
  requires: input_​string_​dialog_​async_​event
  argument: Caption, Default String (Optional)
  returned: Boolean

input_string_async_active
  function: Serves dialog status
  requires: input_​string_​dialog_​async_​event
  returned: Boolean

input_string_dialog_async_event
  function: Dialog entry manager
  in event: Dialog Async (Once, Optional)

For configuration, see input_string.gml

Thanks to: @JujuAdams, @tabularelf, @nkrapivin
Community: discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
