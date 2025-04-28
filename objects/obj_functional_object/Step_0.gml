if on_step == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_step, self)
}
catch (e) {
	log_error($"{error_string} Step: {e}")
}