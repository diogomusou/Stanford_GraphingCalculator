//
//  GraphingView.swift
//  Stanford_GraphingCalculator
//
//  Created by Diogo M Souza on 2017/06/28.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//

import UIKit

//@IBDesignable
class GraphingView: UIView {
    
    @IBInspectable
    var scale : CGFloat = 50 { didSet { setNeedsDisplay() } }
    var originPosition : CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    
    @objc func setScale (byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            print(scale)
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        let axes = AxesDrawer(color: .black, contentScaleFactor: self.contentScaleFactor)
        axes.drawAxes(in: self.bounds, origin: originPosition , pointsPerUnit: scale)
    }
    

}
