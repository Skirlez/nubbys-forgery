if on_room_end == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_room_end, self)
}
catch (e) {
	log_error($"{error_string} Room End: {e.message}")
}