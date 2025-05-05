//
//  MantenerMascotaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData

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
        
        
        // CAMBIO DE TITLE DEPENDIENDO DE LA ACCION
        title = mascotaAEditar == nil ? "🐶 Registrar Mascota 🐱" : "🐶 Actualizar Mascota 🐱"
        
        // FUNCIONALIDAD PARA IMPORTAR FOTO DESDE GALERIA
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarFoto))
        fotoImageView.addGestureRecognizer(tapGesture)
        fotoImageView.isUserInteractionEnabled = true
        
        // COMBOBOX PARA TIPO MASCOTA
        tipoField.inputView = pickerTipo
        tipoField.tintColor = .clear
        tipoField.delegate = self
        pickerTipo.delegate = self
        pickerTipo.dataSource = self
        
        // BARRA DE HERRAMIENTAS CON BOTON "LISTO"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(cerrarPicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        tipoField.inputAccessoryView = toolbar
        
        // ESTABLECER LA PRIMERA OPCION DEL PICKER COMO LA OPCION POR DEFECTO
        if mascotaAEditar == nil {
            tipoField.text = tipos.first
            pickerTipo.selectRow(0, inComponent: 0, animated: false)
        }
        
        cargarDatosParaEditar()
    }
    
    // FUNCION PARA IMPORTAR FOTO DESDE GALERIA
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
            fotoImageView.image = UIImage(named: "perfil_default")
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
            let pesoTexto = campo(pesoField, nombre: "Peso")
        else { return }
        
        // ADICION DE VALOR POR DEFECTO PARA EL CAMPO RAZA
        let raza = razaField.text?.isEmpty == false ? razaField.text! : "Mestizo"
        
        // ADICION DE VALOR POR DEFECTO PARA EL CAMPO DNI
        let dni = dniField.text?.isEmpty == false ? dniField.text! : "Sin dni"
        
        // VALIDAR TIPO DE MASCOTA
        guard let tipo = tipoField.text, tipos.contains(tipo) else {
            mostrarAlerta(mensaje: "Seleccione un tipo de mascota")
            return
        }
        
        // VALIDAR PESO
        guard let pesoDecimal = NSDecimalNumber(string: pesoTexto).isEqual(to: NSDecimalNumber.notANumber) ? nil : NSDecimalNumber(string: pesoTexto) else {
            mostrarAlerta(mensaje: "Peso inválido")
            return
        }
        
        // VALIDAR DNI
        guard validarDNI(dni) else {
            mostrarAlerta(mensaje: "El DNI debe contener exactamente 8 dígitos numéricos")
            return
        }
        
        let mascota: Mascota
        if let mascotaExistente = mascotaAEditar {
            // EDITAR
            mascota = mascotaExistente
        } else {
            mascota = Mascota(context: CoreDataManager.shared.context)
        }
        
        // ASIGNA CAMPOS
        mascota.nombre = nombre.capitalizedFirstLetter
        mascota.edad = edad
        mascota.tipo = tipo
        mascota.peso = pesoDecimal
        mascota.raza = raza.capitalizedFirstLetter
        mascota.dni = dni
        mascota.estadoMascota = "Activa"
        
        // ASIGNAR FOTO (SOLO SI SE HA SELECCIONADO UNA NUEVA IMAGEN, SINO MANTENER LA QUE YA ESTABA REGISTRADA
        if let imagen = imagenSeleccionada,
           let imagenData = imagen.jpegData(compressionQuality: 0.8) {
            mascota.foto = imagenData
        } else if let mascotaExistente = mascotaAEditar,
                  let fotoExistente = mascotaExistente.foto {
            // SI NO SE SELECCIONO UNA IMAGEN, MANTENER LA EXISTENTE
            mascota.foto = fotoExistente
        } else {
            // SI NO SE SELECCIONO UNA IMAGEN, Y NO HAY IMAGEN PREVIA, ASIGNA FOTO POR DEFECTO
            if let imagenPorDefecto = UIImage(named: "perfil_default"),
               let dataPorDefecto = imagenPorDefecto.jpegData(compressionQuality: 0.8) {
                mascota.foto = dataPorDefecto
            }
        }
        
        // ASIGNA USUARIO OBTENIDO
        if let usuarioLogueado = obtenerUsuarioLogueado() {
            mascota.usuario = usuarioLogueado
        } else {
            mostrarAlerta(mensaje: "No hay usuario logueado")
            return
        }
        
        CoreDataManager.shared.saveContext()
        
        mostrarAlerta(titulo: "Éxito", mensaje: mascotaAEditar != nil ? "Mascota actualizada correctamente" : "Mascota registrada correctamente") {
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
            mostrarAlerta(mensaje: "El campo \(nombre) no puede estar vacío")
            return nil
        }
        return texto
    }
    
    // FUNCION PARA VALIDAR DNI
    func validarDNI(_ dni: String?) -> Bool {
        guard let dni = dni else { return false }
        
        // SI EL DNI ES EL VALOR POR DEFECTO, NO SE HACE VALIDACION DE CARACTERES NUMERICOS
        if dni == "Sin dni" {
            return true
        }
        
        // VALIDACION DE CARACTERES NUMERICOS Y RANGO DE CARACTERES
        let caracteresNoNumericos = CharacterSet.decimalDigits.inverted
        return dni.count == 8 && dni.rangeOfCharacter(from: caracteresNoNumericos) == nil
    }
    
    // FUNCION PARA MOSTRAR ALERTA PERSONALIZADA
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
    
    @objc func cerrarPicker() {
        tipoField.resignFirstResponder()
    }
    
    // FUNCION PARA OBTENER EL USUARIO LOGUEADO
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
        // BLOQUE LA EDICION EN EL CAMPO DE TEXTO TIPO MASCOTA
        if textField == tipoField {
            return false
        }
        return true
    }
}

// EXTENSION PARA APLICAR MAYUSCULAS A la PRIMERA LETRA DEL VALOR Y MINUSCULAS AL RESTO
extension String {
    var capitalizedFirstLetter: String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}
