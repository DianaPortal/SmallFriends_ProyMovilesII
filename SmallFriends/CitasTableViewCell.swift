//
//  CitasTableViewCell.swift
//  SmallFriends
//
//  Created by DAMII on 27/04/25.
//

import UIKit

/// Esta clase es una subclase de `UITableViewCell` que se utiliza para mostrar una celda personalizada en la tabla de citas.
/// La celda incluye dos etiquetas para mostrar información sobre la cita y aplica varios estilos visuales y animaciones a la celda.
class CitasTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    /// Etiqueta que muestra el tipo de cita.
    @IBOutlet weak var citaLabel: UILabel!
    
    /// Etiqueta que muestra los detalles de la cita (como la fecha y la mascota asociada).
    @IBOutlet weak var detalleCita: UILabel!
    
    // MARK: - Ciclo de vida de la celda
    
    /// Método que se llama cuando la celda es cargada desde el nib. Se utiliza para estilizar la celda.
    override func awakeFromNib() {
        super.awakeFromNib()
        estilizarCelda() // Estiliza la celda cuando se carga
    }
    
    /// Método que se llama cuando la celda es seleccionada o deseleccionada.
    /// Aplica una animación de sombra cuando la celda es seleccionada.
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
    
    // MARK: - Métodos de estilo y animación
    
    /// Función que aplica estilos visuales a la celda y sus elementos (etiquetas y fondo).
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
    
    /// Función que anima la celda deslizándola hacia su posición original y aumentando su opacidad.
    func animarCelda() {
        UIView.animate(withDuration: 1.0) {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    // MARK: - Funciones para preparar animación
    
    /// Función que prepara la animación de la celda, es llamada por el controlador que usa la celda en la tabla.
    func prepararAnimacion() {
        animarCelda() // Llama a la función de animación
    }
}
