//
//  UIView+Extension.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
