
// Make it so modders can pass in whatever trigger condition they want
// TARGET: LINENUMBER
// 7
default:
    scr_ItemMetaOrder(argument0)
    scr_PerkMetaOrder(argument0)
    scr_StatusMetaOrder(argument0)
    break;

// trigger "on_game_event" happening

// TARGET: LINENUMBER
// 5
get_happening("on_game_event").trigger({ event_name : arg0 })
