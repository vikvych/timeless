//
//  ActionButton.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    private var imageScaleToParent: CGFloat? = nil
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        if let scale = imageScaleToParent {
            return contentRect.insetBy(dx: contentRect.width * (1.0 - scale) / 2.0,
                                       dy: contentRect.height * (1.0 - scale) / 2.0)
        } else {
            return super.imageRect(forContentRect: contentRect)
        }
    }

    func setImageScaleToParent(_ scale: CGFloat?) {
        imageScaleToParent = scale
        setNeedsLayout()
    }
    
}
