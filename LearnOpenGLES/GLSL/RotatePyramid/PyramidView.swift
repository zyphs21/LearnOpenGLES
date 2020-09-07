//
//  PyramidView.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/5/27.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit
import OpenGLES

class PyramidView: BasicGLView {
    
    // MARK: - 6. 绘制
    override func render() {
        // 清屏颜色
        glClearColor(0, 0, 0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        let x = frame.origin.x * scale
        let y = frame.origin.y * scale
        let width = frame.size.width * scale
        let height = frame.size.height * scale
        // (1) 设置视口大小
        glViewport(GLint(x), GLint(y), GLsizei(width), GLsizei(height))
        
        // (2) 获取顶点/片元着色器
        guard let vertexFile = Bundle.main.path(forResource: "imageVetexShader", ofType: "vsh")
            , let fragmentFile = Bundle.main.path(forResource: "imageFragmentShader", ofType: "fsh") else {
                print("---找不到着色器文件---")
                return
        }
        
        // (3) 加载 Shader
        program = loadShader(vertexFile: vertexFile, fragmentFile: fragmentFile)
        
        // (4) 链接
        glLinkProgram(program)
        // 打印链接状态
        logLinkProgramStatus(program: &program)
        
        // (5) 使用 program
        glUseProgram(program)
        
        // (6) 处理顶点数据
        let attrArray: [GLfloat] =
        [
            -0.5, 0.5, 0.0,      1.0, 0.0, 1.0, //左上0
            0.5, 0.5, 0.0,       1.0, 0.0, 1.0, //右上1
            -0.5, -0.5, 0.0,     1.0, 1.0, 1.0, //左下2
            
            0.5, -0.5, 0.0,      1.0, 1.0, 1.0, //右下3
            0.0, 0.0, 1.0,       0.0, 1.0, 0.0, //顶点4
        ]
        
        let indices: [GLuint] =
        [
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3,
        ]
        
        var vbo = GLuint() // vertext buffer object
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 将顶点数组复制到 GPU 中的顶点缓存区
        glBufferData(GLenum(GL_ARRAY_BUFFER), attrArray.size(), attrArray, GLenum(GL_DYNAMIC_DRAW))
        
        // "position" 与 imageVetexShader.vsh 里定义的 position 名字一致
        let position = glGetAttribLocation(program, "position")
        // 开启 position
        glEnableVertexAttribArray(GLuint(position))
        // 设置读取方式
        let strideSize = MemoryLayout<GLfloat>.stride * 6
        glVertexAttribPointer(GLuint(position), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), nil)
        
        // (7) 处理顶点颜色值
        // glGetAttribLocation,用来获取vertex attribute的入口的.
        // 注意：第二参数字符串必须和shaderv.glsl中的输入变量：positionColor保持一致
        let positionColor = glGetAttribLocation(program, "positionColor")
        glEnableVertexAttribArray(GLuint(positionColor))
        // 设置读取方式
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        glVertexAttribPointer(GLuint(positionColor), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), colorOffsetPointer)
        
        // (8) 找到myProgram中的projectionMatrix、modelViewMatrix 2个矩阵的地址。如果找到则返回地址，否则返回-1，表示没有找到2个对象。
        let projectionMatrixSlot = glGetUniformLocation(program, "projectionMatrix")
        let modelViewMatrixSlot = glGetUniformLocation(program, "modelViewMatrix")
        
//        let projectionMatrix = KSM
        
        // 长宽比
        let aspect = frame.size.width / frame.size.height
    
    }
    
    @IBAction func rotateX(_ sender: Any) {
    }
    
    @IBAction func rotateY(_ sender: Any) {
    }
    
    @IBAction func rotateZ(_ sender: Any) {
    }
    
    
    
    
}
