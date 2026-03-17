// Configuración de Firebase para la aplicación Mañachyna Kusa
import { initializeApp } from "firebase/app"
import { getAuth } from "firebase/auth"
import { getFirestore } from "firebase/firestore"
import { getStorage } from "firebase/storage"

// Configuración de Firebase (reemplazar con valores reales en producción)
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyBZ9kfThOPtGPYGhgNvD8n9fdNdERJ0AmM",
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || "manachynakusa.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "manachynakusa",
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || "manachynakusa.firebasestorage.app",
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "832653619760",
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || "1:832653619760:web:5b955e3cc8ef62218133f5",
}

// Inicializar Firebase
const app = initializeApp(firebaseConfig)

// Exportar servicios de Firebase
export const auth = getAuth(app)
export const db = getFirestore(app)
export const storage = getStorage(app)
