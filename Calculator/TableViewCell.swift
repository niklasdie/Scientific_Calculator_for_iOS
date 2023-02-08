//
//  TableViewCell.swift
//  Calculator
//
//  Created by Niklas Diekhöner on 03.02.23.
//

import UIKit

/// Class represens a cell in the TableView.
class TableViewCell: UITableViewCell {

    @IBOutlet weak var calculatorResultWorkings: UILabel!
    @IBOutlet weak var calculatorResult: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
