if item.on_step == noone
	return;
try {
	global.currently_executing_mod = item.mod_of_origin;
	catspeak_execute_ext(item.on_step, self)
}
catch (e) {
	log_error($"Item {string_id} errored on step: {e}")
}