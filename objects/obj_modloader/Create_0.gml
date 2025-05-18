global.empty_method = method(self, empty_function)

global.mods_directory = game_save_id + "mods";
catspeak_force_init();

expose_to_catspeak();

global.mod_id_to_mod_map = ds_map_create();

global.logging_socket = network_create_socket(network_socket_udp)

global.currently_executing_mod = noone;

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

