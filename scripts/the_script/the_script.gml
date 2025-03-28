


function modded_item(globals, mod_id) {
	var struct = {}
	var item_id = globals.item_id
	if (string_count(":", item_id) > 0)
		return result_error(new error("Forbidden character in item_id (:)"))
	struct.on_create = globals.on_create;
	struct.on_step = globals.on_step;
	struct.on_trigger = globals.on_trigger;
	
	return result_ok(item_id)
	
}

function user_mod(name, authors, items, perks) constructor {
	self.name = name;
	self.authors = authors;
	self.items = items;
	self.perks = perks;
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
	
	
	
	// DON'T PUT THIS ON RELEASE!!! THAT'D BE VERY BAD!!!!
	Catspeak.interface.exposeFunction("show_message", show_message)
}

function read_all_mods() {
	var folders = get_all_directories(global.mods_directory)
	for (var i = 0; i < array_length(folders); i++) {
		var mod_dir = global.mods_directory + folders[i] + "/"
		// load mod file
		var mod_definition_file = buffer_load(mod_dir + "mod.meow")
		var mod_definition_ir = Catspeak.parse(mod_definition_file);
		buffer_delete(mod_definition_file)
		var main = Catspeak.compile(mod_definition_ir);
		catspeak_execute(main);
		var globals = catspeak_globals(main);
		globals.on_load();
		/*
		var item_files = get_all_files(mod_dir, "meow")
		for (var i = 0; i < array_length(item_files); i++) {
			var file_path = mod_dir + item_files[i] + ".meow";
			var file = buffer_load(file_path)
			var ir = Catspeak.parse(file);
			buffer_delete(file)
			var main = Catspeak.compile(ir);
			catspeak_execute(main);
			var globals = catspeak_globals(main);
			var item = new modded_item(globals);
		}
		*/
	}
}