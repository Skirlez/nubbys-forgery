if item.on_step == noone
	return;
global.currently_executing_mod = mod_of_origin;
try {
	catspeak_execute_ext(item.on_step, self)
}
catch (e) {
	log_error($"Item {string_id} errored on step: {pretty_error(e)}")
}