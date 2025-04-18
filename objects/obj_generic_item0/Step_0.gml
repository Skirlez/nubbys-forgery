try {
	item.on_step()	
}
catch (e) {
	log($"Item {string_id} errored on step: {e}")
}