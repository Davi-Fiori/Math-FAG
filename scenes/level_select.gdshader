shader_type canvas_item;

void fragment() {
    // Grab the original image data
    vec4 original_color = texture(TEXTURE, UV);
    
    // Force the color to pure white (1, 1, 1) but keep the original transparency shape (.a)
    COLOR = vec4(1.0, 1.0, 1.0, original_color.a);
}