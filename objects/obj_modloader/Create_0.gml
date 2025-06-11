global.empty_method = method(self, empty_function)
global.mod_id_to_mod_map = ds_map_create();
global.logging_socket = network_create_socket(network_socket_udp)
global.mods_directory = game_save_id + "mods";

initialize_catspeak_gmlspeak();

global.cmod = noone;

global.sound_count = 0;
while (audio_exists(global.sound_count))
	global.sound_count++;
global.sprite_count = 0;
while (sprite_exists(global.sprite_count))
	global.sprite_count++;


log_info("****************\nModloader start\n****************")
read_all_mods()

if is_console_and_devmode_enabled()
	alarm[0] = 1

// prevents crash with devmode since this is for some reason set in step of an object and not in create
global.CursTar = -1

run_delayed = [];
function add_to_run_delayed(frames, func, wod) {
	array_push(run_delayed, { time : frames, func : func, mod_of_origin : wod })
}
function remove_mod_from_run_delayed(wod) {
	var len = array_length(run_delayed);
	for (var i = 0; i < len; i++) {
		if run_delayed[i].mod_of_origin == wod {
			array_delete(run_delayed, i, 1)
			len--;
			i--;
		}
	}
}
function iterate_run_delayed() {
	var len = array_length(run_delayed);
	for (var i = 0; i < len; i++) {
		var struct = run_delayed[i];
		struct.time--;
		if struct.time <= 0 {
			struct.func();
			array_delete(run_delayed, i, 1)
			len--;
			i--;
		}
	}
}
