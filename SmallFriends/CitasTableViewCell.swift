//
//  CitasTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//

import UIKit

class CitasTableViewCell: UITableViewCell {

    @IBOutlet weak var citaLabel: UILabel!
    @IBOutlet weak var detalleCita: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
