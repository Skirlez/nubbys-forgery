function nf_catspeak_set_globals(callee, globals){
    if (is_catspeak(callee)) {
        if (method_get_index(callee) == __catspeak_function_method__) {
            // TODO
        } else {
            return callee.setGlobals(globals);
        }
    }
    return undefined;
}