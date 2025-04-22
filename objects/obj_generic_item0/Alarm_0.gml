try {
	global.currently_executing_mod = item.wod;
	catspeak_execute_ext(item.on_trigger, self)
}
catch (e) {
	log_error($"Item {item.string_id} errored on trigger: {e.message}")
}