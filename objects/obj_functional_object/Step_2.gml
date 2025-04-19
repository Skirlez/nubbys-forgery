if on_end_step == noone
	exit
try {
	catspeak_execute_ext(on_end_step, self)
}
catch (e) {
	log($"Functional object {name} errored on End Step: {e}")
}