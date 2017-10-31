//
//  TableViewCell.swift
//  CurrencyConverterTask
//
//  Created by macbook on 31/10/17.
//  Copyright © 2017 Falconnect Technologies Private Limited Falconnect Technologies Private Limited Falconnect Technologies Private Limited. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyNameLabel: UILabel!
    
    @IBOutlet weak var AmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
