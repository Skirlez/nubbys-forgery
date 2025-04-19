// This object is meant to be used by modders if they want to add an object to their game.
// It has events for almost everything you'd need from a regular object.

if on_create == noone
	exit
try {
	catspeak_execute_ext(on_create, self)
}
catch (e) {
	log($"Functional object {name} errored on Create: {e}")
	instance_destroy(id)
}