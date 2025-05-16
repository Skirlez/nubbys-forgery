if on_async_http == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_async_http, self)
}
catch (e) {
	log_error($"{error_string} Async - HTTP: {pretty_error(e)}")
}