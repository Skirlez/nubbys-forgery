try {
	global.currently_executing_mod = item.wod;
	catspeak_execute_ext(item.on_step, self)
}
catch (e) {
	log_error($"Item {string_id} errored on step: {e.message}")
}