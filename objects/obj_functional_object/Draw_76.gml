if on_pre_draw == noone {
	exit
}
try {
	catspeak_execute_ext(on_pre_draw, self)
}
catch (e) {
	log($"Functional object {name} errored on Pre-Draw: {e}")
}