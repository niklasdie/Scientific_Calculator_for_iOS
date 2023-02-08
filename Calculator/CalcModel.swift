//
//  CalcModel.swift
//  Calculator
//
//  Created by Niklas Diekhöner on 04.02.23.
//

import Foundation
import JavaScriptCore

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

class CalcModel {

    struct Result {
        let result: String
        let resultWorking: String
    }

    var workings: String = " "
    var resultList: Array<Result> = Array()
    private lazy var observers = [Observer]()
    private let vm = JSVirtualMachine()
    private let context: JSContext

    init() {
        let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "AlgebriteList.bundle", withExtension: "js")!)
        context = JSContext(virtualMachine: vm)
        context.evaluateScript(jsCode)
    }

    func attach(_ observer: Observer) {
        observers.append(observer)
    }

    func detach(_ observer: Observer) {
        if let idx = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: idx)
        }
    }

    func notify(_ e: Bool) {
        observers.forEach({ $0.update(calcModel: self, enter: e) })
    }

    func digitPressed(_ key: String) {
        workings += key
        notify(false)
    }

    func performOperation(_ op: String) {
        if (op == "ans") {
            workings += resultList.last!.result
        } else {
            workings += op
        }
        notify(false)
    }

    func clearAll() {
        workings = " "
        notify(false)
    }

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
    
    func calculate(_ phrase: String) -> String {
        let jsModule = context.objectForKeyedSubscript("AlgebriteList")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("Math")
        if let result = jsAnalyzer?.invokeMethod("run", withArguments: [phrase]) {
            return String(result.toString())
        }
        return " "
    }

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
    
    
    
    func formatResult(_ r: inout String) -> String {
        r.replace(".", with: ",")
        r.replace("pi", with: "π")
        r.replace("sqrt", with: "√")
        return r
    }

}
