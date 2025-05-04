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
        // Estilizar la celda
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        // Sombra (en el layer de la celda, no del contentView)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
                
        // Texto estilizado
        eventoLabel.font = UIFont.boldSystemFont(ofSize: 17)
        eventoLabel.textColor = UIColor.systemBlue

        fechaEventoLabel.font = UIFont.systemFont(ofSize: 15)
        fechaEventoLabel.textColor = UIColor.darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Animación al seleccionar
        if selected {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = UIColor.systemGray6
                }
        }
    }
    
    // margen entre celdas
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            contentView.frame = contentView.frame.inset(by: margins)
        }
}
