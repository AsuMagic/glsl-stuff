float rand(vec2 seed)
{
    return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 dither(vec3 color, float noise)
{
    return color + mix(-0.5 / 255., 0.5 / 255., noise);
}

float luma(vec3 color)
{
    return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 getSkyColor(float daytime, vec2 position)
{
    return mix(vec3(texture(iChannel0, vec2(daytime, 1. / iChannelResolution[0].y))),
               vec3(texture(iChannel0, vec2(daytime, 0.))),
               distance(position, vec2(0.5, 0.0)) - (0.2 * position.y));
}

vec4 getStarColor(vec2 position, vec4 noise)
{
    if (rand(position * noise.r) > 0.998) // HACK: * noise.r to work around rand()'s precision
    {
        vec4 basecolor = vec4(vec3(0.85), 1.0);
        vec4 randomcoloroff = vec4(noise.r / 7., noise.g / 4., noise.b / 7., noise.a);
        float blink = rand(iTime * position) * 0.1;
        return basecolor - blink - randomcoloroff;
    }

    return vec4(0.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float daytime = iMouse.x / iResolution.x;
    
    vec2 position = fragCoord.xy / iResolution.xy;
    vec4 noise = texture(iChannel1, fragCoord / iChannelResolution[1].xy);

    vec3 skycolor = getSkyColor(daytime, position);
    vec4 starcolor = getStarColor(position, noise);
	vec3 starcolorblend = mix(skycolor, starcolor.rgb, starcolor.a);
    
    fragColor = vec4(max(starcolorblend, dither(skycolor, noise.b)), 1.);
}
