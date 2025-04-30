function log_error(text) {
	show_debug_message(text)
	log_udp(text)
}
function log_info(text) {
	show_debug_message(text)
	log_udp(text)
}

function log_udp(text) {
	var buffer = buffer_create(string_length(text) + 1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, text);
	network_send_udp_raw(global.logging_socket, "127.0.0.1", 1235, buffer, buffer_tell(buffer))
	buffer_delete(buffer)
}