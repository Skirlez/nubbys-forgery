if on_room_start == noone
	exit;
global.cmod = wod;
try {
	execute(on_room_start, id)
}
catch (e) {
	log_error($"{error_string} Room Start: {pretty_error(e)}")
}