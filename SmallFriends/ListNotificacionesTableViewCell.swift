//
//  ListNotificacionesTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//

import UIKit

class ListNotificacionesTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        // Fondo transparente en contentView
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        // Estilo visual moderno
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .systemBackground
    }
}
