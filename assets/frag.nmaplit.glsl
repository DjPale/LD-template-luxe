#ifdef GL_ES
precision mediump float;
#endif

// based on https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6

uniform sampler2D tex0;
uniform sampler2D tex1;

uniform vec3 lightPos;
uniform vec2 resolution;

varying vec2 tcoord;
varying vec4 color;

void main()
{
    vec4 texcolor = texture2D(tex0, tcoord);
    vec3 nmap = texture2D(tex1, tcoord).rgb;

    nmap.g = 1.0 - nmap.g;

    vec3 lightDir = vec3(lightPos.xy - (gl_FragCoord.xy / resolution.xy), lightPos.z);

    //Determine distance (used for attenuation) BEFORE we normalize our LightDir
    float D = length(lightDir);

    //normalize our vectors
    vec3 N = normalize(nmap * 2.0 - 1.0);
    vec3 L = normalize(lightDir);

    //Pre-multiply light color with intensity
    //Then perform "N dot L" to determine our diffuse term
    vec3 diffuse = vec3(max(dot(N, L), 0.0));

    //the calculation which brings it all together
    vec3 finalColor = texcolor.rgb * diffuse;
    gl_FragColor = color * vec4(finalColor, texcolor.a);
}
