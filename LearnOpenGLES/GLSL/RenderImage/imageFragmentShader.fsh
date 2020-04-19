// 从 imageVetexShader.vsh 复制过来，定义一样的 varying 变量，这样才能从顶点着色器传递到片元着色器
varying lowp vec2 varyingTextureCoordinate;

uniform sampler2D colorMap;

void main() {
    // 纹理颜色添加对应像素点上
    // gl_FragColor 内建变量(GLSL 已经提前定义好的变量);
    // 读取纹素: vec4 texture2D(纹理的colorMap，纹理坐标); vec4 --> rgba
    gl_FragColor = texture2D(colorMap, varyingTextureCoordinate);
}
