# Taller Móvil: Canasta Colombiana 🇨🇴

Aplicación móvil desarrollada en Flutter para la plataforma Android. Consiste en un catálogo de productos típicos colombianos donde los usuarios pueden calificar con una prioridad (1 a 5) y registrar notas personales para cada producto, implementando persistencia local offline-first con Drift, el patrón Repository y sincronización en la nube con Cloud Firestore.

## Integrantes
- David Santiago Rodriguez Ruiz
- David Velez

---

## Requisitos
- Flutter SDK con Dart 3.11 o superior (probado con Dart 3.12.2 y Dart 3.13.3)
- Android Studio / Android SDK configurado
- Dispositivo Android físico o emulador con Google Play Services
- Firebase CLI y FlutterFire CLI solo si se quiere enlazar otro proyecto de Firebase (no es necesario para ejecutar)

---

## Estructura del Proyecto

```text
taller_movil/
├── api/
│   └── productos.json              # Catálogo de 20 productos típicos en 5 categorías
├── android/
│   └── app/
│       └── google-services.json    # Configuración de Firebase para Android
├── lib/
│   ├── config/
│   │   └── api_config.dart         # Definición de la URL pública del catálogo (kProductsUrl)
│   ├── database/
│   │   ├── app_database.dart       # Definición de la tabla ProductNotes y la base SQLite
│   │   └── app_database.g.dart     # Código generado por build_runner para Drift
│   ├── local/
│   │   └── product_note_local_data_source.dart  # Consultas de Drift (leer, guardar, pendientes, marcar sincronizado)
│   ├── models/
│   │   ├── product.dart            # Modelo de datos del producto con serialización JSON
│   │   └── product_note.dart       # Modelo de la nota personal usado por la interfaz
│   ├── remote/
│   │   └── product_note_remote_data_source.dart # Escritura en Firestore (product_notes/{productId})
│   ├── repositories/
│   │   └── product_repository.dart # Patrón Repository: coordina Drift y Firestore (offline-first y sync)
│   ├── screens/
│   │   ├── product_detail_screen.dart # Pantalla de detalle, selector de prioridad y notas
│   │   └── product_list_screen.dart   # Pantalla principal con catálogo y botón de sync
│   ├── services/
│   │   └── product_service.dart    # Servicio HTTP con decodificación UTF-8 y excepciones
│   ├── widgets/
│   │   └── product_card.dart       # Tarjeta de producto con formateo en COP y errorBuilder
│   ├── firebase_options.dart       # Opciones de inicialización generadas por FlutterFire
│   └── main.dart                   # Punto de entrada de la aplicación e inyección de dependencias
├── test/
│   ├── product_repository_test.dart # Pruebas de Drift y del Repository con base en memoria
│   └── widget_test.dart            # Pruebas unitarias de modelos y utilidades
├── pubspec.yaml                    # Dependencias y configuración de Flutter
└── README.md                       # Documentación del proyecto
```

---

## Pasos para Ejecutar

1. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```

2. **Generar código de Drift (base de datos local):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Ejecutar la aplicación en Android:**
   ```bash
   flutter run
   ```

4. **Ejecutar las pruebas (opcional):**
   ```bash
   flutter test
   ```

### Firebase
El proyecto ya incluye `lib/firebase_options.dart` y `android/app/google-services.json` enlazados al proyecto `canasta-colombiana`, así que no hace falta ejecutar `flutterfire configure`. La base de Firestore debe estar en modo de prueba (Test mode) para permitir la escritura. Las notas se guardan en la colección `product_notes`, usando el `productId` como ID del documento.

Si se quiere usar otro proyecto de Firebase:
```bash
dart pub global run flutterfire_cli:flutterfire configure --project=<PROJECT_ID> --platforms=android
```

### Catálogo
El catálogo se lee desde `api/productos.json` publicado en este repositorio. La URL está en la constante `kProductsUrl` de `lib/config/api_config.dart`.

---

## Cómo probar el modo offline
1. Abre un producto, elige una prioridad de 2 o más, escribe una nota y guarda. Con internet aparece **Sincronizado**.
2. Activa el modo avión, edita la nota y guarda. La nota se conserva y aparece **Pendiente**.
3. Cierra y vuelve a abrir la app: la nota y su estado siguen ahí porque vienen de Drift.
4. Desactiva el modo avión y pulsa **Sincronizar pendientes**. Al abrir de nuevo el producto aparece **Sincronizado**.
5. Si eliges prioridad 1, la app muestra un mensaje y no guarda nada.

---

## Preguntas

### 1) ¿Para qué sirve pendingSync?
Es una marca en cada registro de Drift que indica si la nota ya llegó a Firestore. Con true está guardada solo en el celular y falta enviarla, y con false ya está sincronizada. Así la app sabe qué mostrar (Pendiente o Sincronizado) y qué registros reintentar al pulsar Sincronizar pendientes.

### 2) ¿Por qué se guarda primero en Drift?
Porque la base local siempre está disponible, aunque no haya internet o Firebase falle, y así el usuario nunca pierde lo que escribió. Primero se asegura el dato en el dispositivo y después se intenta enviarlo a la nube. Eso es el enfoque offline-first.

### 3) ¿Qué función cumple el Repository?
Es la capa intermedia entre la interfaz y las fuentes de datos (la API HTTP, Drift y Firestore). Centraliza la consulta local, el guardado y la sincronización, de modo que las pantallas solo le piden datos al Repository y no coordinan Drift ni Firebase directamente. Esto ordena el código y facilita cambiar una fuente sin tocar la interfaz.

### 4) ¿Qué ocurre si Firebase falla?
La nota sigue guardada en Drift con pendingSync = true, y la app no muestra un error ni deja de funcionar. En el detalle aparece como “Pendiente”. Cuando vuelve la conexión, el usuario pulsa “Sincronizar pendientes”, se envía a Firestore y el registro pasa a pendingSync = false. Como el documento usa el productId como ID, reenviarlo no crea duplicados.
