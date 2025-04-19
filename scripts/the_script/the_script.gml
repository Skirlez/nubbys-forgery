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
	
	globals.items = []
	globals.perks = []
	globals.foods = []
	globals.sprites = []
	globals.translations = ds_map_create();
	
	// TODO check invalid characters
	return new result_ok(globals)
}


function create_modded_item(buffer, filename, mod_id) {
	static item_contract = {
		string_id : "",
		display_name : "",
		description : "",
		trigger_condition : "",
		alt_trigger_condition : "",
		sprite : "",
		level : 0,
		type : 0,
		tier : 0,
		status : 0,
		effect_id : "",
		pool : 0,
		offset_price : 0,
		upgrade_item_id : "",
		odds_weight_early : 0,
		odds_weight_mid : 0,
		odds_weight_end : 0,
		on_create : global.empty_method,
		on_step : global.empty_method,
		on_trigger : global.empty_method,
	}

	
	var struct = {}
	
	var ir = Catspeak.parse(buffer);
	var main = Catspeak.compile(ir);
	catspeak_execute(main);
	var globals = catspeak_globals(main);
	
	
	var discompliance = get_struct_discompliance_with_contract(globals, item_contract)
	if array_length(discompliance.missing) > 0 || array_length(discompliance.mismatched_types) > 0 {
		return new result_error(new generic_error(
			$"Item definition file {filename} has bad variables!\n" 
			+ generate_discompliance_error_text(globals, item_contract, discompliance)
		))
	}
	
	
	var item_id = globals.string_id
	if (string_count(":", item_id) > 0)
		return result_error(new generic_error("Forbidden character in item_id (:)"))

	
	return new result_ok(globals)
}


function init() {
	global.mods_directory = game_save_id + "mods/";
	catspeak_force_init()
}

function clear_all_mods() {
	for (var i = 0; i < array_length(global.mods); i++) {
		var wod = global.mods[i];
		var keys = ds_map_keys_to_array(wod.translations)
		for (var j = 0; j < array_length(keys); j++) {
			ds_grid_destroy(ds_map_find_value(wod.translations, keys[i]))	
		}
		ds_map_clear(wod.translations)
	}
	// the rest can be automatically garbage collected
	global.mods = []
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
			
	
		var items_dir = mod_dir + "items/";
		var item_files = get_all_files(items_dir, "meow")
		for (var i = 0; i < array_length(item_files); i++) {
			var file_path = items_dir + item_files[i] + ".meow";
			var item_buffer = buffer_load(file_path)
			var result_item = create_modded_item(item_buffer, item_files[i], wod.string_id)
			buffer_delete(item_buffer)
			if result_item.is_error() {
				log($"{result_item.error}")
				continue;
			}
			array_push(wod.items, result_item.value)
		}
		
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
			continue;
		}
		array_push(global.mods, wod);
	}
}

// called from gml_Object_obj_ItemMGMT_Create_0
function register_items() {
	free_all_allocated_items()
	
	ds_map_clear(global.item_id_to_index_map)
	ds_map_clear(global.index_to_item_id_map)
	for (var i = 0; i < array_length(global.mods); i++) {
		var wod = global.mods[i];
		for (var j = 0; j < array_length(wod.items); j++) {
			var item = wod.items[j];
			var item_number_id = array_length(agi("obj_ItemMGMT").ItemID)
			var obj = allocate_object_for_item(item)
			
			object_set_sprite(obj, agi(item.sprite))
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
			
			
			ds_map_set(global.item_id_to_index_map, item.string_id, item_number_id)
			ds_map_set(global.index_to_item_id_map, item_number_id, item.string_id)
		}
	}
	// we need to pass over this array after all items have been registered
	// so we can then resolve the temporary upgrade item ID we put in and replace it with
	// an index ID
	var item_pair_arr = agi("obj_ItemMGMT").ItemPair
	for (var i = 0; i < array_length(item_pair_arr); i++) {
		if !is_string(item_pair_arr[i])
			continue
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