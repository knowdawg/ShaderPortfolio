shader_type canvas_item;

uniform float layers : hint_range(1.0, 20.0, 1.0); //How many layers of the fractal
uniform float rotationSpeed : hint_range(0.0, 2.0, 0.1); //Speed the layers spin at
uniform float speed : hint_range(0.1, 5.0, 0.1); //Speed of the sin wave
uniform float glow : hint_range(0.0, 0.05, 0.001); //Glow Intensity
uniform float zoom : hint_range(0.0, 5.0, 0.1); //How many times the fractal subdiides
uniform float shapeSize : hint_range(0.1, 2.0, 0.1); //Size of the given sined distance shape
uniform float isTransparent : hint_range(0.0, 1.0, 1.0); //Transparency Toggle

vec3 palette(float t){
	vec3 a = vec3(0.5, 0.5, 0.5);
	vec3 b = vec3(0.5, 0.5, -0.5);
	vec3 c = vec3(0.5, 0.5, 0.5);
	vec3 d = vec3(1.898, 0.718, -3.1);
	
	return a + b * cos(6.28318 * (c * t + d));
}

//Rotation Matrix
mat2 rotate(float angle){
	mat2 r = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	return r;
}

//
float sdHexagon( in vec2 p, in float r ){
	vec3 k = vec3(-0.866025404,0.5,0.577350269);
	p = abs(p);
	p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
	p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
	return length(p) * sign(p.y);
}

float sdLength(in vec2 p){
	//return length(p); //Circle
	return sdHexagon(p, shapeSize);
	//return UV;
}

void fragment() {
	vec2 clipUV = UV * 2.0 - 1.0;
	vec2 iResolution = 1.0 / TEXTURE_PIXEL_SIZE;
	clipUV.x *= iResolution.x / iResolution.y;
	vec2 uv0 = clipUV;
	
	vec3 finalColor = vec3(0.0);
	
	vec2 temp = clipUV;
	
	for(float i = 1.0; i < layers + 1.0; i++){
		clipUV = rotate(TIME * rotationSpeed * (i - 1.0)) * clipUV;
		temp = clipUV;
		
		clipUV = fract(clipUV * zoom * i) - 0.5;
		
		float dis = sdLength(clipUV) * exp(-length(uv0));
		
		vec3 color = palette(sdLength(uv0) + TIME * 0.4 + i * 0.4);
		
		dis = sin(dis * 8.0 + TIME * speed) / 8.0;
		dis = abs(dis);
		dis = glow / dis;
		
		color *= dis * (1.0 / i);
		finalColor += color;
		
		clipUV = rotate(-TIME * rotationSpeed * (i - 1.0)) * temp;
	}
	
	finalColor = pow(finalColor, vec3(2.0));
	
	float a = 1.0;
	//To make the black transpaent
	a = 0.0;
	a = smoothstep((finalColor.r + finalColor.g + finalColor.b), 1.0 * isTransparent, a);
	
	
	COLOR = vec4(finalColor, a);
}
