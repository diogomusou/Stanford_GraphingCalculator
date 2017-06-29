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
    
    //Zoom in/out by pinching
    @objc func setScale (byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    //move graph by panning
    @objc func moveOrigin (byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            originPosition = CGPoint(x: originPosition.x + panRecognizer.translation(in: self).x , y: originPosition.y + panRecognizer.translation(in: self).y)
            panRecognizer.setTranslation(CGPoint(x: 0, y: 0) , in: self)
        default:
            break
        }
    }
    
    //double-tap to set origin
    @objc func setOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            originPosition = tapRecognizer.location(in: self)
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        let axes = AxesDrawer(color: .black, contentScaleFactor: self.contentScaleFactor)
        axes.drawAxes(in: self.bounds, origin: originPosition , pointsPerUnit: scale)
    }
    

}
