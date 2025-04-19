if on_step == noone
	exit
try {
	catspeak_execute_ext(on_step, self)
}
catch (e) {
	log($"Functional object {name} errored on Step: {e}")
}