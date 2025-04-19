if on_room_end == noone
	exit
try {
	catspeak_execute_ext(on_room_end, self)
}
catch (e) {
	log($"Functional object {name} errored on Room End: {e}")
}