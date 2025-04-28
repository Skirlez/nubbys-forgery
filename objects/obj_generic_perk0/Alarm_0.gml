try {
	global.currently_executing_mod = perk.mod_of_origin;
	catspeak_execute_ext(perk.on_trigger, self)
}
catch (e) {
	log_error($"Perk {perk.string_id} errored on trigger: {e}")
}