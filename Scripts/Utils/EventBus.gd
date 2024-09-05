extends Node

signal on_game_save()
signal on_game_load()

signal cursor_reset()

signal cursor_display(action: String)
signal cursor_request(action: String, key_code: int)
#signal cursor_shape(shape: CustomCursor.CursorState)
signal cursor_color(color: Color)

signal round_start()
signal turn_done(who: int)
signal round_done()
