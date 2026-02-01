import { collection, getDocs, doc, getDoc } from "firebase/firestore"
import { db } from "../firebase-config"

// Interfaz para categorías
export interface Categoria {
  id: string
  nombre: string
  nombreKichwa: string
  descripcion: string
  icono: string
}

// Obtener todas las categorías
export const getCategorias = async (): Promise<Categoria[]> => {
  try {
    const categoriasRef = collection(db, "categorias")
    const snapshot = await getDocs(categoriasRef)

    if (snapshot.empty) {
      console.log("No hay categorías disponibles")
      return categoriasEjemplo // Devolver datos de ejemplo si no hay datos reales
    }

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    })) as Categoria[]
  } catch (error) {
    console.error("Error al obtener categorías:", error)
    return categoriasEjemplo // Devolver datos de ejemplo en caso de error
  }
}

// Obtener una categoría por ID
export const getCategoriaById = async (categoriaId: string): Promise<Categoria | null> => {
  try {
    const categoriaRef = doc(db, "categorias", categoriaId)
    const categoriaDoc = await getDoc(categoriaRef)

    if (!categoriaDoc.exists()) {
      console.log("No se encontró la categoría")
      return null
    }

    return {
      id: categoriaDoc.id,
      ...categoriaDoc.data(),
    } as Categoria
  } catch (error) {
    console.error("Error al obtener categoría:", error)
    return null
  }
}

// Datos de ejemplo para categorías (se usan cuando no hay datos en Firestore)
export const categoriasEjemplo: Categoria[] = [
  {
    id: "c1",
    nombre: "Limpieza",
    nombreKichwa: "Pichana",
    descripcion: "Servicios de limpieza para hogares y oficinas",
    icono: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "c2",
    nombre: "Plomería",
    nombreKichwa: "Yaku Ruray",
    descripcion: "Reparación e instalación de sistemas de agua",
    icono: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "c3",
    nombre: "Electricidad",
    nombreKichwa: "Achik Ruray",
    descripcion: "Instalación y reparación de sistemas eléctricos",
    icono: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "c4",
    nombre: "Carpintería",
    nombreKichwa: "Kaspi Ruray",
    descripcion: "Trabajos en madera y muebles",
    icono: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "c5",
    nombre: "Jardinería",
    nombreKichwa: "Pampa Kamay",
    descripcion: "Mantenimiento de jardines y áreas verdes",
    icono: "/placeholder.svg?height=40&width=40",
  },
  {
    id: "c6",
    nombre: "Cuidado",
    nombreKichwa: "Kamana",
    descripcion: "Cuidado de niños, adultos mayores y mascotas",
    icono: "/placeholder.svg?height=40&width=40",
  },
]
