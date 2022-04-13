//
//  CalculatorService.swift
//  hw4
//
//  Created by Chernousova Maria on 25.09.2021.
//

import Foundation

enum CalculatorServiceError: Error {
    private enum Constant {
        static let descriptionEnding = "was found during the calculation process"
    }
    case incorrectInputExpression
    case undefined
    
    var description: String {
        switch self {
        case .incorrectInputExpression:
            return "Incorrect Input Expression \(Constant.descriptionEnding)"
        case .undefined:
            return "Undefined error \(Constant.descriptionEnding)"
        }
    }
}

final class CalculatorService {
    
    enum Operation: String {
        case increment = "+"
        case decrement = "-"
        case multiply = "*"
        case divide = "/"
        case power = "^"
    }
    
    enum Parenthesis: String {
        case left = "("
        case right = ")"
    }
    
    private enum Constant {
        enum Expression {
            static let numbersWithSymbols = "^[0-9]\\d*\\.?\\d*$"
            static let symbols = "^[-+*^\\/]$"
        }
        
        static let operationPriorities = ["(": 1,
                                          ")": 1,
                                          "+": 2,
                                          "-": 2,
                                          "*": 3,
                                          "/": 3,
                                          "^": 5]
    }
    
    var calculationCache: [String] = []
    var processesExpression: [String] = []
    
    // MARK: For example "3 + 4 * 2 / ( 1 - 5 ) ^ 2"
    func getResult(from expression: [String]) throws -> Double {
        let processedExpression = try process(expression: expression)
        let secondStepResult = try performCalculation(with: processedExpression)
        return secondStepResult
    }
    
    func getResult(from expression: String) throws -> Double {
        return try getResult(from: expression.components(separatedBy: " "))
    }
    
    func computePriority(for character: String) {
        guard !calculationCache.isEmpty,
              let priorityByCharacter = Constant.operationPriorities[character] else {
                  return calculationCache.append(character)
              }
        for element in calculationCache.reversed() {
            guard let priorityByElement = Constant.operationPriorities[element],
                  priorityByCharacter <= priorityByElement else { break }
            if let lastElement = calculationCache.popLast() {
                processesExpression.append(lastElement)
            }
        }
    }
    
    func addRightCharacter() {
        for element in calculationCache.reversed() {
            guard element != Parenthesis.left.rawValue else { break }
            if let lastElement = calculationCache.popLast() {
                processesExpression.append(lastElement)
            }
        }
    }
    
    private func process(expression: [String]) throws -> [String] {
        for character in expression {
            if character.isEqualTo(regexExpression: Constant.Expression.numbersWithSymbols) {
                processesExpression.append(character)
            } else if character.isEqualTo(regexExpression: Constant.Expression.symbols) {
                computePriority(for: character)
            } else if character == Parenthesis.left.rawValue {
                calculationCache.append(character)
            } else if character == Parenthesis.right.rawValue {
                addRightCharacter()
            } else {
                throw CalculatorServiceError.incorrectInputExpression
            }
        }
        
        return [processesExpression, calculationCache.reversed()].flatMap { $0 }
    }
    
    private func performCalculation(with expression: [String]) throws -> Double {
        var calculationCache: [String] = []
        
        for character in expression {
            if character.isEqualTo(regexExpression: Constant.Expression.numbersWithSymbols) {
                calculationCache.append(character)
            } else if character.isEqualTo(regexExpression: Constant.Expression.symbols),
                      let stackPopped2 = calculationCache.popLast(),
                      let stackPopped1 = calculationCache.popLast(),
                      let op2 = Double(stackPopped2),
                      let op1 = Double(stackPopped1),
                      let operation = Operation(rawValue: character) {
                switch operation {
                case .increment:
                    calculationCache.append("\(op1 + op2)")
                case .decrement:
                    calculationCache.append("\(op1 - op2)")
                case .multiply:
                    calculationCache.append("\(op1 * op2)")
                case .divide:
                    calculationCache.append("\(op1 / op2)")
                case .power:
                    calculationCache.append("\(pow(op1, op2))")
                }
            }
        }
        
        if let lastElement = calculationCache.last,
           let result = Double(lastElement) {
            return result
        } else {
            throw CalculatorServiceError.undefined
        }
    }
}

fileprivate extension String {
    func isEqualTo(regexExpression: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regexExpression, options: []) else { return false }
        return !regex.matches(in: self, options: [], range: NSMakeRange(.zero, count)).isEmpty
    }
}


