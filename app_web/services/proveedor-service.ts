import { collection, getDocs, doc, getDoc, query, where, type GeoPoint } from "firebase/firestore"
import { db } from "../firebase-config"

// Interfaz para proveedores
export interface Proveedor {
  id: string
  nombre: string
  apellido: string
  telefono: string
  categorias: string[]
  serviciosOfrecidos: string[]
  zonasCobertura: string[]
  coordenadasBase: GeoPoint
  disponibilidad: {
    [key: string]: {
      inicio: Date
      fin: Date
    }
  }
  calificacionPromedio: number
  fotoPerfil: string
  documentosVerificacion: string[]
  estado: "activo" | "pendiente" | "suspendido"
  descripcion: string
  tokenNotificacion: string
}

// Obtener todos los proveedores
export const getProveedores = async (): Promise<Proveedor[]> => {
  try {
    const proveedoresRef = collection(db, "proveedores")
    const snapshot = await getDocs(proveedoresRef)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Proveedor[]
  } catch (error) {
    console.error("Error al obtener proveedores:", error)
    return []
  }
}

// Obtener proveedores por categoría
export const getProveedoresByCategoria = async (categoriaId: string): Promise<Proveedor[]> => {
  try {
    const proveedoresRef = collection(db, "proveedores")
    const q = query(proveedoresRef, where("categorias", "array-contains", categoriaId))
    const snapshot = await getDocs(q)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Proveedor[]
  } catch (error) {
    console.error("Error al obtener proveedores por categoría:", error)
    return []
  }
}

// Obtener un proveedor por ID
export const getProveedorById = async (proveedorId: string): Promise<Proveedor | null> => {
  try {
    const proveedorRef = doc(db, "proveedores", proveedorId)
    const proveedorDoc = await getDoc(proveedorRef)

    if (!proveedorDoc.exists()) {
      return null
    }

    return {
      id: proveedorDoc.id,
      ...proveedorDoc.data(),
    } as Proveedor
  } catch (error) {
    console.error("Error al obtener proveedor:", error)
    return null
  }
}

// Obtener proveedores cercanos (simulado)
export const getProveedoresCercanos = async (
  latitud: number,
  longitud: number,
  radio: number,
): Promise<Proveedor[]> => {
  try {
    // En una implementación real, se usaría una consulta geoespacial
    // Por ahora, simplemente devolvemos todos los proveedores
    const proveedores = await getProveedores()

    // Aquí se filtrarían por distancia
    return proveedores
  } catch (error) {
    console.error("Error al obtener proveedores cercanos:", error)
    return []
  }
}
