if on_post_draw == noone {
	exit
}
try {
	catspeak_execute_ext(on_post_draw, self)
}
catch (e) {
	log($"Functional object {name} errored on Pre-Draw: {e}")
}