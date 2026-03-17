"use client"

import { useState } from "react"
import { View, Text, StyleSheet, Image, TouchableOpacity, SafeAreaView } from "react-native"
import { useRouter } from "expo-router"

// Datos para las pantallas de onboarding
const onboardingData = [
  {
    title: "Bienvenido a Mañachyna Kusa",
    description: "Conectamos a usuarios con proveedores de servicios domésticos en la provincia de Napo.",
    image: "/placeholder.svg?height=300&width=300",
  },
  {
    title: "Encuentra servicios confiables",
    description: "Plomería, electricidad, carpintería, limpieza y más, todo en un solo lugar.",
    image: "/placeholder.svg?height=300&width=300",
  },
  {
    title: "Agenda y califica",
    description: "Programa servicios según tu disponibilidad y califica la experiencia para ayudar a otros.",
    image: "/placeholder.svg?height=300&width=300",
  },
]

export default function OnboardingScreen() {
  const [currentIndex, setCurrentIndex] = useState(0)
  const router = useRouter()

  // Avanzar a la siguiente pantalla
  const handleNext = () => {
    if (currentIndex < onboardingData.length - 1) {
      setCurrentIndex(currentIndex + 1)
    } else {
      // Si es la última pantalla, ir a la pantalla principal
      router.replace("/home")
    }
  }

  // Saltar el onboarding
  const handleSkip = () => {
    router.replace("/home")
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.skipContainer}>
        {currentIndex < onboardingData.length - 1 && (
          <TouchableOpacity onPress={handleSkip}>
            <Text style={styles.skipText}>Omitir</Text>
          </TouchableOpacity>
        )}
      </View>

      <View style={styles.contentContainer}>
        <Image source={{ uri: onboardingData[currentIndex].image }} style={styles.image} resizeMode="contain" />

        <Text style={styles.title}>{onboardingData[currentIndex].title}</Text>
        <Text style={styles.description}>{onboardingData[currentIndex].description}</Text>
      </View>

      <View style={styles.indicatorContainer}>
        {onboardingData.map((_, index) => (
          <View key={index} style={[styles.indicator, index === currentIndex && styles.activeIndicator]} />
        ))}
      </View>

      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={handleNext}>
          <Text style={styles.buttonText}>{currentIndex === onboardingData.length - 1 ? "Comenzar" : "Siguiente"}</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#FFFFFF",
  },
  skipContainer: {
    alignItems: "flex-end",
    padding: 20,
  },
  skipText: {
    color: "#2E7D32",
    fontSize: 16,
  },
  contentContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 40,
  },
  image: {
    width: 250,
    height: 250,
    marginBottom: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 20,
    color: "#2E7D32",
  },
  description: {
    fontSize: 16,
    textAlign: "center",
    color: "#555",
    lineHeight: 24,
  },
  indicatorContainer: {
    flexDirection: "row",
    justifyContent: "center",
    marginBottom: 40,
  },
  indicator: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "#DDD",
    marginHorizontal: 5,
  },
  activeIndicator: {
    backgroundColor: "#2E7D32",
    width: 20,
  },
  buttonContainer: {
    paddingHorizontal: 20,
    paddingBottom: 40,
  },
  button: {
    backgroundColor: "#2E7D32",
    borderRadius: 10,
    height: 56,
    justifyContent: "center",
    alignItems: "center",
  },
  buttonText: {
    color: "#FFFFFF",
    fontSize: 18,
    fontWeight: "bold",
  },
})
