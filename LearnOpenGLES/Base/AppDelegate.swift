//
//  AppDelegate.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/5.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpWindowAndRootView()
        return true
    }
}

extension AppDelegate {
    private func setUpWindowAndRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.makeKeyAndVisible()
        
        let vc = ViewController()
        window!.rootViewController = UINavigationController(rootViewController: vc)
    }
}

