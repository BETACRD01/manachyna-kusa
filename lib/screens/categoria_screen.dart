import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../models/servicio.dart';
import '../models/proveedor.dart';
import '../services/categoria_service.dart';
import '../services/servicio_service.dart';
import '../services/proveedor_service.dart';

class CategoriaScreen extends StatefulWidget {
  final Categoria categoria;

  const CategoriaScreen({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServicioService _servicioService = ServicioService();
  final ProveedorService _proveedorService = ProveedorService();
  
  List<Servicio> _servicios = [];
  List<Proveedor> _proveedores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // En una implementación real, cargaríamos los datos desde Firebase
      // final servicios = await _servicioService.getServiciosByCategoria(widget.categoria.id);
      // final proveedores = await _proveedorService.getProveedoresByCategoria(widget.categoria.id);
      
      // Por ahora, usamos datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _servicios = [];
        _proveedores = [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria.nombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implementar filtros
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2E7D32),
              child: Column(
                children: [
                  // Información de la categoría
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Image.asset(
                              widget.categoria.icono,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.categoria.nombre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.categoria.nombreKichwa,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.categoria.descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF2E7D32),
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: const Color(0xFF2E7D32),
                      tabs: const [
                        Tab(text: 'Servicios'),
                        Tab(text: 'Proveedores'),
                      ],
                    ),
                  ),
                  // Contenido de los tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab de servicios
                        _servicios.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay servicios disponibles en esta categoría',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(15),
                                itemCount: _servicios.length,
                                itemBuilder: (context, index) {
                                  final servicio = _servicios[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/servicio',
                                          arguments: servicio,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            child: Image.asset(
                                              servicio.imagen,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    servicio.nombre,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Descripción del servicio',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    '\$${servicio.precio.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF2E7D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        // Tab de proveedores
                        _proveedores.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay proveedores disponibles en esta categoría',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(15),
                                itemCount: _proveedores.length,
                                itemBuilder: (context, index) {
                                  final proveedor = _proveedores[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/proveedor',
                                          arguments: proveedor,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 35,
                                              backgroundImage: AssetImage(proveedor.foto),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    proveedor.nombre,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    proveedor.especialidad,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        proveedor.calificacion.toString(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.amber,
                                                        ),
                                                      ),
                                                      Text(
                                                        ' (${proveedor.numCalificaciones})',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                '${proveedor.distancia} km',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF2E7D32),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
