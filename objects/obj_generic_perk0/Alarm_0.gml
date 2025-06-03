global.cmod = mod_of_origin
try {
	execute(perk.on_trigger, id)
}
catch (e) {
	log_error($"Perk {string_id} errored on trigger: {pretty_error(e)}")
}