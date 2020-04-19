//
//  GLKitRenderBackgroundColorVC.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/12.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit
import GLKit

//'GLKViewController' was deprecated in iOS 12.0: OpenGLES API deprecated.
// (Define GLES_SILENCE_DEPRECATION to silence these warnings)
// 在 Build Settings 的 Preprocessor Macros 下定义 GLES_SILENCE_DEPRECATION=1
class GLKitRenderBackgroundColorVC: GLKViewController {

    private var eaglContext: EAGLContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGLView()
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClearColor(0, 0.7, 0, 1.0)

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
}

extension GLKitRenderBackgroundColorVC {
    
    private func setupGLView() {
        eaglContext = EAGLContext(api: .openGLES3)
        
        EAGLContext.setCurrent(eaglContext)
        
        if let glView = self.view as? GLKView
         , let context = eaglContext {
            glView.context = context
            glView.delegate = self
        }
    }
    
}

// MARK: - GLKViewControllerDelegate
extension GLKitRenderBackgroundColorVC: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
}
