//
//  GLSLRenderImageVC.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/19.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class GLSLRenderImageVC: UIViewController {

    /// 旋转纹理图片的方法
    enum RotateMethod {
        case quartzDrawing // 解压绘制图片的时候进行转换
        case rotateMatrix // 将顶点坐标做旋转矩阵变换
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = ImageTextureView(frame: view.frame, rotateMethod: .rotateMatrix)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
