function log_error(text) {
	show_debug_message(text)
	log_udp(text)
	show_message(text)
}
function log_info(text) {
	show_debug_message(text)
	log_udp(text)
}

function log_udp(text) {
	var buffer = buffer_create(string_length(text) + 1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, text);
	network_send_udp_raw(global.logging_socket, "127.0.0.1", 1235, buffer, buffer_tell(buffer) - 1)
	buffer_delete(buffer)
}
// For catspeak
function log() {
	var text;
	if argument_count == 0
		text = ""
	else
		text = argument0
	for (var i = 1; i < argument_count; i++) {
		text += " " + argument[i];
	}
	log_info($"[{global.currently_executing_mod.mod_id}] {text}")
}