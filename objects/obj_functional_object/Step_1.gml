if on_begin_step == noone
	exit;
global.cmod = wod;
try {
	execute(on_begin_step, id)
}
catch (e) {
	log_error($"{error_string} Begin Step: {pretty_error(e)}")
}