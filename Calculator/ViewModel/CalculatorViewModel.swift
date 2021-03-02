//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Guillermo Fernandez on 24/02/2021.
//

import Foundation
import SwiftUI
import Combine

enum CalculatorOperation {
    case none
    case swipeSign
    case percentage
    case division
    case multiplication
    case subtraction
    case addition
    case equal
}

protocol CalculatorViewModelProtocol {
    func addDigit(_ digit: String)
    func resetOperands()
}

class CalculatorViewModel: CalculatorViewModelProtocol,
                           ObservableObject {
    
    @Published var display: String = "0"

    @Published var buttonText: String = "AC"
    
    private var operation: Calculation = Calculation(firstOperator: 0,
                                                     secondOperator: nil,
                                                     operation: .none)
    private var operationFinished: Bool = false
    
    public func addDigit(_ digit: String) {
        
        self.operationFinished = false
        
        if self.operation.operation != .none && self.operation.secondOperator == nil
        {
            self.operation.secondOperator = 0
            self.display = digit
            self.buttonText = "C"
            return
        }
        guard self.display != "0" else {
            self.display = digit
            self.buttonText = "C"
            return
        }
                
        guard self.display.count < 6 else {
            return
        }
        
        self.display += digit
    }
    
    public func resetOperands()
    {
        // Button AC no operation

        // Button C and no operation
        
        // Button C and operation
        
        // Button C, operation and second operand
        
        // Button AC and operation
        
        if self.buttonText == "C"
        {
            self.buttonText = "AC"
            self.operation.operation = .none
            
            if self.operation.firstOperator.truncatingRemainder(dividingBy: 1) == 0
            {
                let intDisplay = Int (self.operation.firstOperator)
                self.display = String (intDisplay)
                return
            }
    
            self.display = String (self.operation.firstOperator).replacingOccurrences(of: ".", with: ",")
        }
        else
        {
            self.operation.reset()
            self.buttonText = "AC"
            self.display = "0"
        }
    }
    
    public func perform(operation: CalculatorOperation)
    {
        var replaced = String(display).replacingOccurrences(of: ",", with: ".")
        
        guard let value = Double(replaced) else { return }
        
        switch operation
        {
            case .swipeSign:
                self.display = String(-value)
            case .equal:
                if !self.operationFinished
                {
                    self.operation.secondOperator = value
                }
                guard let result = calculateResult(for: self.operation) else { return }
                
                if result.truncatingRemainder(dividingBy: 1) == 0
                {
                    let intResult = Int (result)
                    replaced = String (intResult)
                }
                else
                {
                    replaced = String (result).replacingOccurrences(of: ".", with: ",")
                }
                
                
                self.display = replaced
 
                self.operation.firstOperator = result
                self.operationFinished = true
                return
            default:
                self.operation.firstOperator = value
                self.operation.operation = operation
        }
        
        self.display = "0"
    }
    
    func calculateResult(for values: Calculation) -> Double?
    {
        guard let secondOperator = values.secondOperator else { return nil }
        switch values.operation {
        case .addition:
            return operation.firstOperator + secondOperator
        case .division:
            return operation.firstOperator / secondOperator
        case .multiplication:
            return operation.firstOperator * secondOperator
        case .subtraction:
            return operation.firstOperator - secondOperator
        case .percentage:
            let base = Double(secondOperator)
            let percentage = Double(operation.firstOperator) / 100
            let result = base * percentage
            return Double(result)
        default:
            return nil
        }
    }
}
