//
//  CalculatorViewController.swift
//  Stanford Calculator
//
//  Created by Diogo M Souza on 2017/05/31.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var variableLabel: UILabel!
    @IBOutlet weak var acButton: UIButton! //All Clear button. Changes to "C" (clear) when userIsInTheMiddleOfTyping
    @IBOutlet weak var decimalSeparatorButton: UIButton! {
        didSet {
            decimalSeparatorButton.setTitle(decimalSeparator, for: UIControlState())
        }
    }
    
    private var decimalSeparator = formatter.decimalSeparator ?? "."
    private var userIsInTheMiddleOfTyping = false
    private var userIsTypingDoubleValue = false  //flag to avoid numbers with 2 or more dots "."
    private var displayValue : Double {
        get {
            let doubleValue = formatter.number(from: displayLabel.text!)  //convert formatted string to accepted number (e.g "2,34" to "2.34")
            return doubleValue!.doubleValue
        }
        set {
            displayLabel.text = formatter.string(from: newValue as NSNumber)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchedDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = displayLabel.text!
            displayLabel.text = textCurrentlyInDisplay + digit
        } else {
            displayLabel.text = digit
            userIsInTheMiddleOfTyping = true
            acButton.setTitle("C", for: .normal)
        }
    }
    
    //Action for when "." is pressed. 
    //"." can only be inserted once per number
    @IBAction func touchedDot(_ sender: UIButton) {
        let dot = sender.currentTitle!
        if !userIsTypingDoubleValue && userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = displayLabel.text!
            displayLabel.text = textCurrentlyInDisplay + dot
        } else if !userIsTypingDoubleValue {
            displayLabel.text = "0" + dot
        }
        userIsTypingDoubleValue = true
        userIsInTheMiddleOfTyping = true
        acButton.setTitle("C", for: .normal)
    }
    
    @IBAction func insertVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        updateUI()
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        if brain.evaluate(using: ["M":displayValue]).result != nil {
            userIsInTheMiddleOfTyping = false
            updateUI()
        }
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var newValue = displayLabel.text!
            newValue.remove(at: newValue.index(before: newValue.endIndex))
            if newValue == "" {
                newValue = "0"
                userIsInTheMiddleOfTyping = false
            }
            displayLabel.text = newValue
        } else {
            brain.undo()
            updateUI()
        }
    }
    
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userIsTypingDoubleValue = false
            acButton.setTitle("AC", for: .normal)
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        updateUI()
    }

    //Reset brain (by reinitializing the CalculatorBrain
    //and clear the display label
    @IBAction func touchedAC(_ sender: UIButton) {
        if !userIsInTheMiddleOfTyping {
            brain = CalculatorBrain()
            variablesDictionary = [:]
            descriptionLabel.text = " "
            variableLabel.text = " "
            graphButton.isEnabled = false
        }
        displayLabel.text = "0"
        userIsInTheMiddleOfTyping = false
        userIsTypingDoubleValue = false
        acButton.setTitle("AC", for: .normal)
    }
    
    private func updateUI() {
        if let result = brain.evaluate().result {
            displayValue = result
        }
        let description = brain.evaluate().description
        graphButton.isEnabled = false
        if brain.evaluate().isPending {
            descriptionLabel.text = description + " ..."
        } else {
            descriptionLabel.text = description == "" ? " " : (description + " =")
            if descriptionLabel.text != "" {
                graphButton.isEnabled = true
            }
        }
        
        if let variableValue = variablesDictionary["M"] {
            variableLabel.text = "M = \(variableValue)"
        } else {
            variableLabel.text = " "
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphButton.isEnabled = false
        graphButton.setTitleColor(.gray, for: .disabled)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationController = destinationVC as? UINavigationController {
            destinationVC = navigationController.visibleViewController  ?? destinationVC
        }
        if let graphingVC = destinationVC as? GraphingViewController {
            graphingVC.mathematicFunction.function = {[weak weakSelf = self] x in
                return weakSelf!.brain.evaluate(using: ["M":x]).result!
            }
            graphingVC.navigationItem.title = self.brain.evaluate().description
        }
    }
    

}

