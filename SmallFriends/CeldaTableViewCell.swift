//
//  CeldaTableViewCell.swift
//  SmallFriends
//
//  Created by Diana on 28/04/25.
//

import UIKit

class CeldaEventosTableViewCell: UITableViewCell {
    @IBOutlet weak var eventoLabel: UILabel!
    @IBOutlet weak var fechaEventoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
