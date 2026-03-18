/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: [
    'expo',
    'expo-modules-core',
    'react-native',
    'expo-constants',
    'expo-linking',
    'expo-router',
    'react-native-safe-area-context',
    'react-native-screens',
    'react-native-reanimated',
    'lucide-react-native',
    'react-native-svg',
  ],
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  webpack: (config) => {
    config.resolve.alias = {
      ...(config.resolve.alias || {}),
      'react-native$': 'react-native-web',
    }
    return config
  },
}

export default nextConfig