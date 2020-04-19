//
//  GLKitRenderRectangleVC.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/12.
//  Copyright © 2020 Hanson. All rights reserved.
//
// 参考 https://www.raywenderlich.com/5146-glkit-tutorial-for-ios-getting-started-with-opengl-es

import GLKit

class GLKitRenderRectangleVC: GLKViewController {

    private var eaglContext: EAGLContext?
    
    // 构成矩形的顶点数据，OpenGL 只支持三角形，故这里可以看成是两个三角形
    var vertices = [
//        Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
//        Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
//        Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
//        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
        
        Vertex(x:  0.5, y: -0.5, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  0.5, y:  0.5, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -0.5, y:  0.5, z: 0, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -0.5, y: -0.5, z: 0, r: 0, g: 0, b: 0, a: 1),
    ]

    // 索引绘图数组，优化空间
    // 两个三角形组成一个矩形，其中有两个顶点是共用的；
    // 这里代表第 0，1，2 个点构成一个三角形，第 2，3，0 个点构成三角形
    var indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    // Element Buffer Object (EBO)
    private var ebo = GLuint()
    // Vertex Buffer Object (VBO)
    private var vbo = GLuint()
    // Vertex Array Object (VAO)
    private var vao = GLuint()
    
    // 纹理 Shader
    private var effect = GLKBaseEffect()
    
    private var rotation: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGLView()
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClearColor(0, 0.7, 0, 1.0)

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // 绑定并编译纹理数据
        effect.prepareToDraw()

        glBindVertexArrayOES(vao)
        
        // 1-mode: 绘制的模式
        // 2-count：绘制顶点的个数
        // 3-type：索引的类型 GL_UNSIGNED_BYTE/INT/SHORT
        // 4-indice：指向索引数组的指针
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        glBindVertexArrayOES(0)
    }
    
    deinit {
        clearGL()
    }
}

extension GLKitRenderRectangleVC {
    
    private func setupGLView() {
        eaglContext = EAGLContext(api: .openGLES3)
        
        EAGLContext.setCurrent(eaglContext)
        
        if let glView = self.view as? GLKView, let context = eaglContext {
            
            glView.context = context
            
            // 设置 GLKViewControllerDelegate
            delegate = self
        }
        
        
        // MARK: - VAO
        
        // 创建顶点数组对象
        glGenVertexArraysOES(1, &vao)
        // 绑定顶点数组
        glBindVertexArrayOES(vao)
        
        
        // MARK: - VBO (对 vertices 顶点数组处理)
        
        // 创建顶点缓冲区
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 将顶点数组复制到顶点缓存区中(即 GPU 中)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        let vertexSize = MemoryLayout<Vertex>.stride
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3, // 顶点坐标 x，y，z 占三个值
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              GLsizei(vertexSize),
                              nil)
        
        // 指示如何从顶点数组 vertices 中找到颜色信息
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue),
                              4, // 颜色 r，g，b，a 占四个值
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              GLsizei(vertexSize),
                              colorOffsetPointer) // 从顶点数组中索引出取颜色值的位置
        
        
        // MARK: - EBO (对 indices 索引数组处理)
        
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.size(), indices, GLenum(GL_STATIC_DRAW))
        
        
        // MARK: - 取消绑定
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    private func clearGL() {
        EAGLContext.setCurrent(eaglContext)

        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
            
        EAGLContext.setCurrent(nil)
            
        eaglContext = nil
    }

    
}

// MARK: - GLKViewControllerDelegate
extension GLKitRenderRectangleVC: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
        let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
        
        effect.transform.projectionMatrix = projectionMatrix
        
        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        rotation += 90 * Float(timeSinceLastUpdate)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
        
        effect.transform.modelviewMatrix = modelViewMatrix
    }
}
