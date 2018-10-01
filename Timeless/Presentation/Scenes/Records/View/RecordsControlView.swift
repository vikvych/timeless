//
//  RecordsControlView.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

class RecordsControlView: UIView {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        UIColor(white: 0.0, alpha: 0.64).setStroke()
        
        path.lineWidth = 1.0 / traitCollection.displayScale
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0.0))
        path.stroke()
    }

}
