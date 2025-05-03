//
//  ListNotificacionesTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//

import UIKit

class ListNotificacionesTableViewCell: UITableViewCell {

    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                self.selectionStyle = .none
                self.contentView.layer.cornerRadius = 10
                self.contentView.layer.borderWidth = 1
                self.contentView.layer.borderColor = UIColor.systemGray5.cgColor
                self.contentView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
