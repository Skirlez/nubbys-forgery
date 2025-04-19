if on_draw_begin == noone {
	exit
}
try {
	catspeak_execute_ext(on_draw_begin, self)
}
catch (e) {
	log($"Functional object {name} errored on Draw GUI: {e}")
}