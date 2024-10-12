shader_type canvas_item;

uniform sampler2D image : repeat_enable, filter_nearest;
uniform float rotations : hint_range(0.0, 10.0, 0.1);
uniform float depth : hint_range(0.0, 10.0, 0.1);
uniform float shrinkSpeed : hint_range(-10.0, 10.0, 0.1);
uniform float roationSpeed : hint_range(-10.0, 10.0, 0.1);

vec2 toPolar(vec2 cartesian){
	float distance = length(cartesian);
	float angle = atan(cartesian.y, cartesian.x) + PI;
	return vec2(angle / (2.0 * PI), distance);
}

void fragment() {
	vec2 offsetUV = vec2(UV.x - 0.5, UV.y - 0.5);
	
	vec2 polarUV = toPolar(offsetUV);
	polarUV.x *= rotations;
	polarUV.y *= depth;
	
	vec4 c = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 t = texture(image, vec2(polarUV.x + TIME * roationSpeed, polarUV.y + TIME * shrinkSpeed));
	c = t;
	
	COLOR = c;
}