input-string

Multiplatform text entry utility for GameMaker Studio 2

A robust alternative to inbuilt `keyboard_string` usage.

INPUT_STRING.*

get
  function: Serves managed text
  returned: String

set
  function: Sets managed text
  argument: String (Optional)

add
  function: Adds to managed text
  argument: String (Optional)
  
callback_set
  function: Sets submission callback
  requires: input_​string_​tick
  argument: Function (Optional)

virtual_submit
  function: Serves virtual keyboard submission
  requires: input_​string_​tick
  returned: Boolean

tick
  function: Manages state and `keyboard_string`
  in event: Begin Step (Once, Optional)

async_get
  function: Opens modal dialog
  requires: input_​string_​dialog_​async_​event
  argument: Caption, Default String (Optional)
  returned: Boolean

async_active
  function: Serves dialog status
  requires: input_​string_​dialog_​async_​event
  returned: Boolean

dialog_async_event
  function: Dialog entry manager
  in event: Dialog Async (Once, Optional)

platform_hint
  function: Serves entry method hint
  returned: String (Hint)
  possible: "keyboard", "virtual", "async"

Thanks to: @JujuAdams, @tabularelf, @nkrapivin
Community: discord.gg/8krYCqr

@offalynne, 2021
MIT licensed, use as you please
