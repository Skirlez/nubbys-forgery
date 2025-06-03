if on_end_step == noone
	exit;
global.cmod = wod;
try {
	execute(on_end_step, id)
}
catch (e) {
	log_error($"{error_string} End Step: {pretty_error(e)}")
}