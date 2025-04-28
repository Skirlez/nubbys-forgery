if on_pre_draw == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_pre_draw, self)
}
catch (e) {
	log_error($"{error_string} Pre-Draw: {e}")
}