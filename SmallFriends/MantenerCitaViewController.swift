//
//  MantenerCitaViewController.swift
//  SmallFriends
//
//  Created by DAMII on 21/04/25.
//

import UIKit
import CoreData
import FirebaseAuth

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

        // Configuración del UIPickerView
        tipoCitaPickerView.delegate = self
        tipoCitaPickerView.dataSource = self

        // LLAMADO AL PICKER VIEW DE MASCOTA
        mascotaPickerView.delegate = self
        mascotaPickerView.dataSource = self
        cargarMascotasDelUsuario()

        // Evitar selección de fechas pasadas
        fechaDatePicker.minimumDate = Date()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

                        if let cita = self.citaAActualizar {
                            self.fechaDatePicker.date = cita.fechaCita ?? Date()
                            self.lugarTextField.text = cita.lugarCita
                            self.descripCitaTextField.text = cita.descripcionCita

                            if let tipo = cita.tipoCita,
                               let tipoIndex = self.tipoCita.firstIndex(of: tipo) {
                                self.tipoCitaPickerView.selectRow(tipoIndex, inComponent: 0, animated: false)
                            }

                            if let mascota = cita.mascota,
                               let index = self.mascotasUsuario.firstIndex(of: mascota) {
                                self.mascotaPickerView.selectRow(index, inComponent: 0, animated: false)
                            } else {
                                print("La mascota de la cita no está en la lista de mascotas activas del usuario.")
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

        // Validar que la fecha no sea pasada
        if fecha < Date() {
            mostrarAlerta(mensaje: "No puedes seleccionar una fecha pasada para la cita.")
            return
        }

        // Obtener el tipo de cita seleccionado del UIPickerView
        let tipoCitaSeleccionado = tipoCita[tipoCitaPickerView.selectedRow(inComponent: 0)]

        // Guardar en Core Data
        guardarEnCoreData(fecha: fecha, lugar: lugar, tipoCita: tipoCitaSeleccionado, descripcion: descripcion)

        mostrarAlerta(titulo: "Éxito", mensaje: citaAActualizar != nil ? "Cita actualizada correctamente" : "Cita registrada correctamente") {
            NotificationCenter.default.post(name: Notification.Name("ActualizarListadoNotificaciones"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func guardarEnCoreData(fecha: Date, lugar: String, tipoCita: String, descripcion: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        if let cita = citaAActualizar {
            eliminarNotificacion(cita: cita)

            cita.fechaCita = fecha
            cita.lugarCita = lugar
            cita.tipoCita = tipoCita
            cita.descripcionCita = descripcion

            do {
                try context.save()
                programarNotificacion(cita: cita)
            } catch {
                print("Error al actualizar la cita: \(error.localizedDescription)")
            }
        } else {
            let fetchRequest: NSFetchRequest<CitasCD> = CitasCD.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "idCita", ascending: false)]

            var nuevoIdCita: Int16 = 1001
            do {
                let citas = try context.fetch(fetchRequest)
                if let ultimaCita = citas.first, ultimaCita.idCita < Int16.max {
                    nuevoIdCita = ultimaCita.idCita + 1
                }
            } catch {
                print("Error al obtener las citas: \(error)")
            }

            let mascotaSeleccionada = mascotasUsuario[mascotaPickerView.selectedRow(inComponent: 0)]
            let nuevaCita = CitasCD(context: context)
            nuevaCita.fechaCita = fecha
            nuevaCita.mascota = mascotaSeleccionada
            nuevaCita.lugarCita = lugar.capitalizedFirstLetter
            nuevaCita.tipoCita = tipoCita
            nuevaCita.descripcionCita = descripcion.capitalizedFirstLetter
            nuevaCita.idCita = nuevoIdCita
            nuevaCita.estadoCita = "Activa"

            if let correoGuardado = UserDefaults.standard.string(forKey: "email") {
                let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
                fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)
                do {
                    let usuarios = try context.fetch(fetchRequestUsuario)
                    if let usuario = usuarios.first {
                        nuevaCita.usuario = usuario
                    }
                } catch {
                    print("Error al obtener usuario logueado: \(error.localizedDescription)")
                }
            }

            do {
                try context.save()
                programarNotificacion(cita: nuevaCita)
            } catch {
                print("Error al guardar la cita: \(error.localizedDescription)")
            }
        }
    }

    func programarNotificacion(cita: CitasCD) {
        guard let fechaCita = cita.fechaCita else { return }
        let intervalo = fechaCita.timeIntervalSinceNow
        guard intervalo > 0 else {
            DispatchQueue.main.async {
                self.mostrarAlerta(titulo: "Fecha inválida", mensaje: "No puedes programar una cita en el pasado.")
            }
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Cita"
        content.body = "Tienes una cita programada para el \(fechaCita)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalo, repeats: false)
        let nuevoID = UUID().uuidString
        let request = UNNotificationRequest(identifier: nuevoID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al agregar la notificación: \(error.localizedDescription)")
            }
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let notificacion: NotificacionCD
        if let existente = cita.notificaciones {
            notificacion = existente
        } else {
            notificacion = NotificacionCD(context: context)
            cita.notificaciones = notificacion
        }

        notificacion.idNotificacion = nuevoID
        notificacion.fechaProgramada = fechaCita
        notificacion.titulo = "\(cita.tipoCita ?? "Cita") - \(cita.mascota?.nombre ?? "")"
        notificacion.idUsuario = cita.usuario?.idUsuario

        do {
            try context.save()
        } catch {
            print("Error al guardar notificación: \(error.localizedDescription)")
        }
    }

    func eliminarNotificacion(cita: CitasCD) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let usuarioID = Auth.auth().currentUser?.uid else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<NotificacionCD> = NotificacionCD.fetchRequest()
        let predicate = NSPredicate(format: "idUsuario == %@ AND fechaProgramada == %@", usuarioID, cita.fechaCita! as NSDate)
        fetchRequest.predicate = predicate

        do {
            let notificaciones = try context.fetch(fetchRequest)
            for notificacion in notificaciones {
                if let id = notificacion.idNotificacion {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                }
                context.delete(notificacion)
            }
            try context.save()
            cita.notificaciones = nil
        } catch {
            print("Error al eliminar notificación de Core Data: \(error.localizedDescription)")
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == mascotaPickerView ? mascotasUsuario.count : tipoCita.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == mascotaPickerView ? mascotasUsuario[row].nombre ?? "Sin nombre" : tipoCita[row]
    }

    func campo(_ textField: UITextField, nombre: String) -> String? {
        guard let texto = textField.text, !texto.isEmpty else {
            mostrarAlerta(mensaje: "El campo \(nombre) no puede estar vacío")
            return nil
        }
        return texto
    }

    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    func mostrarAlerta(titulo: String, mensaje: String, alAceptar: (() -> Void)? = nil) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default) { _ in alAceptar?() })
        present(alerta, animated: true)
    }

    func actualizarListadoDeNotificaciones() {
        if let navigationController = self.navigationController,
           let listNotificacionesVC = navigationController.viewControllers.first(where: { $0 is ListNotificacionesViewController }) as? ListNotificacionesViewController {
            listNotificacionesVC.cargarNotificacionesProgramadas()
        }
    }
}
