if on_post_draw == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_post_draw, self)
}
catch (e) {
	log_error($"{error_string} Pre-Draw: {pretty_error(e)}")
}