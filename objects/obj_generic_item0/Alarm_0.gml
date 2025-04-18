try {
	item.on_trigger()	
}
catch (e) {
	log($"Item {item.string_id} errored on trigger: {e}")
}