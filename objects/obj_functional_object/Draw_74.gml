if on_draw_gui_begin == noone
	exit;
global.cmod = wod;
try {
	execute(on_draw_gui_begin, id)
}
catch (e) {
	log_error($"{error_string} Draw GUI Begin: {pretty_error(e)}")
}