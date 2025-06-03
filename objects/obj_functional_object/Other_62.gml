if on_async_http == noone
	exit;
global.cmod = wod;
try {
	execute(on_async_http, id)
}
catch (e) {
	log_error($"{error_string} Async - HTTP: {pretty_error(e)}")
}