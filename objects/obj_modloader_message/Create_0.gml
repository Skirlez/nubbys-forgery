draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(agi("scr_LocalEqualFont")(agi("fnt_ComicSansMed")));

var padding = 15;
var text_width = string_width(text);
var text_height = string_height(text)
target_xscale = (text_width + padding) / sprite_width 
target_yscale = (text_height + padding) / sprite_height

timer = 0;
alpha = 0;
image_xscale = 0;
image_yscale = 0;