if on_draw_end == noone {
	exit
}
try {
	catspeak_execute_ext(on_draw_end, self)
}
catch (e) {
	log($"Functional object {name} errored on Draw End: {e}")
}