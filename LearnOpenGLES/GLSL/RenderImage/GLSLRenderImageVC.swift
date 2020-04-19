//
//  GLSLRenderImageVC.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/19.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class GLSLRenderImageVC: UIViewController {

//    private lazy var imageTextureView = ImageTextureView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = ImageTextureView(frame: view.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
