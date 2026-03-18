// ============================================================================
// PANTALLA 3: PAYMENT SUMMARY SCREEN (SIMPLIFICADA)
// features/booking/payment_summary_screen.dart
// ============================================================================
// Pantalla de resumen de pago simplificada donde:
// - Para transferencia bancaria solo se pide subir el comprobante de pago
// - Se eliminan formularios complejos de datos bancarios
// - Se muestra información bancaria fija para realizar la transferencia

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'payment_summary_screen/widgets/service_summary_widget.dart';
import 'payment_summary_screen/widgets/payment_methods_widget.dart';
import 'payment_summary_screen/widgets/price_breakdown_widget.dart';
import 'payment_summary_screen/utils/payment_calculator.dart';
import '../../../config/app_routes.dart' as nav;
import '../../../config/app_routes.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final PaymentSummaryArguments? arguments;

  const PaymentSummaryScreen({
    super.key,
    this.arguments,
  });

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen>
    with TickerProviderStateMixin {
  late Map<String, dynamic> serviceData;
  late List<Map<String, dynamic>> selectedOptions;
  late bool isHeavyWork;
  late double heavyWorkSurcharge;
  late Map<String, dynamic> selectedProvider;
  late Map<String, dynamic> bookingData;
  PaymentSummaryArguments? args;

  String selectedPaymentMethod = 'efectivo';
  bool isReceiptUploaded = false;
  String? receiptImagePath;
  File? receiptImageFile;
  String? receiptFileName;
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Map<String, dynamic> companyBankInfo = {
    'companyName': 'Servicios Hogar Ecuador S.A.',
    'ruc': '1234567890001',
    'banks': [
      {
        'bankName': 'Banco del Pichincha',
        'accountType': 'Cuenta Corriente',
        'accountNumber': '2100123456',
        'accountHolderName': 'SERVICIOS HOGAR ECUADOR S.A.',
      },
      {
        'bankName': 'Banco del Pacífico',
        'accountType': 'Cuenta Corriente',
        'accountNumber': '4567890123',
        'accountHolderName': 'SERVICIOS HOGAR ECUADOR S.A.',
      },
    ],
  };

  final List<Map<String, dynamic>> paymentMethods = const [
    {
      'id': 'efectivo',
      'name': 'Efectivo',
      'description': 'Pago al finalizar el servicio',
      'color': Colors.green,
      'isAvailable': true,
      'processingFee': 0.0,
    },
    {
      'id': 'tarjeta',
      'name': 'Tarjeta de Crédito/Débito',
      'description': 'Temporalmente no disponible',
      'color': Colors.grey,
      'isAvailable': false,
      'processingFee': 0.03,
    },
    {
      'id': 'transferencia',
      'name': 'Transferencia Bancaria',
      'description': 'Sube tu comprobante de pago',
      'color': Colors.purple,
      'isAvailable': true,
      'processingFee': 0.0,
    },
  ];

  PaymentCalculator get calculator => PaymentCalculator(
        serviceData: serviceData,
        selectedOptions: selectedOptions,
        isHeavyWork: isHeavyWork,
        heavyWorkSurcharge: heavyWorkSurcharge,
        selectedPaymentMethod: selectedPaymentMethod,
        paymentMethods: paymentMethods,
      );

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getDataFromArguments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _getDataFromArguments() {
    args = widget.arguments ??
        ModalRoute.of(context)?.settings.arguments as PaymentSummaryArguments?;

    if (args != null) {
      serviceData = args!.serviceData;
      selectedOptions = args!.selectedOptions;
      isHeavyWork = args!.isHeavyWork;
      heavyWorkSurcharge = args!.heavyWorkSurcharge;
      selectedProvider = args!.selectedProvider ?? {};
      bookingData = args!.bookingData ?? {};

      debugPrint('PaymentSummary inicializado con:');
      debugPrint('   - Servicio: ${serviceData['serviceName']}');
      debugPrint('   - Proveedor: ${selectedProvider['name']}');
    } else {
      serviceData = _getDefaultServiceData();
      selectedOptions = [];
      isHeavyWork = false;
      heavyWorkSurcharge = 0.0;
      selectedProvider = {};
      bookingData = {};
      debugPrint('PaymentSummary usando datos por defecto');
    }
  }

  Map<String, dynamic> _getDefaultServiceData() {
    return {
      'serviceId': 'default',
      'serviceName': 'Servicio de Limpieza',
      'serviceCategory': 'limpieza',
      'basePrice': 15.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Resumen del Pedido',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
              const SizedBox(width: 4),
              Text(
                'Paso 3/4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedProvider.isNotEmpty) _buildProviderSummary(),
                  const SizedBox(height: 24),
                  ServiceSummaryWidget(
                    serviceData: serviceData,
                    selectedOptions: selectedOptions,
                  ),
                  const SizedBox(height: 24),
                  PaymentMethodsWidget(
                    paymentMethods: paymentMethods,
                    selectedPaymentMethod: selectedPaymentMethod,
                    onPaymentMethodChanged: _onPaymentMethodChanged,
                    isCardDataSaved: false,
                    isTransferDataSaved: true,
                    onShowCardForm: _showCardNotAvailable,
                    onShowTransferForm: () {},
                  ),
                  const SizedBox(height: 24),
                  if (selectedPaymentMethod == 'transferencia') ...[
                    _buildBankInfoSection(),
                    const SizedBox(height: 16),
                    _buildReceiptUploadSection(),
                    const SizedBox(height: 24),
                  ],
                  PriceBreakdownWidget(calculator: calculator),
                  const SizedBox(height: 24),
                  _buildImportantNotes(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Proveedor seleccionado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: selectedProvider['profileImage'] != null
                    ? NetworkImage(selectedProvider['profileImage'])
                    : null,
                backgroundColor: Colors.grey[300],
                child: selectedProvider['profileImage'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedProvider['name'] ?? 'Proveedor',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${selectedProvider['rating']?.toStringAsFixed(1) ?? '0.0'}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedProvider['completedJobs'] ?? 0} trabajos',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Text(
                      selectedProvider['location'] ?? 'Tena',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance,
                    color: Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Datos para transferencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Empresa:', companyBankInfo['companyName']),
          _buildInfoRow('RUC:', companyBankInfo['ruc']),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Selecciona una cuenta para transferir:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...companyBankInfo['banks']
              .map((bank) => _buildBankAccountCard(bank)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'MONTO A TRANSFERIR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  calculator.formatPrice(calculator.finalTotal),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(Map<String, dynamic> bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bank['bankName'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildAccountDetail('Tipo:', bank['accountType']),
          _buildAccountDetail('Número:', bank['accountNumber']),
          _buildAccountDetail('Titular:', bank['accountHolderName']),
        ],
      ),
    );
  }

  Widget _buildAccountDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReceiptUploaded ? Colors.green[200]! : Colors.purple[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isReceiptUploaded
                      ? Colors.green[100]
                      : Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isReceiptUploaded ? Icons.check_circle : Icons.receipt_long,
                  color: isReceiptUploaded
                      ? Colors.green[600]
                      : Colors.purple[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isReceiptUploaded
                      ? 'Comprobante subido correctamente'
                      : 'Sube tu comprobante de pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isReceiptUploaded ? Colors.green[700] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isReceiptUploaded && receiptImageFile != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  receiptImageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  receiptFileName ?? 'Comprobante',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: _changeReceipt,
                  icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                  label: Text(
                    'Cambiar',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            isReceiptUploaded
                ? 'Tu comprobante ha sido recibido. Procederemos a verificar tu pago.'
                : 'Una vez realizada la transferencia, sube una foto clara del comprobante para verificar tu pago.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (!isReceiptUploaded) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleReceiptUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text(
                  'Seleccionar comprobante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Acepta: JPG, PNG, PDF. Máximo 5MB.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Atrás',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canContinue() ? _onReservePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canContinue() ? Colors.green[600] : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Ir a Pagar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      calculator.formatPrice(calculator.finalTotal),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Información importante',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• El precio final puede variar según la complejidad del trabajo\n'
            '• Se requiere confirmación del proveedor antes del servicio\n'
            '• Para transferencias: sube tu comprobante para verificar el pago\n'
            '• La verificación de transferencias puede tomar 1-2 horas\n'
            '• Cancelación gratuita hasta 2 horas antes del servicio',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _onPaymentMethodChanged(String methodId) {
    setState(() {
      selectedPaymentMethod = methodId;
      if (methodId != 'transferencia') {
        isReceiptUploaded = false;
        receiptImagePath = null;
        receiptImageFile = null;
        receiptFileName = null;
      }
    });
  }

  bool _canContinue() {
    if (selectedPaymentMethod == 'efectivo') return true;

    if (selectedPaymentMethod == 'tarjeta') return false; // Bloqueado

    if (selectedPaymentMethod == 'transferencia') {
      return isReceiptUploaded; // Solo necesita el comprobante subido
    }

    return false;
  }

  void _showCardNotAvailable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.construction, color: Colors.orange[600], size: 48),
        title: const Text('Próximamente'),
        content: const Text(
          'El pago con tarjeta estará disponible en futuras actualizaciones.\n\n'
          'Por ahora puedes usar:\n'
          '• Efectivo (sin comisión)\n'
          '• Transferencia bancaria (sin comisión)',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _handleReceiptUpload() async {
    try {
      final selectedOption = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildImagePickerBottomSheet(),
      );

      if (selectedOption != null && mounted) {
        await _processImageSelection(selectedOption);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error al seleccionar el comprobante. Intenta de nuevo.');
      }
    }
  }

  Future<void> _processImageSelection(String option) async {
    try {
      _showLoadingDialog('Cargando comprobante...');

      File? selectedFile;
      String? fileName;

      switch (option) {
        case 'camera':
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          if (image != null) {
            selectedFile = File(image.path);
            fileName = 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }
          break;

        case 'gallery':
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          if (image != null) {
            selectedFile = File(image.path);
            fileName = image.name;
          }
          break;

        case 'file':
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
            allowMultiple: false,
          );
          if (result != null && result.files.single.path != null) {
            selectedFile = File(result.files.single.path!);
            fileName = result.files.single.name;
          }
          break;
      }

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        if (selectedFile != null) {
          final fileSize = await selectedFile.length();
          if (fileSize > 5 * 1024 * 1024) {
            _showSnackBar('El archivo es muy grande. Máximo 5MB permitido.');
            return;
          }

          try {
            final String downloadUrl =
                await _uploadReceiptToStorage(selectedFile, fileName!);

            setState(() {
              receiptImageFile = selectedFile;
              receiptFileName = fileName;
              isReceiptUploaded = true;
              receiptImagePath = downloadUrl;
            });

            _showSnackBar('Comprobante cargado correctamente');
          } catch (e) {
            _showSnackBar('Error al subir el comprobante: ${e.toString()}');
          }
        } else {
          _showSnackBar('Selección cancelada');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading si está abierto
        _showSnackBar('Error al cargar el comprobante: ${e.toString()}');
      }
    }
  }

  void _changeReceipt() {
    setState(() {
      receiptImageFile = null;
      receiptFileName = null;
      isReceiptUploaded = false;
      receiptImagePath = null;
    });
  }

  void _onReservePressed() {
    debugPrint('\n=== BOTÓN IR A PAGAR PRESIONADO ===');

    final calculatorData = calculator.toBookingData();

    final Map<String, dynamic> finalData = {
      'selectedOptions': selectedOptions,
      'selectedProvider': selectedProvider,
      ...calculatorData,
      'serviceCategory': serviceData['serviceCategory'] ?? 'limpieza',
      'serviceTitle': serviceData['serviceName'] ?? 'Servicio solicitado',
      'receiptImageUrl':
          selectedPaymentMethod == 'transferencia' && receiptImagePath != null
              ? receiptImagePath
              : null,
      'paymentMethod': selectedPaymentMethod,
      'transferData': selectedPaymentMethod == 'transferencia'
          ? {
              'receiptImagePath': receiptImagePath,
              'bankInfo': companyBankInfo,
              'isReceiptUploaded': isReceiptUploaded,
            }
          : null,
      'timestamp': DateTime.now().toIso8601String(),
      'estimatedHours': 1,
    };

    debugPrint('Datos preparados para Final Payment:');
    debugPrint('  - Servicio: ${finalData['serviceTitle']}');
    debugPrint('  - Proveedor: ${selectedProvider['name']}');
    debugPrint('  - Final Total: \${calculator.finalTotal.toStringAsFixed(2)}');
    debugPrint('  - Método de pago: $selectedPaymentMethod');
    debugPrint('  - Comprobante subido: $isReceiptUploaded');

    if (FirebaseAuth.instance.currentUser == null) {
      _showSnackBar('Inicia sesión para continuar con tu reserva');
      Navigator.pushNamed(
        context,
        '/login',
        arguments: {
          'fromBooking': true,
          'returnTo': '/final-payment',
          'bookingData': finalData,
        },
      );
      return;
    }

    Navigator.pushNamed(
      context,
      nav.AppRoutes.finalPayment,
      arguments: FinalPaymentArguments(
        finalBookingData: finalData,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Seleccionar comprobante',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Colors.blue[600]),
              ),
              title: const Text('Tomar foto'),
              subtitle:
                  const Text('Usa la cámara para fotografiar el comprobante'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: Colors.green[600]),
              ),
              title: const Text('Seleccionar de galería'),
              subtitle: const Text('Elige una imagen de tu galería'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.picture_as_pdf, color: Colors.orange[600]),
              ),
              title: const Text('Seleccionar archivo'),
              subtitle: const Text('Sube un PDF del comprobante'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadReceiptToStorage(
      File imageFile, String fileName) async {
    try {
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      debugPrint('Simulando subida de comprobante al backend Django...');
      await Future.delayed(const Duration(seconds: 2));
      final String downloadUrl = 'https://backend.example.com/media/receipts/$uniqueFileName';

      debugPrint('Comprobante subido exitosamente: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir comprobante: $e');
      throw Exception('Error al subir el comprobante: $e');
    }
  }
}
