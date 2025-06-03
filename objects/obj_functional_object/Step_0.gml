if on_step == noone
	exit;
global.cmod = wod;
try {
	execute(on_step, id)
}
catch (e) {
	log_error($"{error_string} Step: {pretty_error(e)}")
}