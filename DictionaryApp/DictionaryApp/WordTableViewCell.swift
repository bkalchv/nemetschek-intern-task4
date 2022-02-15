//
//  WordTableViewCell.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationView: UIView!
    @IBOutlet weak var translationTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        translationView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
