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
    return mix(vec3(texture(iChannel0, vec2(daytime, 2. / iChannelResolution[0].y))),
               vec3(texture(iChannel0, vec2(daytime, 0))),
               distance(position, vec2(0.5, 0.0)) * 1.5 * position.y);
}

vec3 getStarColor(vec2 position, vec3 noise)
{
    if (rand(position * noise.r) > 0.998) // HACK: * noise.r to work around rand()'s precision
    {
        vec3 randomcoloroff = vec3(noise.r / 9., noise.g / 6., noise.b / 9.);
        return rand(iTime * position) * 0.15 + vec3(0.7) - randomcoloroff;
    }

    return vec3(0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 position = fragCoord.xy / iResolution.xy;
    vec3 noise = vec3(texture(iChannel1, fragCoord / iChannelResolution[1].xy));

    vec3 skycolor = getSkyColor(iMouse.x / iResolution.x, position);
    vec3 starcolor = getStarColor(position, noise);

    fragColor = vec4(max(starcolor - luma(skycolor), dither(skycolor, noise.b)), 0);
}
