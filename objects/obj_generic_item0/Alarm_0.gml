global.cmod = mod_of_origin;
try {
	execute(item.on_trigger, id)
}
catch (e) {
	log_error($"Item {string_id} errored on trigger: {pretty_error(e)}")
}