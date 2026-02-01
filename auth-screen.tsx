"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Phone, User, Lock, Eye, EyeOff, MapPin, Mail, Leaf } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { createClient } from "@/lib/supabase/client"

export default function AuthScreen() {
  const router = useRouter()
  const [isLogin, setIsLogin] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  // Estados para formulario de login
  const [phoneNumber, setPhoneNumber] = useState("")
  const [password, setPassword] = useState("")

  // Estados adicionales para registro
  const [nombre, setNombre] = useState("")
  const [apellido, setApellido] = useState("")
  const [email, setEmail] = useState("")
  const [direccion, setDireccion] = useState("")

  // Función para manejar el inicio de sesión con Supabase
  const handleLogin = async () => {
    if (!email || !password) {
      setError("Por favor ingresa tu correo electrónico y contraseña")
      return
    }

    setLoading(true)
    setError(null)
    
    try {
      const supabase = createClient()
      const { error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (authError) {
        setError(authError.message)
        setLoading(false)
        return
      }

      // Redirigir al home después del login exitoso
      router.push("/home")
      router.refresh()
    } catch (err) {
      setLoading(false)
      setError("No se pudo iniciar sesión. Verifica tus credenciales.")
      console.error(err)
    }
  }

  // Función para manejar el registro con Supabase
  const handleRegister = async () => {
    if (!nombre || !apellido || !password || !email) {
      setError("Por favor completa todos los campos obligatorios")
      return
    }

    setLoading(true)
    setError(null)
    
    try {
      const supabase = createClient()
      const { error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/home`,
          data: {
            nombre,
            apellido,
            telefono: phoneNumber,
            direccion,
            tipo_cuenta: "cliente",
          },
        },
      })

      if (authError) {
        setError(authError.message)
        setLoading(false)
        return
      }

      setSuccess("Cuenta creada exitosamente. Por favor revisa tu correo para confirmar tu cuenta.")
      setLoading(false)
    } catch (err) {
      setLoading(false)
      setError("No se pudo completar el registro. Intenta nuevamente.")
      console.error(err)
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
          {/* Mensajes de error y éxito */}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}
          {success && (
            <div className="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-lg text-sm">
              {success}
            </div>
          )}

          {/* Campos solo para registro */}
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
            </>
          )}

          {/* Email - aparece en login y registro */}
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

          {/* Campos adicionales solo para registro */}
          {!isLogin && (
            <>
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
