if on_draw_end == noone
	exit;
global.cmod = wod;
try {
	execute(on_draw_end, id)
}
catch (e) {
	log_error($"{error_string} Draw End: {pretty_error(e)}")
}