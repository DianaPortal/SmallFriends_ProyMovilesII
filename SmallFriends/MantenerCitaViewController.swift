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
            let lugar = lugarTextField.text, !lugar.isEmpty,
            let descripcion = descripCitaTextField.text, !descripcion.isEmpty
        else {
            print("Error: Campos inválidos")
            return
            }
               
        // Obtener la fecha seleccionada del UIDatePicker
            let fecha = fechaDatePicker.date
               
        // Obtener el tipo de cita seleccionado del UIPickerView
            let tipoCitaSeleccionado = tipoCita[tipoCitaPickerView.selectedRow(inComponent: 0)]
               
    // Guardar en Core Data
    guardarEnCoreData(fecha: fecha, lugar: lugar, tipoCita: tipoCitaSeleccionado, descripcion: descripcion)
               
    // Limpiar los campos
    limpiarCampos()
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
                    
                    // Guardar cambios en core data
                    do {
                        try context.save()
                        print("Cita guardada exitosamente")
                    } catch {
                        print("Error al guardar la cita: \(error.localizedDescription)")
                    }
                }
        }
    
    // Función para limpiar los campos del formulario
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
}
