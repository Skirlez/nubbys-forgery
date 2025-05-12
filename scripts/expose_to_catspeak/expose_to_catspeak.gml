
function expose_to_catspeak() {
	// One of the goals of this project is to not limit what mods can do.
	// The worst thing enabling this can do is allow mods to delete saved scores,
	// but since scores are saved in a different folder, and GameMaker has a sandboxed filesystem,
	// your base game scores cannot be touched.
	
	// (This causes an Ubuntu crash. IDK why. The real game is on proton on steam anyways so who cares.)
	Catspeak.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
}

// since alarm is a fake array it doesn't work in catspeak, so i've made these functions to help
// (you can still use with() and alarm_get/set but that's annoying)
function alarm_get_instance(instance, number) {
	return instance.alarm[number];
}
function alarm_set_instance(instance, number, count) {
	instance.alarm[number] = count;
}