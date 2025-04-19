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