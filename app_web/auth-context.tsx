"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { auth } from "./firebase-config"
import { onAuthStateChanged, type User } from "firebase/auth"
import { getCurrentUserData } from "./auth-service"

// Definir tipos para el contexto
interface AuthContextType {
  user: User | null
  userData: any | null
  loading: boolean
  error: string | null
}

// Crear contexto con valores por defecto
const AuthContext = createContext<AuthContextType>({
  user: null,
  userData: null,
  loading: true,
  error: null,
})

// Hook personalizado para usar el contexto
export const useAuth = () => useContext(AuthContext)

// Proveedor del contexto
export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null)
  const [userData, setUserData] = useState<any | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Suscribirse a cambios en el estado de autenticación
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser)

      if (currentUser) {
        try {
          // Obtener datos adicionales del usuario desde Firestore
          const result = await getCurrentUserData()
          if (result.success) {
            setUserData(result.data)
          } else {
            setError(result.error)
          }
        } catch (err: any) {
          setError(err.message)
        }
      } else {
        setUserData(null)
      }

      setLoading(false)
    })

    // Limpiar suscripción al desmontar
    return () => unsubscribe()
  }, [])

  return <AuthContext.Provider value={{ user, userData, loading, error }}>{children}</AuthContext.Provider>
}
