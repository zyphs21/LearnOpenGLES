//
//  ViewController.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/5.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    let dataSet: [Project] = Project.projectData
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Learn OpenGLES"
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = self.view.bounds
    }
}


// MARK: - Function

extension ViewController {
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = dataSet[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(dataSet[indexPath.row].vc, animated: true)
    }
}


enum Project: String, CaseIterable {
    case GLKit渲染背景色
    case GLKit绘制矩形
    case GLKit展示纹理图片
    case GLSL展示纹理图片
    
    var vc: UIViewController {
        switch self {
        case .GLKit渲染背景色:
            return GLKitRenderBackgroundColorVC()
        case .GLKit绘制矩形:
            return GLKitRenderRectangleVC()
        case .GLKit展示纹理图片:
            return GLKitRenderImageVC()
        case .GLSL展示纹理图片:
            return GLSLRenderImageVC()
        }
    }
    
    static let projectData: [Project] = Project.allCases
    
    var demos: [Demo] {
        switch self {
        default:
            return []
        }
    }
}

struct Demo {
    var title: String
    var vc: UIViewController
}
