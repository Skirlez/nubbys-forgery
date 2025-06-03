function get_all_files(dir, ext) {
	var files = [];
	var file_name = string_replace(file_find_first(dir + "/*." + ext, fa_none), "." + ext, "");
	while (file_name != "") {
		array_push(files, file_name);
		file_name = string_replace(file_find_next(),  "." + ext, "");
	}
	file_find_close(); 
	return files;
}

function get_all_directories(dir) {
	var directories = [];
	var directory_name = file_find_first(dir + "/*", fa_directory);
	while (directory_name != "") {
		array_push(directories, directory_name);
		directory_name = file_find_next();
	}
	file_find_close(); 
	return directories;
}


function remove_file_extension(name) {
	var arr = string_split(name, ".", true, 1)
	if array_length(arr) == 0
		return name
	return arr[0]
}
function get_file_extension(name) {
	var arr = string_split(name, ".", true)
	if array_length(arr) == 0
		return ""
	return arr[array_length(arr) - 1];
}

enum code_file_types {
	gml,
	catspeak,
}

function mod_get_code_type(path) {
	var extension = get_file_extension(path)
	if extension == "meow"
		return code_file_types.catspeak;
	else
		return code_file_types.gml;
}
