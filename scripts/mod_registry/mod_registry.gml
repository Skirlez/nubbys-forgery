enum mod_resources {
	item,
	perk,
	supervisor,
	size,
}
global.resource_names = ["item", "perk", "supervisor"]

function registry_create() {
	return array_create_ext(mod_resources.size, function () { 
		return bimap_create();
	})
}

global.registry = registry_create();

function registry_destroy(registry) {
	for (var type = 0; type < mod_resources.size; type++) {
		bimap_destroy(registry[type]);
	}
}
function registry_clear(registry) {
	for (var type = 0; type < mod_resources.size; type++) {
		registry_clear_type(registry, type)
	}
}
function registry_clear_type(registry, type) {
	bimap_clear(registry[type]);
}
function mod_registry_left_exists(registry, type, left) {
	return bimap_left_exists(registry[type], left)
}
function mod_registry_right_exists(registry, type, right) {
	return bimap_right_exists(registry[type], right)
}

function mod_registry_get_left(registry, type, right) {
	return bimap_get_left(registry[type], right)
}
function mod_registry_get_right(registry, type, left) {
	return bimap_get_right(registry[type], left)
}
function mod_registries_exchange(from, to, type, left) {
	var right = bimap_get_right(from[type], left)
	return bimap_get_left(to[type], right)
}