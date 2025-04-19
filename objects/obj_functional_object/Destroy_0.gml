if on_destroy == noone
	exit
try {
	catspeak_execute_ext(on_destroy, self)
}
catch (e) {
	log($"Functional object {name} errored on Destroy: {e}")
}