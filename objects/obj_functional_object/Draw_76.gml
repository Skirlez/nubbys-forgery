if on_pre_draw == noone
	exit;
global.cmod = wod;
try {
	execute(on_pre_draw, id)
}
catch (e) {
	log_error($"{error_string} Pre-Draw: {pretty_error(e)}")
}