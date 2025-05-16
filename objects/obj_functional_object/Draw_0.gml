if on_draw == noone {
	draw_self();
	exit;
}
global.currently_executing_mod = wod
try {
	catspeak_execute_ext(on_draw, self)
}
catch (e) {
	log_error($"{error_string} Draw: {pretty_error(e)}")
}