#define PI 3.1415926535897932384626433832795

varying vec2 vUv;
varying vec3 v_position;
uniform float uTime;

float random(vec2 st)
{
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rotate(vec2 uv, float rotation, vec2 mid)
{
    return vec2(
      cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
      cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
    );
}

//	Classic Perlin 2D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x)
{
    return mod(((x*34.0)+1.0)*x, 289.0);
}

vec2 fade(vec2 t)
{
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(vec2 P)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute(permute(ix) + iy);
    vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 * vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

// float rect(vec2 pt, vec2 size ,vec2 center,vec2 ancor){
//     vec2 p = pt-center;
//     vec2 halfsize = size * 0.5;
//     float hor = step(halfsize.x - ancor.x, p.x) - step(-halfsize.x - ancor.x , p.x);
//     float ver = step(halfsize.y-ancor.y, p.y) - step(-halfsize.y - ancor.y, p.y);
//     return hor * ver;
// }
float rect(vec2 pt, vec2 size ,vec2 center){
    vec2 p = pt-center;
    vec2 halfsize = size * 0.5;
    float hor = step(halfsize.x , p.x) - step(-halfsize.x  , p.x);
    float ver = step(halfsize.y, p.y) - step(-halfsize.y, p.y);
    return hor * ver;
}

float sweep(vec2 pt ,vec2 center,float radius,float line_width,float edge_thickness){
    vec2 d = pt -center;
    float theta = uTime *2.0;
    vec2 p =vec2(cos(theta),-sin(theta)) *radius;
    // 计算向量 d 在向量 p 上的投影长度与p的模的比值，将这个比值 h 限制在 0 到 1 的范围内，确保线段长度不会超过圆的半径。
    float h = clamp(dot(d,p)/dot(p,p),0.,1.);
    /* 点 d到线段p的垂直距离 */
    float l =length(d-p*h);
    /* 反转结果 当l在线宽内为1 在线宽外为0 线宽到线宽边缘呈线性过渡 */
    return 1.0 - smoothstep(line_width,line_width+edge_thickness,l);
}



mat2 getRotationMatrix(float theta){
    return mat2( cos(theta),-sin(theta),sin(theta),cos(theta) );
}

mat2 getScaleMatrix(float multiple){
    return mat2 (multiple,0,0,multiple);
}

float circle(vec2 pt,vec2 center ,float radius){
    vec2 p = pt -center;
    return 1.0 - step(radius ,length(p));
}


float smoothcircle(vec2 pt,vec2 center ,float radius,bool isSharp ){
    vec2 p = pt -center;
    float edge = (isSharp) ? radius*0.5 : 0.0 ;
    return 1.0 - smoothstep(radius - edge,radius + edge,length(p));
}

float Linecircle(vec2 pt,vec2 center ,float radius,float lineWidth ){
    vec2 p = pt -center;
    float len = length(p);
    float halfLineWidth  = lineWidth /2.0;
    return step(radius - halfLineWidth,len) - step(radius + halfLineWidth , len);
}

float smoothLinecircle(vec2 pt,vec2 center ,float radius,float lineWidth,bool soften ){
    vec2 p = pt -center;
    float len = length(p);
    float edge = (soften) ? lineWidth * 0.5 : 0.0;
    float halfLineWidth  = lineWidth /2.0;
    return smoothstep(radius-halfLineWidth-edge,radius - halfLineWidth,len) - smoothstep(radius + halfLineWidth,radius + halfLineWidth+edge , len);
}


float line(float a,float b,float line_width,float edge_thickness){
 float halflinewidth =line_width * 0.5;
 return smoothstep(a - halflinewidth - edge_thickness,a- halflinewidth ,b ) - smoothstep( a+ halflinewidth,a+halflinewidth+edge_thickness,b);
}



void main()
{
    // // Pattern 1
    // gl_FragColor = vec4(vUv, 1.0, 1.0);

    // // Pattern 2
    // gl_FragColor = vec4(vUv, 0.0, 1.0);

    // // Pattern 3
    // float strength = vUv.x;

    // // Pattern 4
    // float strength = vUv.y;

    // // Pattern 5
    // float strength = 1.0 - vUv.y;

    // // Pattern 6
    // float strength = vUv.y * 10.0;

    // // Pattern 7
    // float strength = mod(vUv.y * 10.0, 1.0);

    // // Pattern 8
    // float strength = mod(vUv.y * 10.0, 1.0);
    // strength = step(0.5, strength);

    // // Pattern 9
    // float strength = mod(vUv.y * 10.0, 1.0);
    // strength = step(0.8, strength);

    // // Pattern 10
    // float strength = mod(vUv.x * 10.0, 1.0);
    // strength = step(0.8, strength);

    // // Pattern 11
    // float strength = step(0.8, mod(vUv.x * 10.0, 1.0));
    // strength += step(0.8, mod(vUv.y * 10.0, 1.0));
    // strength = clamp(strength, 0.0, 1.0);

    // // Pattern 12
    // float strength = step(0.8, mod(vUv.x * 10.0, 1.0));
    // strength *= step(0.8, mod(vUv.y * 10.0, 1.0));

    // // Pattern 13
    // float strength = step(0.4, mod(vUv.x * 10.0, 1.0));
    // strength *= step(0.8, mod(vUv.y * 10.0, 1.0));

    // // Pattern 14
    // float barX = step(0.4, mod(vUv.x * 10.0, 1.0)) * step(0.8, mod(vUv.y * 10.0, 1.0));
    // float barY = step(0.8, mod(vUv.x * 10.0, 1.0)) * step(0.4, mod(vUv.y * 10.0, 1.0));
    // float strength = barX + barY;
    // strength = clamp(strength, 0.0, 1.0);

    // // Pattern 15
    // float barX = step(0.4, mod(vUv.x * 10.0 - 0.2, 1.0)) * step(0.8, mod(vUv.y * 10.0, 1.0));
    // float barY = step(0.8, mod(vUv.x * 10.0, 1.0)) * step(0.4, mod(vUv.y * 10.0 - 0.2, 1.0));
    // float strength = barX + barY;
    // strength = clamp(strength, 0.0, 1.0);

    // // Pattern 16
    // float strength = abs(vUv.x - 0.5);

    // // Pattern 17
    // float strength = min(abs(vUv.x - 0.5), abs(vUv.y - 0.5));

    // // Pattern 18
    // float strength = max(abs(vUv.x - 0.5), abs(vUv.y - 0.5));

    // // Pattern 19
    // float strength = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));

    // // Pattern 20
    // float strength = step(0.2, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));
    // strength *= 1.0 - step(0.25, max(abs(vUv.x - 0.5), abs(vUv.y - 0.5)));

    // // Pattern 21
    // float strength = floor(vUv.x * 10.0) / 10.0;

    // // Pattern 22
    // float strength = floor(vUv.x * 10.0) / 10.0 * floor(vUv.y * 10.0) / 10.0;

    // // Pattern 23
    // float strength = random(vUv);

    // // Pattern 24
    // vec2 gridUv = vec2(floor(vUv.x * 10.0) / 10.0, floor(vUv.y * 10.0) / 10.0);
    // float strength = random(gridUv);

    // // Pattern 25
    // vec2 gridUv = vec2(floor(vUv.x * 10.0) / 10.0, floor((vUv.y + vUv.x * 0.5) * 10.0) / 10.0);
    // float strength = random(gridUv);

    // // Pattern 26
    // float strength = length(vUv);

    // // Pattern 27
    // float strength = distance(vUv, vec2(0.5));

    // // Pattern 28
    // float strength = 1.0 - distance(vUv, vec2(0.5));

    // // Pattern 29
    // float strength = 0.015 / (distance(vUv, vec2(0.5)));

    // // Pattern 30
    // float strength = 0.15 / (distance(vec2(vUv.x, (vUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));

    // // Pattern 31
    // float strength = 0.15 / (distance(vec2(vUv.x, (vUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));
    // strength *= 0.15 / (distance(vec2(vUv.y, (vUv.x - 0.5) * 5.0 + 0.5), vec2(0.5)));

    // // Pattern 32
    // vec2 rotatedUv = rotate(vUv, PI * 0.25, vec2(0.5));
    // float strength = 0.15 / (distance(vec2(rotatedUv.x, (rotatedUv.y - 0.5) * 5.0 + 0.5), vec2(0.5)));
    // strength *= 0.15 / (distance(vec2(rotatedUv.y, (rotatedUv.x - 0.5) * 5.0 + 0.5), vec2(0.5)));

    // // Pattern 33
    // float strength = step(0.5, distance(vUv, vec2(0.5)) + 0.25);

    // // Pattern 34
    // float strength = abs(distance(vUv, vec2(0.5)) - 0.25);

    // // Pattern 35
    // float strength = step(0.01, abs(distance(vUv, vec2(0.5)) - 0.25));

    // // Pattern 36
    // float strength = 1.0 - step(0.01, abs(distance(vUv, vec2(0.5)) - 0.25));

    // // Pattern 37
    // vec2 wavedUv = vec2(
    //     vUv.x,
    //     vUv.y + sin(vUv.x * 30.0) * 0.1
    // );
    // float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));

    // // Pattern 38
    // vec2 wavedUv = vec2(
    //     vUv.x + sin(vUv.y * 30.0) * 0.1,
    //     vUv.y + sin(vUv.x * 30.0) * 0.1
    // );
    // float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));

    // // Pattern 39
    // vec2 wavedUv = vec2(
    //     vUv.x + sin(vUv.y * 100.0) * 0.1,
    //     vUv.y + sin(vUv.x * 100.0) * 0.1
    // );
    // float strength = 1.0 - step(0.01, abs(distance(wavedUv, vec2(0.5)) - 0.25));

    // // Pattern 40
    // float angle = atan(vUv.x, vUv.y);
    // float strength = angle;

    // // Pattern 41
    // float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
    // float strength = angle;

    // // Pattern 42
    // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
    // float strength = angle;

    // // Pattern 43
    // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
    // float strength = mod(angle * 20.0, 1.0);

    // // Pattern 44
    // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
    // float strength = sin(angle * 100.0);

    // // Pattern 45
    // float angle = atan(vUv.x - 0.5, vUv.y - 0.5) / (PI * 2.0) + 0.5;
    // float radius = 0.25 + sin(angle * 100.0) * 0.02;
    // float strength = 1.0 - step(0.01, abs(distance(vUv, vec2(0.5)) - radius));

    // // Pattern 46
    // float strength = cnoise(vUv * 10.0);

    // // Pattern 47
    // float strength = step(0.0, cnoise(vUv * 10.0));

    // // Pattern 48
    // float strength = 1.0 - abs(cnoise(vUv * 10.0));

    // // Pattern 49
    // float strength = sin(cnoise(vUv * 10.0) * 20.0);

    // Pattern 50
    // float strength = step(0.9, sin(cnoise(vUv * 10.0) * 20.0));

    // Final color
    // vec3 blackColor = vec3(0.0);
    // vec3 uvColor = vec3(vUv, 1.0);
    // vec3 mixedColor = mix(blackColor, uvColor, strength);

    // gl_FragColor = vec4(vec3(strength), 1.0);

    /* 方块做圆周运动 */
    // float radius = 0.5;
    // vec2 center = vec2(cos(uTime) * radius ,sin(uTime) * radius); 
    // float squaer = rect(v_position.xy,vec2(0.5), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);


    /* 方块绕原点旋转 */
    // float radius = 0.5;
    // vec2 center = vec2(0.); 
    // mat2 rotate = getRotationMatrix(uTime);
    // vec2 pt = rotate * v_position.xy;
    // float squaer = rect(pt,vec2(0.5), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);

    /* 
    绕中心点旋转(不是原点) 先平移到原点 后进行线性变换 在平移回去
     */
    // float radius = 0.5;
    // vec2 ro = vec2(0.25,0.)
    // vec2 center = vec2(0.5,0.); 
    // mat2 rotate = getRotationMatrix(uTime);
    // vec2 pt = rotate * (v_position.xy - center) + center;
    // float squaer = rect(pt,vec2(0.5), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);

    /* 
    绕任意点旋转 先平移 后线性变换 在平移
     */

    //  float radius = 0.5;
    // vec2 center = vec2(0.4,0.); 
    // vec2 ro =vec2(0.2,0.2);
    // mat2 rotate = getRotationMatrix(uTime);
    // vec2 pt = rotate * (v_position.xy -  ro ) +ro;
    // float squaer = rect(pt,vec2(0.4), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);
    /* 
    缩放
     */
    // float radius = 0.5;
    // vec2 center = vec2(0.3,0.); 
    // vec2 rotateCenter = vec2(.5,.2);
    // mat2 rotate = getRotationMatrix(uTime);
    // mat2 scale = getScaleMatrix((sin(uTime)+1.0)/3.0 + 0.5);
    // vec2 pt = scale * rotate * (v_position.xy - rotateCenter ) + rotateCenter ;
    // float squaer = rect(pt,vec2(0.4), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);


    /* 
    Tiling
     */
     
    // float tilingCount = 6.0;
    // vec2 center = vec2(0.5); 
    // mat2 rotate = getRotationMatrix(uTime);
    // vec2 p = fract(vUv * tilingCount);
    // vec2 pt = rotate * (p- center ) + center ;
    // float squaer = rect(pt,vec2(0.4), center);
    // vec3 color = vec3(0.,1.,0.)  * squaer;
    // gl_FragColor = vec4(color,1.);


    /* 
    圆
     */
    //  float radius = 0.5;
    //  vec2 center =vec2(0.5);
    //  /* 边缘锋利 */
    // //  float cir = circle(v_position.xy,center,radius);
    // /* 边缘缓和 */
    // //  float cir = smoothcircle(v_position.xy,center,radius,true);

    // /* 线圈 */
    // float cir = Linecircle(v_position.xy,center,radius,0.02);
    // /* 边缘缓和线圈 */
    // // float cir = smoothLinecircle(v_position.xy,center,radius,0.02,true);
    //  vec3 color = vec3(1.,1.,0.) * cir;
    //  gl_FragColor = vec4(color,1.);


    /* 
    线
     */
     /* 方式一 */
    // vec3 color = vec3(1.0) * line(v_position.x,v_position.y,0.1,0.01);
    // gl_FragColor = vec4(vec3(color),1.0);
    /* 方式二 通过gl_FragCoord */
    //  vec3 color = vec3(1.0) * line(gl_FragCoord.x,gl_FragCoord.y,10.0,1.0);
    // gl_FragColor = vec4(vec3(color),1.0);
    /* 方式三通过vUv */
    //  vec3 color = vec3(1.0) * line(vUv.y,sin(vUv.x*3.14),0.005,0.0002);
    // gl_FragColor = vec4(vec3(color),1.0);

    /* 平行线 */
    // vec3 color = vec3(1.0) * line(vUv.x,0.5,0.05,0.002)+vec3(1.0) * line(vUv.y,0.5,0.05,0.002);
    // gl_FragColor = vec4(vec3(color),1.0);


    /* 雷达 */
    vec3 color = vec3(1.0) * line(vUv.x,0.5,0.002,0.001)+ vec3(1.0) * line(vUv.y,0.5,0.002,0.001)+vec3(1.0) * Linecircle(vUv,vec2(0.5),0.4,0.002);
    color+= vec3(1.0) * Linecircle(vUv,vec2(0.5),0.3,0.002);
    color+=vec3(1.0) * Linecircle(vUv,vec2(0.5),0.2,0.002);
    color+=sweep(vUv,vec2(0.5),0.4,0.003,0.001) * vec3(0.1,0.3,1.0);
    gl_FragColor = vec4(vec3(color),1.0);


}