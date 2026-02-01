import 'package:flutter_application_manachyna_kusa_2_0/core/extensions/supabase_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/services/database_service.dart';

enum ProviderType { individual, group }

class ProviderRequestForm extends StatefulWidget {
  const ProviderRequestForm({super.key});

  @override
  State<ProviderRequestForm> createState() => _ProviderRequestFormState();
}

class _ProviderRequestFormState extends State<ProviderRequestForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  bool _isLoading = false;

  // Tipo de proveedor
  ProviderType _providerType = ProviderType.individual;

  // Controladores - Información personal
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _cedulaController = TextEditingController();

  // Datos adicionales persona individual
  bool _hasTransport = false;

  // Controladores - Grupo/Microempresa
  final _groupNameController = TextEditingController();
  final _teamSizeController = TextEditingController();
  final _groupPhoneController = TextEditingController();
  final _representativeController = TextEditingController();
  final _rucController = TextEditingController();
  final _groupAddressController = TextEditingController();

  // Servicios y precios
  final List<String> _selectedServices = [];
  final _hourlyRateController = TextEditingController();
  final _priceNotesController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Disponibilidad simplificada
  final List<String> _selectedDays = [];
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _worksOutsideTena = false;

  // Referencias
  final _referenceNameController = TextEditingController();
  final _referencePhoneController = TextEditingController();

  // Términos
  bool _acceptTerms = false;

  // Servicios disponibles (simplificado)
  final List<Map<String, dynamic>> _availableServices = [
    {
      'name': 'Limpieza del hogar',
      'icon': Icons.cleaning_services,
      'color': Colors.blue
    },
    {'name': 'Jardinería', 'icon': Icons.local_florist, 'color': Colors.green},
    {'name': 'Plomería básica', 'icon': Icons.plumbing, 'color': Colors.orange},
    {
      'name': 'Electricidad',
      'icon': Icons.electrical_services,
      'color': Colors.amber
    },
    {
      'name': 'Lavado de vehículos',
      'icon': Icons.local_car_wash,
      'color': Colors.cyan
    },
    {'name': 'Cuidado de mascotas', 'icon': Icons.pets, 'color': Colors.pink},
    {'name': 'Pintura', 'icon': Icons.format_paint, 'color': Colors.deepOrange},
    {'name': 'Carpintería', 'icon': Icons.handyman, 'color': Colors.brown},
  ];

  final List<String> _daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _cedulaController.dispose();
    _groupNameController.dispose();
    _teamSizeController.dispose();
    _groupPhoneController.dispose();
    _representativeController.dispose();
    _rucController.dispose();
    _groupAddressController.dispose();
    _hourlyRateController.dispose();
    _priceNotesController.dispose();
    _descriptionController.dispose();
    _referenceNameController.dispose();
    _referencePhoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                  _animationController.reset();
                  _animationController.forward();
                },
                children: [
                  _buildProviderTypeStep(),
                  _buildPersonalInfoStep(),
                  _buildServicesStep(),
                  _buildAvailabilityStep(),
                  _buildConfirmationStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Registro de Proveedor',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // PASO 1: TIPO DE PROVEEDOR
  Widget _buildProviderTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepHeader(
            '¿Cómo trabajas?',
            'Selecciona el tipo que mejor describe tu situación',
            Icons.work_outline,
          ),
          const SizedBox(height: 32),
          _buildProviderTypeCard(
            type: ProviderType.individual,
            title: 'Trabajo solo',
            description: 'Soy una persona independiente',
            icon: Icons.person_outline,
            features: [
              'Registro simple',
              'Horarios flexibles',
              'Validación rápida'
            ],
          ),
          const SizedBox(height: 16),
          _buildProviderTypeCard(
            type: ProviderType.group,
            title: 'Trabajo en grupo',
            description: 'Somos un equipo o pequeña empresa',
            icon: Icons.groups_outlined,
            features: [
              'Varios trabajadores',
              'Mayor capacidad',
              'Proyectos grandes'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTypeCard({
    required ProviderType type,
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = _providerType == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _providerType = type),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[800],
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: features
                      .map((feature) => Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PASO 2: INFORMACIÓN PERSONAL
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepHeader(
              _providerType == ProviderType.individual
                  ? 'Tus datos'
                  : 'Datos del grupo',
              'Información básica para tu registro',
              _providerType == ProviderType.individual
                  ? Icons.person_outline
                  : Icons.business_outlined,
            ),
            const SizedBox(height: 24),
            if (_providerType == ProviderType.individual)
              ..._buildIndividualFields()
            else
              ..._buildGroupFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIndividualFields() {
    return [
      _buildTextField(
        controller: _fullNameController,
        label: 'Nombre completo',
        icon: Icons.person_outline,
        validator: _requiredValidator,
      ),
      _buildTextField(
        controller: _phoneController,
        label: 'Teléfono',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: _phoneValidator,
      ),
      _buildTextField(
        controller: _cedulaController,
        label: 'Cédula',
        icon: Icons.credit_card_outlined,
        keyboardType: TextInputType.number,
        validator: _cedulaValidator,
      ),
      _buildTextField(
        controller: _ageController,
        label: 'Edad',
        icon: Icons.cake_outlined,
        keyboardType: TextInputType.number,
        validator: _ageValidator,
      ),
      _buildTextField(
        controller: _addressController,
        label: 'Dirección',
        icon: Icons.location_on_outlined,
        maxLines: 2,
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      _buildSwitchCard(
        title: '¿Tienes transporte propio?',
        subtitle: 'Moto, bicicleta, vehículo',
        value: _hasTransport,
        onChanged: (value) => setState(() => _hasTransport = value),
        icon: Icons.directions_car_outlined,
      ),
    ];
  }

  List<Widget> _buildGroupFields() {
    return [
      _buildTextField(
        controller: _groupNameController,
        label: 'Nombre del grupo',
        icon: Icons.business_outlined,
        validator: _requiredValidator,
      ),
      _buildTextField(
        controller: _teamSizeController,
        label: 'Número de trabajadores',
        icon: Icons.groups_outlined,
        keyboardType: TextInputType.number,
        validator: _teamSizeValidator,
      ),
      _buildTextField(
        controller: _representativeController,
        label: 'Representante principal',
        icon: Icons.person_pin_outlined,
        validator: _requiredValidator,
      ),
      _buildTextField(
        controller: _groupPhoneController,
        label: 'Teléfono del grupo',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: _phoneValidator,
      ),
      _buildTextField(
        controller: _groupAddressController,
        label: 'Dirección base',
        icon: Icons.location_on_outlined,
        maxLines: 2,
        validator: _requiredValidator,
      ),
      _buildTextField(
        controller: _rucController,
        label: 'RUC (opcional)',
        icon: Icons.assignment_ind_outlined,
        keyboardType: TextInputType.number,
      ),
    ];
  }

  // PASO 3: SERVICIOS
  Widget _buildServicesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepHeader(
            'Tus servicios',
            'Selecciona los servicios que ofreces',
            Icons.build_outlined,
          ),

          const SizedBox(height: 24),

          // Grid de servicios
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _availableServices.length,
            itemBuilder: (context, index) {
              final service = _availableServices[index];
              final isSelected = _selectedServices.contains(service['name']);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Card(
                  elevation: isSelected ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? service['color'] : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedServices.remove(service['name']);
                        } else {
                          _selectedServices.add(service['name']);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? service['color'].withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              service['icon'],
                              size: 28,
                              color: isSelected
                                  ? service['color']
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? service['color']
                                  : Colors.grey[700],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: service['color'],
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Tarifas
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Tarifas',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _hourlyRateController,
                    label: 'Precio por hora (USD)',
                    icon: Icons.schedule_outlined,
                    keyboardType: TextInputType.number,
                    validator: _priceValidator,
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Describe tu experiencia',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    validator: _descriptionValidator,
                  ),
                  _buildTextField(
                    controller: _priceNotesController,
                    label: 'Observaciones (opcional)',
                    icon: Icons.notes_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PASO 4: DISPONIBILIDAD
  Widget _buildAvailabilityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepHeader(
            'Tu disponibilidad',
            'Cuándo y dónde puedes trabajar',
            Icons.access_time_outlined,
          ),

          const SizedBox(height: 24),

          // Días de la semana
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Días disponibles',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _daysOfWeek.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Horarios
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Horario de trabajo',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.wb_sunny_outlined),
                          title: const Text('Desde'),
                          subtitle: Text(_formatTime(_startTime)),
                          onTap: () => _selectTime(true),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.nights_stay_outlined),
                          title: const Text('Hasta'),
                          subtitle: Text(_formatTime(_endTime)),
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Cobertura
          _buildSwitchCard(
            title: '¿Trabajas fuera de Tena?',
            subtitle: 'Sectores alejados, comunidades',
            value: _worksOutsideTena,
            onChanged: (value) => setState(() => _worksOutsideTena = value),
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  // PASO 5: CONFIRMACIÓN
  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepHeader(
            'Confirma tu solicitud',
            'Revisa la información antes de enviar',
            Icons.check_circle_outline,
          ),

          const SizedBox(height: 24),

          // Resumen
          if (_providerType == ProviderType.individual)
            _buildSummaryCard(
                'Información Personal',
                [
                  'Nombre: ${_fullNameController.text}',
                  'Teléfono: ${_phoneController.text}',
                  'Cédula: ${_cedulaController.text}',
                  'Edad: ${_ageController.text} años',
                  'Dirección: ${_addressController.text}',
                  'Transporte propio: ${_hasTransport ? "Sí" : "No"}',
                ],
                Icons.person_outline)
          else
            _buildSummaryCard(
                'Información del Grupo',
                [
                  'Nombre: ${_groupNameController.text}',
                  'Trabajadores: ${_teamSizeController.text}',
                  'Representante: ${_representativeController.text}',
                  'Teléfono: ${_groupPhoneController.text}',
                  'Dirección: ${_groupAddressController.text}',
                ],
                Icons.groups_outlined),

          _buildSummaryCard(
              'Servicios',
              [
                'Servicios: ${_selectedServices.join(", ")}',
                'Precio por hora: \$${_hourlyRateController.text}',
                'Experiencia: ${_descriptionController.text.substring(0, _descriptionController.text.length > 50 ? 50 : _descriptionController.text.length)}...',
              ],
              Icons.build_outlined),

          _buildSummaryCard(
              'Disponibilidad',
              [
                'Días: ${_selectedDays.join(", ")}',
                'Horario: ${_formatTime(_startTime)} - ${_formatTime(_endTime)}',
                'Fuera de Tena: ${_worksOutsideTena ? "Sí" : "No"}',
              ],
              Icons.schedule_outlined),

          const SizedBox(height: 16),

          // Referencia opcional
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_pin_outlined,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Referencia (opcional)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _referenceNameController,
                    label: 'Nombre de referencia',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _referencePhoneController,
                    label: 'Teléfono de referencia',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Términos
          Card(
            color: Colors.green[50],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CheckboxListTile(
                value: _acceptTerms,
                onChanged: (value) =>
                    setState(() => _acceptTerms = value ?? false),
                title: const Text(
                  'Acepto los términos y condiciones. La información proporcionada es verdadera.',
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS AUXILIARES
  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        activeThumbColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<String> items, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // NAVEGACIÓN
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _nextStep,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _currentStep == 4 ? Icons.send : Icons.arrow_forward),
                label:
                    Text(_currentStep == 4 ? 'Enviar Solicitud' : 'Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitRequest();
    }
  }

  // VALIDACIONES
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true;

      case 1:
        if (!_formKey.currentState!.validate()) {
          return false;
        }
        return true;

      case 2:
        if (_selectedServices.isEmpty) {
          _showError('Selecciona al menos un servicio');
          return false;
        }
        if (_hourlyRateController.text.isEmpty) {
          _showError('Ingresa tu tarifa por hora');
          return false;
        }
        if (_descriptionController.text.length < 30) {
          _showError('Describe tu experiencia con más detalle');
          return false;
        }
        return true;

      case 3:
        if (_selectedDays.length < 2) {
          _showError('Selecciona al menos 2 días disponibles');
          return false;
        }
        return true;

      case 4:
        if (!_acceptTerms) {
          _showError('Debes aceptar los términos y condiciones');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // VALIDADORES
  String? _requiredValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Este campo es requerido';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Teléfono es requerido';
    }
    if (value!.length < 10) {
      return 'Teléfono inválido';
    }
    return null;
  }

  String? _cedulaValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Cédula es requerida';
    }
    if (value!.length != 10) {
      return 'Cédula debe tener 10 dígitos';
    }
    return null;
  }

  String? _ageValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Edad es requerida';
    }
    final age = int.tryParse(value!);
    if (age == null || age < 18) {
      return 'Debes ser mayor de 18 años';
    }
    return null;
  }

  String? _teamSizeValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Número de trabajadores es requerido';
    }
    final size = int.tryParse(value!);
    if (size == null || size < 2) {
      return 'Mínimo 2 trabajadores para grupo';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Precio es requerido';
    }
    final price = double.tryParse(value!);
    if (price == null || price < 3) {
      return 'Precio mínimo \$3/hora';
    }
    return null;
  }

  String? _descriptionValidator(String? value) {
    if (value?.isEmpty == true) {
      return 'Descripción es requerida';
    }
    if (value!.length < 30) {
      return 'Mínimo 30 caracteres';
    }
    return null;
  }

  // HELPERS
  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ENVÍO DE SOLICITUD
  Future<void> _submitRequest() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear datos optimizados para el admin
      final requestData = {
        // Información básica
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'applicationDate': DateTime.now().toIso8601String(),
        'status': 'pending',
        'providerType': _providerType.name,

        // Datos del proveedor
        if (_providerType == ProviderType.individual) ...{
          'personalInfo': {
            'fullName': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'cedula': _cedulaController.text.trim(),
            'age': int.tryParse(_ageController.text) ?? 0,
            'address': _addressController.text.trim(),
            'hasTransport': _hasTransport,
          },
        } else ...{
          'groupInfo': {
            'groupName': _groupNameController.text.trim(),
            'teamSize': int.tryParse(_teamSizeController.text) ?? 0,
            'representative': _representativeController.text.trim(),
            'phone': _groupPhoneController.text.trim(),
            'address': _groupAddressController.text.trim(),
            'ruc': _rucController.text.trim(),
          },
        },

        // Servicios
        'services': {
          'offered': _selectedServices,
          'hourlyRate': double.tryParse(_hourlyRateController.text) ?? 0.0,
          'description': _descriptionController.text.trim(),
          'notes': _priceNotesController.text.trim(),
        },

        // Disponibilidad
        'availability': {
          'days': _selectedDays,
          'hours': {
            'start':
                '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
            'end':
                '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
          },
          'worksOutsideTena': _worksOutsideTena,
        },

        // Referencia (si existe)
        if (_referenceNameController.text.isNotEmpty)
          'reference': {
            'name': _referenceNameController.text.trim(),
            'phone': _referencePhoneController.text.trim(),
          },

        // Metadatos
        'location': 'Tena, Napo, Ecuador',
        'acceptedTerms': _acceptTerms,
        'createdAt': DateTime.now().toIso8601String(),

        // Para revisión del admin
        'reviewStatus': 'pending',
        'reviewedBy': null,
        'reviewDate': null,
        'reviewNotes': '',
      };

      // Enviar a Firestore
      final firestoreService = DatabaseService();
      await firestoreService.createProviderRequest(requestData);

      if (mounted) {
        _showSuccess('¡Solicitud enviada exitosamente!\n'
            'Te contactaremos pronto para la verificación.');

        // Esperar un momento para que el usuario lea el mensaje
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al enviar solicitud: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
