// Servicio de autenticación para Mañachyna Kusa
import { auth, db } from "./firebase-config"
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  PhoneAuthProvider,
  type RecaptchaVerifier,
  signInWithPhoneNumber,
} from "firebase/auth"
import { doc, setDoc, getDoc } from "firebase/firestore"

// Interfaz para datos de usuario
interface UserData {
  nombre: string
  apellido: string
  telefono: string
  email: string
  direccion?: string
  tipo: "usuario" | "proveedor"
}

// Registro de usuario
export const registerUser = async (userData: UserData, password: string) => {
  try {
    // Registro con email/password como base
    const userCredential = await createUserWithEmailAndPassword(auth, userData.email, password)

    // Guardar información adicional en Firestore
    const userDoc = userData.tipo === "usuario" ? "usuarios" : "proveedores"

    await setDoc(doc(db, userDoc, userCredential.user.uid), {
      nombre: userData.nombre,
      apellido: userData.apellido,
      telefono: userData.telefono,
      email: userData.email,
      direccion: userData.direccion || "",
      fechaRegistro: new Date(),
      fotoPerfil: null,
      ...(userData.tipo === "usuario"
        ? { historialServicios: [] }
        : {
            categorias: [],
            serviciosOfrecidos: [],
            zonasCobertura: [],
            disponibilidad: {},
            calificacionPromedio: 0,
            estado: "pendiente",
          }),
    })

    return { success: true, uid: userCredential.user.uid }
  } catch (error: any) {
    console.error("Error en registro:", error)
    return { success: false, error: error.message }
  }
}

// Iniciar sesión con email y contraseña
export const loginWithEmail = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    return { success: true, uid: userCredential.user.uid }
  } catch (error: any) {
    console.error("Error en inicio de sesión:", error)
    return { success: false, error: error.message }
  }
}

// Iniciar proceso de verificación por teléfono
export const startPhoneVerification = async (phoneNumber: string, recaptchaVerifier: RecaptchaVerifier) => {
  try {
    const phoneProvider = new PhoneAuthProvider(auth)
    const verificationId = await phoneProvider.verifyPhoneNumber(phoneNumber, recaptchaVerifier)
    return { success: true, verificationId }
  } catch (error: any) {
    console.error("Error en verificación de teléfono:", error)
    return { success: false, error: error.message }
  }
}

// Completar inicio de sesión con código de verificación
export const completePhoneLogin = async (verificationId: string, verificationCode: string) => {
  try {
    const credential = PhoneAuthProvider.credential(verificationId, verificationCode)
    const userCredential = await signInWithPhoneNumber(auth, credential)
    return { success: true, uid: userCredential.user.uid }
  } catch (error: any) {
    console.error("Error en verificación de código:", error)
    return { success: false, error: error.message }
  }
}

// Cerrar sesión
export const logoutUser = async () => {
  try {
    await signOut(auth)
    return { success: true }
  } catch (error: any) {
    console.error("Error al cerrar sesión:", error)
    return { success: false, error: error.message }
  }
}

// Obtener datos del usuario actual
export const getCurrentUserData = async () => {
  try {
    const user = auth.currentUser
    if (!user) {
      return { success: false, error: "No hay usuario autenticado" }
    }

    // Intentar obtener datos de usuario primero
    let userData = await getDoc(doc(db, "usuarios", user.uid))

    // Si no existe, intentar obtener datos de proveedor
    if (!userData.exists()) {
      userData = await getDoc(doc(db, "proveedores", user.uid))
    }

    if (!userData.exists()) {
      return { success: false, error: "No se encontraron datos del usuario" }
    }

    return {
      success: true,
      data: { id: user.uid, ...userData.data() },
    }
  } catch (error: any) {
    console.error("Error al obtener datos del usuario:", error)
    return { success: false, error: error.message }
  }
}
