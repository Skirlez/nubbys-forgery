if on_room_end == noone
	exit;
global.cmod = wod;
try {
	execute(on_room_end, id)
}
catch (e) {
	log_error($"{error_string} Room End: {pretty_error(e)}")
}