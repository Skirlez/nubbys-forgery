if on_clean_up == noone
	exit
try {
	catspeak_execute_ext(on_clean_up, self)
}
catch (e) {
	log($"Functional object {name} errored on Clean Up: {e}")
}