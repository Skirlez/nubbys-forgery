if on_draw_gui_end == noone {
	exit
}
try {
	catspeak_execute_ext(on_draw_gui_end, self)
}
catch (e) {
	log($"Functional object {name} errored on Draw GUI End: {e}")
}