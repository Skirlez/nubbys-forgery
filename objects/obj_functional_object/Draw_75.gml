if on_draw_gui_end == noone
	exit;
global.cmod = wod;
try {
	execute(on_draw_gui_end, id)
}
catch (e) {
	log_error($"{error_string} Draw GUI End: {pretty_error(e)}")
}