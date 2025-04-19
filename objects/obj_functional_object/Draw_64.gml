if on_draw_gui == noone {
	exit
}
try {
	catspeak_execute_ext(on_draw_gui, self)
}
catch (e) {
	log($"Functional object {name} errored on Draw GUI: {e}")
}