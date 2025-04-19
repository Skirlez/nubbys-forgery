if on_begin_step == noone
	exit
try {
	catspeak_execute_ext(on_begin_step, self)
}
catch (e) {
	log($"Functional object {name} errored on Begin Step: {e}")
}