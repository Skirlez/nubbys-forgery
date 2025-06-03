if on_clean_up == noone
	exit;
global.cmod = wod;
try {
	execute(on_clean_up, id)
}
catch (e) {
	log_error($"{error_string} Clean Up: {pretty_error(e)}")
}