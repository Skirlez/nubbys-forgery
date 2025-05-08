global.empty_method = method(self, empty_function)

global.mods_directory = game_save_id + "mods";
catspeak_force_init();

expose_to_catspeak();

global.item_id_to_index_map = ds_map_create()
global.index_to_item_id_map = ds_map_create();

global.perk_id_to_index_map = ds_map_create()
global.index_to_perk_id_map = ds_map_create()

global.supervisor_to_index_map = ds_map_create()
global.index_to_supervisor_map = ds_map_create()

global.mod_id_to_mod_map = ds_map_create();

global.logging_socket = network_create_socket(network_socket_udp)
log_info("****************\nModloader start\n****************")

// used by functions called from catspeak
global.currently_executing_mod = noone;

read_all_mods()

alarm[0] = 1

// prevents crash with devmode since this is for some reason set in step of an object and not in create
global.CursTar = -1


