//
//  HistorialTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 19/04/25.
//

import UIKit

class HistorialTableViewCell: UITableViewCell {

    @IBOutlet weak var fechaRegistroLabel: UILabel!
    
    @IBOutlet weak var tipoHistorialLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
