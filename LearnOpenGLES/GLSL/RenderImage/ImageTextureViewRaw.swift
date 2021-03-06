//
//  ImageTextureViewRaw.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/9/6.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class ImageTextureViewRaw: UIView {
    
    private var eaglLayer: CAEAGLLayer!
    private var eaglContext: EAGLContext!
    
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    
    private var program = GLuint()
    
    private var rotateMethod: GLSLRenderImageVC.RotateMethod!
    
    init(frame: CGRect, rotateMethod: GLSLRenderImageVC.RotateMethod) {
        super.init(frame: frame)
        self.rotateMethod = rotateMethod
        setupLayer()
        setupContext()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        clearRenderAndFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        // 这里如果将 RenderBuffer 和 FrameBuffer 合并成一个方法后，无法渲染成功
//        setupRenderAndFrameBuffer()
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
    
    // MARK: - 2. 设置上下文 Context
    private func setupContext() {
        // TODO: - 改成 openGLES3
        eaglContext = EAGLContext(api: .openGLES2)
        EAGLContext.setCurrent(eaglContext)
    }
    
    // MARK: - 3. 清空缓存区 frameBuffer 和 renderBuffer
    private func clearRenderAndFrameBuffer() {
        glDeleteBuffers(1, &renderBuffer)
        renderBuffer = 0
        
        glDeleteBuffers(1, &frameBuffer)
        frameBuffer = 0
    }
    
    // MARK: - 4. 设置 RenderBuffer
    private func setupRenderBuffer() {
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
    }
    
    // MARK: - 5. 设置 FrameBuffer
    private func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        // 将 colorRenderBuffer 绑定到 GL_COLOR_ATTACHMENT0
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
    }
    
    private func setupRenderAndFrameBuffer() {
        glGenBuffers(1, &renderBuffer)
        glBindBuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
        
        glGenBuffers(1, &frameBuffer)
        glBindBuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
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
//        glLinkProgram(program)
//        printLinkProgramLog(program: &program)
        
        // (5) 使用 program
        glUseProgram(program)
        
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
        let position = glGetAttribLocation(program, "position")
        glEnableVertexAttribArray(GLuint(position))
        glVertexAttribPointer(GLuint(position), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), nil)
        
        // (7) 处理纹理数据
        let textureCoordinate = glGetAttribLocation(program, "textureCoordinate")
        glEnableVertexAttribArray(GLuint(textureCoordinate))
        let textureOffset = MemoryLayout<GLfloat>.stride * 3
        let textureOffsetPointer = UnsafeRawPointer(bitPattern: textureOffset)
        // 读取方式
        glVertexAttribPointer(GLuint(textureCoordinate), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideSize), textureOffsetPointer)
        
        // (8) 加载纹理
        loadTexture("tower")
        
        // 设置纹理采样器 sampler2D; "colorMap" 与 imageFragmentShader.fsh 里定义的一致
        let uniformLocation = glGetUniformLocation(program, "colorMap")
        glUniform1i(uniformLocation, 0)
        
        // 旋转纹理图片
        if case .rotateMatrix = rotateMethod {
            rotateImageWithRotateMatrix()
        }
        
        // (9) 绘图
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        // 从渲染缓冲区显示到屏幕上
        self.eaglContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}

extension ImageTextureViewRaw {
    // MARK: - 加载着色器
    private func loadShader(vertexFile: String, fragmentFile: String) -> GLuint {
        var vertexShader = GLuint()
        var fragmentShader = GLuint()
        var program = glCreateProgram()
        
        compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), filePath: vertexFile)
        compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), filePath: fragmentFile)
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        // 链接
        glLinkProgram(program)
        printLinkProgramLog(program: &program) // 打印链接状态
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        return program
    }
    
    // MARK: - 编译着色器
    private func compileShader(_ shader: inout GLuint, type: GLenum, filePath: String) {
        let sourceContent = try? String(contentsOfFile: filePath, encoding: .utf8)
        let cStringContent = sourceContent?.cString(using: .utf8)
        var sourcePointer = UnsafePointer<GLchar>(cStringContent)
        
        shader = glCreateShader(type) // 创建着色器对象
        glShaderSource(shader, 1, &sourcePointer, nil) // 将着色器源码赋给 shader 对象
        glCompileShader(shader) // 编译着色器代码
        
        printShaderCompileLog(shader: &shader)
    }
    
    // MARK: - 加载纹理
    private func loadTexture(_ texture: String) {
        guard let textureImage = UIImage(named: texture)?.cgImage else {
            print("---无此纹理图片--")
            return
        }
        let width = textureImage.width
        let height = textureImage.height
        // 计算图片所占字节大小 (width * height * rgba)
        let imageData = calloc(width * height * 4, MemoryLayout<GLubyte>.size)
        let context = CGContext(data: imageData, width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: width * 4,
                                space: textureImage.colorSpace!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        let imageRect = CGRect(x: 0, y: 0, width: width, height: width)
        
        if case .quartzDrawing = rotateMethod {
            // 上下翻转图片
            context?.translateBy(x: 0, y: imageRect.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
        }
        
        context?.draw(textureImage, in: imageRect)
        
        /*
        var texture = GLuint()
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glActiveTexture(GLenum(texture))
        */
        // 绑定纹理到默认的纹理id
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        // 设置纹理属性
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        // 加载纹理数据
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        
        // 释放图片数据
        free(imageData)
    }
}

// MARK: - 辅助方法：打印 Compile Shader 和 Link Program 日志
extension ImageTextureViewRaw {
    
    private func printShaderCompileLog(shader: inout GLuint) {
        var status = GLint()
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == GL_FALSE {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shader, GLsizei(infoLog.size()), nil, &infoLog)
            let info = String(cString: infoLog, encoding: .utf8)
            print("--- Compile Shader Error: \(String(describing: info)) ---")
        } else {
            print("--- Compile Shader Success ---")
        }
    }
    
    private func printLinkProgramLog(program: inout GLuint) {
        var status = GLint()
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == GL_FALSE {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetProgramInfoLog(program, GLsizei(infoLog.size()), nil, &infoLog)
            let info = String(cString: infoLog, encoding: .utf8)
            print("--- Link Program Error: \(String(describing: info)) ---")
        } else {
            print("--- Link Program Success ---")
        }
    }
}

extension ImageTextureViewRaw {
    // MARK: - 配置旋转矩阵
    private func rotateImageWithRotateMatrix() {
        let shouldRotateLocation = glGetUniformLocation(program, "shouldRotate")
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
        
        let rotateMatrix = glGetUniformLocation(program, "rotateMatrix")
        glUniformMatrix4fv(rotateMatrix, 1, GLboolean(GL_FALSE), rotateMat)
    }
}
