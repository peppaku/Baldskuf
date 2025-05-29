shader_type canvas_item;

uniform float outline_size : hint_range(1, 8) = 4.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // БЕЛЫЙ

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float alpha = tex.a;
    float outline = 0.0;

    // Проверка пикселей вокруг для outline
    for (float x = -outline_size; x <= outline_size; x++) {
        for (float y = -outline_size; y <= outline_size; y++) {
            vec2 offset = vec2(x, y) / TEXTURE_PIXEL_SIZE;
            outline = max(outline, texture(TEXTURE, UV + offset).a);
        }
    }

    // Если текущий пиксель прозрачный, но вокруг есть непрозрачный — рисуем контур
    if (alpha < 0.1 && outline > 0.1) {
        COLOR = outline_color;
    } else {
        COLOR = tex;
    }
}