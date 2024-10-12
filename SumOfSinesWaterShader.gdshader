shader_type spatial;

uniform int numberOfWaves : hint_range(0, 100, 1); //Number of Waves Calculated
uniform vec4 color : source_color;

uniform float amplitude : hint_range(0.0, 10.0, 0.1); //Hight of the waves

uniform float initialFrequency : hint_range(0.0, 0.1, 0.001); //Frequency of the waves

uniform float xWaveDirectionChange : hint_range(0.0, 2.0, 0.1); //Amount the x Wave Direction Changes each wave, Multiplied by 2PI
uniform float zWaveDirectionChange : hint_range(0.0, 2.0, 0.1); //Amount the z Wave Direction Changes each wave, Multiplied by 2PI
uniform float xInitialDirection : hint_range(0.0, 2.0, 0.1); //Initial Direction of the x Wave RESET:
uniform float zInitialDirection : hint_range(0.0, 2.0, 0.1); //Initial Direction of the z Wave RESET:

uniform float speedMultiplier : hint_range(0.0, 5.0, 0.1); //Increases the speed for every wave
uniform float initailSpeed : hint_range(0.0, 5.0, 0.1); //Initial
uniform float speedAcelerationOverWaves : hint_range(0.0, 50.0, 1.0); //The rate at which smaller waves increase in speed

uniform float amplitudeIndexMultiplier : hint_range(0.0, 2.0, 0.01); //the multiplier each subsequent wave's amplitude is multiplied by
uniform float frequencyIndexMultiplier : hint_range(0.0, 2.0, 0.01); //the multiplier each subsequent wave's frequency is multiplied by

uniform samplerCube cubemap;

void vertex() {
	float yDisplacement = 0.0;
	float partialDirivitiveX = 0.0;
	float partialDirivitiveZ = 0.0;
	
	float phase = 0.0;
	
	float amplidtudeMultiplier = 1.0;
	float freqMultiplier = 1.0;
	
	for(int i = 0; i < numberOfWaves; i++){
		float index = float(numberOfWaves - i)/float(numberOfWaves);
		index = (float(i)/float(numberOfWaves)) * speedAcelerationOverWaves;
		
		float xDirTrig = sin(float(i) * xWaveDirectionChange * PI + xInitialDirection);
		float zDirTrig =  cos(float(i) * zWaveDirectionChange * PI + zInitialDirection);
		
		vec2 waveVector = freqMultiplier * initialFrequency * (vec2(xDirTrig, zDirTrig));
		phase = (index + initailSpeed) * TIME * speedMultiplier;
		
		float trigInside = phase + dot(waveVector, VERTEX.xz + vec2(partialDirivitiveX, partialDirivitiveZ));
		float eExp = pow(E, amplitude * amplidtudeMultiplier * sin(trigInside)) - 1.0;
		
		yDisplacement += eExp;
		partialDirivitiveX += amplitude * amplidtudeMultiplier * waveVector.x * cos(trigInside) * eExp;
		partialDirivitiveZ += amplitude * amplidtudeMultiplier * waveVector.y * cos(trigInside) * eExp;
		
		amplidtudeMultiplier *= amplitudeIndexMultiplier;
		freqMultiplier *= frequencyIndexMultiplier;
	}
	
	VERTEX.y = yDisplacement;
	NORMAL = -(cross(vec3(1, partialDirivitiveX, 0), vec3(0, partialDirivitiveZ, 1)));
}

void fragment() {
	ALBEDO = color.rgb;
	
	vec3 angle = normalize(VIEW);
	vec3 reflection = reflect(angle, NORMAL);
	
	reflection.xyz = (vec4(reflection, 1.0) * VIEW_MATRIX).xyz;
	
	vec4 r = texture(cubemap, reflection * vec3(-1.0, 1.0, 1.0));
	
	float frenel = pow((1.0 - dot(VIEW, NORMAL)), 5);
	r *= frenel;
	
	ALBEDO += r.rgb;
}


void light() {
	vec3 halfwayVector = normalize(VIEW + LIGHT);
	float frenel = pow((1.0 - dot(VIEW, NORMAL)), 5);
	
	SPECULAR_LIGHT += pow(dot(halfwayVector, NORMAL), 100) * ATTENUATION * LIGHT_COLOR * frenel;
	//Lambert Difuse
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR * 1.0;
}
