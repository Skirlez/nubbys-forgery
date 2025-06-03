if on_post_draw == noone
	exit;
global.cmod = wod;
try {
	execute(on_post_draw, id)
}
catch (e) {
	log_error($"{error_string} Pre-Draw: {pretty_error(e)}")
}