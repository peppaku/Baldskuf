shader_type canvas_item;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float r = length(uv);
    float border = 0.45;
    float smooths = 0.15;
    float alpha = smoothstep(border, border - smooths, r);
    COLOR = vec4(1.0, 1.0, 0.0, alpha); // Жёлтый круг, настрой под себя
}