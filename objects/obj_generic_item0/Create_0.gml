allocated_id = real(string_digits(object_get_name(object_index)))
try {
	on_create();
}
catch (e) {
	log($"Item {string_id} errored on creation: {e}")
	// TODO disable item
}