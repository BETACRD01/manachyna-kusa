"use client"

import { useState } from "react"
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from "react-native"
import { useRouter } from "expo-router"
import { PhoneIcon, UserIcon, LockIcon, EyeIcon, EyeOffIcon } from "lucide-react-native"

// Componente principal de autenticación
export default function AuthScreen() {
  const router = useRouter()
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)

  // Estados para formulario de login
  const [phoneNumber, setPhoneNumber] = useState("")
  const [password, setPassword] = useState("")

  // Estados adicionales para registro
  const [nombre, setNombre] = useState("")
  const [apellido, setApellido] = useState("")
  const [email, setEmail] = useState("")
  const [direccion, setDireccion] = useState("")
  const [userType, setUserType] = useState("usuario") // 'usuario' o 'proveedor'

  // Función para manejar el inicio de sesión
  const handleLogin = async () => {
    if (!phoneNumber || !password) {
      Alert.alert("Error", "Por favor ingresa tu número telefónico y contraseña")
      return
    }

    setLoading(true)
    try {
      // Aquí iría la lógica de autenticación con Firebase
      // Para esta implementación, simulamos un login exitoso

      // En una implementación real:
      // const result = await signInWithPhoneNumber(auth, phoneNumber, password)

      setLoading(false)
      router.replace("/home")
    } catch (error) {
      setLoading(false)
      Alert.alert("Error", "No se pudo iniciar sesión. Verifica tus credenciales.")
      console.error(error)
    }
  }

  // Función para manejar el registro
  const handleRegister = async () => {
    if (!nombre || !apellido || !phoneNumber || !password || !email) {
      Alert.alert("Error", "Por favor completa todos los campos obligatorios")
      return
    }

    setLoading(true)
    try {
      // En una implementación real:
      // const userCredential = await createUserWithEmailAndPassword(auth, email, password)
      // await setDoc(doc(db, userType === 'usuario' ? 'usuarios' : 'proveedores', userCredential.user.uid), {
      //   nombre,
      //   apellido,
      //   telefono: phoneNumber,
      //   direccion,
      //   fechaRegistro: new Date(),
      //   fotoPerfil: null,
      //   ...(userType === 'usuario' ? { historialServicios: [] } : {
      //     categorias: [],
      //     serviciosOfrecidos: [],
      //     zonasCobertura: [],
      //     disponibilidad: {},
      //     calificacionPromedio: 0,
      //     estado: 'pendiente'
      //   })
      // })

      setLoading(false)
      router.replace("/onboarding")
    } catch (error) {
      setLoading(false)
      Alert.alert("Error", "No se pudo completar el registro. Intenta nuevamente.")
      console.error(error)
    }
  }

  return (
    <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : "height"} style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.logoContainer}>
          <Image source={{ uri: "/placeholder.svg?height=120&width=120" }} style={styles.logo} resizeMode="contain" />
          <Text style={styles.appName}>Mañachyna Kusa</Text>
          <Text style={styles.appSlogan}>Servicios domésticos a tu alcance</Text>
        </View>

        <View style={styles.formContainer}>
          <Text style={styles.formTitle}>{isLogin ? "Iniciar Sesión" : "Crear Cuenta"}</Text>

          {!isLogin && (
            <>
              <View style={styles.inputContainer}>
                <UserIcon size={20} color="#555" style={styles.inputIcon} />
                <TextInput style={styles.input} placeholder="Nombre" value={nombre} onChangeText={setNombre} />
              </View>

              <View style={styles.inputContainer}>
                <UserIcon size={20} color="#555" style={styles.inputIcon} />
                <TextInput style={styles.input} placeholder="Apellido" value={apellido} onChangeText={setApellido} />
              </View>

              <View style={styles.inputContainer}>
                <UserIcon size={20} color="#555" style={styles.inputIcon} />
                <TextInput
                  style={styles.input}
                  placeholder="Correo electrónico"
                  keyboardType="email-address"
                  value={email}
                  onChangeText={setEmail}
                />
              </View>

              <View style={styles.inputContainer}>
                <UserIcon size={20} color="#555" style={styles.inputIcon} />
                <TextInput style={styles.input} placeholder="Dirección" value={direccion} onChangeText={setDireccion} />
              </View>

              <View style={styles.userTypeContainer}>
                <Text style={styles.userTypeLabel}>Tipo de cuenta:</Text>
                <View style={styles.userTypeOptions}>
                  <TouchableOpacity
                    style={[styles.userTypeButton, userType === "usuario" && styles.userTypeButtonActive]}
                    onPress={() => setUserType("usuario")}
                  >
                    <Text style={[styles.userTypeText, userType === "usuario" && styles.userTypeTextActive]}>
                      Usuario
                    </Text>
                  </TouchableOpacity>

                  <TouchableOpacity
                    style={[styles.userTypeButton, userType === "proveedor" && styles.userTypeButtonActive]}
                    onPress={() => setUserType("proveedor")}
                  >
                    <Text style={[styles.userTypeText, userType === "proveedor" && styles.userTypeTextActive]}>
                      Proveedor
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
            </>
          )}

          <View style={styles.inputContainer}>
            <PhoneIcon size={20} color="#555" style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Número telefónico"
              keyboardType="phone-pad"
              value={phoneNumber}
              onChangeText={setPhoneNumber}
            />
          </View>

          <View style={styles.inputContainer}>
            <LockIcon size={20} color="#555" style={styles.inputIcon} />
            <TextInput
              style={styles.input}
              placeholder="Contraseña"
              secureTextEntry={!showPassword}
              value={password}
              onChangeText={setPassword}
            />
            <TouchableOpacity style={styles.eyeIcon} onPress={() => setShowPassword(!showPassword)}>
              {showPassword ? <EyeOffIcon size={20} color="#555" /> : <EyeIcon size={20} color="#555" />}
            </TouchableOpacity>
          </View>

          {isLogin && (
            <TouchableOpacity style={styles.forgotPassword}>
              <Text style={styles.forgotPasswordText}>¿Olvidaste tu contraseña?</Text>
            </TouchableOpacity>
          )}

          <TouchableOpacity
            style={styles.primaryButton}
            onPress={isLogin ? handleLogin : handleRegister}
            disabled={loading}
          >
            <Text style={styles.primaryButtonText}>
              {loading ? "Cargando..." : isLogin ? "Iniciar Sesión" : "Registrarse"}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.switchModeButton} onPress={() => setIsLogin(!isLogin)}>
            <Text style={styles.switchModeText}>
              {isLogin ? "¿No tienes una cuenta? Regístrate" : "¿Ya tienes una cuenta? Inicia sesión"}
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  scrollContainer: {
    flexGrow: 1,
    paddingBottom: 30,
  },
  logoContainer: {
    alignItems: "center",
    marginTop: 60,
    marginBottom: 30,
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 10,
  },
  appName: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#2E7D32", // Verde amazónico
    marginBottom: 5,
  },
  appSlogan: {
    fontSize: 16,
    color: "#555",
  },
  formContainer: {
    backgroundColor: "#FFFFFF",
    borderRadius: 15,
    padding: 20,
    marginHorizontal: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  formTitle: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 20,
    textAlign: "center",
  },
  inputContainer: {
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDD",
    borderRadius: 8,
    marginBottom: 15,
    paddingHorizontal: 10,
    backgroundColor: "#F9F9F9",
  },
  inputIcon: {
    marginRight: 10,
  },
  input: {
    flex: 1,
    height: 50,
    fontSize: 16,
    color: "#333",
  },
  eyeIcon: {
    padding: 10,
  },
  forgotPassword: {
    alignSelf: "flex-end",
    marginBottom: 20,
  },
  forgotPasswordText: {
    color: "#2E7D32",
    fontSize: 14,
  },
  primaryButton: {
    backgroundColor: "#2E7D32", // Verde amazónico
    borderRadius: 8,
    height: 50,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 15,
  },
  primaryButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "bold",
  },
  switchModeButton: {
    alignItems: "center",
  },
  switchModeText: {
    color: "#2E7D32",
    fontSize: 14,
  },
  userTypeContainer: {
    marginBottom: 15,
  },
  userTypeLabel: {
    fontSize: 16,
    color: "#333",
    marginBottom: 8,
  },
  userTypeOptions: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  userTypeButton: {
    flex: 1,
    borderWidth: 1,
    borderColor: "#DDD",
    borderRadius: 8,
    padding: 12,
    alignItems: "center",
    marginHorizontal: 5,
  },
  userTypeButtonActive: {
    backgroundColor: "#2E7D32",
    borderColor: "#2E7D32",
  },
  userTypeText: {
    color: "#555",
    fontSize: 14,
  },
  userTypeTextActive: {
    color: "#FFFFFF",
    fontWeight: "bold",
  },
})
