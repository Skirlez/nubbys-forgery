if on_draw_gui == noone
	exit;
global.cmod = wod;
try {
	execute(on_draw_gui, id)
}
catch (e) {
	log_error($"{error_string} Draw GUI: {pretty_error(e)}")
}