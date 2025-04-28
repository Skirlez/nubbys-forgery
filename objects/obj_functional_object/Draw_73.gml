if on_draw_end == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_draw_end, self)
}
catch (e) {
	log_error($"{error_string} Draw End: {e}")
}