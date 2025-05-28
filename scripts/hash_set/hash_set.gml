function hashset_create() {
	return ds_map_create()
}
function hashset_destroy(hashset) {
	ds_map_destroy(hashset)	
}
function hashset_size(hashset) {
	return ds_map_size(hashset)
}
function hashset_elements_array(hashset) {
	return ds_map_keys_to_array(hashset)
}
function hashset_put(hashset, element) {
	ds_map_set(hashset, element, 1)
}
function hashset_contains(hashset, element) {
	return ds_map_exists(hashset, element)
}
function hashset_clear(hashset) {
	ds_map_clear(hashset)	
}
function hashset_delete(hashset, element) {
	return ds_map_delete(hashset, element)
}
