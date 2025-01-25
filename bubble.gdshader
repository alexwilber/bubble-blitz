shader_type canvas_item;

uniform float time : hint_range(0.0, 10.0); // Time for animation
uniform float base_intensity : hint_range(0.0, 0.05) = 0.01; // Subtle distortion while idle
uniform float movement_intensity : hint_range(0.0, 0.2) = 0.1; // Distortion while moving
uniform float squish_intensity : hint_range(0.0, 1.0) = 0.5; // Squishing intensity
uniform vec2 velocity; // Character velocity passed from script
uniform float squish_factor; // Squish animation factor, controlled by GDScript

void fragment() {
    // Get UV coordinates
    vec2 uv = UV;

    // Center point for distortion (middle of the sprite)
    vec2 center = vec2(0.5, 0.5);

    // Calculate offset from the center
    vec2 offset = uv - center;

    // Base bubbling distortion (always active)
    float base_ripple = sin(length(offset) * 8.0 - time * 2.0) * base_intensity;
    vec2 base_distortion = offset * base_ripple;

    // Movement-based distortion (depends on velocity)
    vec2 velocity_effect = velocity * 0.005; // Scale velocity for effect
    vec2 movement_distortion = offset * dot(velocity_effect, offset) * movement_intensity;

    // Squish distortion: scales vertically and compensates horizontally to preserve bounds
    vec2 squish_distortion = vec2(0.0, 0.0);
    if (squish_factor > 0.0) {
        float vertical_scale = 1.0 - squish_factor * squish_intensity; // Compress vertically
        float horizontal_scale = 1.0 + squish_factor * squish_intensity * 0.5; // Stretch horizontally
        offset.y *= vertical_scale;
        offset.x *= horizontal_scale;
    }

    // Combine base, movement, and squish distortions
    uv = center + offset + base_distortion + movement_distortion;

    // Sample the texture with the modified UV
    COLOR = texture(TEXTURE, uv);
}
