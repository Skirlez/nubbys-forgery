try {
	catspeak_execute_ext(item.on_step, self)
}
catch (e) {
	log($"Item {string_id} errored on step: {e}")
}