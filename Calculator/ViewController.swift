//
//  ViewController.swift
//  Calculator
//
//  Created by Niklas Diekhöner on 01.02.23.
//

import UIKit
import RichTextView
import SnapKit

// MARK: Observer

protocol Observer: AnyObject {

    func update(calcModel: CalcModel, enter: Bool)
    func alertInvalidInput()
}

// MARK: View

@IBDesignable
class ViewController: UIViewController, UITableViewDataSource, /*RichTextViewDelegate,*/ Observer {
    
//    let attributes = ["456": [NSAttributedString.Key.backgroundColor: UIColor.lightGray]]  // TODO: RichTextView

    @IBOutlet var tableView: UITableView!
    @IBOutlet var calculatorWorkingsUILabel: UILabel!
//    @IBOutlet var richTextView: RichTextView! // TODO: to show Math with Latex

    private var calcModel: CalcModel = CalcModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        calcModel.attach(self)
        /// RichTextView enables to show the Label as Latex.
//        richTextView = RichTextView( // TODO: RichTextView
//            input: "[math]x^2[/math]",
//            latexParser: LatexParser(),
//            font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
//            textColor: UIColor.black,
//            isSelectable: true,
//            isEditable: false,
//            latexTextBaselineOffset: 0,
//            interactiveTextColor: UIColor.blue,
//            textViewDelegate: nil,
//            frame: CGRect.zero,
//            completion: nil
//        )
        update(calcModel: calcModel, enter: false)
    }

    /// Updates the label that shows the calculator workings.
    /// If enter is pressed it scrolls down to show the newest result.
    func update(calcModel: CalcModel, enter: Bool) {
        calculatorWorkingsUILabel.text = calcModel.workings
//        richTextView.textViewDelegate = self  // TODO: RichTextView
//        richTextView.update(
//            input: "[math]" + calcModel.workings + "[/math]",
//            customAdditionalAttributes: attributes
//        )
        tableView.reloadData()
        if (enter) {
            scrollToBottom()
        }
    }

    /// Configures the TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calcModel.resultList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let results = calcModel.resultList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.calculatorResult.text = results.result
        cell.calculatorResultWorkings.text = results.resultWorking
        return cell
    }
    
    /// Scrolls to the bottom of the TableView
    func scrollToBottom(){
        if (self.calcModel.resultList.count > 0) {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.calcModel.resultList.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    /// Alert if the userinput is invalid.
    func alertInvalidInput() {
        let alert = UIAlertController(title: "Invalid Input",
                message: "Invalid Input",
                preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Configures the Buttons

    /// Removes the last symbol of the workings.
    @IBAction func deleteButton(_ sender: Any) {
        if (!calcModel.workings.isEmpty) {
            calcModel.workings.removeLast()
            calculatorWorkingsUILabel.text = calcModel.workings
//            richTextView.textViewDelegate = self  // TODO: RichTextView
//            richTextView.update(
//                input: calcModel.workings,
//                customAdditionalAttributes: attributes
//            )
        }
    }
    
    @IBAction func enterButton(_ sender: Any) {
        calcModel.enterPressed()
    }

    @IBAction func divideButton(_ sender: Any) {
        calcModel.performOperation("/")
    }

    @IBAction func timesButton(_ sender: Any) {
        calcModel.performOperation("×")
    }

    @IBAction func plusButton(_ sender: Any) {
        calcModel.performOperation("+")
    }

    @IBAction func minusButton(_ sender: Any) {
        calcModel.performOperation("-")
    }
    
    @IBAction func bracketOpen(_ sender: Any) {
        calcModel.performOperation("(")
    }
    
    @IBAction func bracketClose(_ sender: Any) {
        calcModel.performOperation(")")
    }
    
    @IBAction func pi(_ sender: Any) {
        calcModel.performOperation("π")
    }
    
    @IBAction func e(_ sender: Any) {
        calcModel.performOperation("e")
    }
    
    @IBAction func powerOf(_ sender: Any) {
        calcModel.performOperation("^")
    }
    
    @IBAction func squareRoot(_ sender: Any) {
        calcModel.performOperation("√(")
    }
    
    @IBAction func ln(_ sender: Any) {
        calcModel.performOperation("ln(")
    }
    
    @IBAction func ans(_ sender: Any) {
        calcModel.performOperation("ans")
    }

    @IBAction func kommaButton(_ sender: Any) {
        calcModel.digitPressed(",")
    }

    @IBAction func zeroButton(_ sender: Any) {
        calcModel.digitPressed("0")
    }

    @IBAction func oneButton(_ sender: Any) {
        calcModel.digitPressed("1")
    }

    @IBAction func twoButton(_ sender: Any) {
        calcModel.digitPressed("2")
    }

    @IBAction func threeButton(_ sender: Any) {
        calcModel.digitPressed("3")
    }

    @IBAction func fourButton(_ sender: Any) {
        calcModel.digitPressed("4")
    }

    @IBAction func fiveButton(_ sender: Any) {
        calcModel.digitPressed("5")
    }

    @IBAction func sixButton(_ sender: Any) {
        calcModel.digitPressed("6")
    }

    @IBAction func sevenButton(_ sender: Any) {
        calcModel.digitPressed("7")
    }

    @IBAction func eightButton(_ sender: Any) {
        calcModel.digitPressed("8")
    }

    @IBAction func nineButton(_ sender: Any) {
        calcModel.digitPressed("9")
    }
    
//    func didTapCustomLink(withID linkID: String) {  // TODO: RichTextView
//        DispatchQueue.main.async {
//                let alertController = UIAlertController(title: "Custom Link", message: linkID, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
//                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
//        }
//    }
}


