try {
	on_trigger()	
}
catch (e) {
	log($"Item {string_id} errored on trigger: {e}")
}