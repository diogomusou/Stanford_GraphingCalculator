//
//  ViewController.swift
//  Stanford_GraphingCalculator
//
//  Created by Diogo M Souza on 2017/06/28.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: graphingView, action: #selector(graphingView.setScale(byReactingTo:)))
            graphingView.addGestureRecognizer(pinch)
            graphingView.originPosition = CGPoint(x: graphingView.bounds.midX, y: graphingView.bounds.midY)
        }
    }
    
    func updateUI () {
        
    }
    
    
    


}

