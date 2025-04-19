if on_draw == noone {
	draw_self()
	exit
}
try {
	catspeak_execute_ext(on_draw, self)
}
catch (e) {
	log($"Functional object {name} errored on Draw: {e}")
}