//
//  CalculatorWorkings.swift
//  Calculator
//
//  Created by Niklas Diekhöner on 07.02.23.
//

import UIKit
import RichTextView

// TODO: RichTextView
/// This class is for RichTextView.
class CalculatorLabel: UIView, RichTextViewDelegate {
    
    // MARK: - Constants
    let attributes = ["456": [NSAttributedString.Key.backgroundColor: UIColor.lightGray]]
    
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var outputRichTextView: RichTextView!
    
    // MARK: - Init
    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setupWithNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupWithNib()
    }
    
    // MARK: - Helpers
    
    private func setupWithNib() {
        Bundle.main.loadNibNamed("CalculatorLabel", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    func updateText(_ text: String) {
        self.inputLabel.text = text
        self.outputRichTextView.textViewDelegate = self
        self.outputRichTextView.update(
            input: text,
            customAdditionalAttributes: self.attributes
        )
    }
    
    // MARK: - RichTextViewDelegate
    
    func didTapCustomLink(withID linkID: String) {
        DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Custom Link", message: linkID, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
        }
    }
    
}
