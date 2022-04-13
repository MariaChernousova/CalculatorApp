//
//  Calculator.swift
//  hw4
//
//  Created by Chernousova Maria on 25.09.2021.
//

import Foundation

struct Stack {
    private(set) var array = [String]()
    
    var isEmpty: Bool {
        array.isEmpty
    }
    
    var count: Int {
        array.count
    }
    
    mutating func push(_ element: String) {
        array.append(element)
    }
    
    @discardableResult
    mutating func pop() -> String? {
        return array.popLast()
    }
    
    func peek() -> String? {
        return array.last
    }
}

enum CalculatorError: Error {
    case incorrectInputExpression
    case undefined
}

struct Calculator {
    private enum Constant {
        static let operationPriorities = ["(": 1,
                                          ")": 1,
                                          "+": 2,
                                          "-": 2,
                                          "*": 3,
                                          "/": 3,
                                          "^": 5]
    }
    
    // MARK: For example "3 + 4 * 2 / ( 1 - 5 ) ^ 2"
    private let expression: [String]
    
    init(inputExpression: String) {
        expression = inputExpression.components(separatedBy: " ")
    }
    
    func getResult() throws -> Double {
        var outputString = ""
        var stack = Stack()
        var expression = expression
        
        for character in expression {
            
            switch character {
            case _ where character.isEqualTo(regexExpression: "^[1-9]\\d*\\.?\\d*$"): outputString += "\(String(character)) "
            case "(": stack.push(character)
            case ")":
                while stack.peek() != "(" {
                    if let function = stack.pop() {
                        outputString += "\(function) "
                    }
                }
                stack.pop()
            case _ where character.isEqualTo(regexExpression: "^[-+*^\\/]$"):
                if !stack.isEmpty {
                    while Constant.operationPriorities[character]! <= Constant.operationPriorities[stack.peek() ?? ""] ?? -1 {
                        if let function = stack.pop() {
                            outputString += "\(function) "
                        }
                    }
                }
                stack.push(character)
            default:
                throw CalculatorError.incorrectInputExpression
            }
        }
        
        while !stack.isEmpty {
            if let function = stack.pop() {
                outputString += "\(function) "
            }
        }
        
        outputString.removeLast()
        
        expression = outputString.components(separatedBy: " ")
        
        for character in expression {
            switch character {
            case _ where character.isEqualTo(regexExpression: "^[1-9]\\d*\\.?\\d*$"): stack.push(character)
            case _ where character.isEqualTo(regexExpression: "^[-+*^\\/]$"):
                guard let op2 = Double(stack.pop()!) else { throw CalculatorError.incorrectInputExpression }
                guard let op1 = Double(stack.pop()!) else { throw CalculatorError.incorrectInputExpression }
                switch character {
                case "+": stack.push(String(op1 + op2))
                case "-": stack.push(String(op1 - op2))
                case "*": stack.push(String(op1 * op2))
                case "/": stack.push(String(op1 / op2))
                case "^": stack.push(String(describing: pow(Decimal(op1), Int(op2))))
                default:
                    throw CalculatorError.undefined
                }
            default:
                throw CalculatorError.undefined
            }
        }
        
        return Double(stack.pop()!)!
    }
}

extension String {
    func isEqualTo(regexExpression: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: regexExpression, options: [])
        return !regex.matches(in: self, options: [], range: NSMakeRange(.zero, count)).isEmpty
    }
}
