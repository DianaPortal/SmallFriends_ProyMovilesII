//
//  DetalleEvento.swift
//  SmallFriends
//
//  Created by Diana on 2/05/25.
//

struct DetalleEvento: Codable {
    let id: Int
    let titulo: String
    let descripcion: String
    let fecha: String
    let hora: String
    let ubicacion: String
    let latitud: Double
    let longitud: Double
}

