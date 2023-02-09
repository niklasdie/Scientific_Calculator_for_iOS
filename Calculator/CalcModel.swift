//
//  CalcModel.swift
//  Calculator
//
//  Created by Niklas Diekhöner on 04.02.23.
//

import Foundation
import JavaScriptCore

// MARK: StringProtocol

/// Extends the String with funtion "string.index(of: string)" and more.
extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

// MARK: CalcModel

/// # This calculator is inspirated by the Jade Scientific Calculator on Android.

/**
 The CalcModel class is the centre of the calculator.
 
 CalcModel imports Algebrite as a math library and handles the view via an Observer-Pattern.
 
 It calculates the results, saves them in a list and notifes the view.
 */
class CalcModel {
    
    /**
     Saves the workings and result of previous calculations.
     */
    struct Result {
        let result: String
        let resultWorking: String
    }

    /// Workings of the calculation
    var workings: String = " "
    
    /// List of previous calculations
    var resultList: [Result] = []
    
    /// Observers of CalcModel
    private lazy var observers = [Observer]()
    
    /// JavaScript to run Algebrite
    private let vm = JSVirtualMachine()
    private let context: JSContext

    init() {
        let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "AlgebriteList.bundle", withExtension: "js")!)
        context = JSContext(virtualMachine: vm)
        context.evaluateScript(jsCode)
    }

    // MARK: Observer
    
    /// For attaching a observer
    func attach(_ observer: Observer) {
        observers.append(observer)
    }

    /// For detaching a observer
    func detach(_ observer: Observer) {
        if let idx = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: idx)
        }
    }

    /// For notifying all observers
    func notify(_ e: Bool) {
        observers.forEach({ $0.update(calcModel: self, enter: e) })
    }

    // MARK: Logic
    
    /// When a digit is pressed it will be appended to the workings of the calculator.
    func digitPressed(_ key: String) {
        workings += key
        notify(false)
    }

    /// When a operation is pressed it will be appended to the workings of the calculator.
    /// If the operation in ''ans'' it append the last result.
    func performOperation(_ op: String) {
        if (op == "ans") {
            workings += resultList.last!.result
        } else {
            workings += op
        }
        notify(false)
    }

    /// Clears the calculator workings.
    func clearAll() {
        workings = " "
        notify(false)
    }

    /// Verifies if the input is valid. (Basic validation)
    func validInput() -> Bool {
        var count = 0
        var funcCharIndexes = [Int]()

        for char in workings {
            if (specialCharacter(char: char)) {
                funcCharIndexes.append(count)
            }
            count += 1
        }

        var previous: Int = -1

        for index in funcCharIndexes {
            if (index == 0) {
                return false
            }
            if (index == workings.count - 1) {
                return false
            }
            if (previous != -1) {
                if (index - previous == 1) {
                    return false
                }
            }
            previous = index
        }

        return true
    }

    func specialCharacter(char: Character) -> Bool {
        switch char {
        case "+":
            return true
        case "-":
            return true
        case "×":
            return true
        case "/":
            return true
        default:
            return false
        }
    }

    /// When the enter key is pressed the result is calculated with Algebrite.
    func enterPressed() {
        if (validInput()) {
            let workingsDisplay = formatResultWorkings(&workings)
            workings = formatWorkings(&workings)
            var result = calculate(workings)
            let resultString = formatResult(&result)
            resultList.append(Result(result: resultString, resultWorking: workingsDisplay))
            clearAll()
        } else {
            observers.forEach({ $0.alertInvalidInput() })
        }
        notify(true)
    }
    
    /// Calculates the result with Algebrite.
    func calculate(_ phrase: String) -> String {
        let jsModule = context.objectForKeyedSubscript("AlgebriteList")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("Math")
        if let result = jsAnalyzer?.invokeMethod("run", withArguments: [phrase]) {
            return String(result.toString())
        }
        return " "
    }

    // MARK: Formatting
    
    /// Formats the workings before calculation with Algebrite.
    func formatWorkings(_ w: inout String) -> String {
        w.replace("×", with: "*")
        w.replace(",", with: ".")
        w.replace("π", with: "pi")
        if (w.contains("√(")) {
            let sqrt = w.index(of: "√(")!
            w.replace("√", with: "sqrt")
            if (!w[sqrt...].contains(")")) {
                w += ")"
            }
        }
        if(w.contains("ln(")) {
            let ln = w.index(of: "ln(")!
            if (!w[ln...].contains(")")) {
                w += ")"
            }
        }
        return w
    }
    
    /// Formats the workings before showing in the view.
    func formatResultWorkings(_ w: inout String) -> String {
        if (w.contains("√(")) {
            let sqrt = w.index(of: "√(")!
            if (!w[sqrt...].contains(")")) {
                w += ")"
            }
        }
        if(w.contains("ln(")) {
            let ln = w.index(of: "ln(")!
            if (!w[ln...].contains(")")) {
                w += ")"
            }
        }
        return w
    }
    
    /// Formats the result before showing in the view.
    func formatResult(_ r: inout String) -> String {
        r.replace(".", with: ",")
        r.replace("pi", with: "π")
        r.replace("sqrt", with: "√")
        return r
    }

}
