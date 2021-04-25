shader_type canvas_item;
render_mode unshaded;


void fragment() {
    // Get per-instance state stashed in the MODULATE uniform
    vec4 m = MODULATE;
    float phase = m.x;

    float t = TIME + 100.0 * phase;

    vec2 uv = UV;
    uv.x += 0.05 * (pow(uv.y, 2.0) * sin(2.0 * (0.5 * t + uv.y * 10.0) + 6.0 * sin(5.0 * uv.x)));

    float intensity = pow(sin(10.0 * uv.y + sin(20.0 * uv.x + 0.7 * t) + 0.3 * t), 2.0);
    intensity = 0.4 + 0.6 * intensity;
    intensity *= texture(TEXTURE, uv).a;

    vec3 base_col = texture(NORMAL_TEXTURE, uv).xyz;

    float blue = 0.6 + 0.4 * pow(sin(uv.x + t), 2.0);
    float green = 0.6 + 0.4 * pow(sin(uv.y + 1.1 * t), 2.0);
    vec3 lum_col = vec3(0.4, green, blue);

    vec3 col = base_col * lum_col;

    COLOR = vec4(col, 1.5 * intensity);
}
