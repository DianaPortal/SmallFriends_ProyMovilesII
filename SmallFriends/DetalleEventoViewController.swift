//
//  DetalleEventoViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class DetalleEventoViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapaImagen: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Coordenadas de ejemplo
        
        /*let latitude: Double = -12.04646
        
        let longitude: Double = -77.02945*/
        
        let urlString = "https://nominatim.openstreetmap.org/ui/reverse.html?lat=-12.04646&lon=-77.02945&zoom=18"
        
        /*"https://staticmap.openstreetmap.de/staticmap.php?center=\(latitude),\(longitude)&zoom=15&size=600x400&markers=\(latitude),\(longitude)"*/
        
        if let url = URL(string: urlString) {downloadImage(from: url)
      
        }
    }
    
    func downloadImage(from url: URL) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
          if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.mapaImagen.image = image
            }

          } else {
            print("Error al obtener la imagen: \(error?.localizedDescription ?? "Desconocido")")
          }
        }
        task.resume()

      }
    }
