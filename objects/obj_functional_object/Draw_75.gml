if on_draw_gui_end == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_draw_gui_end, self)
}
catch (e) {
	log_error($"{error_string} Draw GUI End: {e}")
}