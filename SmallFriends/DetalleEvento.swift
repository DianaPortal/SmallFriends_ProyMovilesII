//
//  DetalleEvento.swift
//  SmallFriends
//
//  Created by DAMII on 3/05/25.
//

/// Estructura que representa los detalles de un evento.
struct DetalleEvento: Codable {
    
    // MARK: - Propiedades
    
    /// Identificador único del evento.
    let id: Int
    
    /// Título o nombre del evento.
    let titulo: String
    
    /// Descripción detallada del evento.
    let descripcion: String
    
    /// Fecha en la que se llevará a cabo el evento (en formato de cadena de texto).
    let fecha: String
    
    /// Hora en la que se llevará a cabo el evento (en formato de cadena de texto).
    let hora: String
    
    /// Ubicación del evento (dirección o lugar donde se realiza).
    let ubicacion: String
    
    /// Latitud de la ubicación del evento.
    let latitud: Double
    
    /// Longitud de la ubicación del evento.
    let longitud: Double
}
