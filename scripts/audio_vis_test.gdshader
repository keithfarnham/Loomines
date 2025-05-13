shader_type canvas_item;

const int VU_COUNT = 30;
const float segment_count = 40.0;

uniform float[VU_COUNT] freq_data;

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

void fragment() {
	vec2 uv = UV;
	uv.y = 1.0 - uv.y;
	float vu_count = float(VU_COUNT);
	vec2 pos = vec2(floor(uv.x * vu_count) / vu_count, floor(uv.y * segment_count) / segment_count);
	//vec2 pos = vec2(0.0, 0.0);
	float fft = freq_data[int(uv.x * vu_count)];
	vec3 color = mix(vec3(0.0, 2.0, 1.0), vec3(2.0, 0.0, 0.0), sqrt(uv.y));
	float mask = pos.y < fft ? 1.0 : 0.1;
	//vec2 dist = fract((uv - pos) * vec2(vu_count, segment_count)) - 0.5;
	float led = smoothstep(0.5, 0.35, abs(pos.x)) * smoothstep(0.5, 0.35, abs(pos.y));
	COLOR = vec4(led * color * mask, 1.0);
}

// void fragment() {
// 	vec2 uv = UV;
// 	uv = uv * 2.0 - vec2(1.0); // Transform UV to range [-1, 1]

// 	float circle = sdCircle(uv, 0.5); // Call sdCircle with radius 0.5
// 	float alpha = smoothstep(0.01, 0.0, circle); // Smooth transition for the circle edge

// 	vec3 color = vec3(0.0, 0.5, 1.0); // Set circle color
// 	COLOR = vec4(color, alpha); // Output color with alpha for the circle
// }