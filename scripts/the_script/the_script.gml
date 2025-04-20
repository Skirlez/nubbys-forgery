#macro agi asset_get_index

function create_mod(buffer) {
	static mod_contract = {
		string_id : "",
		display_name : "",
		description : "",
		version : "",
		modloader_version : 0,
		on_load : global.empty_method,
		on_unload : global.empty_method,
	}
	
	var ir = Catspeak.parse(buffer);
	var main = Catspeak.compile(ir);
	catspeak_execute(main);
	var globals = catspeak_globals(main);
	
	var discompliance = get_struct_discompliance_with_contract(globals, mod_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		return new result_error(new generic_error(
			"Mod definition file has bad variables!\n" 
			+ generate_discompliance_error_text(globals, mod_contract, discompliance)
		))
	}
	
	globals.items = ds_map_create();
	globals.perks = []
	globals.foods = []
	globals.sprites = []
	globals.translations = ds_map_create();
	globals.sprites = ds_map_create();
	globals.audio_streams = ds_map_create();
	
	// TODO check invalid characters
	return new result_ok(globals)
}


function init() {
	global.mods_directory = game_save_id + "mods/";
	catspeak_force_init()
}

function unload_mod(wod) {
	try {
		wod.on_unload();
	}
	catch (e) {
		log($"Mod {wod.string_id} errored while unloading: {e}")
	}
	ds_map_destroy(wod.items);
	var translation_keys = ds_map_keys_to_array(wod.translations)
	for (var j = 0; j < array_length(translation_keys); j++) {
		ds_grid_destroy(ds_map_find_value(wod.translations, translation_keys[j]))	
	}
	ds_map_destroy(wod.translations)
		
	var sprite_keys = ds_map_keys_to_array(wod.sprites)
	for (var j = 0; j < array_length(sprite_keys); j++) {
		sprite_delete(ds_map_find_value(wod.sprites, sprite_keys[j]))	
	}
	ds_map_destroy(wod.sprites)
		
	var audio_stream_keys = ds_map_keys_to_array(wod.audio_streams)
	for (var j = 0; j < array_length(audio_stream_keys); j++) {
		audio_destroy_stream(ds_map_find_value(wod.audio_streams, audio_stream_keys[j]))	
	}
	ds_map_destroy(wod.audio_streams)
}


function clear_all_mods() {
	var mods = ds_map_values_to_array(global.mod_id_to_mod_map)
	for (var i = 0; i < array_length(mods); i++) {
		var wod = mods[i]
		unload_mod(wod)
	}
	ds_map_clear(global.mod_id_to_mod_map)
}

// Reads all mods and returns a list of their structs
function read_all_mods() {
	clear_all_mods();
	
	var folders = get_all_directories(global.mods_directory)
	for (var i = 0; i < array_length(folders); i++) {

		var mod_dir = global.mods_directory + folders[i] + "/"
		// load mod file
		var mod_buffer = buffer_load(mod_dir + "mod.meow")
		var mod_result = create_mod(mod_buffer)	
		buffer_delete(mod_buffer)
		
		if mod_result.is_error() {
			log(mod_result.error)
			continue;
		}
		var wod = mod_result.value;
		array_push(global.mods, wod);
		ds_map_set(global.mod_id_to_mod_map, wod.string_id, wod);
	
		var sprites_dir = mod_dir + "sprites/";
		var sprites_buffer = buffer_load(sprites_dir + "sprites.meow")
		load_mod_sprites(sprites_buffer, sprites_dir, wod.string_id)

		var items_dir = mod_dir + "items/";
		var items_buffer = buffer_load(items_dir + "items.meow")
		load_mod_items(items_buffer, items_dir, wod.string_id)
		/*
		var items = ds_map_values_to_array(wod.items)
		for (var j = 0; j < array_length(items); j++) {
			var item = items[j];
			load_item(item)
		}
		*/
		
		
		// we're gonna assume there's only 1 en.csv for now
		var trans_dir = mod_dir + "trans/";
		//var csv_files = get_all_files(trans_dir, "csv")
		/*for (var i = 0; i < array_length(item_files); i++)*/ {
			var file_path = trans_dir + "en.csv";
			var translation = load_csv(file_path)
			ds_map_add(wod.translations, "en", translation)
		}
		
		try {
			wod.on_load();
		}
		catch (e) {
			log($"Mod {wod.string_id} errored on load: {e}")
			// TODO what to do
		}
		
		
	}
}



// called from gml_Object_obj_ItemMGMT_Create_0
function register_items() {
	free_all_allocated_item_objects()
	
	ds_map_clear(global.item_id_to_index_map)
	ds_map_clear(global.index_to_item_id_map)
	for (var i = 0; i < array_length(global.mods); i++) {
		var wod = global.mods[i];
		var items = ds_map_values_to_array(wod.items)
		for (var j = 0; j < array_length(items); j++) {			
			var item = items[j];
			
			var item_number_id = array_length(agi("obj_ItemMGMT").ItemID)
			var obj = allocate_object_for_item(item)
			object_set_sprite(obj, item.sprite)
			
			agi("scr_Init_Item")(item_number_id,
				agi("scr_Text")(item.display_name),
				obj,
				item.level, 
				item.type, 
				item.tier, 
				item.status,
				item.effect_id, 
				item.pool, 
				item.offset_price, 
				item.upgrade_item_id, 
				item.trigger_condition, 
				item.alt_trigger_condition,
				agi("scr_Text")(item.description, "\n"))
			agi("scr_Init_ItemExt")(item_number_id, 
				item.odds_weight_early, item.odds_weight_mid, item.odds_weight_end)
			
			ds_map_set(global.item_id_to_index_map, get_full_item_id(item), item_number_id)
			ds_map_set(global.index_to_item_id_map, item_number_id, get_full_item_id(item))
		}
	}
	// we need to pass over this array after all items have been registered
	// so we can then resolve the temporary upgrade item ID we put in and replace it with
	// an index ID
	var item_pair_arr = agi("obj_ItemMGMT").ItemPair
	for (var i = 0; i < array_length(item_pair_arr); i++) {
		if !is_string(item_pair_arr[i])
			continue;
		if !ds_map_exists(global.item_id_to_index_map, item_pair_arr[i]) {
			log($"Item {ds_map_find_value(global.index_to_item_id_map, i)} has {item_pair_arr[i]} set"
				+ " as its upgrade, but it does not exist!")
			// TODO figure out what to do about the item in this case
		}
		item_pair_arr[i] = ds_map_find_value(global.item_id_to_index_map, item_pair_arr[i])
	}
	
}

function is_console_and_devmode_enabled() {
	return true;	
}
function reroll_cheats_enabled() {
	return true;	
}