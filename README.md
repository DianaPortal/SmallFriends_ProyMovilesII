# SmallFriends iOS

SmallFriends es una aplicación iOS diseñada para gestionar **citas veterinarias**, **mascotas** y **eventos** relacionados con el cuidado de las mascotas. Los usuarios pueden programar notificaciones para recordarles sobre sus **citas veterinarias** o eventos relevantes. La app también permite consultar eventos disponibles a través de una **API externa**.

## Características

- **Gestión de Mascotas**: Los usuarios pueden agregar, editar y eliminar mascotas en su perfil.
- **Gestión de Citas Veterinarias**: Los usuarios pueden programar citas para sus mascotas, con detalles como la fecha, hora y tipo de consulta.
- **Consulta de Eventos**: Los usuarios pueden consultar eventos relacionados con el cuidado de mascotas disponibles en una API externa.
- **Notificaciones Locales**: Los usuarios pueden programar notificaciones para recibir recordatorios sobre citas veterinarias o eventos.
- **Autenticación de Usuario**: La app permite a los usuarios autenticarse mediante Firebase para gestionar sus datos personales y notificaciones.

## Clases

### 1. `MascotasViewController`

Gestiona la información de las **mascotas** del usuario.

#### Funcionalidad:
- **viewDidLoad**: Carga las mascotas del usuario desde Core Data.
- **agregarMascota**: Permite al usuario agregar una nueva mascota a su perfil.
- **editarMascota**: Permite al usuario editar los detalles de una mascota existente.
- **eliminarMascota**: Permite al usuario eliminar una mascota del perfil.

### 2. `CitasViewController`

Gestiona las **citas veterinarias** de las mascotas del usuario.

#### Funcionalidad:
- **viewDidLoad**: Carga las citas del usuario desde Core Data.
- **agregarCita**: Permite al usuario programar una nueva cita veterinaria para una mascota.
- **editarCita**: Permite al usuario editar los detalles de una cita existente.
- **eliminarCita**: Permite al usuario eliminar una cita veterinaria y la notificación asociada.
- **programarNotificacionDeCita**: Permite al usuario programar una notificación relacionada con una cita veterinaria para recordatorio.

### 3. `EventosViewController`

Consulta eventos disponibles relacionados con el cuidado de las mascotas desde una **API externa**.

#### Funcionalidad:
- **viewDidLoad**: Carga y muestra los eventos disponibles llamando a una API externa.
- **mostrarEventosDisponibles**: Realiza la consulta a la API y muestra los eventos disponibles en una lista.
- **programarNotificacionDeEvento**: Permite al usuario programar una notificación relacionada con un evento seleccionado.

### 4. `NotificacionesViewController`

Permite a los usuarios programar notificaciones personalizadas relacionadas con citas veterinarias o eventos.

#### Propiedades:
- **datePicker**: Control para seleccionar la fecha y hora de la notificación.
- **titulo**: Campo de texto para ingresar el título de la notificación.
- **mensaje**: Área de texto para ingresar el mensaje de la notificación.
- **notificacionesCenter**: Instancia de `UNUserNotificationCenter` para manejar las notificaciones locales.

#### Funcionalidad:
- **viewDidLoad**: Configura los elementos visuales y solicita permisos para las notificaciones.
- **userNotificationCenter(_:willPresent:withCompletionHandler:)**: Muestra las notificaciones con un banner, en la lista y con sonido cuando la aplicación está en primer plano.
- **habilitarNotificaciones**: Muestra una alerta para permitir al usuario habilitar las notificaciones si no las ha autorizado.
- **programarButton**: Lógica para programar la notificación:
  - Verifica si el usuario está autenticado con Firebase.
  - Valida que los campos no estén vacíos y que la fecha seleccionada sea futura.
  - Si todo es correcto, programa la notificación localmente y la guarda en Core Data.
  - Si no se han habilitado las notificaciones, solicita habilitarlas.
- **formattedDate**: Convierte la fecha en un formato legible.

### 5. `ListNotificacionesViewController`

Esta clase gestiona la vista donde se muestran las notificaciones programadas por el usuario.

#### Propiedades:
- **tableNotificacionesTableView**: Tabla que muestra las notificaciones programadas.
- **notificacionesProgramadas**: Arreglo que contiene las notificaciones programadas que se muestran en la tabla.

#### Funcionalidad:
- **viewDidLoad**: Configura la vista, el delegado de la tabla y observa las actualizaciones de notificaciones.
- **viewWillAppear**: Carga las notificaciones programadas cuando la vista aparece.
- **cargarNotificacionesProgramadas**: Recupera las notificaciones programadas desde Core Data.
- **formatearFecha**: Convierte las fechas de las notificaciones a un formato legible.
- **recargarNotificaciones**: Método que recarga la lista de notificaciones cuando se recibe una notificación de actualización.

### 6. `ListNotificacionesTableViewCell`

Celda personalizada para mostrar la información de cada notificación en la tabla.

#### Propiedades:
- **containerView**: Vista contenedora que aplica un estilo visual (bordes redondeados y sombra).
- **tituloLabel**: Etiqueta que muestra el título de la notificación.
- **fechaLabel**: Etiqueta que muestra la fecha programada de la notificación.

#### Funcionalidad:
- **awakeFromNib**: Configura el estilo visual de la celda, como bordes redondeados y sombra.

## Requisitos

- **Xcode 15.2**
- **iOS 12.0+**
- **Firebase**: Para la autenticación de usuarios.
- **Core Data**: Para almacenar las mascotas, citas y notificaciones programadas localmente.
- **UNUserNotificationCenter**: Para gestionar las notificaciones locales.
- **Alamofire (o URLSession)**: Para realizar solicitudes a la API externa de eventos.
