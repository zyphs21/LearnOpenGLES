//
//  RotatePyramidViewController.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/5/27.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class RotatePyramidViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = PyramidView(frame: view.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
