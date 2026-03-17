"use client"

import { useState, useEffect } from "react"
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  TextInput,
  ActivityIndicator,
  RefreshControl,
} from "react-native"
import { useRouter } from "expo-router"
import { useAuth } from "../auth-context"
import { SearchIcon, MapPinIcon, BellIcon, MenuIcon } from "lucide-react-native"
import { getCategorias } from "../services/categoria-service"

// Componente principal de la pantalla de inicio
export default function HomeScreen() {
  const router = useRouter()
  const { userData } = useAuth()
  const [categorias, setCategorias] = useState([])
  const [serviciosDestacados, setServiciosDestacados] = useState([])
  const [proveedoresCercanos, setProveedoresCercanos] = useState([])
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [searchQuery, setSearchQuery] = useState("")

  // Cargar datos iniciales
  useEffect(() => {
    loadData()
  }, [])

  // Función para cargar datos
  const loadData = async () => {
    try {
      setLoading(true)
      // Obtener categorías desde Firestore
      const categoriasData = await getCategorias()
      setCategorias(categoriasData)

      // Aquí se cargarían los servicios destacados y proveedores cercanos
      // Por ahora usamos datos de ejemplo
      setServiciosDestacados(serviciosDestacadosEjemplo)
      setProveedoresCercanos(proveedoresCercanosEjemplo)
    } catch (error) {
      console.error("Error al cargar datos:", error)
    } finally {
      setLoading(false)
      setRefreshing(false)
    }
  }

  // Función para refrescar datos
  const onRefresh = () => {
    setRefreshing(true)
    loadData()
  }

  // Navegar a la pantalla de categoría
  const navigateToCategory = (categoriaId, categoriaNombre) => {
    router.push({
      pathname: "/categoria/[id]",
      params: { id: categoriaId, nombre: categoriaNombre },
    })
  }

  // Navegar a la pantalla de servicio
  const navigateToService = (servicioId) => {
    router.push({
      pathname: "/servicio/[id]",
      params: { id: servicioId },
    })
  }

  // Navegar a la pantalla de proveedor
  const navigateToProvider = (proveedorId) => {
    router.push({
      pathname: "/proveedor/[id]",
      params: { id: proveedorId },
    })
  }

  return (
    <View style={styles.container}>
      {/* Cabecera */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <TouchableOpacity>
            <MenuIcon size={24} color="#333" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Mañachyna Kusa</Text>
          <TouchableOpacity>
            <BellIcon size={24} color="#333" />
          </TouchableOpacity>
        </View>

        <View style={styles.locationContainer}>
          <MapPinIcon size={18} color="#2E7D32" />
          <Text style={styles.locationText}>Tena, Napo</Text>
        </View>

        <View style={styles.searchContainer}>
          <SearchIcon size={20} color="#777" style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Buscar servicios..."
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>
      </View>

      {loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#2E7D32" />
          <Text style={styles.loadingText}>Cargando servicios...</Text>
        </View>
      ) : (
        <ScrollView
          style={styles.scrollView}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={["#2E7D32"]} />}
        >
          {/* Saludo personalizado */}
          <View style={styles.greetingContainer}>
            <Text style={styles.greetingText}>
              Allipunchaw, {userData?.nombre || "Usuario"}
              {"\n"}
              <Text style={styles.greetingSubtext}>¿Qué servicio necesitas hoy?</Text>
            </Text>
          </View>

          {/* Categorías de servicios */}
          <View style={styles.sectionContainer}>
            <Text style={styles.sectionTitle}>Categorías de Servicios</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.categoriesContainer}>
              {categorias.length > 0 ? (
                categorias.map((categoria) => (
                  <TouchableOpacity
                    key={categoria.id}
                    style={styles.categoryCard}
                    onPress={() => navigateToCategory(categoria.id, categoria.nombre)}
                  >
                    <View style={styles.categoryIconContainer}>
                      <Image source={{ uri: categoria.icono }} style={styles.categoryIcon} />
                    </View>
                    <Text style={styles.categoryName}>{categoria.nombre}</Text>
                    <Text style={styles.categoryNameKichwa}>{categoria.nombreKichwa}</Text>
                  </TouchableOpacity>
                ))
              ) : (
                <View style={styles.emptyCategoriesContainer}>
                  <Text style={styles.emptyText}>No hay categorías disponibles</Text>
                </View>
              )}
            </ScrollView>
          </View>

          {/* Servicios destacados */}
          <View style={styles.sectionContainer}>
            <Text style={styles.sectionTitle}>Servicios Destacados</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.servicesContainer}>
              {serviciosDestacados.map((servicio) => (
                <TouchableOpacity
                  key={servicio.id}
                  style={styles.serviceCard}
                  onPress={() => navigateToService(servicio.id)}
                >
                  <Image source={{ uri: servicio.imagen }} style={styles.serviceImage} />
                  <View style={styles.serviceInfo}>
                    <Text style={styles.serviceName}>{servicio.nombre}</Text>
                    <Text style={styles.serviceProvider}>{servicio.proveedor}</Text>
                    <View style={styles.ratingContainer}>
                      <Text style={styles.ratingText}>{servicio.calificacion}</Text>
                      <Text style={styles.ratingCount}>({servicio.numCalificaciones})</Text>
                    </View>
                    <Text style={styles.servicePrice}>${servicio.precio}</Text>
                  </View>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>

          {/* Proveedores cercanos */}
          <View style={styles.sectionContainer}>
            <Text style={styles.sectionTitle}>Proveedores Cercanos</Text>
            {proveedoresCercanos.map((proveedor) => (
              <TouchableOpacity
                key={proveedor.id}
                style={styles.providerCard}
                onPress={() => navigateToProvider(proveedor.id)}
              >
                <Image source={{ uri: proveedor.foto }} style={styles.providerImage} />
                <View style={styles.providerInfo}>
                  <Text style={styles.providerName}>{proveedor.nombre}</Text>
                  <Text style={styles.providerSpecialty}>{proveedor.especialidad}</Text>
                  <View style={styles.providerRatingContainer}>
                    <Text style={styles.providerRating}>{proveedor.calificacion}</Text>
                    <Text style={styles.providerRatingCount}>({proveedor.numCalificaciones})</Text>
                  </View>
                </View>
                <View style={styles.providerDistance}>
                  <Text style={styles.distanceText}>{proveedor.distancia} km</Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </ScrollView>
      )}
    </View>
  )
}

// Estilos
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  header: {
    backgroundColor: "#FFFFFF",
    paddingTop: 50,
    paddingBottom: 15,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: "#EEEEEE",
  },
  headerTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 15,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#2E7D32",
  },
  locationContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 15,
  },
  locationText: {
    fontSize: 14,
    color: "#555",
    marginLeft: 5,
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#F0F0F0",
    borderRadius: 10,
    paddingHorizontal: 15,
    height: 45,
  },
  searchIcon: {
    marginRight: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: "#333",
  },
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: "#555",
  },
  scrollView: {
    flex: 1,
  },
  greetingContainer: {
    padding: 20,
  },
  greetingText: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#333",
  },
  greetingSubtext: {
    fontSize: 16,
    fontWeight: "normal",
    color: "#666",
  },
  sectionContainer: {
    marginBottom: 25,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#333",
    marginLeft: 20,
    marginBottom: 15,
  },
  categoriesContainer: {
    paddingLeft: 20,
  },
  categoryCard: {
    width: 100,
    marginRight: 15,
    alignItems: "center",
  },
  categoryIconContainer: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: "#E8F5E9",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 10,
  },
  categoryIcon: {
    width: 40,
    height: 40,
  },
  categoryName: {
    fontSize: 14,
    fontWeight: "500",
    color: "#333",
    textAlign: "center",
  },
  categoryNameKichwa: {
    fontSize: 12,
    color: "#666",
    textAlign: "center",
  },
  emptyCategoriesContainer: {
    width: "100%",
    height: 100,
    justifyContent: "center",
    alignItems: "center",
  },
  emptyText: {
    color: "#888",
    fontSize: 14,
  },
  servicesContainer: {
    paddingLeft: 20,
  },
  serviceCard: {
    width: 200,
    backgroundColor: "#FFFFFF",
    borderRadius: 10,
    marginRight: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
    overflow: "hidden",
  },
  serviceImage: {
    width: "100%",
    height: 120,
  },
  serviceInfo: {
    padding: 12,
  },
  serviceName: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  serviceProvider: {
    fontSize: 14,
    color: "#666",
    marginBottom: 5,
  },
  ratingContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 5,
  },
  ratingText: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#F9A825",
    marginRight: 3,
  },
  ratingCount: {
    fontSize: 12,
    color: "#888",
  },
  servicePrice: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#2E7D32",
  },
  providerCard: {
    flexDirection: "row",
    backgroundColor: "#FFFFFF",
    borderRadius: 10,
    marginHorizontal: 20,
    marginBottom: 15,
    padding: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  providerImage: {
    width: 60,
    height: 60,
    borderRadius: 30,
  },
  providerInfo: {
    flex: 1,
    marginLeft: 15,
  },
  providerName: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  providerSpecialty: {
    fontSize: 14,
    color: "#666",
    marginBottom: 5,
  },
  providerRatingContainer: {
    flexDirection: "row",
    alignItems: "center",
  },
  providerRating: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#F9A825",
    marginRight: 3,
  },
  providerRatingCount: {
    fontSize: 12,
    color: "#888",
  },
  providerDistance: {
    justifyContent: "center",
  },
  distanceText: {
    fontSize: 14,
    color: "#2E7D32",
    fontWeight: "500",
  },
})

// Datos de ejemplo para servicios destacados
const serviciosDestacadosEjemplo = [
  {
    id: "s1",
    nombre: "Limpieza de hogar",
    proveedor: "María Tanguila",
    calificacion: "4.8",
    numCalificaciones: 56,
    precio: "15.00",
    imagen: "/placeholder.svg?height=120&width=200",
  },
  {
    id: "s2",
    nombre: "Reparación eléctrica",
    proveedor: "Carlos Shiguango",
    calificacion: "4.7",
    numCalificaciones: 42,
    precio: "25.00",
    imagen: "/placeholder.svg?height=120&width=200",
  },
  {
    id: "s3",
    nombre: "Plomería general",
    proveedor: "Luis Andi",
    calificacion: "4.9",
    numCalificaciones: 38,
    precio: "20.00",
    imagen: "/placeholder.svg?height=120&width=200",
  },
]

// Datos de ejemplo para proveedores cercanos
const proveedoresCercanosEjemplo = [
  {
    id: "p1",
    nombre: "Rosa Chimbo",
    especialidad: "Limpieza profesional",
    calificacion: "4.8",
    numCalificaciones: 64,
    distancia: "1.2",
    foto: "/placeholder.svg?height=60&width=60",
  },
  {
    id: "p2",
    nombre: "Juan Tapuy",
    especialidad: "Carpintería y muebles",
    calificacion: "4.6",
    numCalificaciones: 37,
    distancia: "2.5",
    foto: "/placeholder.svg?height=60&width=60",
  },
  {
    id: "p3",
    nombre: "Ana Grefa",
    especialidad: "Cuidado de niños",
    calificacion: "4.9",
    numCalificaciones: 52,
    distancia: "3.1",
    foto: "/placeholder.svg?height=60&width=60",
  },
]
