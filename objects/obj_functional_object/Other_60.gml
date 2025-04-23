if on_async_image_loaded == noone
	exit;
global.currently_executing_mod = wod;
try {
	catspeak_execute_ext(on_async_image_loaded, self)
}
catch (e) {
	log_error($"{error_string} Async - Image Loaded: {e.message}")
}