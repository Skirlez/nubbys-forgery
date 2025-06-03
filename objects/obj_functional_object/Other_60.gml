if on_async_image_loaded == noone
	exit;
global.cmod = wod;
try {
	execute(on_async_image_loaded, id)
}
catch (e) {
	log_error($"{error_string} Async - Image Loaded: {pretty_error(e)}")
}