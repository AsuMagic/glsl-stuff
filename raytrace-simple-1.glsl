const float fov = 60.;

const float epsilon = 1e-4;
const float pi = 3.14159;

vec3 dither(vec3 color, vec2 fragCoord)
{
    return color + mix(-0.5 / 255., 0.5 / 255., texture(iChannel1, fragCoord).r);
}

float luma(vec3 color)
{
	return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 sphere_normal(vec4 sphere, vec3 inter)
{
    return normalize(inter - sphere.xyz);
}

vec2 sphere_uv(vec4 sphere, vec3 inter)
{
    vec3 p = normalize(inter - sphere.xyz);
    return vec2(0.5 + atan(p.z, p.x) / pi , (asin(p.y) / pi));
}

vec3 sphere_light(vec4 sphere, vec3 inter, vec3 normal, vec3 light_pos, vec3 light_color, float light_intensity)
{
    vec3 dir = normalize(light_pos - inter);
    float lambert = max(0., dot(normal, dir));
    const float ambient = 0.2;
    
    return (lambert * light_color * light_intensity) + ambient;
}

vec3 sphere_intersect(vec4 sphere, vec3 rayorigin, vec3 raydir)
{
    vec3 relorigin = rayorigin - sphere.xyz;
    
    float a = dot(raydir, raydir),
          b = 2. * dot(raydir, relorigin),
          c = dot(relorigin, relorigin) - (sphere.w * sphere.w),
        
          dt = (b * b) - 4. * a * c;
    
    float t;
    if (dt < 0.)
    {
        return vec3(-1.f);
    }
    else if (dt < epsilon)
    {
        t = -b / (2. * a);
    }
    else
    {
        float t1 = (-b + sqrt(dt)) / (2. * a),
              t2 = (-b - sqrt(dt)) / (2. * a);
        
        t = min(t1, t2);
    }
    
    vec3 inter = rayorigin + raydir * t;
    vec3 normal = sphere_normal(sphere, inter);
    vec3 tex = vec3(texture(iChannel0, sphere_uv(sphere, inter)));
    vec3 light = sphere_light(sphere, inter, normal, vec3(0.2, 2., -3.), vec3(1.), 1.);
    
    return light * tex;
}

vec3 background(vec3 raydir)
{
    return vec3(texture(iChannel2, raydir));
}

vec3 raytrace(vec3 rayorigin, vec3 raydir)
{
    vec3 sphere1 = sphere_intersect(vec4(((iMouse.xy / iResolution.xy) - 0.5) * 5., 0., 1.4), rayorigin, raydir);
    
    if (sphere1.r != -1.)
    	return sphere1;
    
    return background(raydir);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 ncoord = (fragCoord / iResolution.xy) - 0.5;

    vec3 rayorigin = vec3(0., 0., -10.);
    vec2 raycoord = 2. * ncoord;
    float e = tan(fov * pi / 360.);
    raycoord *= vec2((iResolution.x * e) / iResolution.y, e);

    vec3 raydir = normalize(vec3(raycoord, 1));
    
    fragColor = vec4(dither(raytrace(rayorigin, raydir), fragCoord), 1.);
}
