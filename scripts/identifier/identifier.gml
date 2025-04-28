function identifier(mod_id, string_id) {
	return $"{mod_id}:{string_id}"
}
function is_id_valid(string_id) {
	return true; // TODO
}

function split_id(string_id) {
	var split = string_split(string_id, ":", true, 1)
	return { namespace : split[0], resource : split[1] }
}