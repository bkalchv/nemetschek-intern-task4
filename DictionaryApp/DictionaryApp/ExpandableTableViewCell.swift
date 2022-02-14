//
//  ExpandableTableViewCell.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 14.02.22.
//

import UIKit

class ExpandableTableViewCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationTextView: UITextView!
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var descriptionView: UIView! {
        didSet {
            descriptionView.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
