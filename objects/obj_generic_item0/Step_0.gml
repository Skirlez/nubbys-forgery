if item.on_step == noone
	return;
global.cmod = mod_of_origin;
try {
	execute(item.on_step, id)
}
catch (e) {
	log_error($"Item {string_id} errored on step: {pretty_error(e)}")
}