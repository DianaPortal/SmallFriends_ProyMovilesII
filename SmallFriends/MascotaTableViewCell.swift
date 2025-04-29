//
//  MascotaTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class MascotaTableViewCell: UITableViewCell {

    @IBOutlet weak var fotoMascotaIV: UIImageView!
    @IBOutlet weak var nombreMascotaLabel: UILabel!
    @IBOutlet weak var detallesMascota: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
