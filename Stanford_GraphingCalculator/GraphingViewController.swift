//
//  GraphingViewController.swift
//  Stanford_GraphingCalculator
//
//  Created by Diogo M Souza on 2017/06/28.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {
    

    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: graphingView, action: #selector(graphingView.setScale(byReactingTo:)))
            graphingView.addGestureRecognizer(pinch)
            let pan = UIPanGestureRecognizer(target: graphingView, action: #selector(graphingView.moveOrigin(byReactingTo:)))
            graphingView.addGestureRecognizer(pan)
            let doubleTap = UITapGestureRecognizer(target: graphingView, action: #selector(graphingView.setOrigin(byReactingTo:)))
            doubleTap.numberOfTapsRequired = 2
            graphingView.addGestureRecognizer(doubleTap)
            updateUI()
        }
    }
    
    func updateUI () {
        graphingView?.originPosition = CGPoint(x: graphingView.bounds.midX, y: graphingView.bounds.midY)
    }
    
    
    


}

