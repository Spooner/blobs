#version 110

// Use 3D Simplex noise, even though the shader operates on a 2D
// texture, since then we can make the Z-coordinate act as time.
#include <noise4d>

uniform sampler2D in_Texture;

uniform float in_Time;
uniform int in_Seed;

varying vec4 var_Color;
varying vec2 var_TexCoord;

void main()
{
    vec2 relative_position = var_TexCoord - 0.5;
    float distance_from_center = length(relative_position);

    float angle = atan(relative_position.x, relative_position.y);
    vec4 position1 = vec4(sin(angle), cos(angle), in_Time * 0.5, in_Seed);
    float depth_offset = (snoise(position1) + 1.0) * 0.5; // 0.0..1.0

    float ripple = snoise(vec4(var_TexCoord * 5.0, in_Time * 0.5, in_Seed)); // 0.0..1.0

    float depth = 0.5 - depth_offset * 0.1;
    if(distance_from_center < depth)
    {
        gl_FragColor = texture2D(in_Texture, var_TexCoord) * var_Color * 0.8;
        gl_FragColor.rgb += ripple * 0.2;
        gl_FragColor.a = ((depth - distance_from_center) / depth) * 0.5 + 0.5;
    }
    else
    {
        gl_FragColor.a = 0.0;
    }
}