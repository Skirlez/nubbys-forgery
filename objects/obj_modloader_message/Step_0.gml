image_xscale = lerp(image_xscale, target_xscale, 0.3)
image_yscale = lerp(image_yscale, target_yscale, 0.3)

timer++;
if (global.CursTar == id && timer > 10 && global.B_Press)
	instance_destroy(id);
if timer >= death_time
	instance_destroy(id);

if timer > 12 && alpha < 1  {
	alpha += 0.08
}