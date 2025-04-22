if on_room_start == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_room_start, self)
}
catch (e) {
	log_error($"{error_string} Room Start: {e.message}")
}