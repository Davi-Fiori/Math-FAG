shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Black outline
uniform float outline_width : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
    float sprite_alpha = texture(TEXTURE, UV).a;
    
    // Check all 8 neighboring directions (Cardinals + Diagonals)
    float max_alpha = sprite_alpha;
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, 0.0)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, -size.y)).a);
    
    // Diagonals for smooth corners
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(size.x, -size.y)).a);
    max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-size.x, -size.y)).a);
    
    vec4 col = texture(TEXTURE, UV);
    if (sprite_alpha == 0.0 && max_alpha > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = col;
    }
}