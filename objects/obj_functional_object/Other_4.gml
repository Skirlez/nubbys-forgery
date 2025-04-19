if on_room_start == noone
	exit
try {
	catspeak_execute_ext(on_room_start, self)
}
catch (e) {
	log($"Functional object {name} errored on Room Start: {e}")
}