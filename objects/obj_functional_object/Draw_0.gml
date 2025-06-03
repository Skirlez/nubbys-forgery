if on_draw == noone {
	draw_self();
	exit;
}
global.cmod = wod
try {
	execute(on_draw, id)
}
catch (e) {
	log_error($"{error_string} Draw: {pretty_error(e)}")
}