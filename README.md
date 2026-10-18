# Taller Móvil: Canasta Colombiana 🇨🇴

Aplicación móvil desarrollada en Flutter para la plataforma Android. Consiste en un catálogo de productos típicos colombianos donde los usuarios pueden calificar con una prioridad (1 a 5) y registrar notas personales para cada producto, implementando persistencia local offline-first con Drift, el patrón Repository y sincronización en la nube con Cloud Firestore.

## Integrantes
- Estudiante 1: [Nombre y Apellido]
- Estudiante 2: [Nombre y Apellido]

---

## Requisitos
- Flutter SDK (versión 3.24 o superior recomendada, probado en Flutter 3.47.3 / Dart 3.13.3)
- Android Studio / Android SDK configurado
- Firebase CLI y FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Dispositivo Android físico o emulador con Google Play Services

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
│   │   ├── app_database.dart       # Definición de tabla Drift y métodos de persistencia local
│   │   └── app_database.g.dart     # Código generado por build_runner para Drift
│   ├── models/
│   │   └── product.dart            # Modelo de datos del producto con serialización JSON
│   ├── repositories/
│   │   └── product_repository.dart # Patrón Repository con lógica offline-first y sync
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

3. **Configuración de Firebase:**
   Si no se ha enlazado el proyecto de Firebase:
   ```bash
   flutterfire configure
   ```
   Esto generará el archivo `lib/firebase_options.dart` y enlazará `android/app/google-services.json`.

4. **Publicar catálogo y configurar URL:**
   - Publica el archivo `api/productos.json` en un repositorio público de GitHub o Gist.
   - Copia la URL Raw del archivo.
   - Actualiza la constante `kProductsUrl` en `lib/config/api_config.dart`.

5. **Ejecutar la aplicación en Android:**
   ```bash
   flutter run
   ```

---

## Preguntas

### 1) ¿Para qué sirve pendingSync?
Escribe aquí tu respuesta

### 2) ¿Por qué se guarda primero en Drift?
Escribe aquí tu respuesta

### 3) ¿Qué función cumple el Repository?
Escribe aquí tu respuesta

### 4) ¿Qué ocurre si Firebase falla?
Escribe aquí tu respuesta
