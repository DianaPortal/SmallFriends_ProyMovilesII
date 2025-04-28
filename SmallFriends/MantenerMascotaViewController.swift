//
//  MantenerMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit

class MantenerMascotaViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var mascotaAEditar: Mascota?
    var imagenSeleccionada: UIImage?
    
    let tipos = ["Perro", "Gato"]
    let pickerTipo = UIPickerView()
    
    @IBOutlet weak var fotoImageView: UIImageView!
    @IBOutlet weak var nombreField: UITextField!
    @IBOutlet weak var edadField: UITextField!
    @IBOutlet weak var tipoField: UITextField!
    @IBOutlet weak var pesoField: UITextField!
    @IBOutlet weak var razaField: UITextField!
    @IBOutlet weak var dniField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = mascotaAEditar == nil ? "🐶 Registrar Mascota 🐱" : "🐶 Actualizar Mascota 🐱"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarFoto))
            fotoImageView.addGestureRecognizer(tapGesture)
            fotoImageView.isUserInteractionEnabled = true
        
        tipoField.inputView = pickerTipo
        pickerTipo.delegate = self
        pickerTipo.dataSource = self
        
        cargarDatosParaEditar()
    }
    
    @objc func seleccionarFoto() {
        let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true)
    }
    
    @IBAction func botonGuardarTapped(_ sender: UIButton) {
        guardarMascota()
    }
    
    func cargarDatosParaEditar() {
            guard let mascota = mascotaAEditar else { return }
            nombreField.text = mascota.nombre
            edadField.text = "\(mascota.edad)"
            tipoField.text = mascota.tipo
            pesoField.text = mascota.peso?.stringValue
            razaField.text = mascota.raza
            dniField.text = mascota.dni
            if let datosFoto = mascota.foto {
                fotoImageView.image = UIImage(data: datosFoto)
            } else {
                fotoImageView.image = UIImage(named: "Mascotaswelcome")
            }
        
            // MOSTRAR EL VALOR SE LE EIGIO AL CREAR
            if let tipo = mascota.tipo, let index = tipos.firstIndex(of: tipo) {
                    pickerTipo.selectRow(index, inComponent: 0, animated: false)
            }
        }
    
    @objc func guardarMascota() {
        guard
            let nombre = campo(nombreField, nombre: "Nombre"),
            let edadTexto = campo(edadField, nombre: "Edad"),
            let edad = Int16(edadTexto),
            let tipo = tipoField.text,
            let pesoTexto = campo(pesoField, nombre: "Peso"),
            let raza = campo(razaField, nombre: "Raza"),
            let dni = campo(dniField, nombre: "DNI")
        else { return }

        // VALIDAR PESO
        guard let pesoDecimal = NSDecimalNumber(string: pesoTexto).isEqual(to: NSDecimalNumber.notANumber) ? nil : NSDecimalNumber(string: pesoTexto) else {
            mostrarAlerta(mensaje: "Peso inválido")
            return
        }

        // VALIDAR DNI
        guard validarDNI(dni) else {
            mostrarAlerta(mensaje: "El DNI debe contener exactamente 8 dígitos numéricos.")
            return
        }

        let mascota: Mascota
        if let mascotaExistente = mascotaAEditar {
            // EDITAR
            mascota = mascotaExistente
        } else {
            mascota = Mascota(context: CoreDataManager.shared.context)
        }

        // Asignar campos
        mascota.nombre = nombre
        mascota.edad = edad
        mascota.tipo = tipo
        mascota.peso = pesoDecimal
        mascota.raza = raza
        mascota.dni = dni

        // Asignar foto
        if let imagen = imagenSeleccionada,
           let imagenData = imagen.jpegData(compressionQuality: 0.8) {
            mascota.foto = imagenData
        } else if let imagenPorDefecto = UIImage(named: "Mascotaswelcome"),
                  let dataPorDefecto = imagenPorDefecto.jpegData(compressionQuality: 0.8) {
            mascota.foto = dataPorDefecto
        }

        CoreDataManager.shared.saveContext()

        mostrarAlerta(titulo: "Éxito", mensaje: mascotaAEditar != nil ? "Mascota actualizada correctamente." : "Mascota registrada correctamente.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // FUNCION PARA MOSTRAR ALERTA POR ERRORES EN LOS CAMPOS
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    // FUNCION PARA MOSTRAR ALERTA DE ERROR EN CASO HAYA CAMPOS VACIOS
    func campo(_ textField: UITextField, nombre: String) -> String? {
        guard let texto = textField.text, !texto.isEmpty else {
            mostrarAlerta(mensaje: "El campo \(nombre) no puede estar vacío.")
            return nil
        }
        return texto
    }
    
    // FUNCION PARA VALIDAR DNI
    func validarDNI(_ dni: String) -> Bool {
        let caracteresNoNumericos = CharacterSet.decimalDigits.inverted
        return dni.count == 8 && dni.rangeOfCharacter(from: caracteresNoNumericos) == nil
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, alAceptar: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alAceptar?()
        })
        present(alerta, animated: true, completion: nil)
    }
    
    // METODOS PICKER
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tipos.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tipos[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tipoField.text = tipos[row]
    }
}

extension MantenerMascotaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagen = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imagenSeleccionada = imagen
            fotoImageView.image = imagen
        }
        picker.dismiss(animated: true)
    }
}
