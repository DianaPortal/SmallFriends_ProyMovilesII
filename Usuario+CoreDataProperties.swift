//
//  Usuario+CoreDataProperties.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//
//

import Foundation
import CoreData


extension Usuario {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        return NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    @NSManaged public var idUsuario: String?
    @NSManaged public var email: String?
    @NSManaged public var provider: String?

}

extension Usuario : Identifiable {

}
