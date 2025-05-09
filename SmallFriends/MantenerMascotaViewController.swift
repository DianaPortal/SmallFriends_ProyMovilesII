//
//  MantenerMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseFirestore

/// `MantenerMascotaViewController` es una clase de vista para registrar y editar información de una mascota.
/// Gestiona la captura de datos como nombre, edad, tipo, peso, raza, DNI y foto, y los almacena tanto en CoreData como en Firestore.
class MantenerMascotaViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// La mascota a editar (si es un caso de edición)
    var mascotaAEditar: Mascota?
    
    /// Imagen seleccionada para la mascota
    var imagenSeleccionada: UIImage?
    
    /// Tipos de mascota disponibles para seleccionar (Perro, Gato)
    let tipos = ["Perro", "Gato"]
    
    /// Componente `UIPickerView` para seleccionar el tipo de mascota
    let pickerTipo = UIPickerView()
    
    // MARK: - IBOutlets
    @IBOutlet weak var fotoImageView: UIImageView!
    @IBOutlet weak var nombreField: UITextField!
    @IBOutlet weak var edadField: UITextField!
    @IBOutlet weak var tipoField: UITextField!
    @IBOutlet weak var pesoField: UITextField!
    @IBOutlet weak var razaField: UITextField!
    @IBOutlet weak var dniField: UITextField!
    
    /// Instancia de Firestore para interactuar con la base de datos en la nube
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configura el título dependiendo de si estamos registrando o editando
        title = mascotaAEditar == nil ? "🐶 Registrar Mascota 🐱" : "🐶 Actualizar Mascota 🐱"
        
        // Configura el gesto para seleccionar foto desde la galería
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarFoto))
        fotoImageView.addGestureRecognizer(tapGesture)
        fotoImageView.isUserInteractionEnabled = true
        
        // Configura el picker de tipo de mascota
        tipoField.inputView = pickerTipo
        tipoField.tintColor = .clear
        tipoField.delegate = self
        pickerTipo.delegate = self
        pickerTipo.dataSource = self
        
        // Configura la barra de herramientas con un botón "Listo"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(cerrarPicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        tipoField.inputAccessoryView = toolbar
        
        // Si es un nuevo registro, selecciona la primera opción del picker
        if mascotaAEditar == nil {
            tipoField.text = tipos.first
            pickerTipo.selectRow(0, inComponent: 0, animated: false)
        }
        
        // Carga los datos de la mascota si es necesario
        cargarDatosParaEditar()
    }
    
    /// Permite seleccionar una foto de la galería
    @objc func seleccionarFoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    /// Acción del botón "Guardar"
    @IBAction func botonGuardarTapped(_ sender: UIButton) {
        guardarMascota()
    }
    
    /// Carga los datos de la mascota en los campos para editar
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
            fotoImageView.image = UIImage(named: "perfil_default")
        }
        
        // Configura el picker con el tipo de mascota previamente seleccionado
        if let tipo = mascota.tipo, let index = tipos.firstIndex(of: tipo) {
            pickerTipo.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    /// Guarda la mascota en CoreData y Firestore
    @objc func guardarMascota() {
        guard
            let nombre = campo(nombreField, nombre: "Nombre"),
            let edadTexto = campo(edadField, nombre: "Edad"),
            let edad = Int16(edadTexto),
            let pesoTexto = campo(pesoField, nombre: "Peso")
        else { return }
        
        // Si el campo de raza está vacío, asigna "Mestizo" como valor por defecto
        let raza = razaField.text?.isEmpty == false ? razaField.text! : "Mestizo"
        
        // Si el campo DNI está vacío, asigna "Sin dni" como valor por defecto
        let dni = dniField.text?.isEmpty == false ? dniField.text! : "Sin dni"
        
        // Valida el tipo de mascota seleccionado
        guard let tipo = tipoField.text, tipos.contains(tipo) else {
            mostrarAlerta(mensaje: "Seleccione un tipo de mascota")
            return
        }
        
        // Valida el peso
        guard let pesoDecimal = NSDecimalNumber(string: pesoTexto).isEqual(to: NSDecimalNumber.notANumber) ? nil : NSDecimalNumber(string: pesoTexto) else {
            mostrarAlerta(mensaje: "Peso inválido")
            return
        }
        
        // Valida el DNI
        guard validarDNI(dni) else {
            mostrarAlerta(mensaje: "El DNI debe contener exactamente 8 dígitos numéricos")
            return
        }
        
        let mascota: Mascota
        if let mascotaExistente = mascotaAEditar {
            // Edita una mascota existente
            mascota = mascotaExistente
        } else {
            // Crea una nueva mascota
            mascota = Mascota(context: CoreDataManager.shared.context)
            mascota.id = UUID().uuidString  // Asigna un ID único a la mascota
        }
        
        // Asigna los valores a la mascota
        mascota.nombre = nombre.capitalizedFirstLetter
        mascota.edad = edad
        mascota.tipo = tipo
        mascota.peso = pesoDecimal
        mascota.raza = raza.capitalizedFirstLetter
        mascota.dni = dni
        mascota.estadoMascota = "Activa"
        
        // Asigna la foto seleccionada o una foto predeterminada
        if let imagen = imagenSeleccionada,
           let imagenData = imagen.jpegData(compressionQuality: 0.8) {
            mascota.foto = imagenData
        } else if let mascotaExistente = mascotaAEditar,
                  let fotoExistente = mascotaExistente.foto {
            mascota.foto = fotoExistente
        } else {
            if let imagenPorDefecto = UIImage(named: "perfil_default"),
               let dataPorDefecto = imagenPorDefecto.jpegData(compressionQuality: 0.8) {
                mascota.foto = dataPorDefecto
            }
        }
        
        // Asigna el usuario logueado a la mascota
        if let usuarioLogueado = obtenerUsuarioLogueado() {
            mascota.usuario = usuarioLogueado
        } else {
            mostrarAlerta(mensaje: "No hay usuario logueado")
            return
        }
        
        // Guarda el contexto de CoreData
        CoreDataManager.shared.saveContext()
        
        // ** Sincroniza con Firestore **
        let referencia: DocumentReference
        let id = mascota.id ?? UUID().uuidString
        referencia = db.collection("mascotas").document(id)
        
        let data: [String: Any] = [
            "nombre": mascota.nombre ?? "",
            "edad": mascota.edad,
            "tipo": mascota.tipo ?? "",
            "peso": mascota.peso ?? 0,
            "raza": mascota.raza ?? "",
            "dni": mascota.dni ?? "",
            "foto": mascota.foto != nil ? UIImage(data: mascota.foto!)?.jpegData(compressionQuality: 0.8)?.base64EncodedString() : nil,
            "estadoMascota": mascota.estadoMascota ?? "Activa"
        ]
        
        referencia.setData(data) { error in
            if let error = error {
                print("Error al registrar mascota en Firestore: \(error)")
                self.mostrarAlerta(mensaje: "Hubo un error al registrar la mascota en Firestore.")
            } else {
                print("Mascota registrada exitosamente en Firestore.")
                self.mostrarAlerta(titulo: "Éxito", mensaje: self.mascotaAEditar != nil ? "Mascota actualizada correctamente" : "Mascota registrada correctamente") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    // MARK: - Métodos de validación y ayudas
    
    /// Muestra una alerta con el mensaje de error proporcionado
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    /// Valida si el campo de texto está vacío
    func campo(_ textField: UITextField, nombre: String) -> String? {
        guard let texto = textField.text, !texto.isEmpty else {
            mostrarAlerta(mensaje: "El campo \(nombre) no puede estar vacío")
            return nil
        }
        return texto
    }
    
    /// Valida que el DNI tenga 8 dígitos numéricos
    func validarDNI(_ dni: String?) -> Bool {
        guard let dni = dni else { return false }
        
        // Si el DNI es el valor por defecto, no se valida
        if dni == "Sin dni" {
            return true
        }
        
        // Valida que el DNI tenga exactamente 8 dígitos numéricos
        let caracteresNoNumericos = CharacterSet.decimalDigits.inverted
        return dni.count == 8 && dni.rangeOfCharacter(from: caracteresNoNumericos) == nil
    }
    
    /// Muestra una alerta personalizada
    func mostrarAlerta(titulo: String, mensaje: String, alAceptar: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alAceptar?()
        })
        present(alerta, animated: true, completion: nil)
    }
    
    // MARK: - Métodos UIPickerView
    
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
    
    /// Cierra el picker al presionar el botón "Listo"
    @objc func cerrarPicker() {
        tipoField.resignFirstResponder()
    }
    
    // MARK: - Métodos de usuario
    
    /// Obtiene el usuario logueado desde CoreData
    func obtenerUsuarioLogueado() -> Usuario? {
        guard let correoGuardado = UserDefaults.standard.string(forKey: "email") else {
            print("No hay usuario logueado en UserDefaults")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", correoGuardado)
        
        do {
            let usuarios = try CoreDataManager.shared.context.fetch(fetchRequest)
            return usuarios.first
        } catch {
            print("Error al obtener el usuario logueado: \(error)")
            return nil
        }
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

extension MantenerMascotaViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Bloquea la edición en el campo de texto tipo de mascota
        if textField == tipoField {
            return false
        }
        return true
    }
}

// MARK: - Extensión para capitalizar la primera letra de una cadena
extension String {
    var capitalizedFirstLetter: String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}
