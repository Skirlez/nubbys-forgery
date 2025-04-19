try {
	catspeak_execute_ext(item.on_trigger, self)
}
catch (e) {
	log($"Item {item.string_id} errored on trigger: {e}")
}