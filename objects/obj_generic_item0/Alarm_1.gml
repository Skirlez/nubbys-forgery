try {
	catspeak_execute_ext(item.on_round_init, self)
}
catch (e) {
	log($"Item {item.string_id} errored on round initialization: {e}")
}