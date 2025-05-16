if item.on_round_init == noone
	return;
global.currently_executing_mod = mod_of_origin;
try {
	catspeak_execute_ext(item.on_round_init, self)
}
catch (e) {
	log_error($"Item {string_id} errored on round initialization: {pretty_error(e)}")
}