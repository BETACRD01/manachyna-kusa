import { collection, getDocs, doc, getDoc, query, where } from "firebase/firestore"
import { db } from "../firebase-config"

// Interfaz para servicios
export interface Servicio {
  id: string
  idProveedor: string
  idCategoria: string
  nombre: string
  descripcion: string
  precioBase: number
  unidadPrecio: "hora" | "servicio" | "metro"
  fotosEjemplo: string[]
}

// Obtener todos los servicios
export const getServicios = async (): Promise<Servicio[]> => {
  try {
    const serviciosRef = collection(db, "servicios")
    const snapshot = await getDocs(serviciosRef)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Servicio[]
  } catch (error) {
    console.error("Error al obtener servicios:", error)
    return []
  }
}

// Obtener servicios por categoría
export const getServiciosByCategoria = async (categoriaId: string): Promise<Servicio[]> => {
  try {
    const serviciosRef = collection(db, "servicios")
    const q = query(serviciosRef, where("idCategoria", "==", categoriaId))
    const snapshot = await getDocs(q)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Servicio[]
  } catch (error) {
    console.error("Error al obtener servicios por categoría:", error)
    return []
  }
}

// Obtener servicios por proveedor
export const getServiciosByProveedor = async (proveedorId: string): Promise<Servicio[]> => {
  try {
    const serviciosRef = collection(db, "servicios")
    const q = query(serviciosRef, where("idProveedor", "==", proveedorId))
    const snapshot = await getDocs(q)

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Servicio[]
  } catch (error) {
    console.error("Error al obtener servicios por proveedor:", error)
    return []
  }
}

// Obtener un servicio por ID
export const getServicioById = async (servicioId: string): Promise<Servicio | null> => {
  try {
    const servicioRef = doc(db, "servicios", servicioId)
    const servicioDoc = await getDoc(servicioRef)

    if (!servicioDoc.exists()) {
      return null
    }

    return {
      id: servicioDoc.id,
      ...servicioDoc.data(),
    } as Servicio
  } catch (error) {
    console.error("Error al obtener servicio:", error)
    return null
  }
}
