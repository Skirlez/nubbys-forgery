// This object is cloned by the merger script a lot.
// they are then allocated at runtime to different items.

allocated_id = real(string_digits(object_get_name(object_index)))
item = get_allocated_item(allocated_id)
try {
	item.on_create();
}
catch (e) {
	log($"Item {item.string_id} errored on creation: {e}")
	// TODO disable item
}