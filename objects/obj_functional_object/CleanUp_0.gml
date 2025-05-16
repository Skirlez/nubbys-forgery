if on_clean_up == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_clean_up, self)
}
catch (e) {
	log_error($"{error_string} Clean Up: {pretty_error(e)}")
}