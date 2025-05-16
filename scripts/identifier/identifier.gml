function mod_identifier(mod_id, string_id) {
	return $"{mod_id}:{string_id}"
}
function mod_is_id_valid(string_id) {
	return true; // TODO
}
function mod_is_id_component_valid(str) {
	// TODO
	return string_count(":", str) == 0
}
function mod_identifier_get_namespace(_id) {
	return string_split(_id, ":")[0]
}

