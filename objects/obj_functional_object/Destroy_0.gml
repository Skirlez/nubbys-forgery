if on_destroy == noone
	exit;
global.cmod = wod;
try {
	execute(on_destroy, id)
}
catch (e) {
	log_error($"{error_string} Destroy: {pretty_error(e)}")
}