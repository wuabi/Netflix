# Netflix: simulación de interfaces

## Información del proyecto

- **Aplicación de referencia:** Netflix
- **Plataforma seleccionada:** Escritorio (Windows)
- **Integrantes:**
  - Alex Eduardo Martínez Cerritos "Shin Fujiyama"
  - Leonardo José Banegas Hernández
  - Nury Fabiola Velásquez Caceres
- **Repositorio Git:** https://github.com/wuabi/Netflix.git

## Descripción

Proyecto académico desarrollado con Flutter y Dart que simula algunas de las
interfaces de Netflix. Incluye un inicio de sesión con credenciales de prueba,
un catálogo de películas y series, búsqueda y una lista personal.

El contenido se presenta de forma estática con recursos incluidos en el
proyecto. No se conecta a servicios externos ni implementa autenticación real.

## Pantallas

- **Intro:** presentación inicial que permite continuar al inicio de sesión u
  omitir la introducción.
- **Inicio de sesión:** formulario con validación de campos y comprobación de
  credenciales estáticas.
- **Inicio:** catálogo destacado y filas de títulos.
- **Buscar:** búsqueda de títulos del catálogo.
- **Películas:** catálogo de películas con filtro por género.
- **Series:** catálogo de series con filtro por género.
- **Mi lista:** muestra los títulos guardados durante la sesión.

## Interacciones implementadas

- Validación de campos vacíos y credenciales incorrectas en el inicio de sesión.
- Mostrar u ocultar la contraseña.
- Navegar entre Inicio, Películas, Series, Buscar y Mi lista.
- Buscar títulos por nombre en español o título original.
- Filtrar películas y series por género.
- Avanzar y retroceder en los títulos destacados y carruseles.
- Agregar o quitar títulos de Mi lista. La lista se mantiene en memoria mientras
  la aplicación está abierta y se limpia al cerrar sesión.
- Cerrar sesión y volver al inicio de sesión.

## Credenciales de prueba

| Campo | Valor |
|---|---|
| Usuario | `usuario@netflix.com` |
| Contraseña | `1234` |

Estas credenciales se encuentran definidas en el código de la pantalla de
inicio de sesión y son únicamente para la demostración académica.

## Requisitos

- Flutter SDK instalado.
- Windows configurado como dispositivo de escritorio de Flutter.

Comprueba la instalación y la configuración del entorno con:

```bash
flutter doctor
```

## Cómo ejecutar el proyecto

1. Clona el repositorio:

   ```bash
   git clone [Pegar aquí el enlace del repositorio]
   ```

2. Entra en la carpeta del proyecto:

   ```bash
   cd nt
   ```

3. Descarga las dependencias:

   ```bash
   flutter pub get
   ```

4. Ejecuta la aplicación para Windows:

   ```bash
   flutter run -d windows
   ```

Para ejecutar las pruebas automatizadas:

```bash
flutter test
```

## Estructura principal

```text
lib/
  main.dart
  models/
  screens/
  widgets/
assets/
  images/
  videos/
test/
```
