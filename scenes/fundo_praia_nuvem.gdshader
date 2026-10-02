shader_type canvas_item;

uniform float scroll_speed = 0.05;
uniform float custom_alpha : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec2 shifteduv = UV;
    shifteduv.x += TIME * scroll_speed;
    
    // Read the moving texture, then apply our custom alpha
    vec4 moving_texture = texture(TEXTURE, shifteduv);
    moving_texture.a *= custom_alpha;
    
    // Output directly, ignoring Godot's default COLOR completely
    COLOR = moving_texture;
}