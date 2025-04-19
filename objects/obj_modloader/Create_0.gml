global.empty_method = method(self, empty_function)
global.test = "hello"
init()
expose_to_catspeak();

global.mods = []
read_all_mods()

global.item_id_to_index_map = ds_map_create();
global.index_to_item_id_map = ds_map_create();
alarm[0] = 1

// prevents crash with devmode since this is for some reason set in step of an object and not in create
global.CursTar = -1


