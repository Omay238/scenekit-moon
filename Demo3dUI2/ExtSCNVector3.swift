//
//  ExtSCNVector3.swift
//  Demo3dUI2
//
//  Created by Omay Operations on 11/30/23.
//

import Foundation
import SceneKit

extension SCNVector3 {
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }

    func normalized() -> SCNVector3 {
        let len = length()
        return SCNVector3(x / len, y / len, z / len)
    }
}
