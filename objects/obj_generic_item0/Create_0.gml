try {
	on_create();
}
catch (e) {
	log($"Item {string_id} errored on creation: {e}")
	// TODO disable item
}