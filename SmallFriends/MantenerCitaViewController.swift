import UIKit
import CoreData
import FirebaseFirestore
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

    var mascotasUsuario: [Mascota] = []
    let tipoCita = ["Consulta Médica", "Limpieza Completa", "Vacunación", "Baño", "Revisión"]
    var citaAActualizar: CitasCD?
    
    let db = Firestore.firestore() // Conexión con Firestore

    override func viewDidLoad() {
        super.viewDidLoad()
        title = citaAActualizar == nil ? "📅 Registrar Cita 📅" : "📅 Actualizar Cita 📅"
        
        tipoCitaPickerView.delegate = self
        tipoCitaPickerView.dataSource = self
        mascotaPickerView.delegate = self
        mascotaPickerView.dataSource = self
        cargarMascotasDelUsuario()
        
        fechaDatePicker.minimumDate = Date()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarMascotasDelUsuario()
    }

    func cargarMascotasDelUsuario() {
        guard let correoGuardado = UserDefaults.standard.string(forKey: "email") else { return }

        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)

        do {
            let usuarios = try context?.fetch(fetchRequestUsuario)
            if let usuario = usuarios?.first, let todasLasMascotas = usuario.mascota?.allObjects as? [Mascota] {
                self.mascotasUsuario = todasLasMascotas.filter {
                    $0.estadoMascota?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "activa"
                }

                DispatchQueue.main.async {
                    self.mascotaPickerView.reloadAllComponents()

                    if let cita = self.citaAActualizar {
                        self.fechaDatePicker.date = cita.fechaCita ?? Date()
                        self.lugarTextField.text = cita.lugarCita
                        self.descripCitaTextField.text = cita.descripcionCita

                        if let tipo = cita.tipoCita, let tipoIndex = self.tipoCita.firstIndex(of: tipo) {
                            self.tipoCitaPickerView.selectRow(tipoIndex, inComponent: 0, animated: false)
                        }

                        if let mascota = cita.mascota, let index = self.mascotasUsuario.firstIndex(where: { $0.objectID == mascota.objectID }) {
                            self.mascotaPickerView.selectRow(index, inComponent: 0, animated: false)
                        }
                    }
                }
            }
        } catch {
            print("Error al obtener mascotas del usuario: \(error)")
        }
    }

    @IBAction func guardarTapped(_ sender: UIButton) {
        // Validar si hay una mascota seleccionada en el picker
        guard mascotasUsuario.count > 0 else {
            mostrarAlerta(mensaje: "Debes tener al menos una mascota activa para registrar o actualizar la cita.")
            return
        }
        
        // Verificar si se seleccionó alguna mascota
        let mascotaSeleccionadaIndex = mascotaPickerView.selectedRow(inComponent: 0)
        if mascotaSeleccionadaIndex == -1 {
            mostrarAlerta(mensaje: "Por favor, selecciona una mascota.")
            return
        }

        guard
            let lugar = campo(lugarTextField, nombre: "Lugar")
        else {
            print("Error: Campos inválidos")
            return
        }

        let descripcion = descripCitaTextField.text?.isEmpty == false ? descripCitaTextField.text! : "Sin descripcion"
        let fecha = fechaDatePicker.date

        if fecha < Date() {
            mostrarAlerta(mensaje: "No puedes seleccionar una fecha pasada para la cita.")
            return
        }

        let tipoCitaSeleccionado = tipoCita[tipoCitaPickerView.selectedRow(inComponent: 0)]
        guardarEnCoreData(fecha: fecha, lugar: lugar, tipoCita: tipoCitaSeleccionado, descripcion: descripcion)
        mostrarAlerta(titulo: "Éxito", mensaje: citaAActualizar != nil ? "Cita actualizada correctamente" : "Cita registrada correctamente") {
            NotificationCenter.default.post(name: Notification.Name("ActualizarListadoNotificaciones"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func guardarEnCoreData(fecha: Date, lugar: String, tipoCita: String, descripcion: String) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }

        // 🐶 Obtener la mascota seleccionada del picker
        let mascotaSeleccionada = mascotasUsuario[mascotaPickerView.selectedRow(inComponent: 0)]
        let mascotaObjectID = mascotaSeleccionada.objectID

        // 🧩 Convertir la mascota al contexto actual
        guard let mascotaEnContexto = try? context.existingObject(with: mascotaObjectID) as? Mascota else {
            print("⚠️ No se pudo obtener la mascota en el contexto actual.")
            return
        }

        if let cita = citaAActualizar {
            // 🔁 Actualizar cita existente
            do {
                // Asegurarse de que la cita esté en el contexto correcto
                let citaEnContexto = try context.existingObject(with: cita.objectID) as! CitasCD
                citaEnContexto.fechaCita = fecha
                citaEnContexto.lugarCita = lugar
                citaEnContexto.tipoCita = tipoCita
                citaEnContexto.descripcionCita = descripcion
                citaEnContexto.mascota = mascotaEnContexto

                if citaEnContexto.id == nil {
                    citaEnContexto.id = UUID().uuidString
                }

                try context.save()
                actualizarCitaEnFirestore(cita: citaEnContexto)
            } catch {
                print("❌ Error al actualizar la cita: \(error.localizedDescription)")
            }
        } else {
            // ➕ Crear nueva cita
            let nuevaCita = CitasCD(context: context)
            nuevaCita.fechaCita = fecha
            nuevaCita.lugarCita = lugar.capitalizedFirstLetter
            nuevaCita.tipoCita = tipoCita
            nuevaCita.descripcionCita = descripcion.capitalizedFirstLetter
            nuevaCita.estadoCita = "Activa"
            nuevaCita.mascota = mascotaEnContexto
            nuevaCita.id = UUID().uuidString

            // 🧑 Obtener usuario logueado
            if let correoGuardado = UserDefaults.standard.string(forKey: "email") {
                let fetchRequestUsuario: NSFetchRequest<Usuario> = Usuario.fetchRequest()
                fetchRequestUsuario.predicate = NSPredicate(format: "email == %@", correoGuardado)
                do {
                    let usuarios = try context.fetch(fetchRequestUsuario)
                    if let usuario = usuarios.first {
                        nuevaCita.usuario = usuario
                    }
                } catch {
                    print("❌ Error al obtener usuario logueado: \(error.localizedDescription)")
                }
            }

            do {
                try context.save()
                guardarCitaEnFirestore(cita: nuevaCita)
            } catch {
                print("❌ Error al guardar la cita: \(error.localizedDescription)")
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

        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
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

    func actualizarCitaEnFirestore(cita: CitasCD) {
        guard let citaID = cita.id, !citaID.isEmpty else {
            print("❌ La cita no tiene un ID válido. No se puede actualizar en Firestore.")
            return
        }

        // Nombre de la mascota
        let nombreMascota = cita.mascota?.nombre ?? "Sin nombre"

        db.collection("citas").document(citaID).updateData([
            "fechaCita": cita.fechaCita ?? Date(),
            "mascota": nombreMascota, // Guardamos el nombre de la mascota
            "lugarCita": cita.lugarCita?.capitalizedFirstLetter ?? "",
            "tipoCita": cita.tipoCita ?? "",
            "descripcionCita": cita.descripcionCita ?? "",
            "estadoCita": cita.estadoCita ?? "Activa"
        ]) { error in
            if let error = error {
                print("Error al actualizar la cita en Firestore: \(error.localizedDescription)")
            } else {
                print("Cita actualizada correctamente en Firestore")
            }
        }
    }

    func guardarCitaEnFirestore(cita: CitasCD) {
        guard let citaID = cita.id, !citaID.isEmpty else {
            print("❌ La cita no tiene un ID válido. No se puede guardar en Firestore.")
            return
        }

        // Nombre de la mascota
        let nombreMascota = cita.mascota?.nombre ?? "Sin nombre"

        let nuevaCitaData: [String: Any] = [
            "fechaCita": cita.fechaCita ?? Date(),
            "mascota": nombreMascota, // Guardamos el nombre de la mascota
            "lugarCita": cita.lugarCita ?? "",
            "tipoCita": cita.tipoCita ?? "",
            "descripcionCita": cita.descripcionCita ?? "",
            "estadoCita": cita.estadoCita ?? "Activa",
            "usuarioID": cita.usuario?.idUsuario ?? ""
        ]
        
        db.collection("citas").document(citaID).setData(nuevaCitaData) { error in
            if let error = error {
                print("Error al guardar la cita en Firestore: \(error.localizedDescription)")
            } else {
                print("Cita guardada correctamente en Firestore")
            }
        }
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

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == mascotaPickerView ? mascotasUsuario.count : tipoCita.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == mascotaPickerView ? mascotasUsuario[row].nombre ?? "Sin nombre" : tipoCita[row]
    }
}
