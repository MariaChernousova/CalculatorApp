//
//  CalculatorModel.swift
//  hw4
//
//  Created by Chernousova Maria on 23.09.2021.
//

import Foundation

protocol CalculatorModelProtocol {
    var currentTitle: String { get }
    
    func add(argument: String)
    func add(operation: String)
    
    func calculate()
    func reset()
}

protocol CalculatorModelDelegate: AnyObject {
    func zero(wasSelected: Bool)
    func updateTitle(with title: String)
    func handleError(title: String, message: String)
}

final class CalculatorModel: CalculatorModelProtocol {
    private enum Constant {
        enum Template {
            static let resultTitle = "Result:"
            static let errorOccurredTitle = "Error occurred"
            static let errorTitle = "Error"
        }
        
        static let minusPlusOperator = "+/-"
    }
    
    weak var delegate: CalculatorModelDelegate?
    
    private(set) var currentTitle = ""
    private(set) var isZeroSelected = false
    private var expression = ""
    private var minusOperator = "-"
    private var auxiliaryZero = "0"
    
    func add(argument: String) {
        if let parenthesis = CalculatorService.Parenthesis(rawValue: argument) {
            switch parenthesis {
            case .left:
                expression = "\(expression)\(argument) "
            case .right:
                expression = "\(expression) \(argument)"
            }
            
        } else {
            if argument == "." {
                delegate?.zero(wasSelected: false)
                expression = "\(expression)\(auxiliaryZero)\(argument)"
            } else if argument == "0" {
                delegate?.zero(wasSelected: true)
                expression = "\(expression)\(argument)"
            } else {
                expression = "\(expression)\(argument)"
            }
        }
        updateCurrentTitle(with: argument)
    }
    
    func add(operation: String) {
        delegate?.zero(wasSelected: false)
        if operation == Constant.minusPlusOperator {
            expression = "\(expression)\(auxiliaryZero) \(minusOperator) "
            updateCurrentTitle(with: " \(minusOperator)")
        } else if let lastElement = expression.last,
                  lastElement != " " {
            expression = "\(expression) \(operation) "
            updateCurrentTitle(with: operation)
        }
    }
    
    func calculate() {
        do {
            let result = try CalculatorService().getResult(from: expression)
            
            if result.truncatingRemainder(dividingBy: 1) == .zero {
                currentTitle = "\(Constant.Template.resultTitle) \(Int(result))"
            } else {
                currentTitle = "\(Constant.Template.resultTitle) \(String(format: "%.3f", result))"
            }
            delegate?.updateTitle(with: currentTitle)
        } catch let error as CalculatorServiceError {
            reset()
            delegate?.handleError(title: Constant.Template.errorOccurredTitle,
                                  message: error.description)
        } catch let error {
            reset()
            delegate?.handleError(title: Constant.Template.errorOccurredTitle,
                                  message: error.localizedDescription)
        }
    }
    
    func reset() {
        expression = ""
        currentTitle = ""
        delegate?.updateTitle(with: currentTitle)
    }
    
    private func updateCurrentTitle(with title: String) {
        currentTitle = "\(currentTitle)\(title)"
        delegate?.updateTitle(with: currentTitle)
    }
}
