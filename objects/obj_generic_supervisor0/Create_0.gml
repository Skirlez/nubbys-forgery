// This object is cloned by the merger script a lot, but all of them run the same event code.

// We need to determine at runtime what number object we are:
allocated_id = real(string_digits(object_get_name(object_index)))

// These objects are allocated to different items.
// Get the supervisor this object is allocated to
supervisor = get_allocated_object(allocatable_objects.supervisor, allocated_id)
// This supervisor struct determines how this object behaves.


// Get the supervisor's index ID. Though none of them use it. But might as well get it,
// as perks and items do.
SVID = ds_map_find_value(global.supervisor_to_index_map, supervisor)

try {
	global.currently_executing_mod = supervisor.mod_of_origin;
	catspeak_execute_ext(supervisor.on_create, self)
}
catch (e) {
	log_error($"Supervisor {supervisor.string_id} errored on creation: {e}")
	// TODO leave game?
}