//
//  ImageTextureView.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/19.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class ImageTextureView: UIView, GLViewable {
    var eaglLayer: CAEAGLLayer!
    var eaglContext: EAGLContext!
    
    var renderBuffer = GLuint()
    var frameBuffer = GLuint()
    
    var shaderProgram = GLuint()
    
    private var rotateMethod: GLSLRenderImageVC.RotateMethod!
    
    init(frame: CGRect, rotateMethod: GLSLRenderImageVC.RotateMethod) {
        super.init(frame: frame)
        self.rotateMethod = rotateMethod
        setupLayer()
        setupContext()
        setupShaderProgram()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        clearRenderAndFrameBuffer()
        // TODO: - 疑问：调用此方法无法成功，分开调用却可以
//        setupRenderAndFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        render()
    }
    
    // MARK: - 1. 创建设置图层
    private func setupLayer() {
        // 注意先 override layerClass，将返回的图层从 CALayer替换成CAEAGLLayer
        self.eaglLayer = self.layer as? CAEAGLLayer
        
        self.contentScaleFactor = UIScreen.main.scale
        
        self.eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, // 绘图完之后是否保留状态(类似核心动画)
                                           kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8] // 颜色缓冲区格式
    }
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    // 设置上下文 Context
    private func setupContext() {
        // TODO: - 改成 openGLES3
        eaglContext = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(eaglContext)
    }
    
    // 清空缓存区 frameBuffer 和 renderBuffer
    private func clearRenderAndFrameBuffer() {
        glDeleteBuffers(1, &renderBuffer)
        renderBuffer = 0
        
        glDeleteBuffers(1, &frameBuffer)
        frameBuffer = 0
    }
    
    // TODO: - ⚠️ 疑问：调用此方法会导致最后无法成功渲染内容，但是拆开 setupRenderBuffer 和 setupFrameBuffer 两个方法却可以。
    private func setupRenderAndFrameBuffer() {
        glGenBuffers(1, &renderBuffer)
        glBindBuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
        
        glGenBuffers(1, &frameBuffer)
        glBindBuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
    }
    
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
    }
    
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        // 将 colorRenderBuffer 绑定到 GL_COLOR_ATTACHMENT0
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
    }
    
    private func setupShaderProgram() {
        guard let vertexFile = Bundle.main.path(forResource: "imageVetexShader", ofType: "vsh")
            , let fragmentFile = Bundle.main.path(forResource: "imageFragmentShader", ofType: "fsh") else {
                print("---找不到着色器文件---")
                return
        }
        
        // 加载 Shader
        shaderProgram = loadShader(vertexFile: vertexFile, fragmentFile: fragmentFile)
    }
    
    // MARK: - 6. 绘制
    private func render() {
        glClearColor(1, 1, 0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        let x = frame.origin.x * scale
        let y = frame.origin.y * scale
        let width = frame.size.width * scale
        let height = frame.size.height * scale
        //  设置视口大小
        glViewport(GLint(x), GLint(y), GLsizei(width), GLsizei(height))
        print("---ViewPort: \(width) x \(height)")
                
        //  使用 program
        glUseProgram(shaderProgram)
        
        // (6) 处理顶点数据
        let vertexData: [GLfloat] = [
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            0.5, 0.5, -0.0,    1.0, 1.0, //右上
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            -0.5, -0.5, 0.0,   0.0, 0.0, //左下
        ]
        let strideSize = MemoryLayout<GLfloat>.stride * 5
        
        var vbo = GLuint() // vertext buffer object
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // 将顶点数组复制到 GPU 中的顶点缓存区
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexData.size(), vertexData, GLenum(GL_DYNAMIC_DRAW))
        
        // "position" 与 imageVetexShader.vsh 里定义的 position 名字一致
        let position = glGetAttribLocation(shaderProgram, "position")
        glEnableVertexAttribArray(GLuint(position))
        glVertexAttribPointer(GLuint(position), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), nil)
        
        // (7) 处理纹理数据
        let textureCoordinate = glGetAttribLocation(shaderProgram, "textureCoordinate")
        glEnableVertexAttribArray(GLuint(textureCoordinate))
        let textureOffset = MemoryLayout<GLfloat>.stride * 3
        let textureOffsetPointer = UnsafeRawPointer(bitPattern: textureOffset)
        // 读取方式
        glVertexAttribPointer(GLuint(textureCoordinate), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), textureOffsetPointer)
        
        let texture = loadTexture("tower")
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        
        // 设置纹理采样器 sampler2D; "colorMap" 与 imageFragmentShader.fsh 里定义的一致
        let uniformLocation = glGetUniformLocation(shaderProgram, "colorMap")
        glUniform1i(uniformLocation, 0)
        
        // 旋转纹理图片
        if case .rotateMatrix = rotateMethod {
            // 都在 generateTexture() 方法里对图片进行翻转了
//            rotateImageWithRotateMatrix()
        }
        
        // (9) 绘图
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        // 从渲染缓冲区显示到屏幕上
        self.eaglContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}

extension ImageTextureView {
    // MARK: - 加载纹理
    private func loadTexture(_ texture: String) -> GLuint {
        guard let textureImage = UIImage(named: texture)?.cgImage else {
            print("---无此纹理图片--")
            return GLuint()
        }
        return generateTexture(from: textureImage)
    }
}

extension ImageTextureView {
    // MARK: - 配置旋转矩阵
    private func rotateImageWithRotateMatrix() {
        let shouldRotateLocation = glGetUniformLocation(shaderProgram, "shouldRotate")
        glUniform1i(shouldRotateLocation, 1)
        
        
        let radian = 180 * Float.pi / 180
        let s = sin(radian)
        let c = cos(radian)
        let rotateMat: [GLfloat] = [
            c, -s,  0,  0,
            s,  c,  0,  0,
            0,  0,  1,  0,
            0,  0,  0,  1
        ]
        
        let rotateMatrix = glGetUniformLocation(shaderProgram, "rotateMatrix")
        glUniformMatrix4fv(rotateMatrix, 1, GLboolean(GL_FALSE), rotateMat)
    }
}
