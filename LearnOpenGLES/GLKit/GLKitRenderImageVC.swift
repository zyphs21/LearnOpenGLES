//
//  GLKitRenderImageVC.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/14.
//  Copyright © 2020 Hanson. All rights reserved.
//

import Foundation
import GLKit

class GLKitRenderImageVC: GLKViewController {
    
    private var context: EAGLContext?
    private var effect = GLKBaseEffect()
    
    // 顶点缓存区标识符
    private var vbo = GLuint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGL()
        setupVertexData()
        setupTexture()
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        effect.prepareToDraw()
        
        // 1-mode: 绘制模式；
        // GL_TRIANGLES: 三个顶点为一组来组成图形一个三角形。例如六个顶点 [0,1,2,3,4,5] 对应三角形为 (0,1,2),(3,4,5)
        // GL_TRIANGLE_FAN: 从第三个点开始遍历每个顶点，将这些顶点与它们的前一个，以及数组的第一个顶点组成一个三角形。例如四个顶点：[0,1,2,3] 对应三角形为 (2,1,0)，(3,2,1)
        // GL_TRIANGLE_STRIP: 顺序在每三个顶点之间绘制三角形，这个方法可以保证从相同的方向上所有三角形均被绘制。例如(0,1,2),(1,2,3),(2,3,4)……
        // 2-first: 从顶点数组缓存中哪一位开始绘制，一般定义为0
        // 3-count: 顶点的数量
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
    }
    
    private func setupGL() {
        context = EAGLContext(api: .openGLES3)
        EAGLContext.setCurrent(context)
        
        if let view = self.view as? GLKView, let context = context {
            view.context = context
            // 配置颜色缓冲区的格式
            view.drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
            // 配置深度缓冲区的格式
            view.drawableDepthFormat = GLKViewDrawableDepthFormat.format16
        }
        
        // 背景颜色
        glClearColor(1, 1, 0, 1)
    }
    
    private func setupVertexData() {
        let vertexData: [GLfloat] = [
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            0.5, 0.5, -0.0,    1.0, 1.0, //右上
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            -0.5, -0.5, 0.0,   0.0, 0.0, //左下
        ]
        
        // 创建顶点缓存区
        glGenBuffers(1, &vbo)
        // 绑定顶点缓存区
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 将顶点数组复制到 GPU 中的顶点缓存区
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.size(), vertexData, GLenum(GL_STATIC_DRAW))
        
        /*
         glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
         功能: 上传顶点数据到显存的方法（设置合适的方式从buffer里面读取数据）
         参数列表:
             index,指定要修改的顶点属性的索引值,例如
             size, 每次读取数量。（如position是由3个（x,y,z）组成，而颜色是4个（r,g,b,a）,纹理则是2个.）
             type,指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。
             normalized,指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
             stride,指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
             ptr指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0
        */
        
        let strideSize = MemoryLayout<GLfloat>.stride * 5
        
        // -- 顶点坐标数据
        
        // 设置读取格式
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        // 设置读取方式
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), nil)
        
        
        // -- 纹理坐标数据
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        // 指示如何从顶点数组 vertices 中找到颜色信息
        let texOffset = MemoryLayout<GLfloat>.stride * 3
        let texOffsetPointer = UnsafeRawPointer(bitPattern: texOffset)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), texOffsetPointer)
        
    }
    
    private func setupTexture() {
        guard let filePath = Bundle.main.path(forResource: "Texture", ofType: ".jpg") else { return }
        guard let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: filePath, options: [GLKTextureLoaderOriginBottomLeft : 1]) else { return }
//        guard let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: filePath, options: [:]) else { return }
        effect.texture2d0.enabled = GLboolean(GL_TRUE)
        effect.texture2d0.name = textureInfo.name
    }
}
