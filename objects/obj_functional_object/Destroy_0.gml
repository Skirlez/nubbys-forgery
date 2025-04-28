if on_destroy == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_destroy, self)
}
catch (e) {
	log_error($"{error_string} Destroy: {e}")
}