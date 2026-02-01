"use client"

import { useState } from "react"
import { Phone, User, Lock, Eye, EyeOff, MapPin, Mail, Leaf } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"

export default function AuthScreen() {
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [userType, setUserType] = useState("cliente") // Declare the variable here

  // Estados para formulario de login
  const [phoneNumber, setPhoneNumber] = useState("")
  const [password, setPassword] = useState("")

  // Estados adicionales para registro
  const [nombre, setNombre] = useState("")
  const [apellido, setApellido] = useState("")
  const [email, setEmail] = useState("")
  const [direccion, setDireccion] = useState("")

  // Función para manejar el inicio de sesión
  const handleLogin = async () => {
    if (!phoneNumber || !password) {
      alert("Por favor ingresa tu número telefónico y contraseña")
      return
    }

    setLoading(true)
    try {
      // Simulamos un login exitoso
      await new Promise((resolve) => setTimeout(resolve, 1000))
      setLoading(false)
      // Aquí iría la navegación al home
    } catch (error) {
      setLoading(false)
      alert("No se pudo iniciar sesión. Verifica tus credenciales.")
      console.error(error)
    }
  }

  // Función para manejar el registro
  const handleRegister = async () => {
    if (!nombre || !apellido || !phoneNumber || !password || !email) {
      alert("Por favor completa todos los campos obligatorios")
      return
    }

    setLoading(true)
    try {
      // Simulamos un registro exitoso
      await new Promise((resolve) => setTimeout(resolve, 1000))
      setLoading(false)
      // Aquí iría la navegación al onboarding
    } catch (error) {
      setLoading(false)
      alert("No se pudo completar el registro. Intenta nuevamente.")
      console.error(error)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-emerald-50 to-emerald-100 flex flex-col items-center justify-center p-4">
      {/* Logo y nombre */}
      <div className="text-center mb-8">
        <div className="w-24 h-24 bg-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
          <Leaf className="w-12 h-12 text-white" />
        </div>
        <h1 className="text-3xl font-bold text-emerald-700">Mañachyna Kusa</h1>
        <p className="text-emerald-600 mt-1">Servicios domésticos a tu alcance</p>
      </div>

      {/* Formulario */}
      <Card className="w-full max-w-md shadow-xl border-0">
        <CardHeader className="pb-4">
          <CardTitle className="text-center text-2xl text-gray-800">
            {isLogin ? "Iniciar Sesión" : "Crear Cuenta"}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {!isLogin && (
            <>
              {/* Nombre */}
              <div className="space-y-2">
                <Label htmlFor="nombre">Nombre</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
                  <Input
                    id="nombre"
                    placeholder="Tu nombre"
                    value={nombre}
                    onChange={(e) => setNombre(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              {/* Apellido */}
              <div className="space-y-2">
                <Label htmlFor="apellido">Apellido</Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
                  <Input
                    id="apellido"
                    placeholder="Tu apellido"
                    value={apellido}
                    onChange={(e) => setApellido(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              {/* Email */}
              <div className="space-y-2">
                <Label htmlFor="email">Correo electrónico</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="tu@email.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              {/* Dirección */}
              <div className="space-y-2">
                <Label htmlFor="direccion">Dirección</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
                  <Input
                    id="direccion"
                    placeholder="Tu dirección en Tena"
                    value={direccion}
                    onChange={(e) => setDireccion(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              
            </>
          )}

          {/* Teléfono */}
          <div className="space-y-2">
            <Label htmlFor="phone">Número telefónico</Label>
            <div className="relative">
              <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                id="phone"
                type="tel"
                placeholder="0999999999"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          {/* Contraseña */}
          <div className="space-y-2">
            <Label htmlFor="password">Contraseña</Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
              <Input
                id="password"
                type={showPassword ? "text" : "password"}
                placeholder="Tu contraseña"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="pl-10 pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
            </div>
          </div>

          {/* Olvidé contraseña */}
          {isLogin && (
            <button type="button" className="text-sm text-emerald-600 hover:text-emerald-700 hover:underline">
              ¿Olvidaste tu contraseña?
            </button>
          )}

          {/* Botón principal */}
          <Button
            onClick={isLogin ? handleLogin : handleRegister}
            disabled={loading}
            className="w-full bg-emerald-600 hover:bg-emerald-700 text-white py-6 text-lg font-semibold"
          >
            {loading ? "Cargando..." : isLogin ? "Iniciar Sesión" : "Registrarse"}
          </Button>

          {/* Cambiar modo */}
          <button
            type="button"
            onClick={() => setIsLogin(!isLogin)}
            className="w-full text-center text-emerald-600 hover:text-emerald-700 hover:underline"
          >
            {isLogin ? "¿No tienes una cuenta? Regístrate" : "¿Ya tienes una cuenta? Inicia sesión"}
          </button>
        </CardContent>
      </Card>

      {/* Footer */}
      <p className="mt-6 text-sm text-emerald-600/70 text-center">
        Cantón Tena, Provincia de Napo
      </p>
    </div>
  )
}
