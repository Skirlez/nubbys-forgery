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
			"Mod defintion file has bad variables!\n" 
			+ generate_discompliance_error_text(globals, mod_contract, discompliance)
		))
	}
	
	globals.items = []
	globals.perks = []
	globals.foods = []
	globals.sprites = []
	
	// TODO check invalid characters
	return new result_ok(globals)
}


function create_modded_item(buffer, filename, mod_id) {
	static item_contract = {
		string_id : "",
		display_name : "",
		description : "",
		trigger_text : "",
		alt_trigger_text : "",
		sprite : "",
		level : 0,
		tier : 0,
		status : 0,
		effect_id : "",
		pool : 0,
		offset_price : 0,
		mutant_item_id : "",
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
			$"Item defintion file {filename} has bad variables!\n" 
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


function get_all_files(dir, ext) {
	var files = [];
	var file_name = string_replace(file_find_first(dir + "*." + ext, fa_none), "." + ext, "");
	while (file_name != "") {
		array_push(files, file_name);
		file_name = string_replace(file_find_next(),  "." + ext, "");
	}
	file_find_close(); 
	return files;
}

function get_all_directories(dir) {
	var directories = [];
	var directory_name = file_find_first(dir + "*", fa_directory);
	while (directory_name != "") {
		array_push(directories, directory_name);
		directory_name = file_find_next();
	}
	file_find_close(); 
	return directories;
}

function expose_things_to_catspeak() {
	Catspeak.interface.exposeFunction("instance_exists", instance_exists)
	Catspeak.interface.exposeFunction("get_happening", get_happening)
	
	
	// DON'T PUT THIS ON RELEASE!!! THAT'D BE VERY BAD!!!!
	Catspeak.interface.exposeFunction("show_message", show_message)
}


// Reads all mods and returns a list of their structs
function read_all_mods() {
	var mods = []
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
		array_push(mods, wod);	
	
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
		
		try {
			wod.on_load();
		}
		catch (e) {
			log($"Mod {wod.string_id} errored on load: {e}")	
		}
	}
	return mods;
}

// called from gml_Object_obj_ItemMGMT_Create_0
function register_items() {
	
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
				1, 
				item.tier, 
				item.status,
				item.effect_id, 
				item.pool, 
				item.offset_price, 
				item.mutant_item_id, 
				item.trigger_text, 
				item.alt_trigger_text,
				agi("scr_Text")(item.description, "\n"))
			agi("scr_Init_ItemExt")(item_number_id, 
				item.odds_weight_early, item.odds_weight_mid, item.odds_weight_end)
		}
	}
	
}