"use client"

import { useState, useEffect } from "react"
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  ActivityIndicator,
  RefreshControl,
} from "react-native"
import { useRouter, useLocalSearchParams } from "expo-router"
import { ArrowLeftIcon, FilterIcon } from "lucide-react-native"
import { getCategoriaById } from "../../services/categoria-service"
import { getServiciosByCategoria } from "../../services/servicio-service"
import { getProveedoresByCategoria } from "../../services/proveedor-service"

export default function CategoriaScreen() {
  const router = useRouter()
  const { id, nombre } = useLocalSearchParams()
  const [categoria, setCategoria] = useState(null)
  const [servicios, setServicios] = useState([])
  const [proveedores, setProveedores] = useState([])
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [activeTab, setActiveTab] = useState("servicios") // 'servicios' o 'proveedores'

  useEffect(() => {
    loadData()
  }, [id])

  const loadData = async () => {
    try {
      setLoading(true)

      // Cargar datos de la categoría
      if (id) {
        const categoriaData = await getCategoriaById(id.toString())
        setCategoria(categoriaData)

        // Cargar servicios de la categoría
        const serviciosData = await getServiciosByCategoria(id.toString())
        setServicios(serviciosData)

        // Cargar proveedores de la categoría
        const proveedoresData = await getProveedoresByCategoria(id.toString())
        setProveedores(proveedoresData)
      }
    } catch (error) {
      console.error("Error al cargar datos de categoría:", error)
    } finally {
      setLoading(false)
      setRefreshing(false)
    }
  }

  const onRefresh = () => {
    setRefreshing(true)
    loadData()
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
        <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
          <ArrowLeftIcon size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>{nombre || "Categoría"}</Text>
        <TouchableOpacity style={styles.filterButton}>
          <FilterIcon size={24} color="#333" />
        </TouchableOpacity>
      </View>

      {loading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#2E7D32" />
          <Text style={styles.loadingText}>Cargando...</Text>
        </View>
      ) : (
        <ScrollView
          style={styles.scrollView}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={["#2E7D32"]} />}
        >
          {/* Información de la categoría */}
          {categoria && (
            <View style={styles.categoryInfoContainer}>
              <View style={styles.categoryIconContainer}>
                <Image source={{ uri: categoria.icono }} style={styles.categoryIcon} />
              </View>
              <Text style={styles.categoryName}>{categoria.nombre}</Text>
              <Text style={styles.categoryNameKichwa}>{categoria.nombreKichwa}</Text>
              <Text style={styles.categoryDescription}>{categoria.descripcion}</Text>
            </View>
          )}

          {/* Pestañas */}
          <View style={styles.tabsContainer}>
            <TouchableOpacity
              style={[styles.tab, activeTab === "servicios" && styles.activeTab]}
              onPress={() => setActiveTab("servicios")}
            >
              <Text style={[styles.tabText, activeTab === "servicios" && styles.activeTabText]}>Servicios</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.tab, activeTab === "proveedores" && styles.activeTab]}
              onPress={() => setActiveTab("proveedores")}
            >
              <Text style={[styles.tabText, activeTab === "proveedores" && styles.activeTabText]}>Proveedores</Text>
            </TouchableOpacity>
          </View>

          {/* Contenido según la pestaña activa */}
          {activeTab === "servicios" ? (
            <View style={styles.servicesContainer}>
              {servicios.length > 0 ? (
                servicios.map((servicio) => (
                  <TouchableOpacity
                    key={servicio.id}
                    style={styles.serviceCard}
                    onPress={() => navigateToService(servicio.id)}
                  >
                    <Image
                      source={{
                        uri:
                          servicio.fotosEjemplo && servicio.fotosEjemplo.length > 0
                            ? servicio.fotosEjemplo[0]
                            : "/placeholder.svg?height=100&width=100",
                      }}
                      style={styles.serviceImage}
                    />
                    <View style={styles.serviceInfo}>
                      <Text style={styles.serviceName}>{servicio.nombre}</Text>
                      <Text style={styles.serviceDescription} numberOfLines={2}>
                        {servicio.descripcion}
                      </Text>
                      <Text style={styles.servicePrice}>
                        ${servicio.precioBase} / {servicio.unidadPrecio}
                      </Text>
                    </View>
                  </TouchableOpacity>
                ))
              ) : (
                <View style={styles.emptyContainer}>
                  <Text style={styles.emptyText}>No hay servicios disponibles en esta categoría</Text>
                </View>
              )}
            </View>
          ) : (
            <View style={styles.providersContainer}>
              {proveedores.length > 0 ? (
                proveedores.map((proveedor) => (
                  <TouchableOpacity
                    key={proveedor.id}
                    style={styles.providerCard}
                    onPress={() => navigateToProvider(proveedor.id)}
                  >
                    <Image
                      source={{ uri: proveedor.fotoPerfil || "/placeholder.svg?height=70&width=70" }}
                      style={styles.providerImage}
                    />
                    <View style={styles.providerInfo}>
                      <Text style={styles.providerName}>
                        {proveedor.nombre} {proveedor.apellido}
                      </Text>
                      <Text style={styles.providerDescription} numberOfLines={2}>
                        {proveedor.descripcion || "Proveedor de servicios"}
                      </Text>
                      <View style={styles.providerRatingContainer}>
                        <Text style={styles.providerRating}>{proveedor.calificacionPromedio.toFixed(1)}</Text>
                        <View style={styles.statusBadge}>
                          <Text style={styles.statusText}>
                            {proveedor.estado === "activo"
                              ? "Disponible"
                              : proveedor.estado === "pendiente"
                                ? "Pendiente"
                                : "No disponible"}
                          </Text>
                        </View>
                      </View>
                    </View>
                  </TouchableOpacity>
                ))
              ) : (
                <View style={styles.emptyContainer}>
                  <Text style={styles.emptyText}>No hay proveedores disponibles en esta categoría</Text>
                </View>
              )}
            </View>
          )}
        </ScrollView>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "#FFFFFF",
    paddingTop: 50,
    paddingBottom: 15,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: "#EEEEEE",
  },
  backButton: {
    padding: 5,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#333",
  },
  filterButton: {
    padding: 5,
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
  categoryInfoContainer: {
    alignItems: "center",
    padding: 20,
    backgroundColor: "#FFFFFF",
    marginBottom: 15,
  },
  categoryIconContainer: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: "#E8F5E9",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 15,
  },
  categoryIcon: {
    width: 50,
    height: 50,
  },
  categoryName: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  categoryNameKichwa: {
    fontSize: 16,
    color: "#666",
    marginBottom: 10,
  },
  categoryDescription: {
    fontSize: 14,
    color: "#555",
    textAlign: "center",
  },
  tabsContainer: {
    flexDirection: "row",
    backgroundColor: "#FFFFFF",
    marginBottom: 15,
  },
  tab: {
    flex: 1,
    paddingVertical: 15,
    alignItems: "center",
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: "#2E7D32",
  },
  tabText: {
    fontSize: 16,
    color: "#666",
  },
  activeTabText: {
    color: "#2E7D32",
    fontWeight: "bold",
  },
  servicesContainer: {
    paddingHorizontal: 15,
  },
  serviceCard: {
    flexDirection: "row",
    backgroundColor: "#FFFFFF",
    borderRadius: 10,
    marginBottom: 15,
    overflow: "hidden",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  serviceImage: {
    width: 100,
    height: 100,
  },
  serviceInfo: {
    flex: 1,
    padding: 15,
  },
  serviceName: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  serviceDescription: {
    fontSize: 14,
    color: "#666",
    marginBottom: 10,
  },
  servicePrice: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#2E7D32",
  },
  providersContainer: {
    paddingHorizontal: 15,
  },
  providerCard: {
    flexDirection: "row",
    backgroundColor: "#FFFFFF",
    borderRadius: 10,
    marginBottom: 15,
    padding: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  providerImage: {
    width: 70,
    height: 70,
    borderRadius: 35,
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
  providerDescription: {
    fontSize: 14,
    color: "#666",
    marginBottom: 10,
  },
  providerRatingContainer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  providerRating: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#F9A825",
  },
  statusBadge: {
    backgroundColor: "#E8F5E9",
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
  },
  statusText: {
    fontSize: 12,
    color: "#2E7D32",
    fontWeight: "500",
  },
  emptyContainer: {
    padding: 30,
    alignItems: "center",
    justifyContent: "center",
  },
  emptyText: {
    color: "#888",
    fontSize: 14,
    textAlign: "center",
  },
})
