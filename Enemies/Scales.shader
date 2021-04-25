shader_type canvas_item;

uniform vec2 divs = vec2(10.0, 5.0);

void fragment() {
    vec4 tex_col = texture(TEXTURE, UV);
    float mask = texture(NORMAL_TEXTURE, UV).a;
    COLOR = tex_col;
    if (mask > .5) {

        vec3 col = vec3(0.0); 
        vec2 p = UV;
        p *= divs;
    
        // middle of x, edge of y
        vec2 ptA = vec2(floor(p.x) + 0.5, round(p.y));
        // middle of y, edge of x
        vec2 ptB = vec2(round(p.x), floor(p.y) + 0.5);
    
        float mixer1 = 0.;
        if (round(p.x) < p.x) mixer1 = 1.;
    
        vec2 tmpMixA = mix(ptB, ptA, mixer1);
        vec2 tmpMixB = mix(ptA, ptB, mixer1);
    
        vec2 subMixA = p - tmpMixA;
        vec2 subMixB = p - tmpMixB;
    
        float dA = distance(tmpMixA, p);
        float dB = distance(tmpMixB, p);
    
        float mixer2 = 0.;
        if (dB < 0.5) mixer2 = 1.;
    
        vec2 uv = mix(subMixA, subMixB, mixer2) * vec2(0., 1.) + vec2(0., 0.5);    
        float dist = mix(dA, dB, mixer2) * 3.; // 0 to 1

        col = vec3(uv, dist);
        COLOR = vec4(mix(col, tex_col.xyz, 0.6), mask);
        NORMAL = col;
    }
}