try {
	global.currently_executing_mod = item.wod;
	catspeak_execute_ext(item.on_round_init, self)
}
catch (e) {
	log_error($"Item {item.string_id} errored on round initialization: {e.message}")
}