//
//  ViewController.swift
//  Calculator
//
//  Created by Arthur 😇 on 12.12.22.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
   
    var isWrite: Bool = true
    
    @IBAction func mode(_ sender: UISegmentedControl) {
        if isWrite {
            isWrite = false
        } else {
            isWrite = true
        }
    }
    
    
    var isTyping: Bool = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let buttonTitle = sender.titleLabel?.text
        if isTyping {
        let isDisplay = display!.text!
            
            if (buttonTitle != ".") || !(isDisplay.contains(".")){
            
        display!.text = isDisplay + buttonTitle!
            }
        } else {
            display!.text = buttonTitle
            isTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = formatter.string(from: NSNumber(value:newValue))
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard isTyping && !display.text!.isEmpty else { return}
        display.text = String (display.text!.dropLast())
        if display.text!.isEmpty{
            displayValue = 0
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if isTyping {
            brain.setOperand(displayValue)
            isTyping = false
        }
        if let mathSymbol = sender.titleLabel?.text {
            brain.perfomOperation(mathSymbol)
            }
        if let result = brain.result {
            display.text = String(result)
        }
        
    }
    
    

}

