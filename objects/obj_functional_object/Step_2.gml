if on_end_step == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_end_step, self)
}
catch (e) {
	log_error($"{error_string} End Step: {pretty_error(e)}")
}