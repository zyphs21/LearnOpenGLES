// 不需要赋初始值，由我们 Swift 代码里给这两个属性赋值
attribute vec4 position;
attribute vec2 textureCoordinate;

uniform bool shouldRotate; // 是否使用旋转矩阵，由Swift代码里配置
uniform mat4 rotateMatrix; // 旋转z矩阵

// varying 修饰，传递给片元着色器
varying lowp vec2 varyingTextureCoordinate;

void main() {
    // 赋值给 varying 修饰的 varyingTextureCoordinate，让值传递给片元着色器
    varyingTextureCoordinate = textureCoordinate;
    
    vec4 vPosition = position;
    
    if (shouldRotate == true) {
        vPosition = vPosition * rotateMatrix;
    }
    
    // 内建变量，GLSL 默认建立，vec4 类型，必须赋值
    gl_Position = vPosition;
}
