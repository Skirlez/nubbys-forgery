global.currently_executing_mod = mod_of_origin
try {
	catspeak_execute_ext(perk.on_trigger, self)
}
catch (e) {
	log_error($"Perk {string_id} errored on trigger: {pretty_error(e)}")
}