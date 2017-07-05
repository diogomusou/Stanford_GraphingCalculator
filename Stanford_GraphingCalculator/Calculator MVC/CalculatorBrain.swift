//
//  CalculatorBrain.swift
//  Stanford Calculator
//
//  Created by Diogo M Souza on 2017/05/31.
//  Copyright © 2017 Diogo M Souza. All rights reserved.
//
// Calculator 2

import Foundation

struct CalculatorBrain {
    
    private var inputAccumulator : Array<Input> = []
    private var currentOperation : Int = 0
    
    private enum Input {
        case number(Double)
        case variable(String)
        case operation(String)
    }
    
    
    
    //cannot be mutating
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator : (value : Double?, text : String?)
        var pendingBinaryOperation : PendingBinaryOperation?
        
        func performOperation(_ symbol : String) {
            if let operation = operations[symbol] {
                switch operation {
                case .rand(let function):
                    let randNumber = function()
                    accumulator = (randNumber, "rand(" + formatter.string(from: randNumber as NSNumber)! + ")")
                case .constant(let value):
                    accumulator = (value, symbol)
                case .unaryOperation(let (function, description)):
                    if accumulator.value != nil {
                        accumulator = (function(accumulator.value!), description(accumulator.text!))
                    }
                case .binaryOperation(let (function, descriptionFunction)):
                    //if user wants to do multiple operations without pressing "=",
                    //calculate previous result first (first 3 lines are same code as "case .equals"):
                    performPendingBinaryOperation()
                    
                    if accumulator.value != nil {
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!, descriptionFunction: descriptionFunction, firstDescriptionOperand: accumulator.text!)
                        accumulator = (nil, nil)
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        func performPendingBinaryOperation() {
            if accumulator.value != nil && pendingBinaryOperation != nil {
                accumulator.value = pendingBinaryOperation!.perform(with: accumulator.value!)
                accumulator.text = pendingBinaryOperation!.performDescription(with: accumulator.text!)
                pendingBinaryOperation = nil
            }
        }
        
        if variables != nil {
            for (variable, value) in variables! {
                variablesDictionary.updateValue(value, forKey: variable)
            }
        }
        for input in inputAccumulator {
            switch input {
            case .number(let operand):
                accumulator = (operand, formatter.string(from: operand as NSNumber))
            case .variable(let variable):
                accumulator = (variablesDictionary[variable] ?? 0, variable)
            case .operation(let symbol):
                performOperation(symbol)
            }
        }
        
        let result : Double? = accumulator.value
        let isPending : Bool = (pendingBinaryOperation != nil)
        var description : String = ""
        if !isPending {
            if accumulator.text != nil {
                description = accumulator.text!
            } else {
                description = ""
            }
        } else {
            description = pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.firstDescriptionOperand, accumulator.text ?? "")
        }
        
         return (result, isPending, description)
    }
    
    private enum Operation {
        case rand(() -> Double)
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "Rand" : Operation.rand({Double(arc4random())/Double(UInt32.max)}),
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt,   {"√(\($0))"}),
        "±" : Operation.unaryOperation({-$0},  {"-(\($0))"}),
        "x⁻¹":Operation.unaryOperation({1/$0}, {"(\($0))⁻¹"}),
        "cos":Operation.unaryOperation(cos,    {"cos(\($0))"}),
        "sin":Operation.unaryOperation(sin,    {"sin(\($0))"}),
        "tan":Operation.unaryOperation(tan,    {"tan(\($0))"}),
        "x!": Operation.unaryOperation(factorial, {"!(\($0))"}),
        "+" : Operation.binaryOperation(+, {$0 + " + " + $1}),
        "−" : Operation.binaryOperation(-, {$0 + " - " + $1}),
        "×" : Operation.binaryOperation(*, {$0 + " × " + $1}),
        "÷" : Operation.binaryOperation(/, {$0 + " ÷ " + $1}),
        "=" : Operation.equals
    ]
    
    
    
    mutating func performOperation(_ symbol : String) {
        inputAccumulator.append(.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        inputAccumulator.append(.number(operand))
    }
    
    mutating func setOperand(variable: String) {
        inputAccumulator.append(.variable(variable))
    }
    
    mutating func undo() {
        if inputAccumulator.count > 0 { inputAccumulator.removeLast() }
    }
    
    private struct PendingBinaryOperation {
        let function : (Double,Double) -> Double
        let firstOperand : Double
        let descriptionFunction : (String, String) -> String
        let firstDescriptionOperand : String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(firstDescriptionOperand, secondOperand)
        }
    }
    
    //deprecated
    var description : String? {
        return evaluate().description
    }
    
    //deprecated
    var resultIsPending : Bool {
        return evaluate().isPending
    }
    
    //deprecated
    var result : Double? {
        return evaluate().result
    }
    
    
}

func factorial(_ number: Double) -> Double {
    var result = 1.0
    var x = number
    while (x > 0) {
        result = result * x
        x = x - 1
    }
    return result
}

let formatter : NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    //formatter.usesSignificantDigits = true
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.locale = Locale.current
    return formatter
}()

var variablesDictionary = [String: Double]()
