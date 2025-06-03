// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the supervisor this object is allocated to
supervisor = get_resource_allocated_to_object(mod_resources.supervisor, allocated_id)
// This supervisor struct determines how this object behaves.


// Get the supervisor's index ID. Though none of them use it. But might as well get it,
// as perks and items do.
SVID = bimap_get_left(global.index_registry[mod_resources.supervisor], supervisor)

// Get its string ID, for logging
string_id = bimap_get_left(global.registry[mod_resources.supervisor], supervisor)

mod_of_origin = ds_map_find_value(global.mod_id_to_mod_map, mod_identifier_get_namespace(string_id))



global.cmod = mod_of_origin;
try {
	execute(supervisor.on_create, id)
}
catch (e) {
	log_error($"Supervisor {string_id} errored on creation: {pretty_error(e)}")
	// TODO leave game?
}