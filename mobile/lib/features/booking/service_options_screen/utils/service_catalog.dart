// lib/features/booking/utils/service_catalog.dart

class ServiceCatalog {
  static List<Map<String, dynamic>> getServicesForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electricidad':
        return const [
          {
            'id': 'punto_electrico_basico',
            'name': 'Instalación de punto eléctrico básico',
            'description': 'Instalación de nuevo tomacorriente o interruptor con cableado básico (hasta 3 metros). Incluye materiales estándar.',
            'price': 10.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'cambio_interruptor_toma',
            'name': 'Cambio de interruptor o toma dañada',
            'description': 'Reemplazo de interruptor o tomacorriente defectuoso. Incluye diagnóstico del problema eléctrico.',
            'price': 8.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'instalacion_lampara_plafon',
            'name': 'Instalación de lámpara o plafón',
            'description': 'Montaje y conexión eléctrica de lámpara colgante o plafón LED. Incluye revisión de la conexión existente.',
            'price': 12.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'instalacion_breaker',
            'name': 'Instalación de breaker o térmico',
            'description': 'Instalación de breaker en tablero eléctrico con conexión segura. Incluye etiquetado del circuito.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'revision_electrica_general',
            'name': 'Revisión eléctrica general',
            'description': 'Inspección completa del sistema eléctrico, medición de voltajes y diagnóstico de problemas potenciales.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      case 'carpintería':
        return const [
          {
            'id': 'reparacion_puertas_ventanas',
            'name': 'Reparación de puertas o ventanas de madera',
            'description': 'Ajuste de bisagras, marcos, lijado menor y reparación de elementos de madera. No incluye cambio completo.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'instalacion_repisas_simples',
            'name': 'Instalación de repisas simples',
            'description': 'Montaje de repisas de madera o MDF en pared. Incluye soportes y nivelación (hasta 1.5 metros).',
            'price': 10.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'armado_mueble_pequeno',
            'name': 'Armado de mueble pequeño (banco, mesa)',
            'description': 'Ensamblaje de muebles sencillos como bancos, mesas pequeñas o sillas. No incluye muebles complejos.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'cambio_cerradura',
            'name': 'Cambio de cerradura',
            'description': 'Instalación de cerradura nueva en puerta existente. Incluye ajuste y entrega de llaves.',
            'price': 8.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      case 'jardinería':
        return const [
          {
            'id': 'corte_cesped_100m2',
            'name': 'Corte de césped (hasta 100 m²)',
            'description': 'Corte uniforme de césped en áreas de hasta 100 m². Incluye recogida de césped cortado.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'poda_arbustos_arboles',
            'name': 'Poda de arbustos o árboles pequeños',
            'description': 'Poda técnica de arbustos y árboles de hasta 3 metros de altura. Incluye limpieza de restos vegetales.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'mantenimiento_jardin_completo',
            'name': 'Mantenimiento completo del jardín',
            'description': 'Limpieza general, deshierbe, riego y organización del espacio verde. Servicio integral de jardinería.',
            'price': 25.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'plantacion_decorativa',
            'name': 'Plantación decorativa',
            'description': 'Siembra de plantas ornamentales, flores de temporada y arreglo paisajístico básico.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      case 'limpieza':
        return const [
          {
            'id': 'limpieza_general_50m2',
            'name': 'Limpieza general de casa (hasta 50 m²)',
            'description': 'Barrido, trapeado, sacudido de muebles y limpieza básica de todas las áreas de la casa.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'limpieza_profunda_bano_cocina',
            'name': 'Limpieza profunda de baño y cocina',
            'description': 'Desinfección completa de baño y cocina, incluyendo azulejos, sanitarios, estufa y electrodomésticos.',
            'price': 25.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'lavado_ventanas',
            'name': 'Lavado de ventanas',
            'description': 'Limpieza de vidrios, marcos y repisas de ventanas interiores y exteriores accesibles.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'desinfeccion_espacios',
            'name': 'Desinfección de espacios interiores',
            'description': 'Desinfección sanitaria con productos especializados para eliminar virus, bacterias y hongos.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      case 'pintura':
        return const [
          {
            'id': 'pintura_interior_pared_3x3',
            'name': 'Pintura interior de una pared (3×3 m)',
            'description': 'Preparación y pintura de pared interior con pintura látex de calidad. Incluye materiales básicos.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'pintura_exterior_fachada',
            'name': 'Pintura exterior de fachada baja',
            'description': 'Pintura de fachada exterior accesible (hasta 3 metros de altura) con pintura resistente al clima.',
            'price': 30.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'sellado_grietas',
            'name': 'Sellado de grietas antes de pintar',
            'description': 'Sellado de fisuras y grietas con masilla profesional previo a aplicar pintura decorativa.',
            'price': 18.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'anticorrosivo_metal',
            'name': 'Aplicación de anticorrosivo en metal',
            'description': 'Preparación y aplicación de pintura anticorrosiva en elementos metálicos como rejas y portones.',
            'price': 20.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      case 'plomería':
        return const [
          {
            'id': 'reparacion_grifos_basica',
            'name': 'Reparación básica de grifos',
            'description': 'Cambio de empaques, reparación de goteras y ajuste de presión en grifos y llaves.',
            'price': 12.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'destape_desagues_sencillo',
            'name': 'Destape de desagües sencillo',
            'description': 'Destape de lavamanos, fregaderos y desagües con herramientas básicas.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'instalacion_accesorio_bano',
            'name': 'Instalación de accesorio de baño',
            'description': 'Instalación de toalleros, jaboneras, portapapel y otros accesorios básicos de baño.',
            'price': 10.0,
            'required': false,
            'category': 'servicio',
          },
          {
            'id': 'revision_sistema_agua',
            'name': 'Revisión de sistema de agua',
            'description': 'Inspección de tuberías, presión de agua y detección de posibles fugas menores.',
            'price': 18.0,
            'required': false,
            'category': 'servicio',
          },
        ];

      default:
        return const [
          {
            'id': 'servicio_basico_personalizado',
            'name': 'Servicio básico personalizado',
            'description': 'Servicio estándar adaptado a necesidades específicas del cliente.',
            'price': 15.0,
            'required': false,
            'category': 'servicio',
          },
        ];
    }
  }
}