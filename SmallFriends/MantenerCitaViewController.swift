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
    @IBOutlet weak var mascotaPickerView: UIPickerView!
    
    // VARIABLE PARA EL PICKER DE MASCOTAS
    var mascotasUsuario: [Mascota] = []
    
    // Opciones de tipo de citas para las mascotas
    let tipoCita = ["Consulta Médica", "Limpieza Completa", "Vacunación", "Baño", "Revisión"]
    
    // Propiedad para almacenar la cita que se va a actualizar
    var citaAActualizar: CitasCD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CAMBIO DE TITLE DEPENDIENDO DE LA ACCION
        title = citaAActualizar == nil ? "📅 Registrar Cita 📅" : "📅 Actualizar Cita 📅"

        // Configuración dek UIPickerView
        tipoCitaPickerView.delegate = self
        tipoCitaPickerView.dataSource = self
        
        // LLAMADO AL PICKER VIEW DE MASCOTA
        mascotaPickerView.delegate = self
        mascotaPickerView.dataSource = self
        cargarMascotasDelUsuario()
    }
    
    //Acciones
    
    func cargarMascotasDelUsuario() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        if let correoGuardado = UserDefaults.standard.string(forKey: "email") {
            fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)

            do {
                let usuarios = try context.fetch(fetchRequestUsuario)
                if let usuario = usuarios.first,
                   let todasLasMascotas = usuario.mascota?.allObjects as? [Mascota] {
                    
                    // FILTRA SOLO MASCOTAS CON ESTADO ACTIVO
                    self.mascotasUsuario = todasLasMascotas.filter {
                        $0.estadoMascota?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "activa"
                    }

                    DispatchQueue.main.async {
                        self.mascotaPickerView.reloadAllComponents()

                        // Si hay cita a actualizar
                        if let cita = self.citaAActualizar {
                            self.fechaDatePicker.date = cita.fechaCita ?? Date()
                            self.lugarTextField.text = cita.lugarCita
                            self.descripCitaTextField.text = cita.descripcionCita

                            // Selección en picker de tipo de cita
                            if let tipo = cita.tipoCita,
                               let tipoIndex = self.tipoCita.firstIndex(of: tipo) {
                                self.tipoCitaPickerView.selectRow(tipoIndex, inComponent: 0, animated: false)
                            }

                            // Selección en picker de mascota
                            if let mascota = cita.mascota,
                               let index = self.mascotasUsuario.firstIndex(of: mascota) {
                                self.mascotaPickerView.selectRow(index, inComponent: 0, animated: false)
                            } else {
                                print("⚠️ La mascota de la cita no está en la lista de mascotas activas del usuario.")
                            }
                        }
                    }


                }
            } catch {
                print("Error al obtener mascotas del usuario: \(error)")
            }
        }
    }
    
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
                    
                    let mascotaSeleccionada = mascotasUsuario[mascotaPickerView.selectedRow(inComponent: 0)]
                    
                    // Crear una nueva instancia de la entidad Citas
                    let nuevaCita = CitasCD(context: context)
                    nuevaCita.fechaCita = fecha
                    nuevaCita.mascota = mascotaSeleccionada
                    nuevaCita.lugarCita = lugar
                    nuevaCita.tipoCita = tipoCita
                    nuevaCita.descripcionCita = descripcion
                    nuevaCita.idCita = nuevoIdCita
                    nuevaCita.estadoCita = "Activa"
                    
                    // ✅ Agrega esto en guardarEnCoreData al crear una cita nueva
                    if let correoGuardado = UserDefaults.standard.string(forKey: "email") {
                        let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
                        fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)
                        
                        do {
                            let usuarios = try context.fetch(fetchRequestUsuario)
                            if let usuario = usuarios.first {
                                nuevaCita.usuario = usuario  // ✅ RELACIONA LA CITA AL USUARIO
                            }
                        } catch {
                            print("Error al obtener usuario logueado: \(error.localizedDescription)")
                        }
                    }

                    
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
        if pickerView == mascotaPickerView {
            return mascotasUsuario.count
        }
        return tipoCita.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == mascotaPickerView {
            return mascotasUsuario[row].nombre ?? "Sin nombre"
        }
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
