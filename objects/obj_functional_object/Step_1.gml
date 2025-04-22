if on_begin_step == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_begin_step, self)
}
catch (e) {
	log_error($"{error_string} Begin Step: {e.message}")
}