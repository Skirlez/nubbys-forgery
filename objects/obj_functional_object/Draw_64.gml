if on_draw_gui == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_draw_gui, self)
}
catch (e) {
	log_error($"{error_string} Draw GUI: {e.message}")
}