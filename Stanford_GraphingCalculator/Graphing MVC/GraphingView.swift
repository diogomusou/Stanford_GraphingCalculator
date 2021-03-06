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
    var functionToDraw : (Double) -> Double = {$0 * $0 + $0 * 2 + 10}
    
    /*
     if sender.numberOfTouches() == 2 {
     let locationInView = sender.locationInView(self.view)
     let location = self.convertPointFromView(locationInView)
     if sender.state == .Changed {
     let deltaScale = (sender.scale - 1.0)*2
     let convertedScale = sender.scale - deltaScale
     let newScale = game.camera.xScale*convertedScale
     game.camera.setScale(newScale)
     
     let locationAfterScale = self.convertPointFromView(locationInView)
     let locationDelta = pointSubtract(location, pointB: locationAfterScale)
     let newPoint = pointAdd(game.camera.position, pointB: locationDelta)
     game.camera.position = newPoint
     sender.scale = 1.0
     }
     }
     */
    //Zoom in/out by pinching
    private var initialPinchLocation = CGPoint(x: 0, y: 0)
    private var initialGraphLocation = CGPoint(x: 0, y: 0)
    
    @objc func setScale (byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        if pinchRecognizer.numberOfTouches == 2 {
            initialPinchLocation = pinchRecognizer.location(in: self)
            initialGraphLocation = CGPoint(x: (initialPinchLocation.x - originPosition.x) / scale, y: (initialPinchLocation.y - originPosition.y) / scale)
            if pinchRecognizer.state == .changed {
                scale *= pinchRecognizer.scale
                
                let positionOfInitialLocation = CGPoint(x: initialGraphLocation.x * scale + originPosition.x, y: initialGraphLocation.y * scale + originPosition.y)
                originPosition = CGPoint(x: originPosition.x - (positionOfInitialLocation.x - initialPinchLocation.x), y: originPosition.y - (positionOfInitialLocation.y - initialPinchLocation.y))
                pinchRecognizer.scale = 1.0
            }
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
        axes.drawAxes(in: rect, origin: originPosition , pointsPerUnit: scale)
        
        let path = UIBezierPath()
        for point in 0...Int(rect.maxX) {
            let boundsX = Double(point)
            let graphX = (boundsX - Double(originPosition.x))/Double(scale)   //transform screen X into the axes X
            let nextGraphX = (boundsX + 1 - Double(originPosition.x))/Double(scale)
            let graphY = Double(originPosition.y) - functionToDraw(graphX) * Double(scale)    //get Y and transform it to the correct scale and position on axes Y
            let nextGraphY = Double(originPosition.y) - functionToDraw(nextGraphX) * Double(scale)
            
            path.move(to: CGPoint(x: boundsX, y: graphY ))
            path.addLine(to: CGPoint(x: boundsX + 1, y: nextGraphY ))
        }
        let color : UIColor = UIColor.black
        color.set()
        path.stroke()
        
//        print("scale: \(scale)")
//        print("left in points: \((rect.minX - originPosition.x))")
//        print("left: \((rect.minX - originPosition.x)/scale)")
//        print("right: \((rect.maxX - originPosition.x)/scale)")
//        print("up: \((originPosition.y - abs(rect.minY))/scale)")
//        print("down: \((originPosition.y - abs(rect.maxY))/scale)")
    }
    
    

}
