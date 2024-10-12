shader_type canvas_item;

//When estimating integrals using 32 squares, the shader can approximate about 20 waves. Anything over will break the shader
//Since this is a pixel shader, the preformance depends on how much of the shader is on screen

uniform int numOfWaves : hint_range(0, 50, 1);
uniform float lengthOfRope : hint_range(1.0, 3.0, 0.01);
uniform float speed : hint_range(0.0, 4.0, 0.1);

uniform float amplitude : hint_range(0.0, 2.0, 0.1);

float function(float input, float index){
	float sinVal = sin(index * PI * input / lengthOfRope);
	float customFunction = -pow(E, -pow(input - 0.5, 2) / 0.05);
	//customFunction = cos(input * PI + PI/ 2.0) / 2.0;
	//customFunction = 0.0;
	//customFunction = -input;
	//customFunction = sin(input * PI); 
	//customFunction = pow(input, 3);
	//customFunction = -pow(E, sin(input * PI)) * 0.3;
	//customFunction = -pow(input, 2);
	
	return customFunction * sinVal * amplitude;
}

float simsonsIntegral(float lowerBound, float upperBound, float index){ //Integral Approximation
	float numOfSquares = 64.0;
	float deltaX = (upperBound-lowerBound)/numOfSquares;
	float sum = 0.0;
	
	sum += function(deltaX, index);
	for(int i = 2; i < int(numOfSquares); i += 2){
		sum += 4.0 * function(deltaX * float(i), index);
	}
	for(int i = 3; i < int(numOfSquares); i += 2){
		sum += 2.0 * function(deltaX * float(i), index);
	}
	sum += function(deltaX * numOfSquares, index);
	sum = sum * (deltaX / 3.0);
	
	return sum;
}

void fragment() { //Sum of Sines / Fourier Transform
	vec4 c = vec4(1.0, 1.0, 1.0, 1.0);
	
	float waveSum = 0.0;
	
	for(int i = 1; i < numOfWaves; i++){
		float index = float(i);
		
		// Spacial Value
		float sinVal = sin(index * PI * UV.x); // divided by lengthOfRope
		
		// Temporal Value
		float cosVal = cos((index * PI * TIME/ lengthOfRope) * speed);
		//cosVal += sin((index * PI * TIME/ lengthOfRope) * speed );
		
		// a sub n
		float integralVal = (2.0 / lengthOfRope) * simsonsIntegral(0.0, lengthOfRope, index);
		
		waveSum += integralVal * sinVal * cosVal;
	}
	
	waveSum /= 2.0;
	waveSum += 0.5;
	
	float intensity = 1.0 - step(0.02, abs(waveSum - UV.y));
	
	c.a = intensity;
	
	COLOR = c;
}
