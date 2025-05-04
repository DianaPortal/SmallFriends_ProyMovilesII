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
        estilizarCelda()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Aplicar animación de selección
        if selected {
            UIView.animate(withDuration: 0.2) {
                self.contentView.layer.shadowOpacity = 0.3
                self.contentView.layer.shadowRadius = 5
                self.contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
            }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.contentView.layer.shadowOpacity = 0
                }
            }
        }

        // Función para estilizar las etiquetas y la celda
        func estilizarCelda() {
            // Estilo para la celda
            self.layer.cornerRadius = 10
            self.layer.masksToBounds = true
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.1
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.backgroundColor = UIColor.white
            
            // Estilo para la etiqueta del título (citaLabel)
            citaLabel.font = UIFont.boldSystemFont(ofSize: 18)
            citaLabel.textColor = UIColor.systemBlue
            citaLabel.layer.cornerRadius = 5
            citaLabel.layer.masksToBounds = true
            
            // Estilo para la etiqueta de detalleCita
            detalleCita.font = UIFont.systemFont(ofSize: 14)
            detalleCita.textColor = UIColor.darkGray
            detalleCita.numberOfLines = 0
            detalleCita.lineBreakMode = .byWordWrapping
            detalleCita.layer.cornerRadius = 5
            detalleCita.layer.masksToBounds = true
            
            // Animación de deslizamiento en la carga
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: 30)
        }
        
        // Función para animar los elementos de la celda
        func animarCelda() {
            UIView.animate(withDuration: 1.0) {
                self.contentView.alpha = 1
                self.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        
        // Llamada para animar la celda desde el controlador que está usando la tabla
        func prepararAnimacion() {
            animarCelda()
        }
}
