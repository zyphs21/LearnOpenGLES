//
//  BasicGLView.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/5/27.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

public class BasicGLView: UIView {

    public var eaglLayer: CAEAGLLayer!
    public var eaglContext: EAGLContext!

    public var renderBuffer = GLuint()
    public var frameBuffer = GLuint()

    public var program = GLuint()

    public override init(frame: CGRect) {
        print("---init GLViewFrame: \(frame)")
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        print("---layoutSubviews GLViewFrame: \(frame)")
        setupLayer()
        setupContext()
        clearRenderAndFrameBuffer()
        setupRenderBuffer()
        setupFrameBuffer()
        render()
    }

    public override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    // MARK: - 1. 创建设置图层
    private func setupLayer() {
        // 注意先 override layerClass，将返回的图层从 CALayer 替换成 CAEAGLLayer
        self.eaglLayer = self.layer as? CAEAGLLayer
        
        self.contentScaleFactor = UIScreen.main.scale
        
        self.eaglLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: false, // 绘图完之后是否保留状态(类似核心动画)
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8 // 颜色缓冲区格式
        ]
    }
    
    // MARK: - 2. 设置上下文 Context
    private func setupContext() {
        eaglContext = EAGLContext(api: .openGLES3)
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
        glGenBuffers(1, &renderBuffer)
        glBindBuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
    }
    
    // MARK: - 5. 设置 FrameBuffer
    private func setupFrameBuffer() {
        glGenBuffers(1, &frameBuffer)
        glBindBuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
    }
    
    // MARK: - 加载着色器
    public func loadShader(vertexFile: String, fragmentFile: String) -> GLuint {
        var vertexShader = GLuint()
        var fragmentShader = GLuint()
        var program = glCreateProgram()
        
        compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), filePath: vertexFile)
        compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), filePath: fragmentFile)
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        // 链接
//        glLinkProgram(program)
//        logLinkProgramStatus(program: &program) // 打印链接状态
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        return program
    }
    
    // MARK: - 编译着色器
    public func compileShader(_ shader: inout GLuint, type: GLenum, filePath: String) {
        let sourceContent = try? String(contentsOfFile: filePath, encoding: .utf8)
        let cStringContent = sourceContent?.cString(using: .utf8)
        var sourcePointer = UnsafePointer<GLchar>(cStringContent)
        
        shader = glCreateShader(type) // 创建着色器对象
        glShaderSource(shader, 1, &sourcePointer, nil) // 将着色器源码赋给 shader 对象
        glCompileShader(shader) // 编译着色器代码
        
        logShaderCompileStatus(shader: &shader)
    }
    
    public func render() {
        
    }
    
}

// MARK: - 辅助方法：打印 Compile Shader 和 Link Program 日志
public extension BasicGLView {
    func logShaderCompileStatus(shader: inout GLuint) {
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
    
    func logLinkProgramStatus(program: inout GLuint) {
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
