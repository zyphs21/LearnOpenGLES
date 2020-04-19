//
//  Array+Extension.swift
//  LearnOpenGLES
//
//  Created by Hanson on 2020/4/12.
//  Copyright © 2020 Hanson. All rights reserved.
//

import Foundation

extension Array {
    
    /// 根据数组类型和长度获取数组实际内存空间大小(Bytes)
    public func size() -> Int {
        return MemoryLayout<Element>.stride * self.count
    }
}
