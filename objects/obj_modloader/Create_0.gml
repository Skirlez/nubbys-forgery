global.empty_method = method(self, empty_function)

init()
expose_to_catspeak();

global.item_id_to_index_map = ds_map_create()
global.index_to_item_id_map = ds_map_create();

global.perk_id_to_index_map = ds_map_create()
global.index_to_perk_id_map = ds_map_create()

global.mod_id_to_mod_map = ds_map_create();

// used by functions called from catspeak
global.currently_executing_mod = noone;

create_modloader_happenings()
read_all_mods()

alarm[0] = 1

// prevents crash with devmode since this is for some reason set in step of an object and not in create
global.CursTar = -1


