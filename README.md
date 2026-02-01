# Mañachyna Kusa 2.0 🚀

Plataforma multiservicio para la provincia de Napo, Ecuador. Conecta usuarios con proveedores de servicios locales de forma eficiente y segura.

## 🏗️ Estructura del Proyecto (Monorepo)

Este repositorio está organizado como un monorepo para facilitar la escalabilidad:
- **[App Móvil (Flutter)](./mobile_app):** Corazón de la plataforma para Android, iOS y Web.
- **[Panel Administrativo (Next.js)](./admin_web):** Plataforma web moderna basada en React/Next.js.

## 🛠️ Tecnologías

- **Móvil:** [Flutter 3.x](https://flutter.dev)
- **Web:** [Next.js 15](https://nextjs.org) + [Tailwind CSS](https://tailwindcss.com)
- **Backend:** [Supabase](https://supabase.com) y [Firebase](https://firebase.google.com).

## 🚀 Cómo Ejecutar

### Aplicación Móvil (Flutter)
```bash
cd mobile_app
flutter pub get
flutter run
```

### Página Web (Next.js)
```bash
cd admin_web
npm install --legacy-peer-deps
npm run dev
```

## 📂 Organización

- `mobile_app/`: Todo el código fuente de Flutter, incluyendo assets y configuraciones nativas.
- `admin_web/`: Aplicación Next.js, componentes de UI web y hooks de React.

## ✅ Estado Actual
- [x] Estructura Monorepo organizada.
- [x] Configuración de Firebase/Supabase migrada.
- [x] Linting y Tests verificados.