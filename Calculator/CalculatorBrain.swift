//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Arthur 😇 on 12.12.22.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var descriptionAccumulator: String?
    
    var description: String? {
        get  {
            if  pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,descriptionAccumulator ?? "")
            }
        }
    }
    
    private enum Operation {
        case nullaryOperation(() -> Double,String)
        case constant(Double)
        case unaryOperation((Double) -> Double,((String) -> String)?)
        case binaryOperation((Double,Double) -> Double,((String, String) -> String)?)
        case equals
        case C
    }
    
    private var  operations: Dictionary<String, Operation> =
    [
        "Ran": Operation.nullaryOperation(
                          { Double(arc4random()) / Double(UInt32.max)}, "rand()"),
        "pi": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 },nil),
        "√": Operation.unaryOperation(sqrt,nil ),
        "cos": Operation.unaryOperation(cos,nil),
        "sin": Operation.unaryOperation(sin,nil),
        "tan": Operation.unaryOperation(tan,nil),
        "sin⁻¹" : Operation.unaryOperation(asin,nil),
        "cos⁻¹" : Operation.unaryOperation(acos,nil),
        "tan⁻¹" : Operation.unaryOperation(atan, nil),
        "ln" : Operation.unaryOperation(log,nil),
        "x⁻¹" : Operation.unaryOperation({1.0/$0},
                {"(" + $0 + ")⁻¹"}),
        "х²" : Operation.unaryOperation({$0 * $0}, { "(" + $0 + ")²"}),
        "×": Operation.binaryOperation(*, nil),
        "÷": Operation.binaryOperation(/, nil),
        "+": Operation.binaryOperation(+, nil),
        "−": Operation.binaryOperation(-, nil),
        "xʸ" : Operation.binaryOperation(pow, { $0 + " ^ " + $1 }),
        "=": Operation.equals,
        "C": Operation.C
    ]
    mutating func perfomOperation(_ mathSymbol: String){
        if let operation = operations[mathSymbol] {
            switch operation {
            case .C :
                clear()
                
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = mathSymbol
                
            case .unaryOperation(let function,var descriptionFunction):
                if  accumulator != nil {
                    accumulator = function(accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = {mathSymbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = descriptionFunction!(descriptionAccumulator!)
                }
                
            case .binaryOperation(let function,var descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    if descriptionFunction == nil {
                        descriptionFunction = {$0 + " " + mathSymbol + " " + $1}
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator!)
                    accumulator = nil
                    descriptionAccumulator = nil
                }
            case .equals:
               performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
           accumulator =  pendingBinaryOperation!.perform(with: accumulator!)
            
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator!)
            
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String,String) -> String
        var descriptionOperand: String
        
        
        func perform(with secondOperend: Double) -> Double {
            return function(firstOperand ,secondOperend)
        }
        
        func performDescription(with secondOperend: String) -> String {
            return descriptionFunction(descriptionOperand ,secondOperend)
        }
        
    }
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = formatter.string(from: NSNumber(value:value)) ?? ""
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptionAccumulator = " "
    }
    
}


let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = " "
    formatter.locale = Locale.current
    return formatter
    
} ()
