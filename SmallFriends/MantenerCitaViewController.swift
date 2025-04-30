//
//  MantenerCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData

class MantenerCitaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    @IBOutlet weak var lugarLabel: UILabel!
    @IBOutlet weak var lugarTextField: UITextField!
    @IBOutlet weak var tipoCitaLabel: UILabel!
    @IBOutlet weak var tipoCitaPickerView: UIPickerView!
    @IBOutlet weak var descripCitaLabel: UILabel!
    @IBOutlet weak var descripCitaTextField: UITextField!
    
//Opciones de tipo de citas para las mascotas
    let tipoCita = ["Consulta Médica", "Limpieza Completa", "Vacunación", "Baño", "Revisión"]
    
    // Propiedad para almacenar la cita que se va a actualizar
    var citaAActualizar: CitasCD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuración dek UIPickerView
        tipoCitaPickerView.delegate = self
        tipoCitaPickerView.dataSource = self
        
        //ACTUALIZAR
        // Si hay una cita para actualizar, configurar los campos con sus valores
        if let cita = citaAActualizar {
        // Asignar valores de la cita a los campos
            fechaDatePicker.date = cita.fechaCita ?? Date()  // Si la fecha es nil, usamos la fecha actual
            lugarTextField.text = cita.lugarCita
            descripCitaTextField.text = cita.descripcionCita

        // Establecer el tipo de cita en el picker según la cita
        if let tipo = cita.tipoCita, let index = tipoCita.firstIndex(of: tipo) {
                       tipoCitaPickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    //Acciones
    
    @IBAction func guardarTapped(_ sender: UIButton) {
        guard
            let lugar = campo(lugarTextField, nombre: "Lugar")
        else {
            print("Error: Campos inválidos")
            return
            }
        
        // ADICION DE VALOR POR DEFECTO PARA EL CAMPO DESCRIPCION
        let descripcion = descripCitaTextField.text?.isEmpty == false ? descripCitaTextField.text! : "Sin descripcion"
               
        // Obtener la fecha seleccionada del UIDatePicker
            let fecha = fechaDatePicker.date
               
        // Obtener el tipo de cita seleccionado del UIPickerView
            let tipoCitaSeleccionado = tipoCita[tipoCitaPickerView.selectedRow(inComponent: 0)]
               
        // Guardar en Core Data
        guardarEnCoreData(fecha: fecha, lugar: lugar, tipoCita: tipoCitaSeleccionado, descripcion: descripcion)
               
        // Limpiar los campos
        //limpiarCampos()
        
        mostrarAlerta(titulo: "Éxito", mensaje: citaAActualizar != nil ? "Cita actualizada correctamente" : "Cita registrada correctamente") {
            self.navigationController?.popViewController(animated: true)
        }
   }
    
    func guardarEnCoreData(fecha: Date, lugar: String, tipoCita: String, descripcion: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                
                // Si estamos actualizando una cita
                if let cita = citaAActualizar {
                    // Usa la variable 'cita' que fue definida en el 'if let' para actualizar la cita existente
                        cita.fechaCita = fecha
                        cita.lugarCita = lugar
                        cita.tipoCita = tipoCita
                        cita.descripcionCita = descripcion
                    // Simplemente guardamos los cambios de la cita existente
                    do {
                        try context.save()
                        print("Cita actualizada exitosamente")
                    } catch {
                        print("Error al actualizar la cita: \(error.localizedDescription)")
                    }
                } else {
                    // Si estamos creando una nueva cita
                    let fetchRequest: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
                    
                    // Ordenar por el idCita para encontrar el más alto
                    let sortDescriptor = NSSortDescriptor(key: "idCita", ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                    
                    var nuevoIdCita: Int16 = 1001 // Valor por defecto
                    
                    do {
                        let citas = try context.fetch(fetchRequest)
                        
                        if let ultimaCita = citas.first {
                            if ultimaCita.idCita < Int16.max {
                                nuevoIdCita = ultimaCita.idCita + 1
                            }
                        }
                    } catch {
                        print("Error al obtener las citas: \(error)")
                    }
                    
                    // Crear una nueva instancia de la entidad Citas
                    let nuevaCita = CitasCD(context: context)
                    nuevaCita.fechaCita = fecha
                    nuevaCita.lugarCita = lugar
                    nuevaCita.tipoCita = tipoCita
                    nuevaCita.descripcionCita = descripcion
                    nuevaCita.idCita = nuevoIdCita
                    nuevaCita.estadoCita = "Activa"
                    
                    // OBTENER USUARIO LOGUEADO
                    let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
                    if let correoGuardado = UserDefaults.standard.string(forKey: "email") {
                        fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)
                        
                        do {
                            let usuarios = try context.fetch(fetchRequestUsuario)
                            if let usuario = usuarios.first {
                                nuevaCita.usuario = usuario
                            } else {
                                print("No se encontró el usuario logueado")
                            }
                        } catch {
                            print("Error al obtener el usuario logueado: \(error.localizedDescription)")
                        }
                    }
                    
                    // Guardar cambios en core data
                    do {
                        try context.save()
                        print("Cita guardada exitosamente")
                    } catch {
                        print("Error al guardar la cita: \(error.localizedDescription)")
                    }
                }
        }
    
    // Función para limpiar los campos del formulario (LA FUNCION YA NO ES NECESARIA, PORQUE LUEGO DE MANTENER, REDIRIGE A UNA VISTA DISTINTA)
    func limpiarCampos() {
            lugarTextField.text = ""
            descripCitaTextField.text = ""
            tipoCitaPickerView.selectRow(0, inComponent: 0, animated: true)  // Restablecer el PickerView a la primera opción
            fechaDatePicker.date = Date()  // Restablecer la fecha al valor actual
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tipoCita.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Mostrar las opciones en el Picker
        return tipoCita[row]
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
    
    // FUNCION PARA MOSTRAR ALERTA PERSONALIZADA
    func mostrarAlerta(titulo: String, mensaje: String, alAceptar: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alAceptar?()
        })
        present(alerta, animated: true, completion: nil)
    }
}
